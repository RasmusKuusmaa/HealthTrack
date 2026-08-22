import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import PasswordResetToken, User
from app.security.passwords import hash_password
from app.security.tokens import generate_raw_token, hash_token

pytestmark = pytest.mark.asyncio

OLD_PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"
NEW_PASSWORD = "zQ7#nR3wM!vL9pT6bY2eA$kX"


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password(OLD_PASSWORD))
    db_session.add(user)
    await db_session.flush()
    return user


async def _capture_reset_token(db_session: AsyncSession, email: str) -> str:
    """Issue a reset token directly against the shared db_session (so it's
    visible to the `client` fixture's own session) and capture the raw
    value, which the HTTP endpoint never exposes in its response."""
    result = await db_session.execute(select(User).where(User.email == email))
    user = result.scalar_one()

    settings = get_settings()
    raw_token = generate_raw_token()
    token = PasswordResetToken(
        user_id=user.id,
        token_hash=hash_token(raw_token),
        expires_at=datetime.now(UTC)
        + timedelta(hours=settings.password_reset_token_ttl_hours),
    )
    db_session.add(token)
    await db_session.flush()
    return raw_token


async def test_request_creates_a_token_for_existing_email(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    await _make_user(db_session, "reset1@example.com")

    response = await client.post(
        "/auth/password-reset/request", json={"email": "reset1@example.com"}
    )

    assert response.status_code == 204
    result = await db_session.execute(select(PasswordResetToken))
    assert result.scalar_one_or_none() is not None


async def test_request_returns_204_for_unknown_email_without_creating_token(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    response = await client.post(
        "/auth/password-reset/request", json={"email": "nobody-resets@example.com"}
    )

    assert response.status_code == 204
    result = await db_session.execute(select(PasswordResetToken))
    assert result.scalar_one_or_none() is None


async def test_confirm_resets_password_and_revokes_sessions(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    # Unique per run: the old-password login attempt below counts against
    # the login throttle in real Redis, which has no per-test rollback like
    # the DB — a fixed email would eventually trip the lockout across runs.
    email = f"reset2-{uuid.uuid4().hex}@example.com"
    await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": OLD_PASSWORD, "device_id": device_id},
    )
    assert login.status_code == 200
    old_refresh_token = login.json()["refresh_token"]

    raw_token = await _capture_reset_token(db_session, email)

    confirm = await client.post(
        "/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": NEW_PASSWORD},
    )
    assert confirm.status_code == 204

    old_login = await client.post(
        "/auth/login",
        json={"email": email, "password": OLD_PASSWORD, "device_id": device_id},
    )
    assert old_login.status_code == 401

    new_login = await client.post(
        "/auth/login",
        json={"email": email, "password": NEW_PASSWORD, "device_id": device_id},
    )
    assert new_login.status_code == 200

    refresh_response = await client.post(
        "/auth/refresh",
        json={"refresh_token": old_refresh_token, "device_id": device_id},
    )
    assert refresh_response.status_code == 401


async def test_confirm_rejects_weak_new_password(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "reset3@example.com"
    await _make_user(db_session, email)
    raw_token = await _capture_reset_token(db_session, email)

    response = await client.post(
        "/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": "short"},
    )
    assert response.status_code == 400


async def test_confirm_rejects_unknown_token(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/password-reset/confirm",
        json={"token": "not-a-real-token", "new_password": NEW_PASSWORD},
    )
    assert response.status_code == 400


async def test_confirm_rejects_reused_token(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "reset4@example.com"
    await _make_user(db_session, email)
    raw_token = await _capture_reset_token(db_session, email)

    first = await client.post(
        "/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": NEW_PASSWORD},
    )
    assert first.status_code == 204

    second = await client.post(
        "/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": NEW_PASSWORD},
    )
    assert second.status_code == 400
