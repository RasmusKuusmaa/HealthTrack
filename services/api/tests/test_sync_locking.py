import uuid

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.sync.locking import _lock_key, acquire_user_sync_lock


def test_lock_key_fits_postgres_bigint_range() -> None:
    # bigint is a signed 64-bit int: [-2^63, 2^63 - 1].
    edge_case_uuids = [
        uuid.UUID(int=0),
        uuid.UUID(int=(1 << 128) - 1),  # all bits set
        uuid.uuid4(),
        uuid.uuid4(),
    ]
    for candidate in edge_case_uuids:
        key = _lock_key(candidate)
        assert -(2**63) <= key <= 2**63 - 1


def test_lock_key_is_stable_for_the_same_uuid() -> None:
    user_id = uuid.uuid4()
    assert _lock_key(user_id) == _lock_key(user_id)


def test_lock_key_differs_across_users() -> None:
    assert _lock_key(uuid.uuid4()) != _lock_key(uuid.uuid4())


@pytest.mark.asyncio
async def test_acquire_lock_succeeds_against_real_database(
    db_session: AsyncSession,
) -> None:
    await acquire_user_sync_lock(db_session, uuid.uuid4())


@pytest.mark.asyncio
async def test_acquire_lock_is_reentrant_within_same_transaction(
    db_session: AsyncSession,
) -> None:
    user_id = uuid.uuid4()
    # A session re-acquiring its own advisory lock must not deadlock itself.
    await acquire_user_sync_lock(db_session, user_id)
    await acquire_user_sync_lock(db_session, user_id)


@pytest.mark.asyncio
async def test_acquire_lock_for_different_users_does_not_error(
    db_session: AsyncSession,
) -> None:
    await acquire_user_sync_lock(db_session, uuid.uuid4())
    await acquire_user_sync_lock(db_session, uuid.uuid4())
