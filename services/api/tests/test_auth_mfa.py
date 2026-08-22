import uuid

import pyotp
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


async def _access_token(client: AsyncClient, email: str) -> str:
    response = await client.post(
        "/auth/login",
        json={"email": email, "password": PASSWORD, "device_id": str(uuid.uuid4())},
    )
    assert response.status_code == 200
    return str(response.json()["access_token"])


async def test_enroll_returns_provisioning_uri_and_qr(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "mfa-enroll@example.com"
    await _make_user(db_session, email)
    token = await _access_token(client, email)

    response = await client.post(
        "/auth/mfa/totp/enroll", headers={"Authorization": f"Bearer {token}"}
    )

    assert response.status_code == 200
    body = response.json()
    assert body["provisioning_uri"].startswith("otpauth://totp/")
    assert len(body["qr_code_png_base64"]) > 0


async def test_enroll_requires_authentication(client: AsyncClient) -> None:
    response = await client.post("/auth/mfa/totp/enroll")
    assert response.status_code in (401, 403)


async def test_confirm_activates_mfa_with_correct_code(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "mfa-confirm@example.com"
    user = await _make_user(db_session, email)
    token = await _access_token(client, email)

    await client.post(
        "/auth/mfa/totp/enroll", headers={"Authorization": f"Bearer {token}"}
    )
    await db_session.refresh(user)
    assert user.mfa_totp_secret is not None
    assert user.mfa_totp_enabled is False

    code = pyotp.TOTP(user.mfa_totp_secret).now()
    confirm = await client.post(
        "/auth/mfa/totp/confirm",
        json={"code": code},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert confirm.status_code == 200
    body = confirm.json()
    assert len(body["recovery_codes"]) == 10
    assert len(set(body["recovery_codes"])) == 10  # all unique

    await db_session.refresh(user)
    assert user.mfa_totp_enabled is True


async def test_confirm_rejects_wrong_code(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "mfa-wrong@example.com"
    await _make_user(db_session, email)
    token = await _access_token(client, email)

    await client.post(
        "/auth/mfa/totp/enroll", headers={"Authorization": f"Bearer {token}"}
    )

    response = await client.post(
        "/auth/mfa/totp/confirm",
        json={"code": "000000"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 400


async def test_confirm_without_prior_enrollment_fails(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    email = "mfa-no-enroll@example.com"
    await _make_user(db_session, email)
    token = await _access_token(client, email)

    response = await client.post(
        "/auth/mfa/totp/confirm",
        json={"code": "123456"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 400
