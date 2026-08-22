import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.email import EmailMessage, EmailSender
from app.models import EmailVerificationToken, User
from app.security.tokens import generate_raw_token, hash_token


class VerificationTokenInvalidError(Exception):
    pass


class VerificationTokenExpiredError(Exception):
    pass


class VerificationTokenAlreadyUsedError(Exception):
    pass


async def issue_verification_token(
    db: AsyncSession, user_id: uuid.UUID, email: str, email_sender: EmailSender
) -> str:
    settings = get_settings()
    raw_token = generate_raw_token()
    token = EmailVerificationToken(
        user_id=user_id,
        token_hash=hash_token(raw_token),
        expires_at=datetime.now(UTC)
        + timedelta(hours=settings.email_verification_token_ttl_hours),
    )
    db.add(token)
    await db.flush()

    ttl_hours = settings.email_verification_token_ttl_hours
    await email_sender.send(
        EmailMessage(
            to=email,
            subject="Verify your HealthTrack email address",
            body=(
                "Welcome to HealthTrack. Use the code below to verify your "
                f"email address:\n\n{raw_token}\n\n"
                f"This code expires in {ttl_hours} hours."
            ),
        )
    )
    return raw_token


async def verify_email(db: AsyncSession, raw_token: str) -> User:
    token_hash = hash_token(raw_token)
    result = await db.execute(
        select(EmailVerificationToken).where(
            EmailVerificationToken.token_hash == token_hash
        )
    )
    token = result.scalar_one_or_none()
    if token is None:
        raise VerificationTokenInvalidError("Verification token not recognized.")

    if token.used_at is not None:
        raise VerificationTokenAlreadyUsedError(
            "Verification token has already been used."
        )

    if token.expires_at < datetime.now(UTC):
        raise VerificationTokenExpiredError("Verification token has expired.")

    token.used_at = datetime.now(UTC)

    user = await db.get(User, token.user_id)
    assert user is not None  # FK guarantees the user row exists
    user.email_verified_at = datetime.now(UTC)

    await db.flush()
    return user
