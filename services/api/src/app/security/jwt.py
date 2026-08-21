import logging
import uuid
from datetime import UTC, datetime, timedelta
from functools import lru_cache

import jwt
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

from app.config import get_settings

logger = logging.getLogger(__name__)

ALGORITHM = "RS256"
ACCESS_TOKEN_TYPE = "access"


class TokenError(Exception):
    pass


@lru_cache
def _generated_dev_keypair() -> tuple[str, str]:
    """A process-local RSA keypair used only when no key is configured via
    settings. Regenerated on every restart — never use this outside dev."""
    logger.warning(
        "No JWT_PRIVATE_KEY/JWT_PUBLIC_KEY configured; generating an "
        "ephemeral RSA keypair for this process. Tokens will not verify "
        "across restarts or other processes. Set explicit keys outside dev."
    )
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    private_pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    ).decode("utf-8")
    public_pem = (
        private_key.public_key()
        .public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo,
        )
        .decode("utf-8")
    )
    return private_pem, public_pem


def _signing_key() -> str:
    settings = get_settings()
    if settings.jwt_private_key:
        return settings.jwt_private_key
    return _generated_dev_keypair()[0]


def _verification_key() -> str:
    settings = get_settings()
    if settings.jwt_public_key:
        return settings.jwt_public_key
    return _generated_dev_keypair()[1]


def create_access_token(
    subject: str, extra_claims: dict[str, object] | None = None
) -> str:
    settings = get_settings()
    now = datetime.now(UTC)
    claims: dict[str, object] = {
        "sub": subject,
        "iss": settings.jwt_issuer,
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_access_token_ttl_minutes),
        "jti": str(uuid.uuid4()),
        "type": ACCESS_TOKEN_TYPE,
    }
    if extra_claims:
        claims.update(extra_claims)
    return jwt.encode(claims, _signing_key(), algorithm=ALGORITHM)


def decode_access_token(token: str) -> dict[str, object]:
    settings = get_settings()
    try:
        claims = jwt.decode(
            token,
            _verification_key(),
            algorithms=[ALGORITHM],
            issuer=settings.jwt_issuer,
        )
    except jwt.InvalidTokenError as exc:
        raise TokenError(str(exc)) from exc

    if claims.get("type") != ACCESS_TOKEN_TYPE:
        raise TokenError("Not an access token")
    return claims
