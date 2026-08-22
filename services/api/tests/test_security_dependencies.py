import uuid
from datetime import UTC, datetime

import pytest
from fastapi import Depends, FastAPI
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models import User
from app.security.dependencies import get_current_user, require_verified_email
from app.security.jwt import create_access_token

pytestmark = pytest.mark.asyncio


async def _make_user(
    db_session: AsyncSession, email: str, *, verified: bool = False
) -> User:
    user = User(
        email=email,
        password_hash="hashed",
        email_verified_at=datetime.now(UTC) if verified else None,
    )
    db_session.add(user)
    await db_session.flush()
    return user


def _build_app(db_session: AsyncSession) -> FastAPI:
    app = FastAPI()
    app.dependency_overrides[get_db] = lambda: db_session

    @app.get("/whoami")
    async def whoami(user: User = Depends(get_current_user)) -> dict[str, str]:
        return {"email": str(user.email)}

    @app.get("/verified-only")
    async def verified_only(
        user: User = Depends(require_verified_email),
    ) -> dict[str, str]:
        return {"email": str(user.email)}

    return app


async def test_get_current_user_returns_the_authenticated_user(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "deps1@example.com")
    token = create_access_token(subject=str(user.id))
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get(
            "/whoami", headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 200
    assert response.json() == {"email": "deps1@example.com"}


async def test_get_current_user_rejects_missing_bearer_token(
    db_session: AsyncSession,
) -> None:
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get("/whoami")

    assert response.status_code in (401, 403)


async def test_get_current_user_rejects_token_for_deleted_user(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "deps2@example.com")
    user.deleted_at = datetime.now(UTC)
    await db_session.flush()
    token = create_access_token(subject=str(user.id))
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get(
            "/whoami", headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 401


async def test_get_current_user_rejects_token_for_nonexistent_user(
    db_session: AsyncSession,
) -> None:
    token = create_access_token(subject=str(uuid.uuid4()))
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get(
            "/whoami", headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 401


async def test_require_verified_email_allows_verified_user(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "deps3@example.com", verified=True)
    token = create_access_token(subject=str(user.id))
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get(
            "/verified-only", headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 200


async def test_require_verified_email_blocks_unverified_user(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "deps4@example.com", verified=False)
    token = create_access_token(subject=str(user.id))
    app = _build_app(db_session)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.get(
            "/verified-only", headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 403
