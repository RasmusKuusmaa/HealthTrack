import uuid

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession


def _lock_key(user_id: uuid.UUID) -> int:
    """A stable signed 64-bit key for Postgres advisory locks, derived from
    the user's UUID. A hash collision between two different users would
    only cause unnecessary serialization between them, never incorrect
    materialization — advisory locks are purely a mutual-exclusion aid."""
    return int.from_bytes(user_id.bytes[:8], byteorder="big", signed=True)


async def acquire_user_sync_lock(db: AsyncSession, user_id: uuid.UUID) -> None:
    """Transaction-scoped advisory lock serializing concurrent /sync/push
    materialization for one user (e.g. two devices pushing at once), so two
    batches can't interleave their writes. Held for the rest of the current
    transaction and released automatically on commit or rollback — never
    needs an explicit unlock. Different users never contend with each other.
    """
    await db.execute(
        text("SELECT pg_advisory_xact_lock(:key)"), {"key": _lock_key(user_id)}
    )
