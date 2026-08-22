import uuid
from datetime import UTC, datetime

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import User
from app.security.jwt import create_access_token
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"history_example_{uuid.uuid4().hex}"
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
    entity_id: uuid.UUID, op_type: str, payload: dict[str, object]
) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": ENTITY_TYPE,
        "entity_id": str(entity_id),
        "op_type": op_type,
        "payload": payload,
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


async def test_history_returns_ops_in_order(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "history1@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(entity_id, "create", {"weight_kg": 80.0}),
                _op_request(entity_id, "update", {"weight_kg": 81.0}),
            ]
        },
        headers=headers,
    )

    response = await client.get(
        f"/entities/{ENTITY_TYPE}/{entity_id}/history", headers=headers
    )

    assert response.status_code == 200
    history = response.json()["history"]
    assert len(history) == 2
    assert history[0]["op_type"] == "create"
    assert history[0]["payload"] == {"weight_kg": 80.0}
    assert history[1]["op_type"] == "update"
    assert history[1]["payload"] == {"weight_kg": 81.0}
    assert history[0]["server_seq"] < history[1]["server_seq"]


async def test_history_for_unknown_entity_type_is_404(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "history2@example.com")

    response = await client.get(
        f"/entities/never_registered_entity/{uuid.uuid4()}/history",
        headers=headers,
    )
    assert response.status_code == 404


async def test_history_for_nonexistent_entity_is_empty(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "history3@example.com")

    response = await client.get(
        f"/entities/{ENTITY_TYPE}/{uuid.uuid4()}/history", headers=headers
    )
    assert response.status_code == 200
    assert response.json()["history"] == []


async def test_history_does_not_leak_other_users_entities(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    owner_headers = await _auth_headers(db_session, "history4a@example.com")
    other_headers = await _auth_headers(db_session, "history4b@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "create", {"weight_kg": 80.0})]},
        headers=owner_headers,
    )

    response = await client.get(
        f"/entities/{ENTITY_TYPE}/{entity_id}/history", headers=other_headers
    )
    assert response.status_code == 200
    assert response.json()["history"] == []


async def test_history_requires_authentication(client: AsyncClient) -> None:
    response = await client.get(f"/entities/{ENTITY_TYPE}/{uuid.uuid4()}/history")
    assert response.status_code in (401, 403)
