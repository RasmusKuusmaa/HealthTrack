import logging

from app.email.base import EmailMessage

logger = logging.getLogger(__name__)


class ConsoleEmailSender:
    """Logs the email instead of sending it. Default backend for
    development and tests, where no real mail server is available."""

    async def send(self, message: EmailMessage) -> None:
        logger.info(
            "Email (console backend) to=%s subject=%r\n%s",
            message.to,
            message.subject,
            message.body,
        )
