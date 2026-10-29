# Track agent session state

Needs: observation-bridge

## Goal

Turn delivered agent observations into one shared, in-memory view of each session.
The view keeps concurrent sessions, pending requests, response-ready notices, and unknown state apart.
The notch uses this state now, and the pet will reuse it later. See the [sessions area](area.md) for shared context.

This is a retrospective spec. It moves the completed session-store task and its evidence out of the [source specification](../notch-companion.md).
It records requirements that were approved before the code. It does not treat the code as the definition of scope.

## Done when

- Alerts from two concurrent sessions stay distinct, including two sessions in the same project folder.
- Each agent's finished response produces a response-ready notice. The notice does not claim that the task succeeded.
- Unknown and ended state stay distinct from working and response ready. Retained requests stay marked as unconfirmed.
- Closing a pane or restarting the app cannot present an unverified session as still working.
  Live sessions are kept in memory only. New evidence is needed after a restart.
- The store follows the accepted ordering, request identity, freshness, and memory limits in [decision 0008](../../decisions/0008-define-event-ordering.md) and the [version-1 contract](../../contracts/agent-events-v1.md).
  All 37 contract state sequences (122 steps) and the four memory limits pass as Swift tests.
- Sleep, wake, and system clock changes stop older observations from restoring fresh state.
- The production bridge callback delivers observations from both providers through the inbox to the store.

## Out of scope

- Event delivery, helper deadlines, and endpoint security: [observation-bridge](observation-bridge.md).
- Notch presentation, ordering of rows, and selection: [notch/session-island](../notch/session-island.md).
- Integration health, which records delivery separately from session state: [integration-health](integration-health.md).
- Terminal navigation, provider actions, and usage data.
- Persistent session history, replay, and disk spooling.
- Transcript or terminal-output parsing, and process-liveness guesses about completion.

## Constraints

- Keep the accepted version-1 observation contract and the conservative ordering in decision 0008.
- Keep live session state in memory only, as [decision 0003](../../decisions/0003-store-state-without-a-database.md) requires.
- Keep source session identity separate from project paths and pane hints.
  Missing terminal metadata is valid, under [decision 0012](../../decisions/0012-support-terminal-independent-operation.md).
- Keep the store as the only owner of request classification, ordering, and freshness. Adapters and views must not repeat these rules.

## Verify

- Seam: `SessionEventInbox` into `SessionStore`, fed by the production `EventBridgeServer` callback.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
  The store tests are in `Tests/SessionStateTests/SessionStoreTests.swift`.
- Contract reference checks: `python3 scripts/check-event-contract.py`.
  Its unseen-turn recovery rule differs from the store. See Open questions.
- Physical sleep/wake checks belong to R3 in the source spec. Injected clock checks alone do not establish them.

These are reproduction commands. This retrospective spec ran documentation checks only.

## Decisions

- [0002: Use services and shared stores](../../decisions/0002-use-mvvm-with-services.md).
- [0003: Keep live state in memory](../../decisions/0003-store-state-without-a-database.md).
- [0008: Use conservative event ordering](../../decisions/0008-define-event-ordering.md).
- [0011: Organize records by area and feature](../../decisions/0011-organize-records-by-feature.md).
- [0012: Support terminal-independent operation](../../decisions/0012-support-terminal-independent-operation.md).

## My calls

- The completed "Add the shared session store" task moves here, as the area file's `session-state` entry describes.
- The shared selection and priority rules in `NotchPresentation` (N5) go to `notch/session-island`. They decide presentation, not session meaning.
- Physical sleep/wake (R3) and live provider checks (N6, R6–R7) stay in the source spec. They depend on later features.
- No new tasks are added. The store task is complete on its recorded evidence. The open questions below need a decision, not new code.

## Open questions

- `scripts/check-event-contract.py` lets a previously conflicting turn ID restore working state. `SessionStore` follows the stricter accepted rule.
  The reference-model correction is still a proposed follow-up. It needs approval before anyone edits the check script.
- The Codex interruption limit stays as recorded. An `Interrupt` event is unsupported, so an unresolved approval notice can stay after interruption.
  This follows the accepted contract. It is a known usability limit, not a store defect.

## Tasks

- [x] Add the shared session store with checks for duplicate, delayed, concurrent, and terminal-state events.

## Historical evidence

The following records are copied from the [source specification](../notch-companion.md#historical-implementation-evidence).
Only relative link paths changed. They were not rerun for this spec.
The source spec also keeps them.

Task 7 implementation: `Sources/SessionState/` contains the contract mapping, observable shared store, and bounded bridge inbox.
`NotchPetApp` owns the store and connects the bridge callback through the inbox.
The store enforces ordering, request identity, retained unconfirmed notices, terminal restrictions, freshness, and memory limits.
Snapshots keep source session identity separate from project paths and unverified pane hints.
The app invalidates observations on sleep, wake, and clock notifications.
Its expiry timer runs only while fresh observations exist.
Provider compatibility, hook setup, terminal navigation, and live session presentation remain later tasks.

`Tests/SessionStateTests/SessionStoreTests.swift` checks all 37 existing state sequences with 122 steps.
It also checks four memory limits, concurrent delivery, inbox overflow, delayed publication, byte-distinct Unicode identities,
clock changes, recovery with unseen turns, and a real bridge callback reaching the store.
The Python reference model still permits recovery with a previously conflicting turn ID.
The production store follows the accepted contract's stricter unseen-turn rule, covered by a separate Swift regression.
The reference-model correction is a proposed follow-up, outside this implementation task.

`env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`
passes 31 tests across three suites, including 16 shared-store tests.
The contract checker, helper process checks, and development app bundle build also pass.
An earlier full run exposed a timing assumption in the existing `invalidFramesNeverReachCallback` test.
Its maximum-size valid frame and final extra byte require separate writes on this Mac.
A temporary diagnostic confirmed acceptance when that extra byte arrives after the receiver checks buffered bytes.
This matches the contract's buffered-extra-byte rule.
The final full run passed. The bridge and existing test remain unchanged, with the diagnostic removed.
Physical sleep/wake and live provider behavior remain later verification work.
