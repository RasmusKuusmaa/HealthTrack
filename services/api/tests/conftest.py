from collections.abc import AsyncIterator

import httpx
import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import (
    AsyncConnection,
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)

import app.models  # noqa: F401  (registers models on Base.metadata)
from app.config import get_settings
from app.db import Base, get_db
from app.main import create_app
from app.security.password_strength import get_http_client

pytestmark = pytest.mark.asyncio


def _with_db_name(url: str, db_name: str) -> str:
    base, _, _ = url.rpartition("/")
    return f"{base}/{db_name}"


@pytest_asyncio.fixture(scope="session")
async def test_engine() -> AsyncIterator[AsyncEngine]:
    """Session-scoped engine bound to a dedicated `<db>_test` database,
    created on demand, isolated from the development database."""
    settings = get_settings()
    test_url = settings.resolved_test_database_url()
    test_db_name = test_url.rsplit("/", 1)[-1]

    maintenance_url = _with_db_name(test_url, "postgres")
    maintenance_engine = create_async_engine(
        maintenance_url, isolation_level="AUTOCOMMIT"
    )
    async with maintenance_engine.connect() as conn:
        exists = await conn.scalar(
            text("SELECT 1 FROM pg_database WHERE datname = :name"),
            {"name": test_db_name},
        )
        if not exists:
            await conn.execute(text(f'CREATE DATABASE "{test_db_name}"'))
    await maintenance_engine.dispose()

    engine = create_async_engine(test_url)
    async with engine.begin() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS citext"))
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    await engine.dispose()


@pytest_asyncio.fixture
async def db_connection(test_engine: AsyncEngine) -> AsyncIterator[AsyncConnection]:
    async with test_engine.connect() as connection:
        yield connection


@pytest_asyncio.fixture
async def db_session(db_connection: AsyncConnection) -> AsyncIterator[AsyncSession]:
    """A session bound to a single connection, wrapped in an outer transaction
    that is always rolled back — no test data ever persists."""
    outer_transaction = await db_connection.begin()
    session_factory = async_sessionmaker(
        bind=db_connection,
        join_transaction_mode="create_savepoint",
        expire_on_commit=False,
    )
    session = session_factory()
    try:
        yield session
    finally:
        await session.close()
        await outer_transaction.rollback()


def _no_breach_response(request: httpx.Request) -> httpx.Response:
    """Default fake HIBP response for the `client` fixture: reports no
    password as breached, so endpoint tests don't depend on the network."""
    return httpx.Response(200, text="")


@pytest_asyncio.fixture
async def client(db_session: AsyncSession) -> AsyncIterator[AsyncClient]:
    app = create_app()
    app.dependency_overrides[get_db] = lambda: db_session

    mock_http_client = httpx.AsyncClient(
        transport=httpx.MockTransport(_no_breach_response)
    )
    app.dependency_overrides[get_http_client] = lambda: mock_http_client

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac
    await mock_http_client.aclose()
    app.dependency_overrides.clear()
