import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Device, User
from app.security.passwords import hash_password

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password(PASSWORD))
    db_session.add(user)
    await db_session.flush()
    return user


async def test_login_registers_a_device(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"sessions1-{uuid.uuid4().hex}@example.com"
    user = await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": device_id,
            "device_name": "Alex's Phone",
            "platform": "android",
        },
    )
    assert response.status_code == 200

    device = await db_session.get(Device, uuid.UUID(device_id))
    assert device is not None
    assert device.user_id == user.id
    assert device.name == "Alex's Phone"
    assert device.platform.value == "android"


async def test_login_without_device_info_uses_defaults(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"sessions2-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    response = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": device_id},
    )
    assert response.status_code == 200

    device = await db_session.get(Device, uuid.UUID(device_id))
    assert device is not None
    assert device.name == "Unknown device"
    assert device.platform.value == "web"


async def test_sessions_lists_devices_with_active_refresh_tokens(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"sessions3-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": device_id,
            "device_name": "Work Laptop",
            "platform": "web",
        },
    )
    access_token = login.json()["access_token"]

    response = await client.get(
        "/auth/sessions", headers={"Authorization": f"Bearer {access_token}"}
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body) == 1
    assert body[0]["name"] == "Work Laptop"
    assert body[0]["platform"] == "web"
    assert body[0]["id"] == device_id


async def test_sessions_excludes_devices_after_logout(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"sessions4-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": device_id},
    )
    access_token = login.json()["access_token"]
    refresh_token = login.json()["refresh_token"]

    await client.post("/auth/logout", json={"refresh_token": refresh_token})

    response = await client.get(
        "/auth/sessions", headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 200
    assert response.json() == []


async def test_sessions_only_shows_the_authenticated_users_devices(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email_a = f"sessions5a-{uuid.uuid4().hex}@example.com"
    email_b = f"sessions5b-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email_a)
    await _make_user(db_session, email_b)

    login_a = await client.post(
        "/auth/login",
        json={
            "email": email_a,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )
    await client.post(
        "/auth/login",
        json={
            "email": email_b,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )

    response = await client.get(
        "/auth/sessions",
        headers={"Authorization": f"Bearer {login_a.json()['access_token']}"},
    )
    assert response.status_code == 200
    assert len(response.json()) == 1


async def test_relogging_in_from_same_device_updates_last_seen(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"sessions6-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    first = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": device_id,
            "device_name": "Old Name",
        },
    )
    assert first.status_code == 200

    second = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": device_id,
            "device_name": "New Name",
        },
    )
    assert second.status_code == 200

    stmt = select(Device).where(Device.id == uuid.UUID(device_id))
    result = await db_session.execute(stmt)
    devices = result.scalars().all()
    assert len(devices) == 1
    assert devices[0].name == "New Name"
