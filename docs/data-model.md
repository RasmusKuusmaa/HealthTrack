# Data Model

Living reference for every entity in the system. Each domain section is filled in as its phase lands — see `todo.md` for build order. An entity entry should cover: fields, storage location (Postgres projection table / Drift table / both), op-log registration, and relationships.

## Conventions

- Every timestamped entity carries `logged_at_utc`, `local_date`, and `tz_offset_minutes` (see `docs/architecture.md`).
- All entities that are user-editable are written through the operation log — see `docs/sync-protocol.md` (added in Phase 3).

## Identity & Auth

_Phase 2._

## Operation Log

_Phase 3._

## Body Weight & Measurements

_Phase 5._

## Reminders & Notifications

_Phase 6._

## Hydration

_Phase 7._

## Nutrition

_Phase 8–9._

## Training

_Phase 10–11._

## Sleep

_Phase 12._

## Wellbeing, Substances & Health Markers

_Phase 13._

## Progress Photos

_Phase 14. Local-only — never appears in server-side projections._

## Goals

_Phase 16._

## Gamification

_Phase 17._

## Social & Sharing

_Phase 18._

## Privacy & Consent

_Phase 19._
