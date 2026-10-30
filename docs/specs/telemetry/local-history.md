# Local history

Needs: background-collection

## Goal

Inspect local agent activity and telemetry runs after the interface or collector restarts.
The [telemetry area](area.md) stores history separately from live session evidence, using SQLite inside the collector.
Proposed branch: `feat/telemetry-local-history`.

## Done when

- An allowlisted record sent while the interface is closed is queryable after collector restart.
- Retrying the same stable record ID stores one record. Reusing an ID with different contents is reported as a conflict.
- An acknowledgement means the record's SQLite transaction committed; a socket write or memory enqueue is not an acknowledgement.
- A durable producer retains unacknowledged records until successful retry or explicit expiry/deletion, with bounded storage and visible loss counters.
- Failure after commit but before acknowledgement produces a harmless retry. Failure before commit never produces a success acknowledgement.
- A partial run remains incomplete. Closing snapshots can finish the same run under explicit merge rules without changing its start identity.
- Indexed, paginated queries filter by time, project, agent, skill, version, and outcome without loading the full history.
- The app provides a minimal run list/detail view over the same read API used by an isolated local query client.
- Retention, a total byte budget, and bounded maintenance cover the database, journal files, and outboxes. Disk-full errors cannot imply persistence.
- Monitoring pause blocks new ingestion; explicit Delete History clears retained records and pending delivery without later retry resurrecting deleted data.
- History never restores live working state, navigation targets, approvals, questions, or replies.

## Out of scope

- Hosted ingestion, MySQL, accounts, remote export/upload, synchronization, a browser dashboard, and token/cost estimation.
- Durable guarantees for the unchanged version-1 observation helper. Its best-effort losses remain explicit.
- Persisting prompts, commands, raw tool payloads, transcript contents, credentials, or arbitrary metadata maps.
- Implementing the three pilot skills; that belongs to skill-telemetry.

## Constraints

- D2 permits SQLite for telemetry history only. Preferences, pet assets, and live session state keep their separate storage responsibilities.
- Persist a sanitized projection of observations, not raw hook envelopes. Do not retain raw project paths or terminal selectors in history.
- Store stable event/run/step IDs, optional parent invocation ID, source session identity, opaque local project ID, source/receipt time, and evidence source.
- Outcome and elapsed-time rules distinguish observed failure, reported completion, verified checks, blocked, and unknown. No Stop-to-success inference.
- Use monotonic elapsed time only within a valid producer lifetime; clock discontinuity or missing endpoints means unknown duration.
- Use one collector-owned database writer. UI and query clients use bounded read requests rather than owning SQLite connections.
- Keep history ingestion separate from fast observations and any action channel. No helper waits for database work under the existing observation deadline.
- Use transaction acknowledgement and retry-in-place, not drain-before-send. Bound retries with backoff and honor Pause and Quit All.
- Acknowledgement guarantees are defined in H1, including process crash versus power-loss durability; do not silently trade them for battery cost.
- Capture gaps and retention loss as coverage metadata. A summary never claims that its observed runs represent every invocation.

## Verify

- Seam: actual producer to collector to committed SQLite record, queried through the local client and displayed after app reconnect.
- Build and Swift commands: `bash scripts/run.sh --build-only` and `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Documentation/whitespace: `git diff --check`.
- H7 adds a process checker using an isolated data directory; document the added command when its implementation exists.
- Inject failure before commit, after commit/before acknowledgement, and during retry. Check one retained record and truthful acknowledgement states.
- Exercise duplicates, conflicting IDs, malformed input, queue bounds, SQLite busy/disk-full, retention, and explicit deletion while retries are pending.
- Profile burst writes, idle after writes, paginated reads, and maintenance. Count database journals and outboxes in disk measurements.
- Store runtime files outside repositories. Do not point failure tests at real user history.

## Decisions

- Local-only SQLite history with deduplication and bounded retention is confirmed in D2.

## My calls

- Propose 30-day retention, a 100 MiB history directory budget including SQLite journals, and an 8 MiB aggregate pending-delivery budget.
- H1 reviews these initial values, bounded batch size, queue limits, and overflow behavior against expected load and the battery baseline.
- Prefer a small record protocol with explicit event/run/step variants. Avoid copying Rico's unrestricted data dictionaries.
- Keep all-time quality claims and a full analytics dashboard outside the minimal history interface.

## Tasks

- [ ] H1: Review the allowlisted record and acknowledgement contract, merge rules, durability boundary, retention/byte caps, and deletion behavior using explicit failure examples.
- [ ] H2: Add transactional SQLite ingestion through the collector; check committed acknowledgement, stable-ID deduplication, conflicting IDs, and incomplete-to-closed run merging.
- [ ] H3: Add a bounded durable producer outbox that retains records through failed sends; check commit-before-ack retry, backoff, pause, and queue limits.
- [ ] H4: Enforce reviewed retention and disk budgets with bounded maintenance; check pressure, disk-full reporting, and deletion without retry resurrection.
- [ ] H5: Add indexed paginated history queries and a local query client; check filters and stable pagination against the running isolated collector.
- [ ] H6: Add the minimal native run list/detail view using the same query API; check restart history and clear separation from live session presentation.
- [ ] H7: Run crash/retry/deletion process checks and M2 Air burst/idle profiles; record actual results and coverage limitations.
