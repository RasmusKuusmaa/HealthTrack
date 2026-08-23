import uuid
from datetime import UTC, datetime

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import UserProfile
from app.security.jwt import create_access_token
from app.sync.entities import UserProfileSchema
from app.sync.registry import get_entity_schema, is_registered


async def _register(client: AsyncClient, email: str) -> uuid.UUID:
    response = await client.post(
        "/auth/register",
        json={"email": email, "password": "correct-horse-1", "display_name": "Alex"},
    )
    assert response.status_code == 201
    return uuid.UUID(response.json()["id"])


def _auth_headers(user_id: uuid.UUID) -> dict[str, str]:
    token = create_access_token(subject=str(user_id))
    return {"Authorization": f"Bearer {token}"}


def _update_op(user_id: uuid.UUID, payload: dict[str, object]) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": "user_profile",
        "entity_id": str(user_id),
        "op_type": "update",
        "payload": payload,
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


def test_user_profile_is_registered() -> None:
    assert is_registered("user_profile")
    assert get_entity_schema("user_profile") is UserProfileSchema


@pytest.mark.asyncio
async def test_registration_creates_a_profile_keyed_by_user_id(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user_id = await _register(client, "onboard1@example.com")

    profile = await db_session.get(UserProfile, user_id)
    assert profile is not None
    assert profile.user_id == user_id
    assert profile.deleted_at is None


@pytest.mark.asyncio
async def test_bootstrap_includes_the_profile_created_at_registration(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user_id = await _register(client, "onboard2@example.com")

    response = await client.post("/sync/bootstrap", headers=_auth_headers(user_id))

    assert response.status_code == 200
    profiles = response.json()["entities"]["user_profile"]
    assert len(profiles) == 1
    assert profiles[0]["id"] == str(user_id)
    assert profiles[0]["display_name"] == "Alex"
    assert profiles[0]["unit_system"] == "metric"


@pytest.mark.asyncio
async def test_an_update_op_materializes_onto_the_existing_profile_row(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user_id = await _register(client, "onboard3@example.com")
    headers = _auth_headers(user_id)

    push = await client.post(
        "/sync/push",
        json={
            "ops": [
                _update_op(
                    user_id,
                    {
                        "height_cm": 175.5,
                        "unit_system": "imperial",
                        "timezone": "Europe/Tallinn",
                    },
                )
            ]
        },
        headers=headers,
    )
    assert push.status_code == 200

    result = await db_session.execute(
        select(UserProfile).where(UserProfile.user_id == user_id)
    )
    profile = result.scalar_one()
    assert profile.height_cm is not None
    assert float(profile.height_cm) == 175.5
    assert profile.unit_system.value == "imperial"
    assert profile.timezone == "Europe/Tallinn"

    # No second row was created — the update found the row the register
    # endpoint made, keyed by the same id.
    count = await db_session.execute(
        select(UserProfile).where(UserProfile.user_id == user_id)
    )
    assert len(count.scalars().all()) == 1


@pytest.mark.asyncio
async def test_updated_profile_round_trips_through_bootstrap(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user_id = await _register(client, "onboard4@example.com")
    headers = _auth_headers(user_id)

    await client.post(
        "/sync/push",
        json={"ops": [_update_op(user_id, {"height_cm": 182.3})]},
        headers=headers,
    )

    response = await client.post("/sync/bootstrap", headers=headers)

    profiles = response.json()["entities"]["user_profile"]
    assert profiles[0]["height_cm"] == 182.3
