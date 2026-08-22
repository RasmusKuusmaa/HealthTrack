import uuid
from datetime import datetime
from typing import Any

from sqlalchemy import BigInteger, DateTime, ForeignKey, func
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class SyncSnapshot(Base):
    """A compaction checkpoint: the full materialized state of every entity
    a user owns, as of `server_seq`. Purely additive bookkeeping — never
    touches the `operations` table, which remains the full history forever.
    Used to speed up replay verification (3.16) by starting from here
    instead of server_seq 0. One row per user; each compaction run
    overwrites it with a fresher checkpoint."""

    __tablename__ = "sync_snapshots"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    server_seq: Mapped[int] = mapped_column(BigInteger, nullable=False)
    entities: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
