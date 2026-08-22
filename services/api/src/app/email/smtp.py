from email.message import EmailMessage as MimeEmailMessage

import aiosmtplib

from app.config import Settings
from app.email.base import EmailMessage


class SmtpEmailSender:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def send(self, message: EmailMessage) -> None:
        mime_message = MimeEmailMessage()
        mime_message["From"] = self._settings.email_from_address
        mime_message["To"] = message.to
        mime_message["Subject"] = message.subject
        mime_message.set_content(message.body)

        await aiosmtplib.send(
            mime_message,
            hostname=self._settings.smtp_host,
            port=self._settings.smtp_port,
            username=self._settings.smtp_username,
            password=self._settings.smtp_password,
            start_tls=self._settings.smtp_use_tls,
        )
