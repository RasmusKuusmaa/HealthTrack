import uuid
from dataclasses import dataclass
from typing import Any

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import EntityFieldVersion, Operation
from app.sync.materializer import materialize_op
from app.sync.registry import get_entity_model, get_entity_schema, list_entity_types

_MISSING = object()


@dataclass(frozen=True)
class ReplayDiff:
    entity_type: str
    entity_id: uuid.UUID
    field: str
    expected: Any
    actual: Any


def _row_dict(row: Any, entity_type: str) -> dict[str, Any]:
    schema = get_entity_schema(entity_type)
    assert schema is not None
    data = schema.model_validate(row, from_attributes=True).model_dump(mode="json")
    data["deleted_at"] = row.deleted_at.isoformat() if row.deleted_at else None
    return data


async def _capture_state(
    db: AsyncSession, entity_types: list[str], user_id: uuid.UUID | None
) -> dict[str, dict[uuid.UUID, dict[str, Any]]]:
    state: dict[str, dict[uuid.UUID, dict[str, Any]]] = {}
    for entity_type in entity_types:
        model_cls = get_entity_model(entity_type)
        assert model_cls is not None
        stmt = select(model_cls)
        if user_id is not None:
            stmt = stmt.where(model_cls.user_id == user_id)
        rows = (await db.execute(stmt)).scalars().all()
        state[entity_type] = {row.id: _row_dict(row, entity_type) for row in rows}
    return state


def _diff_states(
    expected: dict[str, dict[uuid.UUID, dict[str, Any]]],
    actual: dict[str, dict[uuid.UUID, dict[str, Any]]],
) -> list[ReplayDiff]:
    diffs: list[ReplayDiff] = []
    for entity_type, expected_rows in expected.items():
        actual_rows = actual.get(entity_type, {})
        for entity_id in set(expected_rows) | set(actual_rows):
            exp_row = expected_rows.get(entity_id)
            act_row = actual_rows.get(entity_id)
            if exp_row is None or act_row is None:
                diffs.append(
                    ReplayDiff(
                        entity_type,
                        entity_id,
                        "<row>",
                        "present" if exp_row is not None else _MISSING,
                        "present" if act_row is not None else _MISSING,
                    )
                )
                continue
            for field in set(exp_row) | set(act_row):
                expected_value = exp_row.get(field, _MISSING)
                actual_value = act_row.get(field, _MISSING)
                if expected_value != actual_value:
                    diffs.append(
                        ReplayDiff(
                            entity_type, entity_id, field, expected_value, actual_value
                        )
                    )
    return diffs


async def verify_replay(
    db: AsyncSession,
    user_id: uuid.UUID | None = None,
    entity_types: list[str] | None = None,
) -> list[ReplayDiff]:
    """Rebuild the given entities' projection state from scratch by
    replaying the operations table through the materializer, and diff the
    result against current live state. Runs inside a savepoint that is
    always rolled back — this never modifies the database, even on
    success. An empty return means the materializer reproduces exactly the
    live state from the op log alone, the core correctness guarantee in
    docs/sync-protocol.md. Pass `user_id` to scope the check to one user
    and/or `entity_types` to check only those types; omit either to cover
    everyone/everything registered.
    """
    entity_types = entity_types if entity_types is not None else list_entity_types()
    expected = await _capture_state(db, entity_types, user_id)

    nested = await db.begin_nested()
    try:
        for entity_type in entity_types:
            model_cls = get_entity_model(entity_type)
            assert model_cls is not None
            delete_rows = delete(model_cls)
            if user_id is not None:
                delete_rows = delete_rows.where(model_cls.user_id == user_id)
            await db.execute(delete_rows)

        delete_versions = delete(EntityFieldVersion)
        if user_id is not None:
            delete_versions = delete_versions.where(
                EntityFieldVersion.user_id == user_id
            )
        await db.execute(delete_versions)

        op_stmt = select(Operation).order_by(Operation.server_seq)
        if user_id is not None:
            op_stmt = op_stmt.where(Operation.user_id == user_id)
        ops = (await db.execute(op_stmt)).scalars().all()
        for op in ops:
            await materialize_op(db, op)

        actual = await _capture_state(db, entity_types, user_id)
    finally:
        await nested.rollback()

    return _diff_states(expected, actual)
