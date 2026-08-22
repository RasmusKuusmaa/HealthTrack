from datetime import UTC, datetime

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import MfaRecoveryCode, User
from app.security.recovery_codes import generate_recovery_code, normalize_recovery_code
from app.security.tokens import hash_token
from app.security.totp import (
    build_provisioning_uri,
    build_qr_code_png_base64,
    generate_totp_secret,
    totp_current_step,
    verify_totp_code,
)

RECOVERY_CODE_COUNT = 10


class TotpConfirmationError(Exception):
    pass


class TotpLoginVerificationError(Exception):
    pass


class RecoveryCodeInvalidError(Exception):
    pass


async def enroll_totp(db: AsyncSession, user: User) -> tuple[str, str]:
    """Generate and store a new (unconfirmed) TOTP secret for `user`.
    Returns (provisioning_uri, qr_code_png_base64). MFA is not enforced
    until the secret is confirmed via `confirm_totp`."""
    settings = get_settings()
    secret = generate_totp_secret()
    user.mfa_totp_secret = secret
    user.mfa_totp_enabled = False
    user.mfa_totp_last_used_step = None
    await db.flush()

    provisioning_uri = build_provisioning_uri(
        secret, str(user.email), settings.jwt_issuer
    )
    qr_code_png_base64 = build_qr_code_png_base64(provisioning_uri)
    return provisioning_uri, qr_code_png_base64


async def confirm_totp(db: AsyncSession, user: User, code: str) -> list[str]:
    """Verify the first code from an enrolled-but-unconfirmed secret and,
    if valid, activate MFA and issue a fresh set of recovery codes — shown
    to the user exactly once, here, since only their hashes are stored."""
    if user.mfa_totp_secret is None:
        raise TotpConfirmationError("No TOTP enrollment in progress.")

    if not verify_totp_code(user.mfa_totp_secret, code):
        raise TotpConfirmationError("Invalid verification code.")

    user.mfa_totp_enabled = True
    # The confirmation code itself must not be replayable as a login code.
    user.mfa_totp_last_used_step = totp_current_step(user.mfa_totp_secret)
    await db.flush()

    return await generate_recovery_codes(db, user)


async def verify_totp_login(db: AsyncSession, user: User, code: str) -> None:
    """Verify a TOTP code presented at login. Rejects a code whose time-step
    was already used, even if it's still within its normal 30s validity
    window, so a captured/observed code can't be replayed."""
    if not user.mfa_totp_enabled or user.mfa_totp_secret is None:
        raise TotpLoginVerificationError("MFA is not enabled for this account.")

    if not verify_totp_code(user.mfa_totp_secret, code):
        raise TotpLoginVerificationError("Invalid verification code.")

    current_step = totp_current_step(user.mfa_totp_secret)
    last_used_step = user.mfa_totp_last_used_step
    if last_used_step is not None and current_step <= last_used_step:
        raise TotpLoginVerificationError("This code has already been used.")

    user.mfa_totp_last_used_step = current_step
    await db.flush()


async def generate_recovery_codes(db: AsyncSession, user: User) -> list[str]:
    """Replace any existing recovery codes with a fresh batch. Only the
    hashes are ever persisted — this is the only point the raw codes exist."""
    await db.execute(delete(MfaRecoveryCode).where(MfaRecoveryCode.user_id == user.id))

    raw_codes = [generate_recovery_code() for _ in range(RECOVERY_CODE_COUNT)]
    for raw_code in raw_codes:
        db.add(
            MfaRecoveryCode(
                user_id=user.id,
                code_hash=hash_token(normalize_recovery_code(raw_code)),
            )
        )
    await db.flush()
    return raw_codes


async def consume_recovery_code(db: AsyncSession, user: User, raw_code: str) -> None:
    """Verify and burn a single-use recovery code as an MFA alternative."""
    code_hash = hash_token(normalize_recovery_code(raw_code))
    result = await db.execute(
        select(MfaRecoveryCode).where(
            MfaRecoveryCode.user_id == user.id,
            MfaRecoveryCode.code_hash == code_hash,
        )
    )
    recovery_code = result.scalar_one_or_none()
    if recovery_code is None or recovery_code.used_at is not None:
        raise RecoveryCodeInvalidError("Recovery code not recognized.")

    recovery_code.used_at = datetime.now(UTC)
    await db.flush()
