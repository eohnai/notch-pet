# Connect and remove Codex observation

Needs: agent-adapters, integration-health

## Goal

Connect Codex to the existing observation bridge through explicit, reversible setup.
Preserve user/Otty hooks, normal trust review and later user edits.
See the [sessions area](area.md). Proposed branch: `feat/sessions-codex-setup`.

## Done when

- A bounded pure planner adds the seven supported lifecycle hooks without replacing unrelated values
  or handler order; an unchanged reinstall leaves configuration bytes unchanged.
- Setup uses verified version/configuration/enablement/timeout evidence and an available bundled helper.
  Unknown versions or shapes fail with a useful bounded explanation.
- A separate ownership record identifies only app-created entries. Lookalikes, edited, missing or
  duplicate entries are conflicts, never automatically adopted.
- Guarded installation and interruption recovery follow an approved write-boundary matrix.
  Unsupported paths, stale plans and observed concurrent edits leave inspected configuration untouched.
- Removal deletes only uniquely matching unchanged app entries and preserves subsequent unrelated edits.
- An actual installer/helper process round trip works in disposable directories. Setup results remain
  distinct from hook trust, delivery and live activity.

## Out of scope

- Automatic startup installation, trust bypasses, config.toml enablement edits, paid agent turns,
  real user configuration changes during development, usage or action-channel setup.
- Completing the seven historical interactive checks by running planner/installer fixtures alone.

## Constraints

- [Codex setup contract](../../contracts/codex-hook-setup.md) preserves the accepted separate ownership
  representation. Recovery, concurrency and the precise schema remain proposals to settle first.
- Use bounded lossless JSON handling; preserve numeric lexemes and unrelated values; reject duplicate keys.
- File operations are shared machinery where provider-independent; provider setup policy stays in its adapter.
- No credentials, transcripts or whole user-configuration backups in ownership/journal/diagnostic records.
- Keep original I3a/I3b/I3c/I5/I6 lines and checkbox states in the source spec during migration.
- Per-slice file/function/test limits apply; refine any oversized task before implementation.

## Verify

- Seam: explicit disposable configuration through production planner, installer, removal and bundled helper.
- Swift filters `CodexHookSetupPlannerTests`, `CodexHookInstallerTests`, `CodexHookRemovalTests`:
  each planned suite has at most five test cases, zero failures, with parameterized failure examples.
- Full suite and packaged build use the exact commands in the goal after renewed verification approval.
- The planned no-capture process checker must establish idempotence, preservation, conflict rejection,
  helper delivery and restoration of isolated configuration. Its exact CLI is frozen in the goal.

## Decisions

- Separate external ownership file is already accepted; see the existing setup contract.
- **Guarded automatic setup with a documented external-editor race, accepted 2026-10-30.** The user
  selected automatic setup after reviewing a plain-language explanation of simultaneous saves and
  the manual-instructions alternative. Use cooperative locking, fresh checks and conflict refusal;
  ask the user to close agent-settings editors during Connect/Disconnect. The final compare/rename
  window cannot guarantee preservation of a noncooperating editor's write. Atomic rename is not CAS.

## My calls

- I3a is completed documentation, not proof of an installer. Do not copy its checkbox as new completed work.
- Current official [Codex hooks](https://learn.chatgpt.com/docs/hooks), reviewed 2026-10-30,
  is documentation evidence only. Revalidate the exact selected installed version before setup.
- Keep development targets disposable. User-facing installation previews its concrete owned changes.

## Tasks

CX3 is implemented in verified slices: typed JSON member inspection, initial byte edits,
the public input/initial-plan API, then owned-entry reconciliation. Each slice keeps the approved
three-file/three-function/five-test limits; the parent checkbox waits for all planner cases.

The implementation API is `HookSetupPlanner.plan(_ input: HookSetupInput) -> HookSetupPlan`.
`HookSetupInput.init(agent:configuration:ownership:target:support:installationID:)` supplies bytes
and evidence explicitly. `HookSetupTarget.init(configurationPath:parentDevice:parentInode:helperPath:)`
binds ownership to one target and helper. Example: an installer passes freshly inspected bytes and
target identity to `HookSetupPlanner.plan(input)`; a view never applies a saved candidate directly.

Version-1 ownership stores installation UUID, provider, target identity, exact app-created group
bytes, and flags identifying the configuration/container/event arrays created by installation.
It contains no unrelated configuration backup. Preserve the already-proposed durable journal/recovery
matrix; journal only old/new digests, bounded identities and new app-only ownership. Automatic setup's
external-editor race is accepted; any uncertain recovery state remains a conflict.

- [ ] CX1: Settle selected-version hook syntax, ownership schema, write/recovery boundaries and concurrency guarantees against fictional failure cases before implementing file writes.
- [x] CX2: Add bounded lossless hook-JSON scanning and duplicate-key rejection, checking nested values, numeric preservation, malformed shapes and byte limits in at most five tests.
- [x] CX3: Add the pure seven-event Codex setup planner with five parameterized tests for initial setup, byte-identical reinstall, preservation, ownership conflicts and version/helper gates.
- [ ] CX4: Add guarded disposable installation using fresh evidence and approved shared file primitives, checking paths, permissions, stale plans and cooperative writers in at most five tests.
- [ ] CX5: Add interruption recovery across the approved durable-write matrix, checking every state without restoring whole-file backups in at most five parameterized tests.
- [ ] CX6: Add owned Codex removal, checking unrelated edits, missing/edited/duplicate owned entries, repeated removal and malformed records in at most five tests.
- [ ] CX7: Verify actual process setup, reinstall, helper delivery and removal against isolated paths, recording version and trust limitations without touching installed settings.

## Execution evidence, 2026-10-30

CX2 ran as an independent bounded decoder slice while CX1's selected-version and schema review
remains open; it performs no setup or file writes. Changed exactly three implementation/test files:
`Sources/EventBridge/HookConfigurationJSON.swift`, `Sources/EventBridge/HookEnvelopeV1.swift`, and
`Tests/EventBridgeTests/HookConfigurationJSONTests.swift`. Added three production functions and five tests.

The new tests first failed with missing-type errors. The implementation reuses the existing strict
parser with opt-in value-range capture; hook parsing keeps capture disabled by default. It validates
the full bounded object, rejects duplicate keys and preserves original bytes, including numeric lexemes.
The five new tests plus the surrounding 36 bridge/adapter/socket tests passed (41 total).

The full approved Swift command then exited 0: 144 tests (78 + 17 + 8 + 41), zero failures.
The packaged build exited 0 with `Info.plist: OK`. The rebuilt real-helper process checker and existing
contract checker exited 0. These are parser/foundation checks, not installed setup or native UI acceptance.

Read-only selected-version commands reported Codex `0.165.0` and Claude Code `2.1.314`.
Codex's `app-server generate-json-schema --out <temporary-directory>` exited 0 and documented the
expected lifecycle names plus timeout/trust metadata. Current official documentation agrees on
timeout seconds and provider turn-field mappings. No isolated hook load, normal trust review or live
agent dispatch was run, so the new versions are not yet promoted to runtime-compatible.

## Planner checkpoint and pause, 2026-10-30

The user paused the goal and explicitly requested checkpointing and committing/pushing.
Their later "just commit and push first" clarification defers PR creation.
No installer, configuration writes or additional implementation started after that request.

CX3's bounded slices are verified. Typed member capture added one production function in three files
and one test; the six configuration-reader tests passed after the expected missing-method failure.
The initial byte-editing core added three functions/two files/five tests. The public input/initial plan
slice changed three files and added two initializers plus `plan`, with five new tests. Owned reconciliation
changed three files, added two production functions and five tests; it also strengthened an existing
lookalike case. Each slice stayed within the approved implementation budgets.

The latest command was
`env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-agent-workflow/build --filter 'CodexHookOwnershipTests|CodexHookSetupPlannerTests|HookGroupEditsTests'`.
It exited 0: 15 tests in three suites passed. It proves initial seven-event plans, unchanged reinstall,
preservation of numeric lexemes/unrelated values and order, strict owned-group shape/identity,
missing/edited/duplicate/copied entry conflicts, bounded failures and helper quoting. It performs no I/O.
The full suite, packaged build and real-helper checks from the previous checkpoint were not rerun
after these planner/member-capture changes; retain their historical scope rather than claiming current full acceptance.

An isolated Codex `0.165.0` app-server initialize/`hooks/list` probe loaded the seven fixture hooks
with `timeoutSec: 3`, source user and trustStatus untrusted. No thread/turn was started and no hook
trust was bypassed. `features list` reported hooks stable/true in both fixture enablement configurations;
this does not establish that the fixture's false setting can disable effective policy. Sanitized evidence
is under `/private/tmp/notch-pet-hook-syntax-live-16md6nzo`. No user configuration or credentials were
read directly or copied. This is syntax/metadata evidence, not live lifecycle dispatch or release compatibility.

CX1 remains open for the remaining recovery/application review and production evidence producer.
On explicit resume, implement guarded file operations and fresh support/identity inspection before any
application path uses planner output. Do not automatically mark original source I3b or deferred acceptance complete.
