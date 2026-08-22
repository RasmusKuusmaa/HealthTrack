import pytest
from fastapi import Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AuditLog, User
from app.services.audit import AuditEventType, record_audit_event

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash="hashed")
    db_session.add(user)
    await db_session.flush()
    return user


def _fake_request(
    ip: str = "203.0.113.5", user_agent: str = "pytest-client"
) -> Request:
    scope = {
        "type": "http",
        "client": (ip, 12345),
        "headers": [(b"user-agent", user_agent.encode())],
    }
    return Request(scope)


async def test_records_event_with_request_metadata(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "audit1@example.com")

    await record_audit_event(
        db_session,
        AuditEventType.LOGIN_SUCCEEDED,
        user_id=user.id,
        request=_fake_request(),
        metadata={"device_id": "abc-123"},
    )

    result = await db_session.execute(
        select(AuditLog).where(AuditLog.user_id == user.id)
    )
    entry = result.scalar_one()
    assert entry.event_type == "login.succeeded"
    assert entry.ip_address == "203.0.113.5"
    assert entry.user_agent == "pytest-client"
    assert entry.event_metadata == {"device_id": "abc-123"}


async def test_records_event_without_user_or_request(
    db_session: AsyncSession,
) -> None:
    await record_audit_event(db_session, AuditEventType.LOGIN_FAILED)

    result = await db_session.execute(
        select(AuditLog).where(AuditLog.event_type == "login.failed")
    )
    entry = result.scalar_one()
    assert entry.user_id is None
    assert entry.ip_address is None
    assert entry.user_agent is None
