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

ENTITY_TYPE = f"bootstrap_example_{uuid.uuid4().hex}"
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
    entity_id: uuid.UUID | None = None,
    op_type: str = "create",
    payload: dict[str, object] | None = None,
) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": ENTITY_TYPE,
        "entity_id": str(entity_id or uuid.uuid4()),
        "op_type": op_type,
        "payload": payload if payload is not None else {"weight_kg": 1.0},
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


async def test_bootstrap_returns_live_entities_and_cursor(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "bootstrap1@example.com")
    entity_id = uuid.uuid4()

    push = await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, payload={"weight_kg": 82.5})]},
        headers=headers,
    )
    assert push.status_code == 200
    pushed_seq = push.json()["results"][0]["server_seq"]

    response = await client.post("/sync/bootstrap", headers=headers)

    assert response.status_code == 200
    body = response.json()
    assert body["cursor"] == pushed_seq
    items = body["entities"][ENTITY_TYPE]
    assert len(items) == 1
    assert items[0]["id"] == str(entity_id)
    assert items[0]["weight_kg"] == 82.5


async def test_bootstrap_excludes_deleted_entities(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "bootstrap2@example.com")
    kept_id, deleted_id = uuid.uuid4(), uuid.uuid4()

    await client.post(
        "/sync/push",
        json={"ops": [_op_request(kept_id), _op_request(deleted_id)]},
        headers=headers,
    )
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(deleted_id, op_type="delete", payload={})]},
        headers=headers,
    )

    response = await client.post("/sync/bootstrap", headers=headers)

    assert response.status_code == 200
    ids = {item["id"] for item in response.json()["entities"][ENTITY_TYPE]}
    assert str(kept_id) in ids
    assert str(deleted_id) not in ids


async def test_bootstrap_is_scoped_to_the_authenticated_user(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers_a = await _auth_headers(db_session, "bootstrap3a@example.com")
    headers_b = await _auth_headers(db_session, "bootstrap3b@example.com")

    await client.post("/sync/push", json={"ops": [_op_request()]}, headers=headers_a)

    response = await client.post("/sync/bootstrap", headers=headers_b)

    assert response.status_code == 200
    assert response.json()["entities"][ENTITY_TYPE] == []
    assert response.json()["cursor"] == 0


async def test_bootstrap_with_no_data_returns_empty_snapshot(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "bootstrap4@example.com")

    response = await client.post("/sync/bootstrap", headers=headers)

    assert response.status_code == 200
    body = response.json()
    assert body["cursor"] == 0
    assert body["entities"][ENTITY_TYPE] == []


async def test_bootstrap_requires_authentication(client: AsyncClient) -> None:
    response = await client.post("/sync/bootstrap")
    assert response.status_code in (401, 403)
