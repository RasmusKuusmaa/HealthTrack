import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Device, DevicePlatform, User

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def test_create_device(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "device1@example.com")

    device = Device(
        user_id=user.id,
        name="Alex's iPhone",
        platform=DevicePlatform.IOS,
        push_token="apns-token-abc",
    )
    db_session.add(device)
    await db_session.flush()
    await db_session.refresh(device)

    assert device.platform == DevicePlatform.IOS
    assert device.push_token == "apns-token-abc"
    assert device.last_seen_at is not None
    assert device.created_at is not None


async def test_push_token_is_optional(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "device2@example.com")

    device = Device(user_id=user.id, name="Web session", platform=DevicePlatform.WEB)
    db_session.add(device)
    await db_session.flush()
    await db_session.refresh(device)

    assert device.push_token is None


async def test_user_can_have_multiple_devices(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "device3@example.com")

    phone = Device(user_id=user.id, name="Phone", platform=DevicePlatform.ANDROID)
    laptop = Device(user_id=user.id, name="Laptop", platform=DevicePlatform.WEB)
    db_session.add(phone)
    db_session.add(laptop)
    await db_session.flush()
