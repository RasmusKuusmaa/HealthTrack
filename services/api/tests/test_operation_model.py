import uuid
from datetime import UTC, datetime

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def test_create_operation_assigns_server_seq(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "op1@example.com")
    entity_id = uuid.uuid4()

    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user.id,
        entity_type="weight_entry",
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={"weight_kg": 82.5},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
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
    entity_id = uuid.uuid4()
    device_id = uuid.uuid4()

    ops = []
    for i in range(3):
        op = Operation(
            client_op_id=uuid.uuid4(),
            user_id=user.id,
            entity_type="weight_entry",
            entity_id=entity_id,
            op_type=OpType.UPDATE,
            payload={"weight_kg": 80 + i},
            device_id=device_id,
            client_ts=datetime.now(UTC),
        )
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

    op_a = Operation(
        client_op_id=shared_client_op_id,
        user_id=user_a.id,
        entity_type="weight_entry",
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    op_b = Operation(
        client_op_id=shared_client_op_id,
        user_id=user_b.id,
        entity_type="weight_entry",
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    db_session.add(op_a)
    db_session.add(op_b)
    await db_session.flush()
