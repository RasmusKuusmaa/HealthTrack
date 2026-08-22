import uuid

import pytest
from redis.asyncio import Redis

from app.redis_client import get_redis
from app.services.login_throttle import clear_failures, is_locked_out, record_failure

pytestmark = pytest.mark.asyncio


@pytest.fixture
def redis() -> Redis:
    return get_redis()


def _email() -> str:
    return f"throttle-{uuid.uuid4().hex}@example.com"


async def test_not_locked_out_before_threshold(redis: Redis) -> None:
    email = _email()
    for _ in range(4):  # default threshold is 5
        await record_failure(redis, email)

    assert await is_locked_out(redis, email) is False


async def test_locked_out_at_threshold(redis: Redis) -> None:
    email = _email()
    for _ in range(5):  # default threshold is 5
        await record_failure(redis, email)

    assert await is_locked_out(redis, email) is True


async def test_clear_failures_lifts_lockout(redis: Redis) -> None:
    email = _email()
    for _ in range(5):
        await record_failure(redis, email)
    assert await is_locked_out(redis, email) is True

    await clear_failures(redis, email)

    assert await is_locked_out(redis, email) is False


async def test_lockout_is_scoped_per_identifier(redis: Redis) -> None:
    locked_email = _email()
    other_email = _email()
    for _ in range(5):
        await record_failure(redis, locked_email)

    assert await is_locked_out(redis, locked_email) is True
    assert await is_locked_out(redis, other_email) is False


async def test_email_matching_is_case_insensitive(redis: Redis) -> None:
    email = _email()
    for _ in range(5):
        await record_failure(redis, email.upper())

    assert await is_locked_out(redis, email.lower()) is True
