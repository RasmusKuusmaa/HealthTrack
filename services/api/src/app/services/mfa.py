from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import User
from app.security.totp import (
    build_provisioning_uri,
    build_qr_code_png_base64,
    generate_totp_secret,
    verify_totp_code,
)


class TotpConfirmationError(Exception):
    pass


async def enroll_totp(db: AsyncSession, user: User) -> tuple[str, str]:
    """Generate and store a new (unconfirmed) TOTP secret for `user`.
    Returns (provisioning_uri, qr_code_png_base64). MFA is not enforced
    until the secret is confirmed via `confirm_totp`."""
    settings = get_settings()
    secret = generate_totp_secret()
    user.mfa_totp_secret = secret
    user.mfa_totp_enabled = False
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
    await db.flush()
