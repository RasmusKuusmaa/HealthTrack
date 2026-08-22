import uuid

import pytest

from app.models import OpType
from app.sync.registry import get_entity_schema, is_registered, register_entity_type
from app.sync.validation import OpValidationError, validate_op_payload
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema


def _register_example_entity() -> str:
    entity_type = f"example_entity_{uuid.uuid4().hex}"
    register_entity_type(entity_type, SyncExampleItemSchema, SyncExampleItem)
    return entity_type


def test_register_and_lookup_entity_type() -> None:
    entity_type = _register_example_entity()

    assert is_registered(entity_type) is True
    assert get_entity_schema(entity_type) is SyncExampleItemSchema


def test_register_rejects_duplicate_entity_type() -> None:
    entity_type = _register_example_entity()

    with pytest.raises(ValueError, match="already registered"):
        register_entity_type(entity_type, SyncExampleItemSchema, SyncExampleItem)


def test_unregistered_entity_type_is_not_registered() -> None:
    assert is_registered(f"never-registered-{uuid.uuid4().hex}") is False
    assert get_entity_schema(f"never-registered-{uuid.uuid4().hex}") is None


def test_validate_accepts_partial_payload() -> None:
    entity_type = _register_example_entity()

    validate_op_payload(entity_type, OpType.UPDATE, {"weight_kg": 82.5})
    validate_op_payload(entity_type, OpType.UPDATE, {"note": "after breakfast"})
    validate_op_payload(entity_type, OpType.CREATE, {})


def test_validate_rejects_unknown_field() -> None:
    entity_type = _register_example_entity()

    with pytest.raises(OpValidationError):
        validate_op_payload(entity_type, OpType.UPDATE, {"not_a_real_field": 1})


def test_validate_rejects_wrong_type() -> None:
    entity_type = _register_example_entity()

    with pytest.raises(OpValidationError):
        validate_op_payload(entity_type, OpType.UPDATE, {"weight_kg": "not-a-number"})


def test_validate_rejects_unknown_entity_type() -> None:
    with pytest.raises(OpValidationError, match="Unknown entity_type"):
        validate_op_payload(
            f"never-registered-{uuid.uuid4().hex}", OpType.UPDATE, {}
        )


def test_validate_rejects_oversized_payload() -> None:
    entity_type = _register_example_entity()

    with pytest.raises(OpValidationError, match="exceeds"):
        validate_op_payload(
            entity_type, OpType.UPDATE, {"note": "x" * (17 * 1024)}
        )


def test_validate_skips_schema_check_for_delete() -> None:
    entity_type = _register_example_entity()

    # A delete payload with fields that don't match the schema at all is
    # still fine — deletes aren't validated against the entity schema.
    validate_op_payload(entity_type, OpType.DELETE, {"reason": "user requested"})
