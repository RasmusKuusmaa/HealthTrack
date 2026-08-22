import uuid

import pyotp
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.passwords import hash_password
from app.security.totp import generate_totp_secret

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _make_mfa_user(db_session: AsyncSession, email: str) -> tuple[User, str]:
    secret = generate_totp_secret()
    user = User(
        email=email,
        password_hash=hash_password(PASSWORD),
        mfa_totp_secret=secret,
        mfa_totp_enabled=True,
    )
    db_session.add(user)
    await db_session.flush()
    return user, secret


async def test_login_without_code_returns_mfa_required(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_mfa_user(db_session, "mfa-login1@example.com")

    response = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login1@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body == {"mfa_required": True}


async def test_login_with_correct_code_succeeds(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    _, secret = await _make_mfa_user(db_session, "mfa-login2@example.com")
    code = pyotp.TOTP(secret).now()

    response = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login2@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": code,
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert "refresh_token" in body


async def test_login_with_wrong_code_fails(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_mfa_user(db_session, "mfa-login3@example.com")

    response = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login3@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": "000000",
        },
    )

    assert response.status_code == 401


async def test_wrong_password_fails_before_mfa_is_checked(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_mfa_user(db_session, "mfa-login4@example.com")

    response = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login4@example.com",
            "password": "totally-wrong",
            "device_id": str(uuid.uuid4()),
        },
    )

    assert response.status_code == 401
    assert response.json()["title"] == "Invalid email or password."


async def test_totp_code_cannot_be_replayed(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    _, secret = await _make_mfa_user(db_session, "mfa-login5@example.com")
    code = pyotp.TOTP(secret).now()

    first = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login5@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": code,
        },
    )
    assert first.status_code == 200

    second = await client.post(
        "/auth/login",
        json={
            "email": "mfa-login5@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": code,
        },
    )
    assert second.status_code == 401
