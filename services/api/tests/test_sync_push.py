import uuid
from datetime import UTC, datetime

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, User
from app.security.jwt import create_access_token
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"push_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)


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
    op_type: str = "create",
    payload: dict[str, object] | None = None,
    client_op_id: uuid.UUID | None = None,
) -> dict[str, object]:
    return {
        "client_op_id": str(client_op_id or uuid.uuid4()),
        "entity_type": ENTITY_TYPE,
        "entity_id": str(entity_id),
        "op_type": op_type,
        "payload": payload if payload is not None else {"weight_kg": 82.5},
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


async def test_push_creates_and_materializes_an_op(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push1@example.com")
    entity_id = uuid.uuid4()

    response = await client.post(
        "/sync/push", json={"ops": [_op_request(entity_id)]}, headers=headers
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body["results"]) == 1
    assert body["results"][0]["server_seq"] is not None

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 82.5


async def test_push_is_idempotent_on_replay(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push2@example.com")
    entity_id = uuid.uuid4()
    client_op_id = uuid.uuid4()
    op_request = _op_request(entity_id, client_op_id=client_op_id)

    first = await client.post(
        "/sync/push", json={"ops": [op_request]}, headers=headers
    )
    second = await client.post(
        "/sync/push", json={"ops": [op_request]}, headers=headers
    )

    assert first.status_code == 200
    assert second.status_code == 200
    assert (
        first.json()["results"][0]["server_seq"]
        == second.json()["results"][0]["server_seq"]
    )

    result = await db_session.execute(
        select(func.count())
        .select_from(Operation)
        .where(Operation.client_op_id == client_op_id)
    )
    assert result.scalar_one() == 1


async def test_push_batch_applies_ops_in_order(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push3@example.com")
    entity_id = uuid.uuid4()

    response = await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(entity_id, payload={"weight_kg": 80.0, "note": "first"}),
                _op_request(entity_id, op_type="update", payload={"note": "second"}),
            ]
        },
        headers=headers,
    )

    assert response.status_code == 200
    seqs = [r["server_seq"] for r in response.json()["results"]]
    assert seqs[0] < seqs[1]

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 80.0
    assert row.note == "second"


async def test_push_rejects_invalid_payload(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push4@example.com")
    client_op_id = uuid.uuid4()

    response = await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(
                    uuid.uuid4(),
                    payload={"not_a_real_field": 1},
                    client_op_id=client_op_id,
                )
            ]
        },
        headers=headers,
    )

    assert response.status_code == 400
    result = await db_session.execute(
        select(func.count())
        .select_from(Operation)
        .where(Operation.client_op_id == client_op_id)
    )
    assert result.scalar_one() == 0


async def test_push_rejects_unknown_entity_type(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push5@example.com")

    op_request = _op_request(uuid.uuid4())
    op_request["entity_type"] = "never_registered_entity"

    response = await client.post(
        "/sync/push", json={"ops": [op_request]}, headers=headers
    )
    assert response.status_code == 400


async def test_push_requires_authentication(client: AsyncClient) -> None:
    response = await client.post(
        "/sync/push", json={"ops": [_op_request(uuid.uuid4())]}
    )
    assert response.status_code in (401, 403)


async def test_push_rejects_empty_batch(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "push6@example.com")

    response = await client.post("/sync/push", json={"ops": []}, headers=headers)
    assert response.status_code == 422
