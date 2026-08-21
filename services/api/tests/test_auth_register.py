import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User, UserProfile
from app.security.passwords import verify_password

pytestmark = pytest.mark.asyncio

STRONG_PASSWORD = "xK9$mQ2vL#pR8nZ4wT!eY6bA"


async def test_register_creates_user_and_profile(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    response = await client.post(
        "/auth/register",
        json={
            "email": "newuser@example.com",
            "password": STRONG_PASSWORD,
            "display_name": "New User",
        },
    )

    assert response.status_code == 201
    body = response.json()
    assert body["email"] == "newuser@example.com"
    assert body["display_name"] == "New User"
    assert "password" not in body
    assert "password_hash" not in body

    result = await db_session.execute(
        select(User).where(User.email == "newuser@example.com")
    )
    user = result.scalar_one()
    assert verify_password(STRONG_PASSWORD, user.password_hash)

    profile_result = await db_session.execute(
        select(UserProfile).where(UserProfile.user_id == user.id)
    )
    profile = profile_result.scalar_one()
    assert profile.display_name == "New User"


async def test_register_rejects_weak_password(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/register",
        json={
            "email": "weak@example.com",
            "password": "short",
            "display_name": "Weak Pw",
        },
    )
    assert response.status_code == 400


async def test_register_rejects_duplicate_email(client: AsyncClient) -> None:
    payload = {
        "email": "dup@example.com",
        "password": STRONG_PASSWORD,
        "display_name": "First",
    }
    first = await client.post("/auth/register", json=payload)
    assert first.status_code == 201

    second = await client.post(
        "/auth/register",
        json={**payload, "email": "DUP@example.com", "display_name": "Second"},
    )
    assert second.status_code == 409


async def test_register_rejects_invalid_email(client: AsyncClient) -> None:
    response = await client.post(
        "/auth/register",
        json={
            "email": "not-an-email",
            "password": STRONG_PASSWORD,
            "display_name": "Bad Email",
        },
    )
    assert response.status_code == 422
