import enum
import uuid
from typing import Any

from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import AuditLog


class AuditEventType(str, enum.Enum):
    USER_REGISTERED = "user.registered"
    EMAIL_VERIFIED = "email.verified"
    LOGIN_SUCCEEDED = "login.succeeded"
    LOGIN_FAILED = "login.failed"
    LOGIN_LOCKED_OUT = "login.locked_out"
    LOGOUT = "logout"
    LOGOUT_ALL = "logout.all"
    REFRESH_TOKEN_REUSE_DETECTED = "refresh_token.reuse_detected"
    PASSWORD_RESET_REQUESTED = "password_reset.requested"
    PASSWORD_RESET_CONFIRMED = "password_reset.confirmed"
    MFA_ENROLLED = "mfa.enrolled"
    MFA_CONFIRMED = "mfa.confirmed"
    MFA_RECOVERY_CODE_USED = "mfa.recovery_code_used"


def _client_ip(request: Request | None) -> str | None:
    if request is None or request.client is None:
        return None
    return request.client.host


def _user_agent(request: Request | None) -> str | None:
    if request is None:
        return None
    return request.headers.get("user-agent")


async def record_audit_event(
    db: AsyncSession,
    event_type: AuditEventType,
    *,
    user_id: uuid.UUID | None = None,
    request: Request | None = None,
    metadata: dict[str, Any] | None = None,
) -> None:
    entry = AuditLog(
        user_id=user_id,
        event_type=event_type.value,
        ip_address=_client_ip(request),
        user_agent=_user_agent(request),
        event_metadata=metadata,
    )
    db.add(entry)
    await db.flush()
