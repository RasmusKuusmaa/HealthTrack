TAGS_METADATA = [
    {"name": "health", "description": "Liveness and readiness checks."},
]

OPENAPI_KWARGS = {
    "version": "0.1.0",
    "description": (
        "Backend API for HealthTrack — offline-first personal health tracking. "
        "See docs/architecture.md and docs/sync-protocol.md for the operation log "
        "and sync contract this API implements."
    ),
    "openapi_tags": TAGS_METADATA,
    "servers": [
        {"url": "http://localhost:8000", "description": "Local development"},
        {"url": "https://staging.api.healthtrack.example", "description": "Staging"},
        {"url": "https://api.healthtrack.example", "description": "Production"},
    ],
}
