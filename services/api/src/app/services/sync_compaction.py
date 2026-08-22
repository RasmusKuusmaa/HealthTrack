import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, SyncSnapshot
from app.services.sync_bootstrap import build_bootstrap_snapshot


async def compact_user(db: AsyncSession, user_id: uuid.UUID) -> SyncSnapshot:
    """Write a fresh compaction checkpoint for one user: the current
    materialized state of every entity they own, as of the current max
    server_seq. Overwrites any prior checkpoint — this is a cache, not
    history; the operations table is untouched either way."""
    entities, cursor = await build_bootstrap_snapshot(db, user_id)

    snapshot = await db.get(SyncSnapshot, user_id)
    if snapshot is None:
        snapshot = SyncSnapshot(user_id=user_id, server_seq=cursor, entities=entities)
        db.add(snapshot)
    else:
        snapshot.server_seq = cursor
        snapshot.entities = entities

    await db.flush()
    return snapshot


async def compact_all_users(db: AsyncSession) -> int:
    """The scheduled compaction job's entry point: refresh the checkpoint
    for every user who has written at least one op. Returns how many users
    were compacted."""
    result = await db.execute(select(Operation.user_id).distinct())
    user_ids = result.scalars().all()

    for user_id in user_ids:
        await compact_user(db, user_id)

    return len(user_ids)
