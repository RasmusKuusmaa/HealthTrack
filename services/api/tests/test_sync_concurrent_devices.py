import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.jwt import create_access_token
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"concurrent_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)

_BASE_TS = datetime(2026, 1, 1, tzinfo=UTC)


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def _auth_headers(db_session: AsyncSession, email: str) -> dict[str, str]:
    user = await _make_user(db_session, email)
    token = create_access_token(subject=str(user.id))
    return {"Authorization": f"Bearer {token}"}


def _op_request(
    entity_id: uuid.UUID,
    device_id: uuid.UUID,
    op_type: str,
    payload: dict[str, object],
    client_ts: datetime,
) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": ENTITY_TYPE,
        "entity_id": str(entity_id),
        "op_type": op_type,
        "payload": payload,
        "device_id": str(device_id),
        "client_ts": client_ts.isoformat(),
    }


async def _push(
    client: AsyncClient, headers: dict[str, str], ops: list[dict[str, object]]
) -> list[int]:
    response = await client.post("/sync/push", json={"ops": ops}, headers=headers)
    assert response.status_code == 200
    return [r["server_seq"] for r in response.json()["results"]]


async def test_concurrent_edits_to_different_fields_both_apply(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """Two devices independently editing disjoint fields of the same entity
    while offline, then both syncing, must not clobber each other — field
    level LWW is per-field, not per-row."""
    headers = await _auth_headers(db_session, "concurrent1@example.com")
    entity_id = uuid.uuid4()
    device_a, device_b = uuid.uuid4(), uuid.uuid4()

    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_a,
                "create",
                {"weight_kg": 80.0, "note": "init"},
                _BASE_TS,
            )
        ],
    )

    # Device A and device B each edited a different field while offline,
    # then both sync — neither has seen the other's edit yet.
    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_a,
                "update",
                {"weight_kg": 82.0},
                _BASE_TS + timedelta(seconds=10),
            )
        ],
    )
    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_b,
                "update",
                {"note": "from device b"},
                _BASE_TS + timedelta(seconds=11),
            )
        ],
    )

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 82.0
    assert row.note == "from device b"


async def test_same_field_conflict_resolved_by_client_ts_not_arrival_order(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """Device B's edit has an earlier client_ts than device A's, but B's op
    reaches the server *after* A's. The later wall-clock edit (by client_ts)
    must still win, regardless of which op the server received first."""
    headers = await _auth_headers(db_session, "concurrent2@example.com")
    entity_id = uuid.uuid4()
    device_a, device_b = uuid.uuid4(), uuid.uuid4()

    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id, device_a, "create", {"weight_kg": 80.0}, _BASE_TS
            )
        ],
    )

    # A's edit is chronologically later...
    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_a,
                "update",
                {"weight_kg": 90.0},
                _BASE_TS + timedelta(seconds=20),
            )
        ],
    )
    # ...but B's edit, made and timestamped earlier, arrives at the server
    # second (e.g. B was offline longer).
    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_b,
                "update",
                {"weight_kg": 85.0},
                _BASE_TS + timedelta(seconds=15),
            )
        ],
    )

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 90.0  # A's later client_ts wins, despite arriving first


async def test_op_log_retains_both_devices_edits_even_though_one_loses(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """LWW governs the materialized projection only — the append-only op
    log must still contain every device's op, so pulling clients see the
    full history and can converge."""
    headers = await _auth_headers(db_session, "concurrent3@example.com")
    entity_id = uuid.uuid4()
    device_a, device_b = uuid.uuid4(), uuid.uuid4()

    create_seqs = await _push(
        client,
        headers,
        [
            _op_request(
                entity_id, device_a, "create", {"weight_kg": 80.0}, _BASE_TS
            )
        ],
    )
    losing_seqs = await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_b,
                "update",
                {"weight_kg": 70.0},
                _BASE_TS - timedelta(seconds=5),
            )
        ],
    )

    response = await client.get("/sync/pull?since=0", headers=headers)
    assert response.status_code == 200
    pulled_seqs = {op["server_seq"] for op in response.json()["ops"]}
    assert set(create_seqs) | set(losing_seqs) <= pulled_seqs

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 80.0  # the earlier-client_ts loser did not apply


async def test_concurrent_create_of_same_entity_id_merges_fields(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """Two devices race to create the same entity (e.g. both create it
    offline before ever syncing). The second CREATE must not error — it
    materializes like any other field-level write, resolved by client_ts."""
    headers = await _auth_headers(db_session, "concurrent4@example.com")
    entity_id = uuid.uuid4()
    device_a, device_b = uuid.uuid4(), uuid.uuid4()

    await _push(
        client,
        headers,
        [
            _op_request(
                entity_id,
                device_a,
                "create",
                {"weight_kg": 80.0, "note": "from a"},
                _BASE_TS,
            )
        ],
    )
    response = await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(
                    entity_id,
                    device_b,
                    "create",
                    {"weight_kg": 90.0, "note": "from b"},
                    _BASE_TS + timedelta(seconds=1),
                )
            ]
        },
        headers=headers,
    )

    assert response.status_code == 200
    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 90.0
    assert row.note == "from b"
