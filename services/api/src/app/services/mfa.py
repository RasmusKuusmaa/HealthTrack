from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import User
from app.security.totp import (
    build_provisioning_uri,
    build_qr_code_png_base64,
    generate_totp_secret,
    totp_current_step,
    verify_totp_code,
)


class TotpConfirmationError(Exception):
    pass


class TotpLoginVerificationError(Exception):
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


async def confirm_totp(db: AsyncSession, user: User, code: str) -> None:
    """Verify the first code from an enrolled-but-unconfirmed secret and,
    if valid, activate MFA for this account."""
    if user.mfa_totp_secret is None:
        raise TotpConfirmationError("No TOTP enrollment in progress.")

    if not verify_totp_code(user.mfa_totp_secret, code):
        raise TotpConfirmationError("Invalid verification code.")

    user.mfa_totp_enabled = True
    # The confirmation code itself must not be replayable as a login code.
    user.mfa_totp_last_used_step = totp_current_step(user.mfa_totp_secret)
    await db.flush()


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
