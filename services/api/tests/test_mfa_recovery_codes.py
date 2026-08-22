import pytest
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import MfaRecoveryCode, User
from app.security.passwords import hash_password
from app.services.mfa import (
    RecoveryCodeInvalidError,
    consume_recovery_code,
    generate_recovery_codes,
)

pytestmark = pytest.mark.asyncio


async def _make_user(db_session: AsyncSession, email: str) -> User:
    user = User(email=email, password_hash=hash_password("irrelevant"))
    db_session.add(user)
    await db_session.flush()
    return user


async def test_generate_creates_ten_unique_codes(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "recovery1@example.com")

    codes = await generate_recovery_codes(db_session, user)

    assert len(codes) == 10
    assert len(set(codes)) == 10

    result = await db_session.execute(
        select(MfaRecoveryCode).where(MfaRecoveryCode.user_id == user.id)
    )
    stored = result.scalars().all()
    assert len(stored) == 10
    assert all(row.used_at is None for row in stored)
    # Only hashes are stored — never the raw code text.
    assert all(row.code_hash not in codes for row in stored)


async def test_consume_marks_code_used(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "recovery2@example.com")
    codes = await generate_recovery_codes(db_session, user)

    await consume_recovery_code(db_session, user, codes[0])

    result = await db_session.execute(
        select(MfaRecoveryCode).where(MfaRecoveryCode.user_id == user.id)
    )
    stored = result.scalars().all()
    used = [row for row in stored if row.used_at is not None]
    assert len(used) == 1


async def test_consume_rejects_reuse(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "recovery3@example.com")
    codes = await generate_recovery_codes(db_session, user)

    await consume_recovery_code(db_session, user, codes[0])

    with pytest.raises(RecoveryCodeInvalidError):
        await consume_recovery_code(db_session, user, codes[0])


async def test_consume_rejects_unknown_code(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "recovery4@example.com")
    await generate_recovery_codes(db_session, user)

    with pytest.raises(RecoveryCodeInvalidError):
        await consume_recovery_code(db_session, user, "not-a-real-code")


async def test_consume_is_case_and_whitespace_insensitive(
    db_session: AsyncSession,
) -> None:
    user = await _make_user(db_session, "recovery5@example.com")
    codes = await generate_recovery_codes(db_session, user)

    await consume_recovery_code(db_session, user, f"  {codes[0].upper()}  ")


async def test_regenerating_invalidates_old_codes(db_session: AsyncSession) -> None:
    user = await _make_user(db_session, "recovery6@example.com")
    old_codes = await generate_recovery_codes(db_session, user)

    await generate_recovery_codes(db_session, user)

    with pytest.raises(RecoveryCodeInvalidError):
        await consume_recovery_code(db_session, user, old_codes[0])
