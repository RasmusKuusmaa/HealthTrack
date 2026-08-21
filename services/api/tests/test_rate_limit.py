import uuid

import pytest
from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from app.middleware.rate_limit import RateLimitMiddleware
from app.redis_client import get_redis

pytestmark = pytest.mark.asyncio


def _build_rate_limited_app(limit: int) -> tuple[FastAPI, str]:
    """A fresh app with a unique path each time, so the Redis rate-limit
    key (which is keyed by path) never leaks state between tests."""
    path = f"/limited-{uuid.uuid4().hex}"
    app = FastAPI()

    @app.get(path)
    async def limited() -> dict[str, str]:
        return {"status": "ok"}

    app.add_middleware(
        RateLimitMiddleware, redis=get_redis(), limit=limit, window_seconds=60
    )
    return app, path


async def test_allows_requests_under_the_limit() -> None:
    app, path = _build_rate_limited_app(limit=2)
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        for _ in range(2):
            response = await ac.get(path)
            assert response.status_code == 200


async def test_blocks_requests_over_the_limit() -> None:
    app, path = _build_rate_limited_app(limit=2)
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        for _ in range(2):
            await ac.get(path)
        response = await ac.get(path)
        assert response.status_code == 429
        assert response.json()["title"] == "Too Many Requests"
        assert "Retry-After" in response.headers


async def test_health_endpoints_are_exempt_from_rate_limiting() -> None:
    app = FastAPI()

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    app.add_middleware(
        RateLimitMiddleware, redis=get_redis(), limit=1, window_seconds=60
    )

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        for _ in range(3):
            response = await ac.get("/health")
            assert response.status_code == 200
