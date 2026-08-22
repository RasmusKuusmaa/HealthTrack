import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

import app.routers.auth as auth_router
from app.models import User
from app.security.jwt import decode_access_token
from app.security.passwords import hash_password
from app.services.refresh_tokens import rotate_refresh_token

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password(PASSWORD))
    db_session.add(user)
    await db_session.flush()
    return user


async def test_login_succeeds_with_correct_credentials(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "login1@example.com")
    device_id = str(uuid.uuid4())

    payload = {
        "email": "login1@example.com",
        "password": PASSWORD,
        "device_id": device_id,
    }
    response = await client.post("/auth/login", json=payload)

    assert response.status_code == 200
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["expires_in"] > 0

    claims = decode_access_token(body["access_token"])
    assert claims["sub"] == str(user.id)


async def test_login_rejects_wrong_password(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    # Unique per run: a wrong-password attempt counts against the login
    # throttle in real Redis, which has no per-test rollback like the DB —
    # a fixed email would eventually trip the lockout across repeated runs.
    email = f"login-wrongpw-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)

    response = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": "totally-wrong-password",
            "device_id": str(uuid.uuid4()),
        },
    )

    assert response.status_code == 401
    assert response.json()["title"] == "Invalid email or password."


async def test_login_rejects_unknown_email_with_same_message(
    client: AsyncClient,
) -> None:
    response = await client.post(
        "/auth/login",
        json={
            "email": f"nobody-{uuid.uuid4().hex}@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )

    assert response.status_code == 401
    assert response.json()["title"] == "Invalid email or password."


async def test_login_verifies_password_even_for_unknown_email(
    client: AsyncClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Timing-safety property: the password hasher must run on every login
    attempt, even when no account matches, not just when one does."""
    calls: list[str] = []
    original_verify = auth_router.verify_password

    def spy(password: str, password_hash: str) -> bool:
        calls.append(password_hash)
        return original_verify(password, password_hash)

    monkeypatch.setattr(auth_router, "verify_password", spy)

    await client.post(
        "/auth/login",
        json={
            "email": f"still-nobody-{uuid.uuid4().hex}@example.com",
            "password": PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )

    assert len(calls) == 1


async def test_login_issued_refresh_token_is_usable(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "login3@example.com")
    device_id = str(uuid.uuid4())

    payload = {
        "email": "login3@example.com",
        "password": PASSWORD,
        "device_id": device_id,
    }
    response = await client.post("/auth/login", json=payload)
    refresh_token = response.json()["refresh_token"]

    new_raw_token, new_token = await rotate_refresh_token(
        db_session, refresh_token, uuid.UUID(device_id)
    )
    assert new_raw_token != refresh_token
    assert new_token.revoked_at is None


async def test_login_locks_out_after_repeated_failures(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    # Unique per run: unlike the transactional DB, Redis lockout state has
    # no per-test rollback, so a fixed email would leak state across runs.
    email = f"lockout-target-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    wrong_payload = {
        "email": email,
        "password": "definitely-wrong",
        "device_id": str(uuid.uuid4()),
    }

    for _ in range(5):  # default threshold is 5
        response = await client.post("/auth/login", json=wrong_payload)
        assert response.status_code == 401

    locked_response = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": str(uuid.uuid4())},
    )
    assert locked_response.status_code == 429
    expected_detail = "Too many failed login attempts. Try again later."
    assert locked_response.json()["title"] == expected_detail


async def test_successful_login_clears_prior_failures(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"recovers-target-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    wrong_payload = {
        "email": email,
        "password": "definitely-wrong",
        "device_id": str(uuid.uuid4()),
    }

    for _ in range(3):  # below the lockout threshold
        response = await client.post("/auth/login", json=wrong_payload)
        assert response.status_code == 401

    good_payload = {
        "email": email,
        "password": PASSWORD,
        "device_id": str(uuid.uuid4()),
    }
    success = await client.post("/auth/login", json=good_payload)
    assert success.status_code == 200

    # Further failures should need the full threshold again, not continue
    # from where the previous (now-cleared) streak left off.
    for _ in range(4):
        response = await client.post("/auth/login", json=wrong_payload)
        assert response.status_code == 401

    still_allowed = await client.post("/auth/login", json=good_payload)
    assert still_allowed.status_code == 200
