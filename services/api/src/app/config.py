from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "HealthTrack API"
    environment: str = "development"

    database_url: str = (
        "postgresql+asyncpg://healthtrack:healthtrack@localhost:5432/healthtrack"
    )
    test_database_url: str | None = None
    redis_url: str = "redis://localhost:6379/0"

    cors_origins: list[str] = ["http://localhost:3000"]

    rate_limit_requests: int = 100
    rate_limit_window_seconds: int = 60

    def resolved_test_database_url(self) -> str:
        """The database used by the test suite. Defaults to `<db>_test` on the
        same server so tests never touch the development database."""
        if self.test_database_url:
            return self.test_database_url
        base, _, db_name = self.database_url.rpartition("/")
        return f"{base}/{db_name}_test"


@lru_cache
def get_settings() -> Settings:
    return Settings()
