from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import EmailVerificationToken, User
from app.services.email_verification import (
    VerificationTokenAlreadyUsedError,
    VerificationTokenExpiredError,
    VerificationTokenInvalidError,
    issue_verification_token,
    verify_email,
)

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def test_issue_and_verify_marks_user_verified(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "verify1@example.com")
    raw_token = await issue_verification_token(db_session, user.id)

    verified_user = await verify_email(db_session, raw_token)

    assert verified_user.id == user.id
    assert verified_user.email_verified_at is not None


async def test_verify_rejects_unknown_token(db_session: AsyncSession) -> None:
    with pytest.raises(VerificationTokenInvalidError):
        await verify_email(db_session, "not-a-real-token")


async def test_verify_rejects_expired_token(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "expired-verify@example.com")
    raw_token = await issue_verification_token(db_session, user.id)

    result = await db_session.execute(
        select(EmailVerificationToken).where(EmailVerificationToken.user_id == user.id)
    )
    token = result.scalar_one()
    token.expires_at = datetime.now(UTC) - timedelta(seconds=1)
    await db_session.flush()

    with pytest.raises(VerificationTokenExpiredError):
        await verify_email(db_session, raw_token)


async def test_verify_rejects_reused_token(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "reuse-verify@example.com")
    raw_token = await issue_verification_token(db_session, user.id)

    await verify_email(db_session, raw_token)

    with pytest.raises(VerificationTokenAlreadyUsedError):
        await verify_email(db_session, raw_token)
