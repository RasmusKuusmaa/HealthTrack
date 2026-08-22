import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.passwords import hash_password

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password(PASSWORD))
    db_session.add(user)
    await db_session.flush()
    return user


async def _login(client: AsyncClient, email: str, device_id: str) -> dict[str, str]:
    response = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": device_id},
    )
    assert response.status_code == 200
    return response.json()


async def test_logout_all_revokes_every_device(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "logout-all@example.com"
    await _make_user(db_session, email)
    device_a, device_b = str(uuid.uuid4()), str(uuid.uuid4())

    tokens_a = await _login(client, email, device_a)
    tokens_b = await _login(client, email, device_b)

    response = await client.post(
        "/auth/logout-all",
        headers={"Authorization": f"Bearer {tokens_a['access_token']}"},
    )
    assert response.status_code == 204

    for tokens, device_id in [(tokens_a, device_a), (tokens_b, device_b)]:
        refresh_response = await client.post(
            "/auth/refresh",
            json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
        )
        assert refresh_response.status_code == 401


async def test_logout_all_does_not_affect_other_users(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "victim@example.com")
    await _make_user(db_session, "bystander@example.com")
    device_id = str(uuid.uuid4())

    victim_tokens = await _login(client, "victim@example.com", device_id)
    bystander_tokens = await _login(client, "bystander@example.com", device_id)

    response = await client.post(
        "/auth/logout-all",
        headers={"Authorization": f"Bearer {victim_tokens['access_token']}"},
    )
    assert response.status_code == 204

    bystander_refresh = await client.post(
        "/auth/refresh",
        json={
            "refresh_token": bystander_tokens["refresh_token"],
            "device_id": device_id,
        },
    )
    assert bystander_refresh.status_code == 200


async def test_logout_all_requires_authorization(client: AsyncClient) -> None:
    response = await client.post("/auth/logout-all")
    assert response.status_code in (401, 403)


async def test_logout_all_rejects_garbage_token(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/logout-all", headers={"Authorization": "Bearer not-a-real-token"}
    )
    assert response.status_code == 401
