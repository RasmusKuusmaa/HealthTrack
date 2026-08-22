"""End-to-end journeys through the full auth system, exercising several
endpoints together in sequence. Individual behaviors already have focused
unit/endpoint tests elsewhere — these confirm the pieces actually compose.
"""

import uuid

import pyotp
import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.email.console import ConsoleEmailSender
from app.models import EmailVerificationToken
from app.services.email_verification import issue_verification_token

pytestmark = pytest.mark.asyncio

STRONG_PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def _register_and_verify(
    client: AsyncClient, db_session: AsyncSession, email: str
) -> str:
    register = await client.post(
        "/auth/register",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "display_name": "E2E User",
        },
    )
    assert register.status_code == 201
    user_id = register.json()["id"]

    # Registration already issued one token, but only its hash is stored —
    # the raw value would normally arrive by email. Issue a fresh one
    # directly (bypassing the sender) to get a raw token this test can use.
    result = await db_session.execute(
        select(EmailVerificationToken).where(
            EmailVerificationToken.user_id == uuid.UUID(user_id)
        )
    )
    existing = result.scalar_one()
    assert existing.used_at is None  # sanity: register issued one already

    raw_token = await issue_verification_token(
        db_session, uuid.UUID(user_id), email, ConsoleEmailSender()
    )
    verify = await client.post("/auth/verify-email", json={"token": raw_token})
    assert verify.status_code == 200

    return user_id


async def test_register_verify_login_refresh_logout(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"e2e-basic-{uuid.uuid4().hex}@example.com"
    user_id = await _register_and_verify(client, db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": STRONG_PASSWORD, "device_id": device_id},
    )
    assert login.status_code == 200
    tokens = login.json()

    sessions = await client.get(
        "/auth/sessions",
        headers={"Authorization": f"Bearer {tokens['access_token']}"},
    )
    assert sessions.status_code == 200
    assert len(sessions.json()) == 1
    assert sessions.json()[0]["id"] == device_id

    refreshed = await client.post(
        "/auth/refresh",
        json={"refresh_token": tokens["refresh_token"], "device_id": device_id},
    )
    assert refreshed.status_code == 200
    new_tokens = refreshed.json()

    logout = await client.post(
        "/auth/logout", json={"refresh_token": new_tokens["refresh_token"]}
    )
    assert logout.status_code == 204

    sessions_after = await client.get(
        "/auth/sessions",
        headers={"Authorization": f"Bearer {new_tokens['access_token']}"},
    )
    assert sessions_after.json() == []
    assert user_id  # the id we tracked throughout is real and consistent


async def test_full_mfa_enrollment_and_login_flow(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"e2e-mfa-{uuid.uuid4().hex}@example.com"
    await _register_and_verify(client, db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": STRONG_PASSWORD, "device_id": device_id},
    )
    access_token = login.json()["access_token"]

    enroll = await client.post(
        "/auth/mfa/totp/enroll", headers={"Authorization": f"Bearer {access_token}"}
    )
    assert enroll.status_code == 200
    provisioning_uri = enroll.json()["provisioning_uri"]
    secret = provisioning_uri.split("secret=")[1].split("&")[0]

    confirm = await client.post(
        "/auth/mfa/totp/confirm",
        json={"code": pyotp.TOTP(secret).now()},
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert confirm.status_code == 200
    recovery_codes = confirm.json()["recovery_codes"]
    assert len(recovery_codes) == 10

    # A fresh login now requires MFA.
    challenge = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )
    assert challenge.status_code == 200
    assert challenge.json() == {"mfa_required": True}

    with_code = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "device_id": str(uuid.uuid4()),
            "totp_code": pyotp.TOTP(secret).now(),
        },
    )
    assert with_code.status_code == 401  # same 30s step already consumed above

    # A recovery code still works as an MFA alternative.
    with_recovery = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "device_id": str(uuid.uuid4()),
            "recovery_code": recovery_codes[0],
        },
    )
    assert with_recovery.status_code == 200

    # That recovery code is now burned.
    reused = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "device_id": str(uuid.uuid4()),
            "recovery_code": recovery_codes[0],
        },
    )
    assert reused.status_code == 401


async def test_refresh_token_reuse_revokes_the_whole_chain_e2e(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"e2e-reuse-{uuid.uuid4().hex}@example.com"
    await _register_and_verify(client, db_session, email)
    device_id = str(uuid.uuid4())

    login = await client.post(
        "/auth/login",
        json={"email": email, "password": STRONG_PASSWORD, "device_id": device_id},
    )
    original_refresh_token = login.json()["refresh_token"]

    rotated = await client.post(
        "/auth/refresh",
        json={"refresh_token": original_refresh_token, "device_id": device_id},
    )
    assert rotated.status_code == 200
    rotated_refresh_token = rotated.json()["refresh_token"]

    # Reusing the already-consumed token is treated as theft: the whole
    # chain — including the token that replaced it — gets revoked.
    reuse_attempt = await client.post(
        "/auth/refresh",
        json={"refresh_token": original_refresh_token, "device_id": device_id},
    )
    assert reuse_attempt.status_code == 401

    now_also_dead = await client.post(
        "/auth/refresh",
        json={"refresh_token": rotated_refresh_token, "device_id": device_id},
    )
    assert now_also_dead.status_code == 401


async def test_account_lockout_after_repeated_failures_e2e(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = f"e2e-lockout-{uuid.uuid4().hex}@example.com"
    await _register_and_verify(client, db_session, email)

    wrong_payload = {
        "email": email,
        "password": "not-the-password",
        "device_id": str(uuid.uuid4()),
    }
    for _ in range(5):  # default threshold
        response = await client.post("/auth/login", json=wrong_payload)
        assert response.status_code == 401

    locked_out = await client.post(
        "/auth/login",
        json={
            "email": email,
            "password": STRONG_PASSWORD,
            "device_id": str(uuid.uuid4()),
        },
    )
    assert locked_out.status_code == 429
