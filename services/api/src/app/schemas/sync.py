import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field

from app.config import get_settings
from app.models import OpType


class PushOpRequest(BaseModel):
    client_op_id: uuid.UUID
    entity_type: str
    entity_id: uuid.UUID
    op_type: OpType
    payload: dict[str, Any]
    device_id: uuid.UUID
    client_ts: datetime


class PushRequest(BaseModel):
    ops: list[PushOpRequest] = Field(
        min_length=1, max_length=get_settings().sync_max_push_batch_size
    )


class PushOpResult(BaseModel):
    client_op_id: uuid.UUID
    server_seq: int


class PushResponse(BaseModel):
    results: list[PushOpResult]


class PulledOp(BaseModel):
    server_seq: int
    client_op_id: uuid.UUID
    entity_type: str
    entity_id: uuid.UUID
    op_type: OpType
    payload: dict[str, Any]
    device_id: uuid.UUID
    client_ts: datetime

    model_config = {"from_attributes": True}


class PullResponse(BaseModel):
    ops: list[PulledOp]
    next_cursor: int
