"""Registers every production sync entity type. Imported once from
`app.main.create_app` so registration runs exactly once per process."""

from datetime import date

from pydantic import BaseModel, ConfigDict

from app.models import SexAtBirth, UnitSystem, UserProfile
from app.sync.registry import register_entity_type


class UserProfileSchema(BaseModel):
    model_config = ConfigDict(extra="forbid")

    display_name: str | None = None
    birth_date: date | None = None
    sex_at_birth: SexAtBirth | None = None
    height_cm: float | None = None
    timezone: str | None = None
    locale: str | None = None
    unit_system: UnitSystem | None = None


def register_all() -> None:
    register_entity_type("user_profile", UserProfileSchema, UserProfile)
