import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import RefreshToken, User

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def test_create_refresh_token(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "rt1@example.com")
    family_id = uuid.uuid4()
    device_id = uuid.uuid4()

    token = RefreshToken(
        user_id=user.id,
        token_hash="hash-of-token-1",
        device_id=device_id,
        family_id=family_id,
        expires_at=datetime.now(UTC) + timedelta(days=30),
    )
    db_session.add(token)
    await db_session.flush()
    await db_session.refresh(token)

    assert token.revoked_at is None
    assert token.family_id == family_id
    assert token.created_at is not None


async def test_token_hash_is_unique(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "rt2@example.com")
    shared_hash = "duplicate-hash"

    db_session.add(
        RefreshToken(
            user_id=user.id,
            token_hash=shared_hash,
            device_id=uuid.uuid4(),
            family_id=uuid.uuid4(),
            expires_at=datetime.now(UTC) + timedelta(days=30),
        )
    )
    await db_session.flush()

    db_session.add(
        RefreshToken(
            user_id=user.id,
            token_hash=shared_hash,
            device_id=uuid.uuid4(),
            family_id=uuid.uuid4(),
            expires_at=datetime.now(UTC) + timedelta(days=30),
        )
    )
    with pytest.raises(IntegrityError):
        await db_session.flush()


async def test_multiple_tokens_can_share_a_family(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "rt3@example.com")
    family_id = uuid.uuid4()
    device_id = uuid.uuid4()
    expires_at = datetime.now(UTC) + timedelta(days=30)

    db_session.add(
        RefreshToken(
            user_id=user.id,
            token_hash="hash-a",
            device_id=device_id,
            family_id=family_id,
            expires_at=expires_at,
        )
    )
    db_session.add(
        RefreshToken(
            user_id=user.id,
            token_hash="hash-b",
            device_id=device_id,
            family_id=family_id,
            expires_at=expires_at,
        )
    )
    await db_session.flush()
