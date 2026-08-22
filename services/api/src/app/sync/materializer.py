from datetime import UTC, datetime
from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType
from app.sync.conflict_resolution import resolve_field
from app.sync.registry import get_entity_model


class MaterializationError(Exception):
    pass


async def _apply_field(
    db: AsyncSession, op: Operation, row: Any, field_name: str, value: Any
) -> None:
    if not hasattr(row, field_name):
        raise MaterializationError(
            f"{op.entity_type} has no field {field_name!r} to materialize."
        )

    if not await resolve_field(db, op, field_name):
        return  # a later write already won this field — this op loses

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
            row = model_cls(id=op.entity_id, user_id=op.user_id)
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
