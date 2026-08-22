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

ENTITY_TYPE = f"revert_example_{uuid.uuid4().hex}"
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


async def test_revert_restores_prior_field_values(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "revert1@example.com")
    entity_id = uuid.uuid4()

    create = await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(entity_id, "create", {"weight_kg": 80.0, "note": "a"})
            ]
        },
        headers=headers,
    )
    create_seq = create.json()["results"][0]["server_seq"]

    await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "update", {"weight_kg": 85.0})]},
        headers=headers,
    )

    revert = await client.post(
        f"/entities/{ENTITY_TYPE}/{entity_id}/revert",
        json={"target_server_seq": create_seq, "device_id": str(uuid.uuid4())},
        headers=headers,
    )

    assert revert.status_code == 200
    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 80.0
    assert row.note == "a"


async def test_revert_restores_full_state_as_of_that_point(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    """Reverting to a point restores every field's value as of then, not
    just the field the targeted op itself touched."""
    headers = await _auth_headers(db_session, "revert2@example.com")
    entity_id = uuid.uuid4()

    await client.post(
        "/sync/push",
        json={
            "ops": [
                _op_request(entity_id, "create", {"weight_kg": 80.0, "note": "a"})
            ]
        },
        headers=headers,
    )
    weight_only_update = await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "update", {"weight_kg": 85.0})]},
        headers=headers,
    )
    target_seq = weight_only_update.json()["results"][0]["server_seq"]

    await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "update", {"note": "b"})]},
        headers=headers,
    )

    revert = await client.post(
        f"/entities/{ENTITY_TYPE}/{entity_id}/revert",
        json={"target_server_seq": target_seq, "device_id": str(uuid.uuid4())},
        headers=headers,
    )
    assert revert.status_code == 200

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 85.0  # value as of target_seq
    assert row.note == "a"  # also as of target_seq, even though untouched by it


async def test_revert_appears_in_history_without_rewriting_it(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "revert3@example.com")
    entity_id = uuid.uuid4()

    create = await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "create", {"weight_kg": 80.0})]},
        headers=headers,
    )
    create_seq = create.json()["results"][0]["server_seq"]
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "update", {"weight_kg": 85.0})]},
        headers=headers,
    )

    await client.post(
        f"/entities/{ENTITY_TYPE}/{entity_id}/revert",
        json={"target_server_seq": create_seq, "device_id": str(uuid.uuid4())},
        headers=headers,
    )

    history = await client.get(
        f"/entities/{ENTITY_TYPE}/{entity_id}/history", headers=headers
    )
    entries = history.json()["history"]
    assert len(entries) == 3  # create, update, and the revert's own update
    assert entries[-1]["payload"] == {"weight_kg": 80.0}


async def test_revert_rejects_target_not_in_history(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "revert4@example.com")
    entity_id = uuid.uuid4()
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "create", {"weight_kg": 80.0})]},
        headers=headers,
    )

    response = await client.post(
        f"/entities/{ENTITY_TYPE}/{entity_id}/revert",
        json={"target_server_seq": 999999999, "device_id": str(uuid.uuid4())},
        headers=headers,
    )
    assert response.status_code == 400


async def test_revert_rejects_unknown_entity_type(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "revert5@example.com")

    response = await client.post(
        f"/entities/never_registered_entity/{uuid.uuid4()}/revert",
        json={"target_server_seq": 1, "device_id": str(uuid.uuid4())},
        headers=headers,
    )
    assert response.status_code == 404


async def test_revert_cannot_target_another_users_entity(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    owner_headers = await _auth_headers(db_session, "revert6a@example.com")
    other_headers = await _auth_headers(db_session, "revert6b@example.com")
    entity_id = uuid.uuid4()

    create = await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, "create", {"weight_kg": 80.0})]},
        headers=owner_headers,
    )
    create_seq = create.json()["results"][0]["server_seq"]

    response = await client.post(
        f"/entities/{ENTITY_TYPE}/{entity_id}/revert",
        json={"target_server_seq": create_seq, "device_id": str(uuid.uuid4())},
        headers=other_headers,
    )
    assert response.status_code == 400


async def test_revert_requires_authentication(client: AsyncClient) -> None:
    response = await client.post(
        f"/entities/{ENTITY_TYPE}/{uuid.uuid4()}/revert",
        json={"target_server_seq": 1, "device_id": str(uuid.uuid4())},
    )
    assert response.status_code in (401, 403)
