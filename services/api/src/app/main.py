from fastapi import FastAPI

from app.config import get_settings
from app.logging_config import configure_logging
from app.middleware.correlation import CorrelationIdMiddleware
from app.routers import health


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging()
    app = FastAPI(title=settings.app_name)
    app.add_middleware(CorrelationIdMiddleware)
    app.include_router(health.router)
    return app


app = create_app()
