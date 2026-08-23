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

### `weight_entry`

A single body-weight measurement.

| Field | Type | Notes |
|---|---|---|
| `id` | UUID | Primary key. Client-generated on create, per the sync protocol — the same id that becomes the op's `entity_id`. |
| `user_id` | UUID | Owning user. Not part of the op payload — set from the authenticated request, not client-supplied. |
| `logged_at_utc` | timestamp with time zone | The instant the weight was recorded. |
| `local_date` | date | Computed on-device at entry time from `logged_at_utc` and the device's local timezone — never derived from UTC server-side. All daily aggregation groups by this field. |
| `tz_offset_minutes` | integer | The device's UTC offset at the moment of entry. |
| `weight_kg` | numeric(5,2) | Canonical storage is always kg, regardless of the user's display unit preference (`user_profile.unit_system`) — conversion is a UI concern only. |
| `source` | text | How the entry was recorded. `manual` for now; reserved for a wearable/scale source once Phase 20/21 lands. |
| `note` | text, nullable | Optional free-text note. |
| `deleted_at` | timestamp with time zone, nullable | Tombstone — see `docs/sync-protocol.md`. Never hard-deleted. |

**Storage:** Postgres `weight_entries` projection table (5.2) + local Drift `weight_entries` table (5.4).

**Op log:** registered as sync entity type `weight_entry` (5.3). Every field except `id`/`user_id`/`deleted_at` is optional in the op payload schema, per the field-level partial-payload convention — a single-field update (e.g. just correcting `note`) must not require resending the rest.

**Relationships:** none yet. A future goal (Phase 16) may track progress against weight trend data, but references it by query, not a foreign key to individual entries.

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
