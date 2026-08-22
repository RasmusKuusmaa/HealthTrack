import uuid
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.models import OpType
from app.schemas.entities import (
    EntityHistoryEntry,
    EntityHistoryResponse,
    RevertRequest,
)
from app.schemas.sync import PushOpResult
from app.security.dependencies import get_current_user_id
from app.services.entity_history import (
    NothingToRevertError,
    RevertTargetNotFoundError,
    compute_field_state_as_of,
    get_entity_history,
)
from app.services.sync_ingestion import ingest_op
from app.sync.materializer import materialize_op
from app.sync.registry import is_registered

router = APIRouter(prefix="/entities", tags=["entities"])


@router.get("/{entity_type}/{entity_id}/history", response_model=EntityHistoryResponse)
async def entity_history(
    entity_type: str,
    entity_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(get_current_user_id),
) -> EntityHistoryResponse:
    if not is_registered(entity_type):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unknown entity type {entity_type!r}.",
        )

    ops = await get_entity_history(db, user_id, entity_type, entity_id)
    return EntityHistoryResponse(
        history=[EntityHistoryEntry.model_validate(op) for op in ops]
    )


@router.post("/{entity_type}/{entity_id}/revert", response_model=PushOpResult)
async def revert_entity(
    entity_type: str,
    entity_id: uuid.UUID,
    payload: RevertRequest,
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(get_current_user_id),
) -> PushOpResult:
    """Restore an entity's fields to their state as of a prior point in its
    history. This does not rewrite history — it emits a brand new UPDATE
    op (through the normal push pipeline) setting the current fields back
    to those prior values, and shows up as its own entry in future history
    queries. See docs/sync-protocol.md."""
    if not is_registered(entity_type):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Unknown entity type {entity_type!r}.",
        )

    try:
        restored_fields = await compute_field_state_as_of(
            db, user_id, entity_type, entity_id, payload.target_server_seq
        )
    except (RevertTargetNotFoundError, NothingToRevertError) as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc

    op, _ = await ingest_op(
        db,
        user_id=user_id,
        client_op_id=uuid.uuid4(),
        entity_type=entity_type,
        entity_id=entity_id,
        op_type=OpType.UPDATE,
        payload=restored_fields,
        device_id=payload.device_id,
        client_ts=datetime.now(UTC),
    )
    await materialize_op(db, op)

    return PushOpResult(client_op_id=op.client_op_id, server_seq=op.server_seq)
