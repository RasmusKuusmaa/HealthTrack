from functools import lru_cache

from app.config import get_settings
from app.email.base import EmailSender
from app.email.console import ConsoleEmailSender
from app.email.smtp import SmtpEmailSender


@lru_cache
def get_email_sender() -> EmailSender:
    settings = get_settings()
    if settings.email_backend == "smtp":
        return SmtpEmailSender(settings)
    return ConsoleEmailSender()
