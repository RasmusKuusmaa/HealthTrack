import enum
import uuid
from datetime import date, datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Numeric, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column

from app.db import Base


class SexAtBirth(str, enum.Enum):
    FEMALE = "female"
    MALE = "male"
    INTERSEX = "intersex"
    PREFER_NOT_TO_SAY = "prefer_not_to_say"


class UnitSystem(str, enum.Enum):
    METRIC = "metric"
    IMPERIAL = "imperial"


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )

    display_name: Mapped[str] = mapped_column(nullable=False)
    birth_date: Mapped[date | None] = mapped_column(nullable=True)
    sex_at_birth: Mapped[SexAtBirth | None] = mapped_column(
        Enum(
            SexAtBirth,
            name="sex_at_birth",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=True,
    )
    height_cm: Mapped[float | None] = mapped_column(Numeric(5, 1), nullable=True)
    timezone: Mapped[str] = mapped_column(nullable=False, server_default="UTC")
    locale: Mapped[str] = mapped_column(nullable=False, server_default="en")
    unit_system: Mapped[UnitSystem] = mapped_column(
        Enum(
            UnitSystem,
            name="unit_system",
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        nullable=False,
        server_default=UnitSystem.METRIC.value,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )
