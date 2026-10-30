# Local history

## Goal

Run a skill with Notch Pet closed, then import and inspect its records later.
The emitter writes files. The app or a local command imports them into SQLite.
See the [telemetry area](area.md). Branch: `feat/telemetry-local-history`.

## Done when

- A real emitter call with the app closed creates a complete record that can later be queried from SQLite.
- Reimporting a record adds zero rows. The same record ID with different contents reports a conflict.
- Start, end, and check records are immutable and have separate record IDs. Their shared run_id joins them into one invocation.
- A crash before commit leaves the source file pending. A crash after commit causes a harmless reimport.
- The importer never reads a half-written record. Parallel emitters cannot replace another record's file.
- A run shows its project name, skill-folder hash, repository revision, dirty state, and version first-seen time.
- Queries use an index on (skill, started_at) and bounded pages. Failed imports and storage limits remain visible.

## Records

These are fictional examples. Each record is one JSON object in one file.

### run_start

```json
{
  "v": 1, "type": "run_start",
  "record_id": "e1", "run_id": "r1", "parent_run_id": null,
  "at": "2026-10-30T10:00:00Z",
  "skill": "debug-issue", "session_id": "s1", "agent": "claude",
  "project": {"id": "p1", "name": "notch-pet"},
  "version": {"tree_hash": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "repo_sha": "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "dirty": true},
  "source": "hook_post_tool_use", "start_kind": "loaded", "closure_expected": true
}
```

### run_end

```json
{
  "v": 1, "type": "run_end",
  "record_id": "e2", "run_id": "r1",
  "at": "2026-10-30T10:05:00Z",
  "source": "agent_reported",
  "outcome": "failed", "error_category": "check_failed"
}
```

### check

```json
{
  "v": 1, "type": "check",
  "record_id": "e3", "run_id": "r1",
  "at": "2026-10-30T10:04:00Z",
  "source": "check_wrapper",
  "check_id": "project-tests", "exit_code": 1
}
```

Each new record gets a random UUID for record_id. Each invocation gets a different random UUID for run_id.
Examples use short IDs for readability. A retry preserves the record ID and all record fields.
An end or check may arrive before its start. Keep it pending in the projection until the start arrives.
Duplicate equivalent fields count once regardless of JSON key order. Conflicting contents are never silently replaced.
Different end records with contradictory outcomes leave the run marked conflicting for inspection.

The start stores version and project metadata once. End/check records refer to that run instead of recomputing its version.
start_kind is attempted for a pre-event and loaded only for a verified load signal.
An agent report stays labeled as a report. check_wrapper means a wrapper actually ran an allowlisted check and captured its exit code.
If the agent supplies an exit code itself, source must be agent_reported instead.
completed, failed, and blocked are closed outcomes. A missing end is unknown until the timeout rules below apply.

## Publication and import

1. The emitter writes a uniquely named temporary file in the spool directory and closes it.
2. It renames that file on the same filesystem to a unique ready filename. The filename includes a delivery UUID, not just record_id.
3. The importer reads only ready files and commits their records and deduplication keys in one SQLite transaction.
4. Only after commit does it remove the imported files. A failed removal is safe to retry.

Private directory permissions and a shared local lock coordinate publication, import, quota checks, and deletion.
Temporary files are ignored during import. Cleanup removes only owned stale files under that lock.
A short-lived hook may call the emitter, but it never waits for app import or sends a network request.
This handles process crashes. H1 must document file-sync and SQLite settings before claiming survival of sudden power loss.
No acknowledgement socket, separate producer outbox, or background retry loop is needed.

## Version, project, and metrics

- The emitter computes the skill-folder hash once at run_start. Hook adapters call it rather than implementing a second hasher.
- Hash sorted relative paths and file bytes, including SKILL.md, references, scripts, and assets. Ignore documented generated caches and Git metadata.
- Follow the installed skill-directory symlink to its source. Define safe handling for nested symlinks and oversized trees in H2.
- Store the full agent-skills commit ID and a skill-folder dirty flag. Display a short SHA and dirty marker beside the tree hash.
- Track first-seen time per hash in retained history. A hash or Git SHA alone does not order versions chronologically.
- Use a stable local project ID with a readable folder-name label. Matching folder names do not merge projects or worktrees.
- Count attempted starts separately from loaded runs. Preserve each parent's outcome, but count a related nested error at its deepest failing invocation.
- Use error categories check_failed, tool_failed, blocked, and other. Unknown failed categories count as other rather than disappearing.
- A loaded run becomes never_closed only when its start says closure_expected and it has no end after the chosen timeout.
- Derive closure_expected from the installed instrumentation capability/version. Older runs without an end mechanism are excluded, not backdated from one global date.
- Proposed timeout: 24 hours from start. A /clear or abandoned session may leave a run open. A later end closes it even after that timeout.
- Show elapsed time only when timestamps support it. Clock reversals or missing endpoints produce unknown duration.
- Report import counts as new, duplicate, rejected, and conflicting. A retry contributes zero new rows.

## Out of scope

- A collector, hosted service, network delivery, live-state extraction, app history UI, and automatic invocation detection.
- Prompts, command contents/output, transcripts, credentials, terminal selectors, free-form errors, and arbitrary metadata maps.

## Verify

- Seam: actual emitter process, ready files, SQLite import, and a local query with the app closed.
- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Use isolated temporary data for partial writes, two emitters, duplicate/conflicting IDs, out-of-order records, and crashes on both sides of commit.
- Check the examples against the production decoder when it exists. Document exact emitter/import commands when their implementation is added.
- Check version changes from a reference/script edit, dirty state, named projects, timeout eligibility, nested failures, and bounded queries.
- Measure emitter latency, import CPU, and idle behavior on the M2 Air. Run no persistent process for this feature.

## Decisions

- Use immutable records and commit-before-removal import. See [D3](../../DECISIONS.md#d3-record-skill-history-before-extracting-live-monitoring).

## My calls

- Use one ready file per record instead of a shared JSONL file. This gives the importer a clear publication boundary.
- Propose 30-day retention, a 100 MiB history budget including journals, and an 8 MiB ready-file budget. H5 reviews pressure and loss behavior.
- Propose the 24-hour timeout above. H4 checks it without waiting a day by supplying observation time.

## Tasks

- [ ] H1: Add the bounded record emitter with temporary-file publication and a real-process round trip for the three example types, documenting its durability boundary.
- [ ] H2: Add emitter-owned skill-tree version metadata and local project identity, checking reference edits, dirty state, symlink roots, and tree limits.
- [ ] H3: Add SQLite import and a paginated local query, checking commit-before-removal, duplicates/conflicts, and the skill/time index.
- [ ] H4: Add run projections and coverage-aware summaries, checking missing/out-of-order closure, never-closed eligibility, nested failures, and other errors.
- [ ] H5: Bound retention and storage work, checking concurrent publication/import, disk pressure, and safe local deletion with isolated crash checks.
