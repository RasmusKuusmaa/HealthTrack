import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.email import EmailMessage, EmailSender
from app.models import PasswordResetToken, User
from app.security.tokens import generate_raw_token, hash_token


class PasswordResetTokenInvalidError(Exception):
    pass


class PasswordResetTokenExpiredError(Exception):
    pass


class PasswordResetTokenAlreadyUsedError(Exception):
    pass


async def request_password_reset(
    db: AsyncSession, email: str, email_sender: EmailSender
) -> None:
    """Look up the user and, if found, issue + email a reset token.

    Always succeeds regardless of whether the email matches an account —
    callers must not branch on the return value, or they'd leak account
    existence through response timing/shape.
    """
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    if user is None:
        return

    settings = get_settings()
    raw_token = generate_raw_token()
    token = PasswordResetToken(
        user_id=user.id,
        token_hash=hash_token(raw_token),
        expires_at=datetime.now(UTC)
        + timedelta(hours=settings.password_reset_token_ttl_hours),
    )
    db.add(token)
    await db.flush()

    ttl_hours = settings.password_reset_token_ttl_hours
    await email_sender.send(
        EmailMessage(
            to=email,
            subject="Reset your HealthTrack password",
            body=(
                "Use the code below to reset your password:\n\n"
                f"{raw_token}\n\n"
                f"This code expires in {ttl_hours} hour(s). "
                "If you didn't request this, you can ignore this email."
            ),
        )
    )


async def confirm_password_reset(
    db: AsyncSession, raw_token: str, new_password_hash: str
) -> uuid.UUID:
    """Consume a reset token and set the user's new password hash.
    Returns the user id so the caller can revoke their other sessions."""
    token_hash = hash_token(raw_token)
    result = await db.execute(
        select(PasswordResetToken).where(PasswordResetToken.token_hash == token_hash)
    )
    token = result.scalar_one_or_none()
    if token is None:
        raise PasswordResetTokenInvalidError("Reset token not recognized.")

    if token.used_at is not None:
        raise PasswordResetTokenAlreadyUsedError("Reset token has already been used.")

    if token.expires_at < datetime.now(UTC):
        raise PasswordResetTokenExpiredError("Reset token has expired.")

    token.used_at = datetime.now(UTC)

    user = await db.get(User, token.user_id)
    assert user is not None  # FK guarantees the user row exists
    user.password_hash = new_password_hash

    await db.flush()
    return user.id
