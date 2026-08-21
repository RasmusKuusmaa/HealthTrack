import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import RefreshToken, User
from app.services.refresh_tokens import (
    RefreshTokenExpiredError,
    RefreshTokenInvalidError,
    RefreshTokenReuseError,
    issue_refresh_token,
    rotate_refresh_token,
)

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def test_issue_creates_a_row_and_returns_a_usable_raw_token(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "issue@example.com")
    device_id = uuid.uuid4()

    raw_token, token = await issue_refresh_token(db_session, user.id, device_id)

    assert isinstance(raw_token, str) and len(raw_token) > 20
    assert token.user_id == user.id
    assert token.device_id == device_id
    assert token.revoked_at is None


async def test_rotate_consumes_old_token_and_issues_new_one_in_same_family(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "rotate@example.com")
    device_id = uuid.uuid4()
    raw_token, original = await issue_refresh_token(db_session, user.id, device_id)

    new_raw_token, new_token = await rotate_refresh_token(
        db_session, raw_token, device_id
    )

    await db_session.refresh(original)
    assert original.revoked_at is not None
    assert new_token.family_id == original.family_id
    assert new_raw_token != raw_token


async def test_rotate_rejects_unknown_token(db_session: AsyncSession) -> None:
    with pytest.raises(RefreshTokenInvalidError):
        await rotate_refresh_token(db_session, "not-a-real-token", uuid.uuid4())


async def test_rotate_rejects_expired_token(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "expired@example.com")
    device_id = uuid.uuid4()
    raw_token, token = await issue_refresh_token(db_session, user.id, device_id)

    token.expires_at = datetime.now(UTC) - timedelta(seconds=1)
    await db_session.flush()

    with pytest.raises(RefreshTokenExpiredError):
        await rotate_refresh_token(db_session, raw_token, device_id)


async def test_reusing_a_rotated_token_revokes_the_whole_family(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "reuse@example.com")
    device_id = uuid.uuid4()
    raw_token_a, token_a = await issue_refresh_token(db_session, user.id, device_id)

    _, token_b = await rotate_refresh_token(db_session, raw_token_a, device_id)
    assert token_b.revoked_at is None  # sanity check before the reuse attempt

    with pytest.raises(RefreshTokenReuseError):
        await rotate_refresh_token(db_session, raw_token_a, device_id)

    result = await db_session.execute(
        select(RefreshToken).where(RefreshToken.family_id == token_a.family_id)
    )
    family_tokens = result.scalars().all()
    assert len(family_tokens) == 2
    assert all(t.revoked_at is not None for t in family_tokens)
