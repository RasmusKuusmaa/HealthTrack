from dataclasses import dataclass
from typing import Any

from pydantic import BaseModel


@dataclass(frozen=True)
class EntityRegistration:
    # Field-level partial payload schema — see the note on _REGISTRATIONS.
    schema: type[BaseModel]
    # The SQLAlchemy declarative model backing this entity's projection
    # table. Required convention: primary key column `id` (matching an
    # op's `entity_id`), a `user_id` column (every synced entity is owned
    # by one user — this scopes bootstrap snapshots), and a nullable
    # `deleted_at` column for tombstones.
    model: type[Any]


# entity_type -> its schema + projection model. Every schema field must be
# optional: ops carry field-level partial payloads (see
# docs/sync-protocol.md), never a full-object replace, so a schema that
# required every field would reject perfectly valid single-field updates.
_REGISTRATIONS: dict[str, EntityRegistration] = {}


def register_entity_type(
    entity_type: str, schema: type[BaseModel], model: type[Any]
) -> None:
    if entity_type in _REGISTRATIONS:
        raise ValueError(f"Entity type {entity_type!r} is already registered.")

    # Soft delete is not optional (docs/sync-protocol.md: "never hard-delete
    # rows") — catch a model that can't support it at registration time,
    # not the first time a delete op for it fails to materialize.
    if not hasattr(model, "id"):
        raise ValueError(
            f"Model {model.__name__} for entity_type {entity_type!r} has no "
            "'id' primary key column matching an op's entity_id."
        )
    if not hasattr(model, "user_id"):
        raise ValueError(
            f"Model {model.__name__} for entity_type {entity_type!r} has no "
            "'user_id' column — every synced entity must be scoped to its "
            "owning user, so it can appear in that user's bootstrap snapshot."
        )
    if not hasattr(model, "deleted_at"):
        raise ValueError(
            f"Model {model.__name__} for entity_type {entity_type!r} has no "
            "'deleted_at' column — every synced entity must support "
            "tombstone-based soft delete."
        )

    _REGISTRATIONS[entity_type] = EntityRegistration(schema=schema, model=model)


def get_entity_schema(entity_type: str) -> type[BaseModel] | None:
    registration = _REGISTRATIONS.get(entity_type)
    return registration.schema if registration else None


def get_entity_model(entity_type: str) -> type[Any] | None:
    registration = _REGISTRATIONS.get(entity_type)
    return registration.model if registration else None


def is_registered(entity_type: str) -> bool:
    return entity_type in _REGISTRATIONS


def list_entity_types() -> list[str]:
    return list(_REGISTRATIONS.keys())
