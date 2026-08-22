import base64
import io
from datetime import UTC, datetime

import pyotp
import qrcode


def generate_totp_secret() -> str:
    return pyotp.random_base32()


def build_provisioning_uri(secret: str, account_email: str, issuer: str) -> str:
    return pyotp.TOTP(secret).provisioning_uri(name=account_email, issuer_name=issuer)


def build_qr_code_png_base64(provisioning_uri: str) -> str:
    image = qrcode.make(provisioning_uri)
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode("ascii")


def verify_totp_code(secret: str, code: str) -> bool:
    return pyotp.TOTP(secret).verify(code)


def totp_current_step(secret: str) -> int:
    """The current 30s time-step index, used to detect replay of a code
    that was already accepted within its own validity window."""
    return int(pyotp.TOTP(secret).timecode(datetime.now(UTC)))
