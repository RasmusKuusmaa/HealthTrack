import uuid
from datetime import UTC, datetime

import pytest
from pydantic import BaseModel
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base
from app.models import Operation, OpType, User
from app.sync.materializer import materialize_op
from app.sync.registry import register_entity_type
from app.sync.tombstones import is_deleted, live_rows
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

ENTITY_TYPE = f"tombstone_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)


class _NoDeletedAtModel(Base):
    __tablename__ = "no_deleted_at_models"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)


class _NoUserIdModel(Base):
    __tablename__ = "no_user_id_models"
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True)


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


def test_register_rejects_model_without_deleted_at() -> None:
    with pytest.raises(ValueError, match="deleted_at"):
        register_entity_type(
            f"bad_entity_{uuid.uuid4().hex}", BaseModel, _NoDeletedAtModel
        )


def test_register_rejects_model_without_user_id() -> None:
    with pytest.raises(ValueError, match="user_id"):
        register_entity_type(
            f"bad_entity_{uuid.uuid4().hex}", BaseModel, _NoUserIdModel
        )


@pytest.mark.asyncio
async def test_live_rows_excludes_tombstoned_entities(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "tombstone1@example.com")
    kept_id, deleted_id = uuid.uuid4(), uuid.uuid4()

    for entity_id in (kept_id, deleted_id):
        op = await _make_op(
            db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 1.0}
        )
        await materialize_op(db_session, op)

    delete_op = await _make_op(db_session, user.id, deleted_id, OpType.DELETE, {})
    await materialize_op(db_session, delete_op)

    result = await db_session.execute(live_rows(SyncExampleItem))
    live_ids = {row.id for row in result.scalars().all()}

    assert kept_id in live_ids
    assert deleted_id not in live_ids


@pytest.mark.asyncio
async def test_is_deleted_reflects_tombstone_state(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "tombstone2@example.com")
    entity_id = uuid.uuid4()

    create_op = await _make_op(
        db_session, user.id, entity_id, OpType.CREATE, {"weight_kg": 1.0}
    )
    await materialize_op(db_session, create_op)
    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert is_deleted(row) is False

    delete_op = await _make_op(db_session, user.id, entity_id, OpType.DELETE, {})
    await materialize_op(db_session, delete_op)
    await db_session.refresh(row)
    assert is_deleted(row) is True


@pytest.mark.asyncio
async def test_tombstoned_row_keeps_its_fields(db_session: AsyncSession) -> None:
    """Soft delete tombstones — it must never erase the row's own data."""
    user = await _make_user(db_session, "tombstone3@example.com")
    entity_id = uuid.uuid4()

    create_op = await _make_op(
        db_session,
        user.id,
        entity_id,
        OpType.CREATE,
        {"weight_kg": 82.5, "note": "keep me"},
    )
    await materialize_op(db_session, create_op)

    delete_op = await _make_op(db_session, user.id, entity_id, OpType.DELETE, {})
    await materialize_op(db_session, delete_op)

    row = await db_session.get(SyncExampleItem, entity_id)
    assert row is not None
    assert row.weight_kg == 82.5
    assert row.note == "keep me"
