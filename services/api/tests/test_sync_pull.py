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

ENTITY_TYPE = f"pull_example_{uuid.uuid4().hex}"
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


async def _push(
    client: AsyncClient, headers: dict[str, str], ops: list[dict[str, object]]
) -> list[int]:
    response = await client.post("/sync/push", json={"ops": ops}, headers=headers)
    assert response.status_code == 200
    return [r["server_seq"] for r in response.json()["results"]]


async def test_pull_returns_ops_in_order(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "pull1@example.com")
    pushed_seqs = await _push(
        client, headers, [_op_request(), _op_request(), _op_request()]
    )

    response = await client.get("/sync/pull?since=0", headers=headers)

    assert response.status_code == 200
    body = response.json()
    pulled_seqs = [op["server_seq"] for op in body["ops"]]
    assert pulled_seqs == pushed_seqs
    assert body["next_cursor"] == pushed_seqs[-1]


async def test_pull_only_returns_newer_ops(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "pull2@example.com")
    pushed_seqs = await _push(client, headers, [_op_request(), _op_request()])

    response = await client.get(
        f"/sync/pull?since={pushed_seqs[0]}", headers=headers
    )

    assert response.status_code == 200
    body = response.json()
    assert len(body["ops"]) == 1
    assert body["ops"][0]["server_seq"] == pushed_seqs[1]


async def test_pull_paging_via_next_cursor(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "pull3@example.com")
    pushed_seqs = await _push(
        client, headers, [_op_request(), _op_request(), _op_request()]
    )

    first_page = await client.get("/sync/pull?since=0&limit=2", headers=headers)
    assert first_page.status_code == 200
    first_body = first_page.json()
    assert len(first_body["ops"]) == 2
    assert first_body["next_cursor"] == pushed_seqs[1]

    second_page = await client.get(
        f"/sync/pull?since={first_body['next_cursor']}", headers=headers
    )
    assert second_page.status_code == 200
    second_body = second_page.json()
    assert len(second_body["ops"]) == 1
    assert second_body["ops"][0]["server_seq"] == pushed_seqs[2]
    assert second_body["next_cursor"] == pushed_seqs[2]


async def test_pull_empty_page_keeps_cursor_unchanged(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers = await _auth_headers(db_session, "pull4@example.com")
    pushed_seqs = await _push(client, headers, [_op_request()])

    response = await client.get(
        f"/sync/pull?since={pushed_seqs[-1]}", headers=headers
    )

    assert response.status_code == 200
    body = response.json()
    assert body["ops"] == []
    assert body["next_cursor"] == pushed_seqs[-1]


async def test_pull_is_scoped_to_the_authenticated_user(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    headers_a = await _auth_headers(db_session, "pull5a@example.com")
    headers_b = await _auth_headers(db_session, "pull5b@example.com")

    await _push(client, headers_a, [_op_request()])
    await _push(client, headers_b, [_op_request()])

    response = await client.get("/sync/pull?since=0", headers=headers_b)

    assert response.status_code == 200
    assert len(response.json()["ops"]) == 1


async def test_pull_requires_authentication(client: AsyncClient) -> None:
    response = await client.get("/sync/pull?since=0")
    assert response.status_code in (401, 403)
