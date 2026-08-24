import uuid
from datetime import UTC, date, datetime

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User, WeightEntry, WeightEntrySource

pytestmark = pytest.mark.asyncio


async def test_create_weight_entry_with_defaults(db_session: AsyncSession) -> None:
    user = User(email="weight1@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    entry = WeightEntry(
        id=uuid.uuid4(),
        user_id=user.id,
        logged_at_utc=datetime(2026, 1, 1, 8, tzinfo=UTC),
        local_date=date(2026, 1, 1),
        tz_offset_minutes=120,
        weight_kg=82.5,
    )
    db_session.add(entry)
    await db_session.flush()
    await db_session.refresh(entry)

    assert entry.source == WeightEntrySource.MANUAL
    assert entry.note is None
    assert entry.deleted_at is None


async def test_weight_entry_accepts_an_explicit_note(
    db_session: AsyncSession,
) -> None:
    user = User(email="weight2@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    entry = WeightEntry(
        id=uuid.uuid4(),
        user_id=user.id,
        logged_at_utc=datetime(2026, 1, 1, 8, tzinfo=UTC),
        local_date=date(2026, 1, 1),
        tz_offset_minutes=0,
        weight_kg=70.0,
        note="after breakfast",
    )
    db_session.add(entry)
    await db_session.flush()
    await db_session.refresh(entry)

    assert entry.note == "after breakfast"


async def test_a_user_can_have_multiple_weight_entries(
    db_session: AsyncSession,
) -> None:
    user = User(email="weight3@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    db_session.add(
        WeightEntry(
            id=uuid.uuid4(),
            user_id=user.id,
            logged_at_utc=datetime(2026, 1, 1, 8, tzinfo=UTC),
            local_date=date(2026, 1, 1),
            tz_offset_minutes=0,
            weight_kg=80.0,
        )
    )
    db_session.add(
        WeightEntry(
            id=uuid.uuid4(),
            user_id=user.id,
            logged_at_utc=datetime(2026, 1, 2, 8, tzinfo=UTC),
            local_date=date(2026, 1, 2),
            tz_offset_minutes=0,
            weight_kg=79.8,
        )
    )
    # Two distinct rows for the same user must not collide.
    await db_session.flush()
