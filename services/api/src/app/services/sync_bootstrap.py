import uuid
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation
from app.sync.registry import get_entity_model, get_entity_schema, list_entity_types
from app.sync.tombstones import live_rows


def _row_to_dict(row: Any, entity_type: str) -> dict[str, Any]:
    schema = get_entity_schema(entity_type)
    assert schema is not None  # entity_type came from the registry itself
    data = schema.model_validate(row, from_attributes=True).model_dump(mode="json")
    data["id"] = str(row.id)
    return data


async def build_bootstrap_snapshot(
    db: AsyncSession, user_id: uuid.UUID
) -> tuple[dict[str, list[dict[str, Any]]], int]:
    """The current materialized state of every entity the user owns, plus
    the server_seq cursor to resume incremental GET /sync/pull from —
    see docs/sync-protocol.md."""
    entities: dict[str, list[dict[str, Any]]] = {}
    for entity_type in list_entity_types():
        model_cls = get_entity_model(entity_type)
        assert model_cls is not None
        stmt = live_rows(model_cls).where(model_cls.user_id == user_id)
        rows = (await db.execute(stmt)).scalars().all()
        entities[entity_type] = [_row_to_dict(row, entity_type) for row in rows]

    cursor_result = await db.execute(
        select(func.max(Operation.server_seq)).where(Operation.user_id == user_id)
    )
    cursor = cursor_result.scalar_one() or 0

    return entities, cursor
