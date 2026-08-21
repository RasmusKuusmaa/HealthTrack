# Architecture

This document records the locked architectural decisions for HealthTrack and the invariants that apply across every feature. These are not up for casual revision — changing one is a deliberate decision, not a side effect of feature work.

## Locked decisions

| # | Decision | Choice |
|---|---|---|
| 1 | Food database | Full Open Food Facts mirror + USDA FoodData Central + user-created foods. OFF data lives in an isolated `foodref` Postgres schema to keep the ODbL share-alike boundary physical and away from user data. No paid APIs. |
| 2 | Sync protocol | Append-only **operation log** with full edit history, undo, and replay. Field-level last-write-wins on materialization. |
| 3 | Auth | Self-rolled. FastAPI + Argon2id + JWT access tokens + rotating refresh tokens + TOTP MFA. |
| 4 | Progress photos | **Local-only.** Never uploaded, never synced. Stored in app-private storage, encrypted at rest with a device key. |
| 5 | Local DB | Drift (SQLite) with proper migrations. |
| 6 | Wearables | Deferred. HealthKit / Health Connect in Phase 20, direct vendor APIs in Phase 21. All manual-entry paths must work standalone first. |
| 7 | Hosting | Deferred. Everything runs in Docker Compose locally; keep it portable, no vendor lock-in. |
| 8 | Web scope | Full feature parity **plus** a desktop-only analytics workspace. |

## Non-negotiable cross-cutting invariants

- **Offline-first.** Local Drift DB is the source of truth for all UI. The network is an optimisation. Every screen must work in airplane mode.
- **Every timestamped record stores three fields:** `logged_at_utc` (instant), `local_date` (plain date, computed on-device at entry), `tz_offset_minutes`. All daily aggregation uses `local_date`, never a UTC-derived date.
- **All scheduled reminders are local notifications.** Server push (FCM/APNs) is reserved exclusively for events originating from another user.
- **Sharing is per-category and revocable.** No all-or-nothing sharing, ever.
- **No leaderboards over weight, body fat, or calorie deficit.** Compare consistency and adherence only.
- **Every write goes through the op log.** No direct table mutation from feature code.

## Rationale notes

- **Op log over CRDTs:** an append-only log with server-assigned sequence numbers and field-level last-write-wins gives full edit history and undo for free, at the cost of needing an explicit materializer. See `docs/sync-protocol.md` (Phase 3) for the detailed protocol once it exists.
- **Self-rolled auth over an auth-as-a-service provider:** avoids vendor lock-in and keeps health data (Article 9 special category under GDPR) entirely within infrastructure we control.
- **Physical schema isolation for OFF data:** ODbL's share-alike obligation applies to the database, not derived works built on top of it. Keeping it in its own schema (`foodref`) makes the boundary enforceable rather than just documented.
- **Local-only photos:** the highest-sensitivity data in the app. Removing sync removes an entire class of breach and interception risk for it.
