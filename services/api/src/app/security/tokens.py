import hashlib
import secrets


def generate_raw_token() -> str:
    """A high-entropy opaque token suitable for refresh tokens, email
    verification links, password resets, etc. Only ever store its hash."""
    return secrets.token_urlsafe(32)


def hash_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()
