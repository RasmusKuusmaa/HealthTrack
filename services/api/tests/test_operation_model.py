import uuid
from datetime import UTC, datetime

import pytest
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


def _make_op(
    user_id: uuid.UUID, client_op_id: uuid.UUID | None = None
) -> Operation:
    return Operation(
        client_op_id=client_op_id or uuid.uuid4(),
        user_id=user_id,
        entity_type="weight_entry",
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={"weight_kg": 82.5},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )


async def test_create_operation_assigns_server_seq(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "op1@example.com")

    op = _make_op(user.id)
    db_session.add(op)
    await db_session.flush()
    await db_session.refresh(op)

    assert op.server_seq is not None
    assert op.server_ts is not None
    assert op.op_type == OpType.CREATE


async def test_server_seq_is_monotonically_increasing(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "op2@example.com")

    ops = []
    for _ in range(3):
        op = _make_op(user.id)
        db_session.add(op)
        await db_session.flush()
        await db_session.refresh(op)
        ops.append(op)

    seqs = [op.server_seq for op in ops]
    assert seqs == sorted(seqs)
    assert len(set(seqs)) == 3


async def test_client_op_id_can_repeat_across_users(db_session: AsyncSession) -> None:
    user_a = await _make_user(db_session, "op3a@example.com")
    user_b = await _make_user(db_session, "op3b@example.com")
    shared_client_op_id = uuid.uuid4()

    db_session.add(_make_op(user_a.id, shared_client_op_id))
    db_session.add(_make_op(user_b.id, shared_client_op_id))
    await db_session.flush()


async def test_client_op_id_must_be_unique_per_user(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "op4@example.com")
    shared_client_op_id = uuid.uuid4()

    db_session.add(_make_op(user.id, shared_client_op_id))
    await db_session.flush()

    db_session.add(_make_op(user.id, shared_client_op_id))
    with pytest.raises(IntegrityError):
        await db_session.flush()
