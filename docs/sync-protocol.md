# Sync Protocol

This document specifies the append-only operation log that every write in HealthTrack goes through (see `docs/architecture.md`, invariant: "Every write goes through the op log. No direct table mutation from feature code."). Everything else in the product — every feature table, every screen — is a read model built on top of this. Get this right before writing feature code; changing it later means migrating every entity.

## Why an op log

Three requirements drove this design over a simpler "last write wins on the row" model:

- **Full edit history and undo.** Users can see what changed and revert it (see `GET /entities/{type}/{id}/history` and `POST /entities/{type}/{id}/revert`).
- **Offline-first with multi-device sync.** A phone and a web client can both edit the same weight entry while offline and reconcile later without silently dropping one edit.
- **Deterministic replay.** The current state of every entity must be fully reproducible by replaying its ops in order — this is how we verify the materializer is correct (`3.16`) and how a new device bootstraps.

## Op shape

An operation is the atomic unit of write. Every op has:

| Field | Type | Meaning |
|---|---|---|
| `server_seq` | bigint (bigserial) | Global, monotonically increasing, per-user order assigned by the server on ingestion. This is the authoritative ordering — not `client_ts`. |
| `client_op_id` | UUID | Client-generated, unique per user. The idempotency key — see below. |
| `user_id` | UUID | Owning user. All op-log queries are scoped to a single user; there is no cross-user ordering. |
| `entity_type` | text | Which entity this op mutates, e.g. `weight_entry`, `body_measurement`. Must be a registered type (`3.4`). |
| `entity_id` | UUID | The entity instance. Client-generated at creation time (so offline creates don't need a server round-trip to get an id). |
| `op_type` | text | One of `create`, `update`, `delete`. |
| `payload` | jsonb | For `create`/`update`: a partial object of `{field: value}` for the fields being set. For `delete`: empty or reason metadata. Never a full-row replace — payloads are field-level. |
| `device_id` | UUID | Which device produced this op. References `devices.id` once 2.20's registration path guarantees the row exists at write time. |
| `client_ts` | timestamptz | When the device believes the edit happened (device clock, not trusted for ordering — see below). |
| `server_ts` | timestamptz | When the server ingested the op (`now()` at insert). |

## Ordering: server_seq is truth, client_ts is a tiebreak

`server_seq` is a `bigserial` assigned at push time, one per user, strictly increasing. It is the **only** field that determines global op order — the order ops are materialized in, the order `GET /sync/pull` returns them in, the order the history timeline renders in.

`client_ts` is never used for ordering across ops from different devices — device clocks drift and can't be trusted. It is used for exactly one thing: **field-level conflict resolution** (below), where it acts as the primary signal for "which device's edit to this specific field is more recent," with `server_seq` as the deterministic tiebreak when two ops carry the same `client_ts` (e.g. a device that queued several offline edits with a clock that didn't advance between them).

## Idempotent ingestion

`client_op_id` is generated once per logical edit, on-device, when the user takes the action (not regenerated on retry). `(user_id, client_op_id)` is unique. When `POST /sync/push` receives an op whose `client_op_id` already exists for that user:

- It is **not** re-materialized.
- The response includes the **original** `server_seq` that was assigned the first time.
- No error — this is the expected, common case of a client retrying a push after a dropped response.

This makes push safe to retry blindly after any network failure, which offline-first clients do constantly.

## The materializer

Each entity type has a projection table (e.g. `weight_entries`) that holds the entity's *current* state — this is what feature code reads. The materializer is the only code path allowed to write to projection tables, and it runs synchronously during `POST /sync/push`, one op at a time, in the order the ops appear in the batch (which the client should send in its own local causal order; the server does not reorder a single push batch).

For each op:

- `create`: insert a new projection row for `entity_id` if one doesn't already exist. If it does (duplicate create, e.g. from a retried batch under a different `client_op_id` due to a client bug), treat it as an `update`.
- `update`: apply field-level last-write-wins (below) to the projection row.
- `delete`: write a tombstone (below); never `DELETE FROM`.

## Field-level last-write-wins

Conflicts are resolved **per field**, not per row. If device A offline-edits `weight_kg` and device B offline-edits `note` on the same entry, both edits survive — they don't touch the same field, so there's nothing to resolve.

When two ops *do* touch the same field on the same entity, the materializer keeps, per field, the `(client_ts, server_seq)` of whichever op last won:

1. Compare `client_ts`: the op with the later `client_ts` wins.
2. If `client_ts` is equal: the op with the higher `server_seq` wins (i.e. whichever was actually ingested later, since `server_seq` order is authoritative and never ties in practice for two different ops).

The projection table does not need a `(client_ts, server_seq)` pair per column in the common case — the materializer determines the winner by replaying that field's history from the op log at write time (or, for performance, a per-entity "last writer" side table keyed by `(entity_id, field_name)` — implementation detail left to `3.6`, not a protocol requirement). What the protocol guarantees is that the result is **order-independent**: replaying the same set of ops in any order that respects each op's own `server_seq` position produces the same final projection state. `3.17`'s property tests assert exactly this.

## Soft delete: tombstones

A `delete` op never removes the projection row. It sets `deleted_at` (and, if the entity table doesn't already carry it, the materializer adds it as part of that entity's schema). Tombstoned rows:

- Are excluded from normal feature-code queries (which filter `deleted_at IS NULL`).
- Remain visible in `GET /entities/{type}/{id}/history` — deletion is an event in the timeline like any other.
- Can be undone via `POST /entities/{type}/{id}/revert`, which emits a new op restoring prior field values (including implicitly "undeleting" by virtue of the entity having live fields again — a explicit un-delete is just another `update` op in the log, not a special op type).

Hard deletes only happen outside this protocol entirely, via the GDPR purge job (Phase 19) — a deliberately separate, audited, non-reversible path.

## Push: `POST /sync/push`

Request: a batch of ops (no `server_seq` — the client never assigns this). Response: for each op in the batch, in the same order, the assigned (or, for a replayed `client_op_id`, the original) `server_seq`.

Materialization for one push batch happens under a **per-user Postgres advisory lock** (`3.11`), held for the duration of the batch. This serializes concurrent pushes from the same user's multiple devices, so two devices pushing at the same instant can't interleave their materialization in a way that produces a different result than pushing them one after another. Different users never contend with each other.

## Pull: `GET /sync/pull?since=<server_seq>&limit=<n>`

Returns ops for the calling user with `server_seq > since`, ordered by `server_seq` ascending, up to `limit`. Response includes a `next_cursor` (the last returned `server_seq`, or `since` unchanged if the page was empty) so the client can keep paging until it catches up, then persist that cursor (in secure storage on-device) as the low-water mark for its next pull.

A pulled op is materialized locally by the client exactly the same way the server materializes it — same field-level LWW rule, same tombstone semantics. This symmetry (client and server run the same materializer logic) is what keeps every device converging on identical state.

## Bootstrap: `POST /sync/bootstrap`

For a new device (or a device that wants to skip replaying the entire history — e.g. after a reinstall). Returns the **current materialized state** of every entity the user owns — a compacted snapshot, not the raw op log — plus the `server_seq` cursor to resume incremental `GET /sync/pull` from. This is what makes onboarding a second device fast regardless of how large the user's op history has grown.

## Compaction

A scheduled job (`3.13`) that produces fresh snapshots (the same shape bootstrap serves) so bootstrap stays cheap as the op log grows. Compaction is **purely additive**: it never deletes or rewrites rows in the `operations` table. Full history remains queryable forever through the op log itself — compaction only changes how fast a *new* device can catch up, not what history is available to an *existing* one.

## Entity history and revert

- `GET /entities/{type}/{id}/history` replays every op for that `entity_id`, in `server_seq` order, into a timeline: who changed what, when, from which device.
- `POST /entities/{type}/{id}/revert` doesn't delete or rewrite history. It reads the entity's state as of a target point in history and emits a **new** `update` op (a fresh `server_seq`, a fresh `client_op_id`) setting the current fields back to those prior values. Reverting is just editing — it goes through the same push path as any other write, and shows up as its own entry in future history queries.

## Replay verification

`3.16` provides a command that rebuilds every projection table from scratch by replaying the entire `operations` table through the materializer, then diffs the result against the live projection tables. Any difference is a materializer bug — projections must always be a pure function of the op log. This is the ground-truth check that keeps the "op log is the source of truth" invariant honest as the materializer evolves.
