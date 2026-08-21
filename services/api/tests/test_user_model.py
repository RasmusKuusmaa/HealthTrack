import pytest
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User

pytestmark = pytest.mark.asyncio


async def test_create_and_fetch_user(db_session: AsyncSession) -> None:
    user = User(email="Person@Example.com", password_hash="hashed")
    db_session.add(user)
    await db_session.flush()

    stmt = select(User).where(User.email == "person@example.com")
    result = await db_session.execute(stmt)
    fetched = result.scalar_one()
    assert fetched.id == user.id
    assert fetched.deleted_at is None
    assert fetched.created_at is not None


async def test_email_uniqueness_is_case_insensitive(db_session: AsyncSession) -> None:
    db_session.add(User(email="dup@example.com", password_hash="a"))
    await db_session.flush()

    db_session.add(User(email="DUP@example.com", password_hash="b"))
    with pytest.raises(IntegrityError):
        await db_session.flush()
