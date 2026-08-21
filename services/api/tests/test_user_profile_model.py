import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import SexAtBirth, UnitSystem, User, UserProfile

pytestmark = pytest.mark.asyncio


async def test_create_profile_with_defaults(db_session: AsyncSession) -> None:
    user = User(email="profile@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    profile = UserProfile(user_id=user.id, display_name="Alex")
    db_session.add(profile)
    await db_session.flush()
    await db_session.refresh(profile)

    assert profile.timezone == "UTC"
    assert profile.locale == "en"
    assert profile.unit_system == UnitSystem.METRIC
    assert profile.sex_at_birth is None


async def test_profile_accepts_explicit_sex_at_birth(db_session: AsyncSession) -> None:
    user = User(email="profile2@example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    profile = UserProfile(
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

    db_session.add(UserProfile(user_id=user.id, display_name="First"))
    await db_session.flush()

    db_session.add(UserProfile(user_id=user.id, display_name="Second"))
    with pytest.raises(IntegrityError):
        await db_session.flush()
