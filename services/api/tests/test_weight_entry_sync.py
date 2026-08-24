import uuid
from datetime import UTC, datetime

import pytest
from httpx import AsyncClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User, WeightEntry, WeightEntrySource
from app.security.jwt import create_access_token
from app.sync.entities import WeightEntrySchema
from app.sync.registry import get_entity_schema, is_registered


def test_weight_entry_is_registered() -> None:
    assert is_registered("weight_entry")
    assert get_entity_schema("weight_entry") is WeightEntrySchema


async def _make_user_headers(db_session: AsyncSession, email: str) -> dict[str, str]:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    token = create_access_token(subject=str(user.id))
    return {"Authorization": f"Bearer {token}"}


def _create_op(entity_id: uuid.UUID, payload: dict[str, object]) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": "weight_entry",
        "entity_id": str(entity_id),
        "op_type": "create",
        "payload": payload,
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


@pytest.mark.asyncio
async def test_a_create_op_materializes_a_full_weight_entry(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _make_user_headers(db_session, "wsync1@example.com")
    entity_id = uuid.uuid4()

    response = await client.post(
        "/sync/push",
        json={
            "ops": [
                _create_op(
                    entity_id,
                    {
                        "logged_at_utc": "2026-01-01T08:00:00Z",
                        "local_date": "2026-01-01",
                        "tz_offset_minutes": 120,
                        "weight_kg": 82.5,
                        "source": "manual",
                        "note": "morning",
                    },
                )
            ]
        },
        headers=headers,
    )
    assert response.status_code == 200

    entry = await db_session.get(WeightEntry, entity_id)
    assert entry is not None
    assert float(entry.weight_kg) == 82.5
    assert entry.source == WeightEntrySource.MANUAL
    assert entry.note == "morning"
    assert entry.tz_offset_minutes == 120


@pytest.mark.asyncio
async def test_bootstrap_includes_weight_entries_with_the_right_field_names(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _make_user_headers(db_session, "wsync2@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={
            "ops": [
                _create_op(
                    entity_id,
                    {
                        "logged_at_utc": "2026-01-01T08:00:00Z",
                        "local_date": "2026-01-01",
                        "tz_offset_minutes": 0,
                        "weight_kg": 70.0,
                        "source": "manual",
                    },
                )
            ]
        },
        headers=headers,
    )

    response = await client.post("/sync/bootstrap", headers=headers)

    assert response.status_code == 200
    entries = response.json()["entities"]["weight_entry"]
    assert len(entries) == 1
    assert entries[0]["id"] == str(entity_id)
    assert entries[0]["weight_kg"] == 70.0
    assert entries[0]["source"] == "manual"


@pytest.mark.asyncio
async def test_an_update_op_changes_only_the_given_field(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _make_user_headers(db_session, "wsync3@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={
            "ops": [
                _create_op(
                    entity_id,
                    {
                        "logged_at_utc": "2026-01-01T08:00:00Z",
                        "local_date": "2026-01-01",
                        "tz_offset_minutes": 0,
                        "weight_kg": 70.0,
                        "source": "manual",
                        "note": "before",
                    },
                )
            ]
        },
        headers=headers,
    )

    await client.post(
        "/sync/push",
        json={
            "ops": [
                {
                    "client_op_id": str(uuid.uuid4()),
                    "entity_type": "weight_entry",
                    "entity_id": str(entity_id),
                    "op_type": "update",
                    "payload": {"weight_kg": 69.5},
                    "device_id": str(uuid.uuid4()),
                    "client_ts": datetime.now(UTC).isoformat(),
                }
            ]
        },
        headers=headers,
    )

    entry = await db_session.get(WeightEntry, entity_id)
    assert entry is not None
    assert float(entry.weight_kg) == 69.5
    assert entry.note == "before"


@pytest.mark.asyncio
async def test_a_deleted_weight_entry_is_tombstoned_and_excluded_from_bootstrap(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _make_user_headers(db_session, "wsync4@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={
            "ops": [
                _create_op(
                    entity_id,
                    {
                        "logged_at_utc": "2026-01-01T08:00:00Z",
                        "local_date": "2026-01-01",
                        "tz_offset_minutes": 0,
                        "weight_kg": 70.0,
                        "source": "manual",
                    },
                )
            ]
        },
        headers=headers,
    )
    await client.post(
        "/sync/push",
        json={
            "ops": [
                {
                    "client_op_id": str(uuid.uuid4()),
                    "entity_type": "weight_entry",
                    "entity_id": str(entity_id),
                    "op_type": "delete",
                    "payload": {},
                    "device_id": str(uuid.uuid4()),
                    "client_ts": datetime.now(UTC).isoformat(),
                }
            ]
        },
        headers=headers,
    )

    result = await db_session.execute(
        select(WeightEntry).where(WeightEntry.id == entity_id)
    )
    entry = result.scalar_one()
    assert entry.deleted_at is not None

    response = await client.post("/sync/bootstrap", headers=headers)
    assert response.json()["entities"]["weight_entry"] == []
