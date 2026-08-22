import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models import RefreshToken
from app.security.tokens import generate_raw_token, hash_token


class RefreshTokenInvalidError(Exception):
    pass


class RefreshTokenExpiredError(Exception):
    pass


class RefreshTokenReuseError(Exception):
    """Raised when an already-rotated (or revoked) token is presented again.
    By the time this is raised, the entire token family has been revoked."""

    def __init__(self, message: str, user_id: uuid.UUID) -> None:
        self.user_id = user_id
        super().__init__(message)


async def issue_refresh_token(
    db: AsyncSession,
    user_id: uuid.UUID,
    device_id: uuid.UUID,
    family_id: uuid.UUID | None = None,
) -> tuple[str, RefreshToken]:
    """Issue a new refresh token. Pass `family_id` when rotating an existing
    chain; omit it to start a new chain (e.g. on login)."""
    settings = get_settings()
    raw_token = generate_raw_token()
    token = RefreshToken(
        user_id=user_id,
        token_hash=hash_token(raw_token),
        device_id=device_id,
        family_id=family_id or uuid.uuid4(),
        expires_at=datetime.now(UTC) + timedelta(days=settings.refresh_token_ttl_days),
    )
    db.add(token)
    await db.flush()
    return raw_token, token


async def _revoke_family(db: AsyncSession, family_id: uuid.UUID) -> None:
    await db.execute(
        update(RefreshToken)
        .where(
            RefreshToken.family_id == family_id,
            RefreshToken.revoked_at.is_(None),
        )
        .values(revoked_at=datetime.now(UTC))
    )


async def rotate_refresh_token(
    db: AsyncSession, raw_token: str, device_id: uuid.UUID
) -> tuple[str, RefreshToken]:
    """Consume `raw_token` and issue its replacement in the same family.

    If the token has already been consumed (or revoked) before, this is
    treated as token theft/replay: the whole family is revoked and
    RefreshTokenReuseError is raised — every device sharing that chain must
    log in again.
    """
    token_hash = hash_token(raw_token)
    result = await db.execute(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    existing = result.scalar_one_or_none()
    if existing is None:
        raise RefreshTokenInvalidError("Refresh token not recognized.")

    if existing.revoked_at is not None:
        await _revoke_family(db, existing.family_id)
        await db.flush()
        raise RefreshTokenReuseError(
            "Refresh token reuse detected; the token family has been revoked.",
            user_id=existing.user_id,
        )

    if existing.expires_at < datetime.now(UTC):
        raise RefreshTokenExpiredError("Refresh token has expired.")

    existing.revoked_at = datetime.now(UTC)
    new_raw_token, new_token = await issue_refresh_token(
        db, existing.user_id, device_id, family_id=existing.family_id
    )
    await db.flush()
    return new_raw_token, new_token


async def revoke_all_user_tokens(db: AsyncSession, user_id: uuid.UUID) -> None:
    """Revoke every still-active refresh token for a user, across every
    device and family — used by logout-all / "sign out everywhere"."""
    await db.execute(
        update(RefreshToken)
        .where(
            RefreshToken.user_id == user_id,
            RefreshToken.revoked_at.is_(None),
        )
        .values(revoked_at=datetime.now(UTC))
    )
    await db.flush()


async def revoke_refresh_token(db: AsyncSession, raw_token: str) -> bool:
    """Revoke a single refresh token (logout on one device). Idempotent:
    returns False rather than raising if the token is unknown or already
    revoked, so callers can treat logout as always succeeding."""
    token_hash = hash_token(raw_token)
    result = await db.execute(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    )
    existing = result.scalar_one_or_none()
    if existing is None or existing.revoked_at is not None:
        return False

    existing.revoked_at = datetime.now(UTC)
    await db.flush()
    return True
