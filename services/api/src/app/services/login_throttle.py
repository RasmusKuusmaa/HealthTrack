from redis.asyncio import Redis

from app.config import get_settings


def _failures_key(email: str) -> str:
    return f"login:failures:{email.lower()}"


def _locked_key(email: str) -> str:
    return f"login:locked:{email.lower()}"


async def is_locked_out(redis: Redis, email: str) -> bool:
    return bool(await redis.exists(_locked_key(email)))


async def record_failure(redis: Redis, email: str) -> None:
    """Count a failed attempt and, once past the threshold, lock the
    identifier out for an exponentially growing backoff window."""
    settings = get_settings()
    failures_key = _failures_key(email)

    async with redis.pipeline(transaction=True) as pipe:
        pipe.incr(failures_key)
        pipe.expire(failures_key, settings.login_failure_window_seconds, nx=True)
        failures, _ = await pipe.execute()

    if failures >= settings.login_max_attempts:
        backoff_seconds = min(
            settings.login_lockout_max_seconds,
            settings.login_lockout_base_seconds
            * 2 ** (failures - settings.login_max_attempts),
        )
        await redis.set(_locked_key(email), "1", ex=backoff_seconds)


async def clear_failures(redis: Redis, email: str) -> None:
    await redis.delete(_failures_key(email), _locked_key(email))
