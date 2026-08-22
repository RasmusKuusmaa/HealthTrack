import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType


class RevertTargetNotFoundError(Exception):
    pass


class NothingToRevertError(Exception):
    pass


async def get_entity_history(
    db: AsyncSession, user_id: uuid.UUID, entity_type: str, entity_id: uuid.UUID
) -> list[Operation]:
    """The full op timeline for one entity, in server_seq order. Scoped to
    the caller's own ops — if the entity belongs to someone else (or
    doesn't exist), this returns empty rather than a 404, so it can't be
    used to probe for another user's entity ids."""
    result = await db.execute(
        select(Operation)
        .where(
            Operation.user_id == user_id,
            Operation.entity_type == entity_type,
            Operation.entity_id == entity_id,
        )
        .order_by(Operation.server_seq)
    )
    return list(result.scalars().all())


async def compute_field_state_as_of(
    db: AsyncSession,
    user_id: uuid.UUID,
    entity_type: str,
    entity_id: uuid.UUID,
    target_server_seq: int,
) -> dict[str, Any]:
    """Reconstruct what each field's value was immediately after
    `target_server_seq` was applied, using the same field-level
    last-write-wins rule the materializer uses — restricted to the ops up
    to that point. Used by revert: emitting an UPDATE with this payload
    restores exactly this historical state (see docs/sync-protocol.md).
    """
    history = await get_entity_history(db, user_id, entity_type, entity_id)
    relevant = [op for op in history if op.server_seq <= target_server_seq]

    if not any(op.server_seq == target_server_seq for op in relevant):
        raise RevertTargetNotFoundError(
            f"server_seq {target_server_seq} is not part of this entity's history."
        )

    winners: dict[str, tuple[datetime, int, Any]] = {}
    for op in relevant:
        if op.op_type == OpType.DELETE:
            continue  # deletion tombstones, not a restorable schema field
        for field_name, value in op.payload.items():
            current = winners.get(field_name)
            if current is None or (op.client_ts, op.server_seq) > current[:2]:
                winners[field_name] = (op.client_ts, op.server_seq, value)

    if not winners:
        raise NothingToRevertError(
            "No field values existed at that point in this entity's history."
        )

    return {field_name: value for field_name, (_, _, value) in winners.items()}
