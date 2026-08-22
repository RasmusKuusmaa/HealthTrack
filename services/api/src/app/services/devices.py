import uuid
from datetime import UTC, datetime

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import Device, DevicePlatform, RefreshToken


async def register_device(
    db: AsyncSession,
    user_id: uuid.UUID,
    device_id: uuid.UUID,
    name: str,
    platform: DevicePlatform,
) -> Device:
    """Upsert the device row touched by a login: create it on first sight,
    otherwise just refresh its name/platform/last_seen_at."""
    device = await db.get(Device, device_id)
    now = datetime.now(UTC)

    if device is None:
        device = Device(
            id=device_id,
            user_id=user_id,
            name=name,
            platform=platform,
            last_seen_at=now,
        )
        db.add(device)
    else:
        device.user_id = user_id
        device.name = name
        device.platform = platform
        device.last_seen_at = now

    await db.flush()
    return device


async def list_active_devices(db: AsyncSession, user_id: uuid.UUID) -> list[Device]:
    """Devices with at least one still-valid (non-revoked, unexpired)
    refresh token — i.e. devices that could use a session right now."""
    result = await db.execute(
        select(Device)
        .join(RefreshToken, RefreshToken.device_id == Device.id)
        .where(
            Device.user_id == user_id,
            RefreshToken.revoked_at.is_(None),
            RefreshToken.expires_at > datetime.now(UTC),
        )
        .distinct()
        .order_by(Device.last_seen_at.desc())
    )
    return list(result.scalars().all())
