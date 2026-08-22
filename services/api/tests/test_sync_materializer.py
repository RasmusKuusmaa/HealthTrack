import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User
from app.sync.materializer import MaterializationError, materialize_op
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"materializer_example_{uuid.uuid4().hex}"
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
    client_ts: datetime,
) -> Operation:
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user_id,
        entity_type=ENTITY_TYPE,
        entity_id=entity_id,
        op_type=op_type,
        payload=payload,
        device_id=uuid.uuid4(),
        client_ts=client_ts,
    )
    db_session.add(op)
    await db_session.flush()
    await db_session.refresh(op)
    return op


async def test_create_populates_fields(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat1@example.com")
    entity_id = uuid.uuid4()
    op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.CREATE,
        {"weight_kg": 82.5, "note": "morning"},
        datetime.now(UTC),
    )

    await materialize_op(db_session, op)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 82.5
    assert row.note == "morning"
    assert row.deleted_at is None


async def test_update_applies_to_existing_row(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat2@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}, base_ts
    )
    await materialize_op(db_session, create_op)

    update_op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.UPDATE,
        {"weight_kg": 81.0},
        base_ts + timedelta(seconds=1),
    )
    await materialize_op(db_session, update_op)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 81.0


async def test_older_client_ts_loses_to_newer(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat3@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}, base_ts
    )
    await materialize_op(db_session, create_op)

    newer_update = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.UPDATE,
        {"weight_kg": 85.0},
        base_ts + timedelta(minutes=5),
    )
    await materialize_op(db_session, newer_update)

    # This op has an earlier client_ts than the update already applied —
    # even though it's ingested later (higher server_seq), it must lose.
    older_update = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.UPDATE,
        {"weight_kg": 70.0},
        base_ts + timedelta(seconds=1),
    )
    await materialize_op(db_session, older_update)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 85.0  # the newer client_ts write still stands


async def test_tied_client_ts_breaks_tie_with_server_seq(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "mat4@example.com")
    entity_id = uuid.uuid4()
    shared_ts = datetime.now(UTC)

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}, shared_ts
    )
    await materialize_op(db_session, create_op)

    first = await _make_op(
        db_session, user.id, entity_id, OpType.UPDATE, {"weight_kg": 90.0}, shared_ts
    )
    second = await _make_op(
        db_session, user.id, entity_id, OpType.UPDATE, {"weight_kg": 95.0}, shared_ts
    )
    assert second.server_seq > first.server_seq

    # Apply out of server_seq order — the result must not depend on
    # application order, only on server_seq among tied client_ts values.
    await materialize_op(db_session, second)
    await materialize_op(db_session, first)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 95.0  # `second` has the higher server_seq


async def test_field_level_conflicts_are_independent(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "mat5@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    create_op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.CREATE,
        {"weight_kg": 80.0, "note": "original"},
        base_ts,
    )
    await materialize_op(db_session, create_op)

    # Two "devices" edit different fields — both survive even though they
    # touch the same entity, because they don't touch the same field.
    weight_update = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.UPDATE,
        {"weight_kg": 79.0},
        base_ts + timedelta(seconds=1),
    )
    note_update = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.UPDATE,
        {"note": "after run"},
        base_ts + timedelta(seconds=2),
    )
    await materialize_op(db_session, weight_update)
    await materialize_op(db_session, note_update)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 79.0
    assert row.note == "after run"


async def test_delete_sets_tombstone(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat6@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 80.0}, base_ts
    )
    await materialize_op(db_session, create_op)

    delete_op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.DELETE,
        {},
        base_ts + timedelta(seconds=1),
    )
    await materialize_op(db_session, delete_op)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.deleted_at is not None
    assert row.weight_kg == 80.0  # delete tombstones, never erases fields


async def test_update_on_nonexistent_entity_raises(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat7@example.com")
    op = await _make_op(
        db_session,
        user.id,
        uuid.uuid4(),
        OpType.UPDATE,
        {"weight_kg": 1.0},
        datetime.now(UTC),
    )

    with pytest.raises(MaterializationError):
        await materialize_op(db_session, op)


async def test_delete_on_nonexistent_entity_raises(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat8@example.com")
    op = await _make_op(
        db_session, user.id, uuid.uuid4(), OpType.DELETE, {}, datetime.now(UTC)
    )

    with pytest.raises(MaterializationError):
        await materialize_op(db_session, op)


async def test_unregistered_entity_type_raises(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "mat9@example.com")
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="never_registered_entity",
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    db_session.add(op)
    await db_session.flush()

    with pytest.raises(MaterializationError):
        await materialize_op(db_session, op)
