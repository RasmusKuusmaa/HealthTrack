import enum
import uuid
from datetime import date, datetime

from sqlalchemy import Date, DateTime, Enum, ForeignKey, Index, Numeric, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class WeightEntrySource(str, enum.Enum):
    MANUAL = "manual"


class WeightEntry(Base):
    __tablename__ = "weight_entries"
    __table_args__ = (
        # Every daily-aggregation query filters by user_id and groups by
        # local_date — see docs/data-model.md.
        Index("ix_weight_entries_user_id_local_date", "user_id", "local_date"),
    )

    # Client-generated on create, per the sync protocol — no server default.
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    logged_at_utc: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    # Computed on-device from logged_at_utc and the device's local timezone
    # at entry time — never derived from UTC server-side. See
    # docs/architecture.md's offline-first invariants.
    local_date: Mapped[date] = mapped_column(Date, nullable=False)
    tz_offset_minutes: Mapped[int] = mapped_column(nullable=False)
    # Canonical storage is always kg; unit conversion is a UI concern only.
    weight_kg: Mapped[float] = mapped_column(Numeric(5, 2), nullable=False)
    source: Mapped[WeightEntrySource] = mapped_column(
        Enum(
            WeightEntrySource,
            name="weight_entry_source",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=False,
        server_default=WeightEntrySource.MANUAL.value,
    )
    note: Mapped[str | None] = mapped_column(nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
    # Tombstone for the sync entity registry — never hard-deleted.
    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
