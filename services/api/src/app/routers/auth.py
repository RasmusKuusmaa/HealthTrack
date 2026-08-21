import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models import User, UserProfile
from app.schemas.auth import RegisterRequest, UserPublic, VerifyEmailRequest
from app.security.password_strength import (
    PasswordTooWeakError,
    get_http_client,
    validate_password_strength,
)
from app.security.passwords import hash_password
from app.services.email_verification import (
    VerificationTokenAlreadyUsedError,
    VerificationTokenExpiredError,
    VerificationTokenInvalidError,
    issue_verification_token,
    verify_email,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register", response_model=UserPublic, status_code=status.HTTP_201_CREATED
)
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
    http_client: httpx.AsyncClient = Depends(get_http_client),
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

    await issue_verification_token(db, user.id)

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


def _user_public(user: User, profile: UserProfile) -> UserPublic:
    return UserPublic(
        id=user.id, email=str(user.email), display_name=profile.display_name
    )
