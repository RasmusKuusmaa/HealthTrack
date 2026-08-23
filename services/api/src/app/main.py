from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.errors import register_exception_handlers
from app.logging_config import configure_logging
from app.middleware.correlation import CorrelationIdMiddleware
from app.middleware.rate_limit import RateLimitMiddleware
from app.openapi import API_DESCRIPTION, API_VERSION, SERVERS, TAGS_METADATA
from app.redis_client import get_redis
from app.routers import auth, entities, health, sync
from app.sync.entities import register_all as register_sync_entities

# Runs once per process at import time — not inside create_app(), which
# tests call repeatedly (see tests/conftest.py's `client` fixture) and
# register_entity_type() raises on a duplicate registration.
register_sync_entities()


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging()
    app = FastAPI(
        title=settings.app_name,
        version=API_VERSION,
        description=API_DESCRIPTION,
        openapi_tags=TAGS_METADATA,
        servers=SERVERS,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(
        RateLimitMiddleware,
        redis=get_redis(),
        limit=settings.rate_limit_requests,
        window_seconds=settings.rate_limit_window_seconds,
    )
    app.add_middleware(CorrelationIdMiddleware)
    register_exception_handlers(app)
    app.include_router(health.router)
    app.include_router(auth.router)
    app.include_router(sync.router)
    app.include_router(entities.router)
    return app


app = create_app()
