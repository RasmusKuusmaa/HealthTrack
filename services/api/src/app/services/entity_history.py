import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation


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
