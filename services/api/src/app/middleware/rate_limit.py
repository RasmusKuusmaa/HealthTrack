from collections.abc import Awaitable, Callable

from fastapi import Request, Response
from fastapi.responses import JSONResponse
from redis.asyncio import Redis
from starlette.middleware.base import BaseHTTPMiddleware

EXEMPT_PATHS = {"/health", "/health/db"}


def _identity(request: Request) -> str:
    """Rate-limit key: the authenticated user if one is set on request.state
    by auth middleware (Phase 2), otherwise the client IP."""
    user_id = getattr(request.state, "user_id", None)
    if user_id:
        return f"user:{user_id}"
    client_host = request.client.host if request.client else "unknown"
    return f"ip:{client_host}"


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(
        self,
        app: object,
        redis: Redis,
        limit: int,
        window_seconds: int,
    ) -> None:
        super().__init__(app)  # type: ignore[arg-type]
        self._redis = redis
        self._limit = limit
        self._window_seconds = window_seconds

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        if request.url.path in EXEMPT_PATHS:
            return await call_next(request)

        key = f"ratelimit:{_identity(request)}:{request.url.path}"
        async with self._redis.pipeline(transaction=True) as pipe:
            pipe.incr(key)
            pipe.expire(key, self._window_seconds, nx=True)
            count, _ = await pipe.execute()

        if count > self._limit:
            return JSONResponse(
                status_code=429,
                media_type="application/problem+json",
                content={
                    "type": "about:blank",
                    "title": "Too Many Requests",
                    "status": 429,
                    "instance": str(request.url.path),
                },
                headers={"Retry-After": str(self._window_seconds)},
            )

        return await call_next(request)
