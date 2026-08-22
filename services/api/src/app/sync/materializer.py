from datetime import UTC, datetime
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import EntityFieldVersion, Operation, OpType
from app.sync.registry import get_entity_model


class MaterializationError(Exception):
    pass


async def _get_field_version(
    db: AsyncSession, entity_id: Any, field_name: str
) -> EntityFieldVersion | None:
    result = await db.execute(
        select(EntityFieldVersion).where(
            EntityFieldVersion.entity_id == entity_id,
            EntityFieldVersion.field_name == field_name,
        )
    )
    return result.scalar_one_or_none()


def _wins(op: Operation, current: EntityFieldVersion | None) -> bool:
    """Field-level last-write-wins: later client_ts wins; server_seq breaks
    a tie (see docs/sync-protocol.md)."""
    if current is None:
        return True
    if op.client_ts != current.client_ts:
        return op.client_ts > current.client_ts
    return op.server_seq > current.server_seq


async def _apply_field(
    db: AsyncSession, op: Operation, row: Any, field_name: str, value: Any
) -> None:
    if not hasattr(row, field_name):
        raise MaterializationError(
            f"{op.entity_type} has no field {field_name!r} to materialize."
        )

    current = await _get_field_version(db, op.entity_id, field_name)
    if not _wins(op, current):
        return  # a later write already won this field — this op loses

    if current is None:
        db.add(
            EntityFieldVersion(
                entity_id=op.entity_id,
                field_name=field_name,
                user_id=op.user_id,
                client_ts=op.client_ts,
                server_seq=op.server_seq,
            )
        )
    else:
        current.client_ts = op.client_ts
        current.server_seq = op.server_seq

    setattr(row, field_name, value)


async def materialize_op(db: AsyncSession, op: Operation) -> None:
    """Apply one op to its entity's projection table. The only code path
    allowed to write to projection tables — see docs/sync-protocol.md."""
    model_cls = get_entity_model(op.entity_type)
    if model_cls is None:
        raise MaterializationError(
            f"No projection model registered for entity_type {op.entity_type!r}."
        )

    row = await db.get(model_cls, op.entity_id)

    if op.op_type == OpType.CREATE:
        if row is None:
            row = model_cls(id=op.entity_id)
            db.add(row)
            await db.flush()
        for field_name, value in op.payload.items():
            await _apply_field(db, op, row, field_name, value)

    elif op.op_type == OpType.UPDATE:
        if row is None:
            raise MaterializationError(
                f"Cannot update {op.entity_type} {op.entity_id}: no such entity."
            )
        for field_name, value in op.payload.items():
            await _apply_field(db, op, row, field_name, value)

    elif op.op_type == OpType.DELETE:
        if row is None:
            raise MaterializationError(
                f"Cannot delete {op.entity_type} {op.entity_id}: no such entity."
            )
        await _apply_field(db, op, row, "deleted_at", datetime.now(UTC))

    await db.flush()
