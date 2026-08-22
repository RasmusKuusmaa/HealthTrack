import logging

import pytest

from app.config import get_settings
from app.email.base import EmailMessage
from app.email.console import ConsoleEmailSender
from app.email.dependency import get_email_sender
from app.email.smtp import SmtpEmailSender


@pytest.mark.asyncio
async def test_console_sender_logs_the_message(
    caplog: pytest.LogCaptureFixture,
) -> None:
    sender = ConsoleEmailSender()
    with caplog.at_level(logging.INFO):
        await sender.send(
            EmailMessage(to="a@example.com", subject="Hi", body="body text")
        )

    assert "a@example.com" in caplog.text
    assert "Hi" in caplog.text
    assert "body text" in caplog.text


def test_factory_defaults_to_console_backend(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.delenv("EMAIL_BACKEND", raising=False)
    get_settings.cache_clear()
    get_email_sender.cache_clear()
    try:
        sender = get_email_sender()
        assert isinstance(sender, ConsoleEmailSender)
    finally:
        get_settings.cache_clear()
        get_email_sender.cache_clear()


def test_factory_returns_smtp_sender_when_configured(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setenv("EMAIL_BACKEND", "smtp")
    get_settings.cache_clear()
    get_email_sender.cache_clear()
    try:
        sender = get_email_sender()
        assert isinstance(sender, SmtpEmailSender)
    finally:
        monkeypatch.delenv("EMAIL_BACKEND", raising=False)
        get_settings.cache_clear()
        get_email_sender.cache_clear()
