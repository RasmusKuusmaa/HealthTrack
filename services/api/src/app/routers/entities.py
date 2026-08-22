import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_db
from app.schemas.entities import EntityHistoryEntry, EntityHistoryResponse
from app.security.dependencies import get_current_user_id
from app.services.entity_history import get_entity_history
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
