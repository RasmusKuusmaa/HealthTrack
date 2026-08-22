import uuid
from datetime import UTC, datetime

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User
from app.sync.materializer import materialize_op
from app.sync.registry import register_entity_type
from app.sync.replay_verification import verify_replay
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"replay_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def _make_op(
    db_session: AsyncSession,
    user_id: uuid.UUID,
    entity_id: uuid.UUID,
    op_type: OpType,
    payload: dict[str, object],
) -> Operation:
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user_id,
        entity_type=ENTITY_TYPE,
        entity_id=entity_id,
        op_type=op_type,
        payload=payload,
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    db_session.add(op)
    await db_session.flush()
    return op


async def test_verify_replay_finds_no_diff_for_correct_state(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "replay1@example.com")
    entity_id = uuid.uuid4()

    create_op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.CREATE,
        {"weight_kg": 80.0, "note": "a"},
    )
    await materialize_op(db_session, create_op)
    update_op = await _make_op(
        db_session, user.id, entity_id, OpType.UPDATE, {"weight_kg": 85.0}
    )
    await materialize_op(db_session, update_op)

    diffs = await verify_replay(db_session, user_id=user.id, entity_types=[ENTITY_TYPE])

    assert diffs == []


async def test_verify_replay_detects_drift_from_live_state(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "replay2@example.com")
    entity_id = uuid.uuid4()

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}
    )
    await materialize_op(db_session, create_op)

    # Corrupt the live projection directly — bypassing the op log, the way
    # a materializer bug or an out-of-band write might.
    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    row.weight_kg = 999.0
    await db_session.flush()

    diffs = await verify_replay(db_session, user_id=user.id, entity_types=[ENTITY_TYPE])

    assert len(diffs) == 1
    assert diffs[0].field == "weight_kg"
    assert diffs[0].expected == 999.0
    assert diffs[0].actual == 80.0


async def test_verify_replay_never_persists_changes(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "replay3@example.com")
    entity_id = uuid.uuid4()
    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}
    )
    await materialize_op(db_session, create_op)

    await verify_replay(db_session, user_id=user.id, entity_types=[ENTITY_TYPE])

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 80.0


async def test_verify_replay_handles_deleted_entities(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "replay4@example.com")
    entity_id = uuid.uuid4()
    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}
    )
    await materialize_op(db_session, create_op)
    delete_op = await _make_op(db_session, user.id, entity_id, OpType.DELETE, {})
    await materialize_op(db_session, delete_op)

    diffs = await verify_replay(db_session, user_id=user.id, entity_types=[ENTITY_TYPE])

    assert diffs == []
