import uuid

import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from redis.asyncio import Redis
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db import get_db
from app.email import EmailSender, get_email_sender
from app.models import User, UserProfile
from app.redis_client import get_redis
from app.schemas.auth import (
    LoginRequest,
    LogoutRequest,
    MfaRequiredResponse,
    PasswordResetConfirm,
    PasswordResetRequest,
    RefreshRequest,
    RegisterRequest,
    TokenPair,
    TotpConfirmRequest,
    TotpEnrollResponse,
    UserPublic,
    VerifyEmailRequest,
)
from app.security.jwt import TokenError, create_access_token, decode_access_token
from app.security.password_strength import (
    PasswordTooWeakError,
    get_http_client,
    validate_password_strength,
)
from app.security.passwords import DUMMY_PASSWORD_HASH, hash_password, verify_password
from app.services.email_verification import (
    VerificationTokenAlreadyUsedError,
    VerificationTokenExpiredError,
    VerificationTokenInvalidError,
    issue_verification_token,
    verify_email,
)
from app.services.login_throttle import clear_failures, is_locked_out, record_failure
from app.services.mfa import (
    TotpConfirmationError,
    TotpLoginVerificationError,
    confirm_totp,
    enroll_totp,
    verify_totp_login,
)
from app.services.password_reset import (
    PasswordResetTokenAlreadyUsedError,
    PasswordResetTokenExpiredError,
    PasswordResetTokenInvalidError,
    confirm_password_reset,
    request_password_reset,
)
from app.services.refresh_tokens import (
    RefreshTokenExpiredError,
    RefreshTokenInvalidError,
    RefreshTokenReuseError,
    issue_refresh_token,
    revoke_all_user_tokens,
    revoke_refresh_token,
    rotate_refresh_token,
)

router = APIRouter(prefix="/auth", tags=["auth"])

INVALID_CREDENTIALS_DETAIL = "Invalid email or password."
LOCKED_OUT_DETAIL = "Too many failed login attempts. Try again later."

_bearer_scheme = HTTPBearer()


def _current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> uuid.UUID:
    """Minimal bearer-token identity check for this router. Superseded by
    the shared `current_user` dependency (2.21), which will also load the
    User row and apply scope checks."""
    try:
        claims = decode_access_token(credentials.credentials)
    except TokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token.",
        ) from exc
    return uuid.UUID(str(claims["sub"]))


async def _get_current_user(
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(_current_user_id),
) -> User:
    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User for this token no longer exists.",
        )
    return user


@router.post(
    "/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED
)
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
    http_client: httpx.AsyncClient = Depends(get_http_client),
    email_sender: EmailSender = Depends(get_email_sender),
) -> UserPublic:
    try:
        await validate_password_strength(
            payload.password,
            user_inputs=[payload.email, payload.display_name],
            http_client=http_client,
        )
    except PasswordTooWeakError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="; ".join(exc.reasons),
        ) from exc

    user = User(email=payload.email, password_hash=hash_password(payload.password))
    db.add(user)
    try:
        await db.flush()
    except IntegrityError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists.",
        ) from exc

    profile = UserProfile(user_id=user.id, display_name=payload.display_name)
    db.add(profile)
    await db.flush()

    await issue_verification_token(db, user.id, str(user.email), email_sender)

    return _user_public(user, profile)


@router.post("/verify-email", status_code=status.HTTP_200_OK)
async def verify_email_endpoint(
    payload: VerifyEmailRequest, db: AsyncSession = Depends(get_db)
) -> dict[str, bool]:
    try:
        await verify_email(db, payload.token)
    except (
        VerificationTokenInvalidError,
        VerificationTokenExpiredError,
        VerificationTokenAlreadyUsedError,
    ) as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc

    return {"verified": True}


@router.post("/login", response_model=TokenPair | MfaRequiredResponse)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
) -> TokenPair | MfaRequiredResponse:
    if await is_locked_out(redis, payload.email):
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=LOCKED_OUT_DETAIL,
        )

    result = await db.execute(select(User).where(User.email == payload.email))
    user = result.scalar_one_or_none()

    # Always verify against *some* hash, real or dummy, so a nonexistent
    # account takes the same time as a wrong password on a real one.
    password_hash = user.password_hash if user is not None else DUMMY_PASSWORD_HASH
    password_ok = verify_password(payload.password, password_hash)

    if user is None or not password_ok:
        await record_failure(redis, payload.email)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=INVALID_CREDENTIALS_DETAIL,
        )

    if user.mfa_totp_enabled:
        if payload.totp_code is None:
            # Password was correct, but the caller must resubmit with a
            # TOTP code — no failure recorded, since this isn't wrong
            # credentials, and no tokens issued until MFA passes.
            return MfaRequiredResponse()

        try:
            await verify_totp_login(db, user, payload.totp_code)
        except TotpLoginVerificationError as exc:
            await record_failure(redis, payload.email)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)
            ) from exc

    await clear_failures(redis, payload.email)

    settings = get_settings()
    access_token = create_access_token(subject=str(user.id))
    refresh_token, _ = await issue_refresh_token(db, user.id, payload.device_id)

    return TokenPair(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.jwt_access_token_ttl_minutes * 60,
    )


@router.post("/refresh", response_model=TokenPair)
async def refresh(
    payload: RefreshRequest, db: AsyncSession = Depends(get_db)
) -> TokenPair:
    try:
        new_refresh_token, new_token = await rotate_refresh_token(
            db, payload.refresh_token, payload.device_id
        )
    except (
        RefreshTokenInvalidError,
        RefreshTokenExpiredError,
        RefreshTokenReuseError,
    ) as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)
        ) from exc

    settings = get_settings()
    access_token = create_access_token(subject=str(new_token.user_id))

    return TokenPair(
        access_token=access_token,
        refresh_token=new_refresh_token,
        expires_in=settings.jwt_access_token_ttl_minutes * 60,
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(payload: LogoutRequest, db: AsyncSession = Depends(get_db)) -> None:
    # Idempotent by design: whether the token existed or not, the caller's
    # intent (this session should be logged out) is now satisfied either way.
    await revoke_refresh_token(db, payload.refresh_token)


@router.post("/logout-all", status_code=status.HTTP_204_NO_CONTENT)
async def logout_all(
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(_current_user_id),
) -> None:
    await revoke_all_user_tokens(db, user_id)


@router.post("/password-reset/request", status_code=status.HTTP_204_NO_CONTENT)
async def password_reset_request(
    payload: PasswordResetRequest,
    db: AsyncSession = Depends(get_db),
    email_sender: EmailSender = Depends(get_email_sender),
) -> None:
    # Always 204, whether or not the email matches an account — the body
    # and status must not reveal which, or this becomes an enumeration oracle.
    await request_password_reset(db, payload.email, email_sender)


@router.post("/password-reset/confirm", status_code=status.HTTP_204_NO_CONTENT)
async def password_reset_confirm(
    payload: PasswordResetConfirm,
    db: AsyncSession = Depends(get_db),
    http_client: httpx.AsyncClient = Depends(get_http_client),
) -> None:
    try:
        await validate_password_strength(
            payload.new_password, http_client=http_client
        )
    except PasswordTooWeakError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="; ".join(exc.reasons),
        ) from exc

    try:
        user_id = await confirm_password_reset(
            db, payload.token, hash_password(payload.new_password)
        )
    except (
        PasswordResetTokenInvalidError,
        PasswordResetTokenExpiredError,
        PasswordResetTokenAlreadyUsedError,
    ) as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc

    # A password reset means the credential may have been compromised —
    # every existing session (everywhere) must re-authenticate.
    await revoke_all_user_tokens(db, user_id)


@router.post("/mfa/totp/enroll", response_model=TotpEnrollResponse)
async def mfa_totp_enroll(
    db: AsyncSession = Depends(get_db),
    user: User = Depends(_get_current_user),
) -> TotpEnrollResponse:
    provisioning_uri, qr_code_png_base64 = await enroll_totp(db, user)
    return TotpEnrollResponse(
        provisioning_uri=provisioning_uri, qr_code_png_base64=qr_code_png_base64
    )


@router.post("/mfa/totp/confirm", status_code=status.HTTP_204_NO_CONTENT)
async def mfa_totp_confirm(
    payload: TotpConfirmRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(_get_current_user),
) -> None:
    try:
        await confirm_totp(db, user, payload.code)
    except TotpConfirmationError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc


def _user_public(user: User, profile: UserProfile) -> UserPublic:
    return UserPublic(
        id=user.id, email=str(user.email), display_name=profile.display_name
    )
