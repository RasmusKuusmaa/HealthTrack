from typing import Any

from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType
from app.sync.conflict_resolution import resolve_field
from app.sync.registry import get_entity_model, get_entity_schema


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

    if op.op_type in (OpType.CREATE, OpType.UPDATE):
        # op.payload is the JSON the client sent over the wire (dates and
        # enums as plain strings) — coerce it through the entity's schema
        # so we hand the ORM real Python types, not JSON primitives.
        schema = get_entity_schema(op.entity_type)
        if schema is None:
            raise MaterializationError(
                f"No schema registered for entity_type {op.entity_type!r}."
            )
        coerced = schema.model_validate(op.payload)

    if op.op_type == OpType.CREATE:
        is_new = row is None
        if is_new:
            # Not added to the session yet: it doesn't satisfy its NOT NULL
            # columns until the payload loop below fills them in, and any
            # query one of those iterations triggers (resolve_field) would
            # otherwise autoflush this incomplete row prematurely.
            row = model_cls(id=op.entity_id, user_id=op.user_id)
        for field_name in op.payload:
            await _apply_field(db, op, row, field_name, getattr(coerced, field_name))
        if is_new:
            db.add(row)

    elif op.op_type == OpType.UPDATE:
        if row is None:
            raise MaterializationError(
                f"Cannot update {op.entity_type} {op.entity_id}: no such entity."
            )
        for field_name in op.payload:
            await _apply_field(db, op, row, field_name, getattr(coerced, field_name))

    elif op.op_type == OpType.DELETE:
        if row is None:
            raise MaterializationError(
                f"Cannot delete {op.entity_type} {op.entity_id}: no such entity."
            )
        # Use the op's own persisted server_ts, not wall-clock "now" — a
        # replay of the same op must always produce the same tombstone
        # timestamp (see docs/sync-protocol.md's replay-determinism goal).
        await _apply_field(db, op, row, "deleted_at", op.server_ts)

    await db.flush()
