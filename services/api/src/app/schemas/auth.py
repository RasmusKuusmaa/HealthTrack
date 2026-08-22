import uuid
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field

from app.models import DevicePlatform


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=256)
    display_name: str = Field(min_length=1, max_length=100)


class UserPublic(BaseModel):
    id: uuid.UUID
    email: str
    display_name: str

    model_config = {"from_attributes": True}


class VerifyEmailRequest(BaseModel):
    token: str = Field(min_length=1)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=256)
    device_id: uuid.UUID
    device_name: str = Field(default="Unknown device", min_length=1, max_length=100)
    platform: DevicePlatform = DevicePlatform.WEB
    totp_code: str | None = Field(default=None, min_length=6, max_length=6)
    recovery_code: str | None = Field(default=None, min_length=1, max_length=64)


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class MfaRequiredResponse(BaseModel):
    mfa_required: Literal[True] = True


class RefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=1)
    device_id: uuid.UUID


class LogoutRequest(BaseModel):
    refresh_token: str = Field(min_length=1)


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    token: str = Field(min_length=1)
    new_password: str = Field(min_length=1, max_length=256)


class TotpEnrollResponse(BaseModel):
    provisioning_uri: str
    qr_code_png_base64: str


class TotpConfirmRequest(BaseModel):
    code: str = Field(min_length=6, max_length=6)


class TotpConfirmResponse(BaseModel):
    recovery_codes: list[str]


class DeviceOut(BaseModel):
    id: uuid.UUID
    name: str
    platform: DevicePlatform
    last_seen_at: datetime

    model_config = {"from_attributes": True}
