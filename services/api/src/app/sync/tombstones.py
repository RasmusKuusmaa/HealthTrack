from typing import Any

from sqlalchemy import Select, select


def live_rows(model_cls: type[Any]) -> Select[Any]:
    """A `select()` for `model_cls` pre-filtered to exclude tombstoned
    (soft-deleted) rows. Feature code should build its normal queries from
    this rather than querying the projection table directly and filtering
    `deleted_at` itself — see docs/sync-protocol.md."""
    return select(model_cls).where(model_cls.deleted_at.is_(None))


def is_deleted(row: Any) -> bool:
    return row.deleted_at is not None
