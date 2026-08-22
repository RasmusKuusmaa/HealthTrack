import uuid
from datetime import datetime

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType
from app.sync.validation import validate_op_payload


async def _find_existing(
    db: AsyncSession, user_id: uuid.UUID, client_op_id: uuid.UUID
) -> Operation | None:
    result = await db.execute(
        select(Operation).where(
            Operation.user_id == user_id, Operation.client_op_id == client_op_id
        )
    )
    return result.scalar_one_or_none()


async def ingest_op(
    db: AsyncSession,
    *,
    user_id: uuid.UUID,
    client_op_id: uuid.UUID,
    entity_type: str,
    entity_id: uuid.UUID,
    op_type: OpType,
    payload: dict[str, object],
    device_id: uuid.UUID,
    client_ts: datetime,
) -> Operation:
    """Append one op to the log. Idempotent: replaying a `client_op_id`
    already seen for this user returns the original row (same `server_seq`)
    without inserting a duplicate or touching any projection table — this
    only appends to the log, it does not materialize (see 3.6).

    Raises OpValidationError (from validate_op_payload) before ever
    touching the database if the payload is invalid.
    """
    validate_op_payload(entity_type, op_type, payload)

    existing = await _find_existing(db, user_id, client_op_id)
    if existing is not None:
        return existing

    op = Operation(
        client_op_id=client_op_id,
        user_id=user_id,
        entity_type=entity_type,
        entity_id=entity_id,
        op_type=op_type,
        payload=payload,
        device_id=device_id,
        client_ts=client_ts,
    )
    db.add(op)
    try:
        await db.flush()
    except IntegrityError:
        # Lost a race: another concurrent push inserted the same
        # (user_id, client_op_id) between our check and our insert.
        existing = await _find_existing(db, user_id, client_op_id)
        if existing is None:
            raise  # some other integrity error — don't swallow it
        return existing

    return op
