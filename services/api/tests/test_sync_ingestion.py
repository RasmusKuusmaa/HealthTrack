import uuid
from datetime import UTC, datetime

import pytest
from pydantic import BaseModel, ConfigDict
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User
from app.services.sync_ingestion import ingest_op
from app.sync.registry import register_entity_type
from app.sync.validation import OpValidationError

pytestmark = pytest.mark.asyncio


class _ExampleEntitySchema(BaseModel):
    model_config = ConfigDict(extra="forbid")

    weight_kg: float | None = None


ENTITY_TYPE = f"ingestion_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, _ExampleEntitySchema)


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


async def _count_ops(db_session: AsyncSession, client_op_id: uuid.UUID) -> int:
    result = await db_session.execute(
        select(func.count()).select_from(Operation).where(
            Operation.client_op_id == client_op_id
        )
    )
    return result.scalar_one()


async def test_ingest_creates_a_new_op(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "ingest1@example.com")

    op = await ingest_op(
        db_session,
        user_id=user.id,
        client_op_id=uuid.uuid4(),
        entity_type=ENTITY_TYPE,
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={"weight_kg": 82.5},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )

    assert op.server_seq is not None


async def test_replaying_client_op_id_returns_original_seq(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "ingest2@example.com")
    client_op_id = uuid.uuid4()
    entity_id = uuid.uuid4()
    device_id = uuid.uuid4()
    client_ts = datetime.now(UTC)

    first = await ingest_op(
        db_session,
        user_id=user.id,
        client_op_id=client_op_id,
        entity_type=ENTITY_TYPE,
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={"weight_kg": 82.5},
        device_id=device_id,
        client_ts=client_ts,
    )

    second = await ingest_op(
        db_session,
        user_id=user.id,
        client_op_id=client_op_id,
        entity_type=ENTITY_TYPE,
        entity_id=entity_id,
        op_type=OpType.CREATE,
        payload={"weight_kg": 82.5},
        device_id=device_id,
        client_ts=client_ts,
    )

    assert second.server_seq == first.server_seq
    assert await _count_ops(db_session, client_op_id) == 1


async def test_different_client_op_ids_create_separate_ops(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "ingest3@example.com")

    first = await ingest_op(
        db_session,
        user_id=user.id,
        client_op_id=uuid.uuid4(),
        entity_type=ENTITY_TYPE,
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )
    second = await ingest_op(
        db_session,
        user_id=user.id,
        client_op_id=uuid.uuid4(),
        entity_type=ENTITY_TYPE,
        entity_id=uuid.uuid4(),
        op_type=OpType.CREATE,
        payload={},
        device_id=uuid.uuid4(),
        client_ts=datetime.now(UTC),
    )

    assert first.server_seq != second.server_seq


async def test_invalid_payload_is_rejected_before_insert(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "ingest4@example.com")
    client_op_id = uuid.uuid4()

    with pytest.raises(OpValidationError):
        await ingest_op(
            db_session,
            user_id=user.id,
            client_op_id=client_op_id,
            entity_type=ENTITY_TYPE,
            entity_id=uuid.uuid4(),
            op_type=OpType.CREATE,
            payload={"not_a_real_field": 1},
            device_id=uuid.uuid4(),
            client_ts=datetime.now(UTC),
        )

    assert await _count_ops(db_session, client_op_id) == 0


async def test_unknown_entity_type_is_rejected(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "ingest5@example.com")

    with pytest.raises(OpValidationError):
        await ingest_op(
            db_session,
            user_id=user.id,
            client_op_id=uuid.uuid4(),
            entity_type="never_registered_entity",
            entity_id=uuid.uuid4(),
            op_type=OpType.CREATE,
            payload={},
            device_id=uuid.uuid4(),
            client_ts=datetime.now(UTC),
        )
