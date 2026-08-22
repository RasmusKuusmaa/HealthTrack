import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.jwt import decode_access_token
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


async def test_refresh_issues_new_token_pair(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "refresh1@example.com")
    device_id = str(uuid.uuid4())
    tokens = await _login(client, "refresh1@example.com", device_id)

    response = await client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
    )

    assert response.status_code == 200
    body = response.json()
    assert body["refresh_token"] != tokens["refresh_token"]
    claims = decode_access_token(body["access_token"])
    assert claims["sub"] == str(user.id)


async def test_reusing_a_rotated_refresh_token_is_rejected(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "refresh2@example.com")
    device_id = str(uuid.uuid4())
    tokens = await _login(client, "refresh2@example.com", device_id)

    first = await client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
    )
    assert first.status_code == 200

    second = await client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
    )
    assert second.status_code == 401


async def test_refresh_rejects_unknown_token(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/refresh",
        json={"refresh_token": "not-a-real-token", "device_id": str(uuid.uuid4())},
    )
    assert response.status_code == 401


async def test_logout_revokes_the_refresh_token(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "logout1@example.com")
    device_id = str(uuid.uuid4())
    tokens = await _login(client, "logout1@example.com", device_id)

    logout_response = await client.post(
        "/auth/logout", json={"refresh_token": tokens["refresh_token"]}
    )
    assert logout_response.status_code == 204

    refresh_response = await client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
    )
    assert refresh_response.status_code == 401


async def test_logout_is_idempotent(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "logout2@example.com")
    device_id = str(uuid.uuid4())
    tokens = await _login(client, "logout2@example.com", device_id)

    first = await client.post(
        "/auth/logout", json={"refresh_token": tokens["refresh_token"]}
    )
    assert first.status_code == 204

    second = await client.post(
        "/auth/logout", json={"refresh_token": tokens["refresh_token"]}
    )
    assert second.status_code == 204


async def test_logout_with_unknown_token_still_succeeds(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/logout", json={"refresh_token": "never-existed"}
    )
    assert response.status_code == 204
