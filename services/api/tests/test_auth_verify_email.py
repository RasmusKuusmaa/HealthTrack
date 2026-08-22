import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.email.console import ConsoleEmailSender
from app.models import EmailVerificationToken, User
from app.services.email_verification import issue_verification_token

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def _issue(db_session: AsyncSession, user: User) -> str:
    return await issue_verification_token(
        db_session, user.id, str(user.email), ConsoleEmailSender()
    )


async def test_verify_email_endpoint_succeeds(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "endpoint-verify@example.com")
    raw_token = await _issue(db_session, user)

    response = await client.post("/auth/verify-email", json={"token": raw_token})

    assert response.status_code == 200
    assert response.json() == {"verified": True}
    await db_session.refresh(user)
    assert user.email_verified_at is not None


async def test_verify_email_endpoint_rejects_unknown_token(
    client: AsyncClient,
) -> None:
    response = await client.post(
        "/auth/verify-email", json={"token": "totally-bogus"}
    )
    assert response.status_code == 400


async def test_verify_email_endpoint_rejects_reuse(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "endpoint-reuse@example.com")
    raw_token = await _issue(db_session, user)

    first = await client.post("/auth/verify-email", json={"token": raw_token})
    assert first.status_code == 200

    second = await client.post("/auth/verify-email", json={"token": raw_token})
    assert second.status_code == 400


async def test_register_issues_a_verification_token(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    response = await client.post(
        "/auth/register",
        json={
            "email": "gets-verify-token@example.com",
            "password": "xK9$mQ2vL#pR8nZ4wT!eY6bA",
            "display_name": "Gets Token",
        },
    )
    assert response.status_code == 201
    user_id = response.json()["id"]

    result = await db_session.execute(
        select(EmailVerificationToken).where(
            EmailVerificationToken.user_id == user_id
        )
    )
    assert result.scalar_one_or_none() is not None
