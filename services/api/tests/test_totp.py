import base64

import pyotp

from app.security.totp import (
    build_provisioning_uri,
    build_qr_code_png_base64,
    generate_totp_secret,
    verify_totp_code,
)

PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def test_generate_totp_secret_is_valid_base32() -> None:
    secret = generate_totp_secret()
    assert len(secret) >= 16
    base64.b32decode(secret)  # raises if not valid base32


def test_provisioning_uri_contains_issuer_and_account() -> None:
    uri = build_provisioning_uri("JBSWY3DPEHPK3PXP", "user@example.com", "HealthTrack")
    assert uri.startswith("otpauth://totp/")
    assert "user%40example.com" in uri or "user@example.com" in uri
    assert "HealthTrack" in uri


def test_qr_code_is_a_valid_png() -> None:
    uri = build_provisioning_uri("JBSWY3DPEHPK3PXP", "user@example.com", "HealthTrack")
    qr_base64 = build_qr_code_png_base64(uri)
    png_bytes = base64.b64decode(qr_base64)
    assert png_bytes.startswith(PNG_MAGIC)


def test_verify_totp_code_accepts_current_code() -> None:
    secret = generate_totp_secret()
    current_code = pyotp.TOTP(secret).now()
    assert verify_totp_code(secret, current_code) is True


def test_verify_totp_code_rejects_wrong_code() -> None:
    secret = generate_totp_secret()
    assert verify_totp_code(secret, "000000") is False
