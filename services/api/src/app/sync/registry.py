from pydantic import BaseModel

# entity_type -> the Pydantic model describing that entity's fields. Every
# field must be optional: ops carry field-level partial payloads (see
# docs/sync-protocol.md), never a full-object replace, so a schema that
# required every field would reject perfectly valid single-field updates.
_ENTITY_SCHEMAS: dict[str, type[BaseModel]] = {}


def register_entity_type(entity_type: str, schema: type[BaseModel]) -> None:
    if entity_type in _ENTITY_SCHEMAS:
        raise ValueError(f"Entity type {entity_type!r} is already registered.")
    _ENTITY_SCHEMAS[entity_type] = schema


def get_entity_schema(entity_type: str) -> type[BaseModel] | None:
    return _ENTITY_SCHEMAS.get(entity_type)


def is_registered(entity_type: str) -> bool:
    return entity_type in _ENTITY_SCHEMAS
