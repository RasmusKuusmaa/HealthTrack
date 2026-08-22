import json
from typing import Any

from pydantic import ValidationError

from app.config import get_settings
from app.models import OpType
from app.sync.registry import get_entity_schema


class OpValidationError(Exception):
    pass


def validate_op_payload(
    entity_type: str, op_type: OpType, payload: dict[str, Any]
) -> None:
    """Raises OpValidationError if `payload` isn't safe to materialize:
    unknown entity type, oversized, or fields that don't match the
    registered schema for `entity_type`."""
    settings = get_settings()
    payload_size = len(json.dumps(payload).encode("utf-8"))
    if payload_size > settings.sync_max_payload_bytes:
        raise OpValidationError(
            f"Payload of {payload_size} bytes exceeds the "
            f"{settings.sync_max_payload_bytes}-byte limit."
        )

    schema = get_entity_schema(entity_type)
    if schema is None:
        raise OpValidationError(f"Unknown entity_type {entity_type!r}.")

    if op_type == OpType.DELETE:
        # Delete ops carry no entity fields to validate against the schema.
        return

    try:
        schema.model_validate(payload)
    except ValidationError as exc:
        raise OpValidationError(str(exc)) from exc
