import enum
import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import BigInteger, DateTime, Enum, ForeignKey, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class OpType(str, enum.Enum):
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"


class Operation(Base):
    __tablename__ = "operations"

    # The authoritative, per-user total order — see docs/sync-protocol.md.
    server_seq: Mapped[int] = mapped_column(
        BigInteger, primary_key=True, autoincrement=True
    )

    # Idempotency key: a client retrying a push after a dropped response
    # must not double-materialize. Unique per user, not globally.
    client_op_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    entity_type: Mapped[str] = mapped_column(nullable=False)
    entity_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    op_type: Mapped[OpType] = mapped_column(
        Enum(
            OpType,
            name="op_type",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=False,
    )
    # Field-level partial payload for create/update; empty/metadata for delete.
    payload: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)

    device_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)

    # Device clock at edit time — used only for field-level LWW, never for
    # global ordering (see docs/sync-protocol.md).
    client_ts: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    server_ts: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
