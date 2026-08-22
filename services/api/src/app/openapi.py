API_VERSION = "0.1.0"

API_DESCRIPTION = (
    "Backend API for HealthTrack — offline-first personal health tracking. "
    "See docs/architecture.md and docs/sync-protocol.md for the operation log "
    "and sync contract this API implements."
)

TAGS_METADATA: list[dict[str, str]] = [
    {"name": "health", "description": "Liveness and readiness checks."},
    {"name": "auth", "description": "Registration, login, and session management."},
    {"name": "sync", "description": "The operation log sync protocol."},
]

SERVERS: list[dict[str, str]] = [
    {"url": "http://localhost:8000", "description": "Local development"},
    {"url": "https://staging.api.healthtrack.example", "description": "Staging"},
    {"url": "https://api.healthtrack.example", "description": "Production"},
]
