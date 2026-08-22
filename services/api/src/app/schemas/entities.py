import uuid
from datetime import datetime
from typing import Any

from pydantic import BaseModel

from app.models import OpType


class EntityHistoryEntry(BaseModel):
    server_seq: int
    op_type: OpType
    payload: dict[str, Any]
    device_id: uuid.UUID
    client_ts: datetime
    server_ts: datetime

    model_config = {"from_attributes": True}


class EntityHistoryResponse(BaseModel):
    history: list[EntityHistoryEntry]


class RevertRequest(BaseModel):
    # The server_seq (from a GET .../history entry) to restore field values
    # back to.
    target_server_seq: int
    device_id: uuid.UUID
