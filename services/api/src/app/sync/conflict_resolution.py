from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import EntityFieldVersion, Operation


async def get_field_version(
    db: AsyncSession, entity_id: Any, field_name: str
) -> EntityFieldVersion | None:
    result = await db.execute(
        select(EntityFieldVersion).where(
            EntityFieldVersion.entity_id == entity_id,
            EntityFieldVersion.field_name == field_name,
        )
    )
    return result.scalar_one_or_none()


def field_wins(op: Operation, current: EntityFieldVersion | None) -> bool:
    """Field-level last-write-wins: the op with the later `client_ts` wins;
    if `client_ts` ties, the op with the higher `server_seq` — i.e.
    whichever was actually ingested later — wins. See docs/sync-protocol.md.
    """
    if current is None:
        return True
    if op.client_ts != current.client_ts:
        return op.client_ts > current.client_ts
    return op.server_seq > current.server_seq


async def resolve_field(db: AsyncSession, op: Operation, field_name: str) -> bool:
    """Decide whether `op`'s write to `field_name` should be applied. If it
    wins, records `op` as the new last-writer for that field. Returns
    whether the caller should go ahead and apply the value — this function
    never touches the projection row itself, only the version bookkeeping.
    """
    current = await get_field_version(db, op.entity_id, field_name)
    if not field_wins(op, current):
        return False

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

    return True
