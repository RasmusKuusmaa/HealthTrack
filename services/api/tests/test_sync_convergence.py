import uuid
from datetime import UTC, datetime, timedelta

import pytest
from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Operation, OpType, User
from app.sync.materializer import materialize_op
from app.sync.registry import register_entity_type
from tests.sync_support import SyncExampleItem, SyncExampleItemSchema

pytestmark = pytest.mark.asyncio

ENTITY_TYPE = f"convergence_example_{uuid.uuid4().hex}"
register_entity_type(ENTITY_TYPE, SyncExampleItemSchema, SyncExampleItem)

_BASE_TS = datetime(2026, 1, 1, tzinfo=UTC)
_FIELD_NAMES = ("weight_kg", "note")


def _value_for(field: str, offset: int) -> float | str:
    return float(offset) if field == "weight_kg" else f"note-{offset}"


@st.composite
def _update_specs(draw: st.DrawFn) -> list[tuple[int, str]]:
    n = draw(st.integers(min_value=1, max_value=6))
    offsets = draw(
        st.lists(
            st.integers(min_value=1, max_value=10_000),
            unique=True,
            min_size=n,
            max_size=n,
        )
    )
    fields = draw(st.lists(st.sampled_from(_FIELD_NAMES), min_size=n, max_size=n))
    return list(zip(offsets, fields, strict=True))


async def _make_user(db_session: AsyncSession) -> User:
    user = User(
        email=f"convergence-{uuid.uuid4().hex}@example.com", password_hash="hashed"
    )
    db_session.add(user)
    await db_session.flush()
    return user


async def _apply_op(
    db_session: AsyncSession,
    user_id: uuid.UUID,
    entity_id: uuid.UUID,
    op_type: OpType,
    payload: dict[str, object],
    client_ts: datetime,
) -> None:
    op = Operation(
        client_op_id=uuid.uuid4(),
        user_id=user_id,
        entity_type=ENTITY_TYPE,
        entity_id=entity_id,
        op_type=op_type,
        payload=payload,
        device_id=uuid.uuid4(),
        client_ts=client_ts,
    )
    db_session.add(op)
    await db_session.flush()
    await materialize_op(db_session, op)


async def _build_entity(
    db_session: AsyncSession,
    user_id: uuid.UUID,
    updates_in_order: list[tuple[int, str]],
) -> uuid.UUID:
    entity_id = uuid.uuid4()
    await _apply_op(
        db_session,
        user_id,
        entity_id,
        OpType.CREATE,
        {"weight_kg": 0.0, "note": "init"},
        _BASE_TS,
    )
    for offset, field in updates_in_order:
        await _apply_op(
            db_session,
            user_id,
            entity_id,
            OpType.UPDATE,
            {field: _value_for(field, offset)},
            _BASE_TS + timedelta(seconds=offset),
        )
    return entity_id


@given(specs=_update_specs(), data=st.data())
@settings(
    max_examples=25,
    deadline=None,
    suppress_health_check=[HealthCheck.function_scoped_fixture],
)
async def test_update_order_does_not_affect_final_state(
    db_session: AsyncSession,
    specs: list[tuple[int, str]],
    data: st.DataObject,
) -> None:
    """The materializer resolves conflicts by (client_ts, server_seq), never
    by application order, so replaying the same set of field updates — with
    distinct client_ts values, so no tie-break is exercised — in any order
    must converge to identical final state. See docs/sync-protocol.md."""
    shuffled = data.draw(st.permutations(specs), label="shuffled_order")

    user = await _make_user(db_session)
    entity_a = await _build_entity(db_session, user.id, specs)
    entity_b = await _build_entity(db_session, user.id, shuffled)

    row_a = await db_session.get(SyncExampleItem, entity_a)
    row_b = await db_session.get(SyncExampleItem, entity_b)
    assert row_a is not None
    assert row_b is not None

    best: dict[str, int] = {}
    for offset, field in specs:
        if field not in best or offset > best[field]:
            best[field] = offset
    expected = {"weight_kg": 0.0, "note": "init"}
    for field, offset in best.items():
        expected[field] = _value_for(field, offset)

    assert row_a.weight_kg == expected["weight_kg"]
    assert row_a.note == expected["note"]
    assert row_b.weight_kg == row_a.weight_kg
    assert row_b.note == row_a.note
