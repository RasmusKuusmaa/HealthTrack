import jwt as pyjwt
import pytest

from app.config import get_settings
from app.security.jwt import TokenError, create_access_token, decode_access_token


def test_issues_and_decodes_valid_token() -> None:
    token = create_access_token(subject="user-123")
    claims = decode_access_token(token)

    assert claims["sub"] == "user-123"
    assert claims["type"] == "access"
    assert claims["iss"] == get_settings().jwt_issuer


def test_token_is_signed_with_rs256() -> None:
    token = create_access_token(subject="user-123")
    header = pyjwt.get_unverified_header(token)
    assert header["alg"] == "RS256"


def test_extra_claims_are_included() -> None:
    token = create_access_token(subject="user-123", extra_claims={"scope": "admin"})
    claims = decode_access_token(token)
    assert claims["scope"] == "admin"


def test_tampered_token_is_rejected() -> None:
    token = create_access_token(subject="user-123")
    header, payload, signature = token.split(".")
    mid = len(payload) // 2
    flipped_char = "A" if payload[mid] != "A" else "B"
    tampered_payload = payload[:mid] + flipped_char + payload[mid + 1 :]
    tampered = f"{header}.{tampered_payload}.{signature}"

    with pytest.raises(TokenError):
        decode_access_token(tampered)


def test_expired_token_is_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("JWT_ACCESS_TOKEN_TTL_MINUTES", "-1")
    get_settings.cache_clear()
    try:
        token = create_access_token(subject="user-123")
        with pytest.raises(TokenError):
            decode_access_token(token)
    finally:
        get_settings.cache_clear()


def test_rejects_token_with_wrong_issuer(monkeypatch: pytest.MonkeyPatch) -> None:
    token = create_access_token(subject="user-123")

    monkeypatch.setenv("JWT_ISSUER", "some-other-issuer")
    get_settings.cache_clear()
    try:
        with pytest.raises(TokenError):
            decode_access_token(token)
    finally:
        get_settings.cache_clear()
