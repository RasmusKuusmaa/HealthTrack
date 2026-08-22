import uuid

import pyotp
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.passwords import hash_password
from app.security.totp import generate_totp_secret
from app.services.mfa import generate_recovery_codes

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


def _unique_email(label: str) -> str:
    # Unique per run: a failed /auth/login attempt counts against the login
    # throttle in real Redis, which has no per-test rollback like the DB —
    # a fixed email would eventually trip the lockout across repeated runs.
    return f"mfa-{label}-{uuid.uuid4().hex}@example.com"


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
    email = _unique_email("login1")
    await _make_mfa_user(db_session, email)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
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
    email = _unique_email("login2")
    _, secret = await _make_mfa_user(db_session, email)
    code = pyotp.TOTP(secret).now()

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
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
    email = _unique_email("login3")
    await _make_mfa_user(db_session, email)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": "000000",
        },
    )

    assert response.status_code == 401


async def test_wrong_password_fails_before_mfa_is_checked(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = _unique_email("login4")
    await _make_mfa_user(db_session, email)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": "totally-wrong",
            "device_id": str(uuid.uuid4()),
        },
    )

    assert response.status_code == 401
    assert response.json()["title"] == "Invalid email or password."


async def test_totp_code_cannot_be_replayed(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = _unique_email("login5")
    _, secret = await _make_mfa_user(db_session, email)
    code = pyotp.TOTP(secret).now()

    first = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": code,
        },
    )
    assert first.status_code == 200

    second = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": code,
        },
    )
    assert second.status_code == 401


async def test_login_with_recovery_code_succeeds(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = _unique_email("login6")
    user, _ = await _make_mfa_user(db_session, email)
    codes = await generate_recovery_codes(db_session, user)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "recovery_code": codes[0],
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body


async def test_recovery_code_cannot_be_reused(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = _unique_email("login7")
    user, _ = await _make_mfa_user(db_session, email)
    codes = await generate_recovery_codes(db_session, user)

    payload = {
        "email": email,
        "password": PASSWORD,
        "device_id": str(uuid.uuid4()),
        "recovery_code": codes[0],
    }
    first = await client.post("/auth/login", json=payload)
    assert first.status_code == 200

    second = await client.post("/auth/login", json=payload)
    assert second.status_code == 401


async def test_wrong_recovery_code_fails(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = _unique_email("login8")
    user, _ = await _make_mfa_user(db_session, email)
    await generate_recovery_codes(db_session, user)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
            "recovery_code": "not-a-real-code",
        },
    )
    assert response.status_code == 401
