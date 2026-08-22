"""Shared test-only scaffolding for exercising the sync engine (Phase 3)
before any real feature entity exists. `SyncExampleItem` is a stand-in
projection table with the same shape (`id` PK, `user_id`, `deleted_at`
tombstone) every real entity will follow starting in Phase 5. It lives only
in the test database — nothing under `app/` imports this module, so Alembic
never sees it and it is never migrated into a real environment.
"""

import uuid
from datetime import datetime

from pydantic import BaseModel, ConfigDict
from sqlalchemy import DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class SyncExampleItem(Base):
    __tablename__ = "sync_example_items"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), nullable=False)
    weight_kg: Mapped[float | None] = mapped_column(nullable=True)
    note: Mapped[str | None] = mapped_column(nullable=True)
    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )


class SyncExampleItemSchema(BaseModel):
    model_config = ConfigDict(extra="forbid")

    weight_kg: float | None = None
    note: str | None = None
