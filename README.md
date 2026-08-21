# HealthTrack

A full-stack, offline-first personal health tracking platform: body metrics, nutrition, training, sleep, wellbeing, and social accountability — all synced through a single append-only operation log.

## Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter, with Drift (SQLite) for local-first storage |
| Backend | FastAPI + PostgreSQL, async SQLAlchemy, Alembic migrations |
| Web | Next.js, full feature parity plus a desktop analytics workspace |
| Sync | Append-only operation log, field-level last-write-wins, full edit history and undo |
| Infra | Docker Compose (Postgres, Redis, MinIO), portable, no vendor lock-in |

See `docs/architecture.md` for the locked architectural decisions and cross-cutting invariants this project is built on.

## Layout

```
apps/
  mobile/          Flutter application
  web/              Next.js application
services/
  api/              FastAPI backend
packages/
  contracts/        Shared API/data contracts (OpenAPI-generated clients, schemas)
infra/              Docker Compose, deployment and environment configuration
docs/               Architecture, data model, protocol, and policy documentation
```

## Local development

This project is under active initial development; the commands below reflect the intended workflow as each piece lands (see `todo.md` for build sequence).

```
make up       # start Postgres, Redis, MinIO via Docker Compose
make api      # run the FastAPI backend with hot reload
make mobile   # run the Flutter app
make web      # run the Next.js app
make test     # run all test suites
make lint     # run all linters
make migrate  # apply database migrations
make down     # stop all services
```

Environment variables are documented in `.env.example` (added once the backend is scaffolded).

## Contributing

This is a personal project built incrementally, one task at a time, with a commit per task. See `docs/architecture.md` for the non-negotiable invariants that every feature must respect (offline-first, per-category revocable sharing, no outcome-based leaderboards, every write through the op log).
