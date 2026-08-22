import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db import get_db
from app.models import Operation
from app.schemas.sync import (
    PulledOp,
    PullResponse,
    PushOpResult,
    PushRequest,
    PushResponse,
)
from app.security.dependencies import get_current_user_id
from app.services.sync_ingestion import ingest_op
from app.sync.materializer import MaterializationError, materialize_op
from app.sync.validation import OpValidationError

router = APIRouter(prefix="/sync", tags=["sync"])


@router.post("/push", response_model=PushResponse)
async def push(
    payload: PushRequest,
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(get_current_user_id),
) -> PushResponse:
    """Ingest a batch of ops and materialize each new one, in the order
    the client sent them. Any invalid op fails the whole batch (the
    transaction rolls back) — see docs/sync-protocol.md."""
    results: list[PushOpResult] = []

    for op_request in payload.ops:
        try:
            op, is_new = await ingest_op(
                db,
                user_id=user_id,
                client_op_id=op_request.client_op_id,
                entity_type=op_request.entity_type,
                entity_id=op_request.entity_id,
                op_type=op_request.op_type,
                payload=op_request.payload,
                device_id=op_request.device_id,
                client_ts=op_request.client_ts,
            )
        except OpValidationError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
            ) from exc

        if is_new:
            try:
                await materialize_op(db, op)
            except MaterializationError as exc:
                raise HTTPException(
                    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(exc)
                ) from exc

        results.append(
            PushOpResult(client_op_id=op.client_op_id, server_seq=op.server_seq)
        )

    return PushResponse(results=results)


@router.get("/pull", response_model=PullResponse)
async def pull(
    since: int = Query(default=0, ge=0),
    limit: int | None = Query(default=None, gt=0),
    db: AsyncSession = Depends(get_db),
    user_id: uuid.UUID = Depends(get_current_user_id),
) -> PullResponse:
    """Ops for the caller with server_seq > `since`, in server_seq order,
    up to `limit` — page through by re-calling with each response's
    `next_cursor` until a page comes back empty. See docs/sync-protocol.md.
    """
    settings = get_settings()
    effective_limit = min(
        limit or settings.sync_pull_default_limit, settings.sync_pull_max_limit
    )

    result = await db.execute(
        select(Operation)
        .where(Operation.user_id == user_id, Operation.server_seq > since)
        .order_by(Operation.server_seq)
        .limit(effective_limit)
    )
    ops = result.scalars().all()
    next_cursor = ops[-1].server_seq if ops else since

    return PullResponse(
        ops=[PulledOp.model_validate(op) for op in ops], next_cursor=next_cursor
    )
