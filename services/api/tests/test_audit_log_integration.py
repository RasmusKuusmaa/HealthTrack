import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import AuditLog, PasswordResetToken, User
from app.security.passwords import hash_password
from app.security.tokens import generate_raw_token, hash_token

pytestmark = pytest.mark.asyncio

PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password(PASSWORD))
    db_session.add(user)
    await db_session.flush()
    return user


async def _event_types(db_session: AsyncSession, user_id: uuid.UUID) -> list[str]:
    result = await db_session.execute(
        select(AuditLog.event_type).where(AuditLog.user_id == user_id)
    )
    return list(result.scalars().all())


async def test_register_is_audited(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    response = await client.post(
        "/auth/register",
        json={
            "email": "audit-register@example.com",
            "password": PASSWORD,
            "display_name": "Audit Test",
        },
    )
    assert response.status_code == 201
    user_id = uuid.UUID(response.json()["id"])

    events = await _event_types(db_session, user_id)
    assert "user.registered" in events


async def test_login_success_and_failure_are_audited(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "audit-login@example.com"
    user = await _make_user(db_session, email)

    await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": "wrong",
            "device_id": str(uuid.uuid4()),
        },
    )
    await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": str(uuid.uuid4())},
    )

    events = await _event_types(db_session, user.id)
    assert "login.failed" in events
    assert "login.succeeded" in events


async def test_logout_all_is_audited(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "audit-logout-all@example.com"
    user = await _make_user(db_session, email)

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": str(uuid.uuid4())},
    )
    token = login.json()["access_token"]

    await client.post(
        "/auth/logout-all", headers={"Authorization": f"Bearer {token}"}
    )

    events = await _event_types(db_session, user.id)
    assert "logout.all" in events


async def test_password_reset_flow_is_audited(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "audit-reset@example.com"
    user = await _make_user(db_session, email)

    await client.post("/auth/password-reset/request", json={"email": email})

    settings = get_settings()
    raw_token = generate_raw_token()
    db_session.add(
        PasswordResetToken(
            user_id=user.id,
            token_hash=hash_token(raw_token),
            expires_at=datetime.now(UTC)
            + timedelta(hours=settings.password_reset_token_ttl_hours),
        )
    )
    await db_session.flush()

    await client.post(
        "/auth/password-reset/confirm",
        json={"token": raw_token, "new_password": "zQ7#nR3wM!vL9pT6bY2eA$kX"},
    )

    # "requested" is deliberately not linked to a user_id — associating it
    # with a specific account would leak whether that email is registered.
    result = await db_session.execute(
        select(AuditLog.event_type).where(
            AuditLog.event_type == "password_reset.requested"
        )
    )
    assert "password_reset.requested" in result.scalars().all()

    events = await _event_types(db_session, user.id)
    assert "password_reset.confirmed" in events


async def test_refresh_token_reuse_is_audited(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "audit-reuse@example.com"
    user = await _make_user(db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": device_id},
    )
    refresh_token = login.json()["refresh_token"]

    await client.post(
        "/auth/refresh",
        json={"refresh_token": refresh_token, "device_id": device_id},
    )
    # Reusing the already-rotated token triggers reuse detection.
    await client.post(
        "/auth/refresh",
        json={"refresh_token": refresh_token, "device_id": device_id},
    )

    events = await _event_types(db_session, user.id)
    assert "refresh_token.reuse_detected" in events
