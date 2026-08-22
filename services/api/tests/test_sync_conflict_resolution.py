import uuid
from datetime import UTC, datetime, timedelta

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import EntityFieldVersion, Operation, OpType, User
from app.sync.conflict_resolution import field_wins, get_field_version, resolve_field


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


def _make_op(
    user_id: uuid.UUID, entity_id: uuid.UUID, client_ts: datetime, server_seq: int = 0
) -> Operation:
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user_id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.UPDATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=client_ts,
    )
    op.server_seq = server_seq  # unpersisted stand-in, just for field_wins()
    return op


def test_field_wins_when_no_current_version() -> None:
    op = _make_op(uuid.uuid4(), uuid.uuid4(), datetime.now(UTC))
    assert field_wins(op, None) is True


def test_field_wins_with_later_client_ts() -> None:
    base_ts = datetime.now(UTC)
    current = EntityFieldVersion(
        entity_id=uuid.uuid4(),
        field_name="weight_kg",
        user_id=uuid.uuid4(),
        client_ts=base_ts,
        server_seq=1,
    )
    newer_op = _make_op(
        uuid.uuid4(), current.entity_id, base_ts + timedelta(seconds=1), server_seq=2
    )
    assert field_wins(newer_op, current) is True


def test_field_loses_with_earlier_client_ts() -> None:
    base_ts = datetime.now(UTC)
    current = EntityFieldVersion(
        entity_id=uuid.uuid4(),
        field_name="weight_kg",
        user_id=uuid.uuid4(),
        client_ts=base_ts,
        server_seq=5,
    )
    older_op = _make_op(
        uuid.uuid4(), current.entity_id, base_ts - timedelta(seconds=1), server_seq=6
    )
    assert field_wins(older_op, current) is False


def test_tied_client_ts_uses_server_seq_as_tiebreak() -> None:
    shared_ts = datetime.now(UTC)
    current = EntityFieldVersion(
        entity_id=uuid.uuid4(),
        field_name="weight_kg",
        user_id=uuid.uuid4(),
        client_ts=shared_ts,
        server_seq=10,
    )
    higher_seq_op = _make_op(uuid.uuid4(), current.entity_id, shared_ts, server_seq=11)
    lower_seq_op = _make_op(uuid.uuid4(), current.entity_id, shared_ts, server_seq=9)

    assert field_wins(higher_seq_op, current) is True
    assert field_wins(lower_seq_op, current) is False


@pytest.mark.asyncio
async def test_resolve_field_records_first_version(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "conflict1@example.com")
    entity_id = uuid.uuid4()
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    db_session.add(op)
    await db_session.flush()

    won = await resolve_field(db_session, op, "weight_kg")

    assert won is True
    version = await get_field_version(db_session, entity_id, "weight_kg")
    assert version is not None
    assert version.server_seq == op.server_seq


@pytest.mark.asyncio
async def test_resolve_field_updates_version_when_op_wins(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "conflict2@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    first_op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=base_ts,
    )
    db_session.add(first_op)
    await db_session.flush()
    assert await resolve_field(db_session, first_op, "weight_kg") is True

    second_op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.UPDATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=base_ts + timedelta(seconds=1),
    )
    db_session.add(second_op)
    await db_session.flush()
    assert await resolve_field(db_session, second_op, "weight_kg") is True

    version = await get_field_version(db_session, entity_id, "weight_kg")
    assert version is not None
    assert version.server_seq == second_op.server_seq


@pytest.mark.asyncio
async def test_resolve_field_rejects_a_losing_op(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "conflict3@example.com")
    entity_id = uuid.uuid4()
    base_ts = datetime.now(UTC)

    winner_op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=base_ts + timedelta(minutes=1),
    )
    db_session.add(winner_op)
    await db_session.flush()
    assert await resolve_field(db_session, winner_op, "weight_kg") is True

    loser_op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="test_entity",
        entity_id=entity_id,
        op_type=OpType.UPDATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=base_ts,
    )
    db_session.add(loser_op)
    await db_session.flush()

    won = await resolve_field(db_session, loser_op, "weight_kg")

    assert won is False
    version = await get_field_version(db_session, entity_id, "weight_kg")
    assert version is not None
    assert version.server_seq == winner_op.server_seq  # unchanged
