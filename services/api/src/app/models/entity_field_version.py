import uuid
from datetime import datetime

from sqlalchemy import BigInteger, DateTime, ForeignKey, PrimaryKeyConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class EntityFieldVersion(Base):
    """Tracks, per (entity_id, field_name), which op most recently won that
    field under last-write-wins — see docs/sync-protocol.md. This is
    materializer bookkeeping, not something feature code reads directly."""

    __tablename__ = "entity_field_versions"
    __table_args__ = (PrimaryKeyConstraint("entity_id", "field_name"),)

    entity_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    field_name: Mapped[str] = mapped_column()

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False
    )
    client_ts: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    server_seq: Mapped[int] = mapped_column(BigInteger, nullable=False)
