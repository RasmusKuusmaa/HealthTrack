import uuid

import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import SexAtBirth, UnitSystem, User, UserProfile

pytestmark = pytest.mark.asyncio


async def test_create_profile_with_defaults(db_session: AsyncSession) -> None:
    user = User(email="profile@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    profile = UserProfile(id=user.id, user_id=user.id, display_name="Alex")
    db_session.add(profile)
    await db_session.flush()
    await db_session.refresh(profile)

    assert profile.timezone == "UTC"
    assert profile.locale == "en"
    assert profile.unit_system == UnitSystem.METRIC
    assert profile.sex_at_birth is None
    assert profile.deleted_at is None
    # id == user_id is required by the sync entity registry, which uses the
    # (client-known) user id as this entity's entity_id.
    assert profile.id == user.id


async def test_profile_accepts_explicit_sex_at_birth(db_session: AsyncSession) -> None:
    user = User(email="profile2@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    profile = UserProfile(
        id=user.id,
        user_id=user.id,
        display_name="Sam",
        sex_at_birth=SexAtBirth.INTERSEX,
        unit_system=UnitSystem.IMPERIAL,
    )
    db_session.add(profile)
    await db_session.flush()
    await db_session.refresh(profile)

    assert profile.sex_at_birth == SexAtBirth.INTERSEX
    assert profile.unit_system == UnitSystem.IMPERIAL


async def test_one_profile_per_user(db_session: AsyncSession) -> None:
    user = User(email="onlyone@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    db_session.add(UserProfile(id=user.id, user_id=user.id, display_name="First"))
    await db_session.flush()

    # A distinct id isolates this from the primary key constraint, so the
    # failure below is specifically the `user_id` uniqueness being enforced.
    db_session.add(
        UserProfile(id=uuid.uuid4(), user_id=user.id, display_name="Second")
    )
    with pytest.raises(IntegrityError):
        await db_session.flush()
