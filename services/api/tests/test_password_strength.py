import hashlib

import httpx
import pytest

from app.security.password_strength import (
    PasswordTooWeakError,
    validate_password_strength,
)

pytestmark = pytest.mark.asyncio


def _clean_hibp_client() -> httpx.AsyncClient:
    """A fake HIBP client that reports no breach matches for any password."""

    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(200, text="")

    return httpx.AsyncClient(transport=httpx.MockTransport(handler))


def _breached_hibp_client(password: str) -> httpx.AsyncClient:
    """A fake HIBP client that reports the given password as breached."""
    sha1 = hashlib.sha1(password.encode("utf-8")).hexdigest().upper()
    suffix = sha1[5:]

    body = f"{suffix}:12345\nAAAA0000AAAA0000AAAA0000AAAA00:1"

    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(200, text=body)

    return httpx.AsyncClient(transport=httpx.MockTransport(handler))


def _erroring_hibp_client() -> httpx.AsyncClient:
    def handler(request: httpx.Request) -> httpx.Response:
        raise httpx.ConnectError("simulated network failure", request=request)

    return httpx.AsyncClient(transport=httpx.MockTransport(handler))


async def test_rejects_too_short_password() -> None:
    async with _clean_hibp_client() as client:
        with pytest.raises(PasswordTooWeakError) as exc_info:
            await validate_password_strength("Sh0rt!", http_client=client)
    assert any("at least" in reason for reason in exc_info.value.reasons)


async def test_rejects_common_weak_password() -> None:
    async with _clean_hibp_client() as client:
        with pytest.raises(PasswordTooWeakError):
            await validate_password_strength(
                "password123456", http_client=client
            )


async def test_accepts_strong_unbreached_password() -> None:
    async with _clean_hibp_client() as client:
        await validate_password_strength(
            "xK9$mQ2vL#pR8nZ4wT!eY6bA", http_client=client
        )


async def test_rejects_breached_password() -> None:
    strong_password = "xK9$mQ2vL#pR8nZ4wT!eY6bA"
    async with _breached_hibp_client(strong_password) as client:
        with pytest.raises(PasswordTooWeakError) as exc_info:
            await validate_password_strength(strong_password, http_client=client)
    assert any("data breach" in reason for reason in exc_info.value.reasons)


async def test_breach_service_failure_does_not_block() -> None:
    strong_password = "xK9$mQ2vL#pR8nZ4wT!eY6bA"
    async with _erroring_hibp_client() as client:
        await validate_password_strength(strong_password, http_client=client)


async def test_user_inputs_penalize_zxcvbn_score() -> None:
    async with _clean_hibp_client() as client:
        with pytest.raises(PasswordTooWeakError):
            await validate_password_strength(
                "alex1990alex1990ab",
                user_inputs=["alex", "smith", "1990"],
                http_client=client,
            )
