import hashlib
from collections.abc import AsyncIterator

import httpx
from zxcvbn import zxcvbn

MIN_LENGTH = 12
MAX_LENGTH = 128
MIN_ZXCVBN_SCORE = 3  # 0-4 scale; 3 means "safe against offline attacks"

HIBP_RANGE_URL = "https://api.pwnedpasswords.com/range/{prefix}"


class PasswordTooWeakError(Exception):
    def __init__(self, reasons: list[str]) -> None:
        self.reasons = reasons
        super().__init__("; ".join(reasons))


def _check_length(password: str) -> str | None:
    if len(password) < MIN_LENGTH:
        return f"Password must be at least {MIN_LENGTH} characters long."
    if len(password) > MAX_LENGTH:
        return f"Password must be at most {MAX_LENGTH} characters long."
    return None


def _check_zxcvbn(password: str, user_inputs: list[str]) -> str | None:
    result = zxcvbn(password, user_inputs=user_inputs)
    if result["score"] < MIN_ZXCVBN_SCORE:
        feedback = result.get("feedback", {})
        warning = feedback.get("warning") or "Password is too easy to guess."
        return warning
    return None


async def _check_breached(password: str, client: httpx.AsyncClient) -> str | None:
    """k-anonymity check against the Have I Been Pwned Pwned Passwords range
    API: only the first 5 hex chars of the SHA-1 hash ever leave the server,
    so the full password (and its hash) are never disclosed to a third party."""
    sha1 = hashlib.sha1(password.encode("utf-8")).hexdigest().upper()
    prefix, suffix = sha1[:5], sha1[5:]

    response = await client.get(HIBP_RANGE_URL.format(prefix=prefix), timeout=5.0)
    response.raise_for_status()

    for line in response.text.splitlines():
        candidate_suffix, _, _count = line.partition(":")
        if candidate_suffix == suffix:
            return "This password has appeared in a known data breach."
    return None


async def get_http_client() -> AsyncIterator[httpx.AsyncClient]:
    """FastAPI dependency wrapping a request-scoped httpx client, so tests
    can override it (e.g. with a MockTransport) via dependency_overrides."""
    async with httpx.AsyncClient() as client:
        yield client


async def validate_password_strength(
    password: str,
    *,
    user_inputs: list[str] | None = None,
    http_client: httpx.AsyncClient | None = None,
) -> None:
    """Raises PasswordTooWeakError with all applicable reasons if the
    password fails length, zxcvbn strength, or breach-list checks."""
    reasons: list[str] = []

    if length_error := _check_length(password):
        reasons.append(length_error)

    if zxcvbn_error := _check_zxcvbn(password, user_inputs or []):
        reasons.append(zxcvbn_error)

    owns_client = http_client is None
    client = http_client or httpx.AsyncClient()
    try:
        try:
            if breach_error := await _check_breached(password, client):
                reasons.append(breach_error)
        except httpx.HTTPError:
            # The breach-list service is a defense in depth, not a gate —
            # if it's unreachable, don't block registration/login on it.
            pass
    finally:
        if owns_client:
            await client.aclose()

    if reasons:
        raise PasswordTooWeakError(reasons)
