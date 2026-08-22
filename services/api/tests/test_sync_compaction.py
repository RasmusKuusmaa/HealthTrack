import uuid
from datetime import UTC, datetime

import pytest
from httpx import AsyncClient
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, SyncSnapshot, User
from app.security.jwt import create_access_token
from app.services.sync_compaction import compact_all_users, compact_user
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"compaction_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def _auth_headers(user: User) -> dict[str, str]:
    token = create_access_token(subject=str(user.id))
    return {"Authorization": f"Bearer {token}"}


def _op_request(entity_id: uuid.UUID, weight_kg: float = 1.0) -> dict[str, object]:
    return {
        "client_op_id": str(uuid.uuid4()),
        "entity_type": ENTITY_TYPE,
        "entity_id": str(entity_id),
        "op_type": "create",
        "payload": {"weight_kg": weight_kg},
        "device_id": str(uuid.uuid4()),
        "client_ts": datetime.now(UTC).isoformat(),
    }


async def _op_count(db_session: AsyncSession) -> int:
    result = await db_session.execute(select(func.count()).select_from(Operation))
    return result.scalar_one()


async def test_compact_user_creates_a_snapshot(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "compact1@example.com")
    entity_id = uuid.uuid4()
    push = await client.post(
        "/sync/push",
        json={"ops": [_op_request(entity_id, weight_kg=82.5)]},
        headers=await _auth_headers(user),
    )
    pushed_seq = push.json()["results"][0]["server_seq"]

    snapshot = await compact_user(db_session, user.id)

    assert snapshot.server_seq == pushed_seq
    assert len(snapshot.entities[ENTITY_TYPE]) == 1
    assert snapshot.entities[ENTITY_TYPE][0]["weight_kg"] == 82.5


async def test_recompacting_overwrites_the_same_row(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "compact2@example.com")
    headers = await _auth_headers(user)

    await client.post(
        "/sync/push", json={"ops": [_op_request(uuid.uuid4())]}, headers=headers
    )
    await compact_user(db_session, user.id)

    await client.post(
        "/sync/push", json={"ops": [_op_request(uuid.uuid4())]}, headers=headers
    )
    await compact_user(db_session, user.id)

    result = await db_session.execute(
        select(func.count())
        .select_from(SyncSnapshot)
        .where(SyncSnapshot.user_id == user.id)
    )
    assert result.scalar_one() == 1

    snapshot = await db_session.get(SyncSnapshot, user.id)
    assert snapshot is not None
    assert len(snapshot.entities[ENTITY_TYPE]) == 2


async def test_compaction_never_modifies_the_operations_table(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user = await _make_user(db_session, "compact3@example.com")
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(uuid.uuid4())]},
        headers=await _auth_headers(user),
    )

    before = await _op_count(db_session)
    await compact_user(db_session, user.id)
    after = await _op_count(db_session)

    assert before == after


async def test_compact_all_users_compacts_everyone_with_ops(
    client: AsyncClient, db_session: AsyncSession
) -> None:
    user_a = await _make_user(db_session, "compact4a@example.com")
    user_b = await _make_user(db_session, "compact4b@example.com")
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(uuid.uuid4())]},
        headers=await _auth_headers(user_a),
    )
    await client.post(
        "/sync/push",
        json={"ops": [_op_request(uuid.uuid4())]},
        headers=await _auth_headers(user_b),
    )
    # A third user with no ops at all should not be touched.
    user_c = await _make_user(db_session, "compact4c@example.com")

    compacted_count = await compact_all_users(db_session)

    assert compacted_count == 2
    assert await db_session.get(SyncSnapshot, user_a.id) is not None
    assert await db_session.get(SyncSnapshot, user_b.id) is not None
    assert await db_session.get(SyncSnapshot, user_c.id) is None
