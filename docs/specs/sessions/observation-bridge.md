# Observe local agent events

## Goal

When Codex CLI or Claude Code emits a supported hook, deliver its allowed identity and event fields into the running native app.
This is the first working path for the [sessions area](area.md), enabling later session alerts without changing agent decisions.
The native shell and bundled helper are shared foundations for later notch, pet, and usage features.

This spec documents existing work against approved requirements and decisions.
The implementation review below checks those requirements rather than treating existing code as the product definition.

The 2026-10-30 [terminal-independence decision](../../decisions/0012-support-terminal-independent-operation.md) adds no required terminal identity.
Version-1 observations already permit missing terminal metadata. Their optional terminal object still supports only Otty.
Historical evidence below remains unchanged; live operation without Otty is a new N8 acceptance check in the source spec.

## Done when

- The local SwiftUI/AppKit app launches with a menu-bar Quit action and starts its observation receiver.
  Quit stops the receiver and removes only its owned socket.
- The bundled helper accepts the seven supported hook names from each provider and delivers only version-1 allowed fields.
  Claude `prompt_id` becomes `turn_id`. Missing source identities remain missing.
- Actual helper-process checks cover all 15 fictional provider payloads, exact input capacity, invalid input, unavailable app, open stdin, and a busy socket.
  Production socket-to-inbox-to-store checks establish receipt for both providers.
- Invalid, oversized, stale, future-dated, truncated, unsupported, and already-buffered extra-frame input cannot reach the receiver callback.
  Fragmented input retains one receiver deadline.
- The helper makes one bounded delivery attempt and handles failure silently, with exit `0` and empty stdout/stderr.
  It emits no approval decision. Successful helper exit alone never establishes delivery.
- The endpoint verifies ownership, permissions, and peer user IDs.
  Lifecycle checks preserve active listeners, symlinks, unrelated files, and replacement paths.

These checks describe the accepted foundation, not completed live-agent or visible-alert acceptance.
The historical results below support the migrated completed tasks. They were not rerun during this planning review.

## Out of scope

- Session ordering, request classification, concurrency, freshness, and unknown-state presentation: `session-state` and `notch/session-island`.
  The existing inbox and store are consumers used to verify delivery here.
- Hook installation, removal, trust handling, and integration-health controls: the setup and health specs in this area.
- Optional terminal navigation, remaining installed-agent checks, and final first-use acceptance.
  Preserve N6–N8 and R6–R8 in the source spec until their destinations are written.
- Permission decisions, structured answers, and follow-up replies: the `actions` area and its separate contracts.
- Provider allowance, pet behavior, persistent session history, retries, acknowledgements, and disk spooling.
- Guarantees for arbitrary prose questions, unsupported lifecycle events, or events emitted while the app is closed.

## Constraints

- Keep SwiftUI/AppKit, shared stores, separate provider adapters, and the accepted [version-1 contract](../../contracts/agent-events-v1.md).
- Preserve the 262144-byte raw-input limit and 16384-byte frame limit.
  Preserve the 250 ms total helper deadline after executable entry and its 50 ms stdin/connect/write deadlines.
  The receiver frame deadline remains 100 ms after accept. Process launch time is additional.
- Keep `/private/tmp/notch-pet-<uid>/events-v1.sock`, directory mode `0700`, and socket mode `0600`.
  Same-user checks do not authenticate a provider and cannot authorize an action.
- Keep raw content, credentials, runtime files, and captured session data outside the repository.
  Do not read transcripts or forward prompts, commands, or raw tool input.
- Preserve existing Codex, Claude Code, and Otty configuration.
  This observer does not install hooks or bypass provider trust review.
- Preserve original task wording, checkbox states, and G1/G2 IDs during migration.
  Historical task sizes describe past work. Apply the current per-session limits to any new implementation task.

## Verify

- Seam: bundled `NotchPetHook` process through the production socket receiver and bounded inbox into the shared store.
- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Helper process checks: `python3 scripts/check-event-bridge.py`, with the app stopped.
- Contract reference checks: `python3 scripts/check-event-contract.py`.
  Its known unseen-turn recovery discrepancy belongs to the later session-state review.
  Reference-model success alone cannot establish correct production behavior.
- Real app lifecycle: `bash scripts/run.sh`, followed by Quit and owned-socket cleanup inspection.
- Documentation: local links resolve, original task text and checkbox totals remain intact, and `git diff --check` is clean.

These are reproduction commands, not authorization to restart paused runtime checks.
This planning session runs documentation checks only.

## Decisions

- [0001: Use SwiftUI and AppKit](../../decisions/0001-use-swiftui-and-appkit.md).
- [0002: Use services and shared stores](../../decisions/0002-use-mvvm-with-services.md).
- [0003: Keep live state in memory](../../decisions/0003-store-state-without-a-database.md).
- [0004: Observe official agent hooks](../../decisions/0004-receive-agent-hook-events.md).
- [0005: Use a local helper and Unix-domain socket](../../decisions/0005-use-a-local-unix-socket.md).
- [0008: Preserve conservative observations without persistent sequencing or replay](../../decisions/0008-define-event-ordering.md).
- [0009: Retain deferred Codex interactive checks](../../decisions/0009-defer-remaining-codex-interactive-checks.md).
- [0011: Preserve implemented features and evidence during record migration](../../decisions/0011-organize-records-by-feature.md).
- [0012: Support terminal-independent operation](../../decisions/0012-support-terminal-independent-operation.md).

## My calls

- Treat the bridge as an enabling feature, not a complete notification experience.
  Its end-to-end delivery checks let later features rely on it independently of their interface.
- Keep both provider projections in this spec because they deliver the same observation capability through the same contract.
  Provider setup remains separate because configuration can be reviewed independently.
- Retain the native shell here as shared setup, as the approved area index requires.
  Do not move later notch or usage behavior here merely because it shares the app entry point.
- Leave shared architecture investigation, usage investigation, and session-store tasks in the source spec for their later migration.
  Link their accepted decisions here without duplicating completed task counts.
- Leave out `Status: done` pending review of this retrospective spec.
  Migrated completed tasks do not establish final release acceptance.

## Implementation review, 2026-10-29

Checked the accepted contract, source-spec requirements and evidence, decisions 0001–0005 and 0008,
the helper, both provider adapters, parser, socket support, receiver, inbox, app lifecycle wiring, and relevant test code.
This was a static scope review. No build, process probe, agent invocation, or app walkthrough ran.

- **Delivery boundary fits the requirement.** `HookHelper.run` projects allowed fields through the provider adapter.
  `EventBridgeClient` sends one frame. `EventBridgeServer` validates it before calling its consumer.
  `SessionEventInbox` moves receipt into the app's main-thread store.
  This is a complete delivery path, while presentation remains another feature.
- **Provider adapters preserve evidence limits.** Both accept the investigated seven hook names.
  They omit content and retain missing identities instead of inventing them.
  Their existence does not establish current installed-agent compatibility.
- **Failure behavior fits an observer.** The helper returns silently on handled failures and has no response channel.
  The app starts and stops the receiver through its delegate.
  This supports observation without granting permission or waiting indefinitely for the app.
- **Receipt and session meaning stay separate.** The receiver supplies wall and monotonic receipt times.
  The inbox passes observations to the store, which owns their meaning and uncertainty.
  Moving request classification into the bridge would couple delivery to later session behavior without a requirement.
- **One existing socket test has a known timing assumption.** `invalidFramesNeverReachCallback` includes a maximum-size frame plus an extra byte.
  That byte can require a later write, after the receiver has checked buffered bytes.
  The accepted contract rejects extra bytes already buffered after LF, not every later byte.
  Historical evidence records this distinction. Keep its correction proposed, without weakening framing or claiming deterministic coverage.
- **Existing app edits remain unverified.** The working tree includes usage receiver wiring in `NotchPetApp.swift` and `NotchPanelController.swift`.
  The saved interrupted build has no result. Historical bridge results do not verify these edits.

Judgment: retain the approved observation-bridge boundary.
No new code-shape decision is needed for this migration.
Remaining visible-alert and live-provider checks must stay open in their owning specs.

## Tasks

These seven tasks are migrated completed work, not a new implementation list.
The first five had no IDs in the source checklist. Their historical evidence numbers are 1, 4, 5, 6, and 8 respectively.
G2 retains the original Claude adapter task-9 evidence.

- [x] Verify installed agent event coverage and Otty pane identity; save a compatibility matrix and sanitized example payloads.
- [x] Add the native app shell with a menu-bar quit action and a reproducible local launch command.
- [x] Specify the versioned event contract with session identity, ordering, freshness, and bounded payload behavior.
- [x] Add the local event bridge with checks for malformed input and an unavailable app.
- [x] Implement the Codex event adapter and verify it with fictional inputs.
- [x] G1: Resolve the maximum-input helper deadline failure while preserving accepted payload bounds, the 250 ms internal deadline, and silent failure behavior; complete the helper process checks.
- [x] G2: Complete verification of the implemented Claude Code adapter using the full bridge and store checks before marking the original adapter task complete.

Coverage: native launch maps to the shell task. Projection and receipt map to the bridge, Codex adapter, and G2 tasks.
Input rejection, bounds, silent failure, and endpoint lifecycle map to the contract, bridge, G1, and G2 tasks.
The investigation task records source coverage limits rather than replacing remaining live acceptance.

## Historical evidence

The following records are copied from the [source specification](../notch-companion.md#historical-implementation-evidence).
They retain their historical context, including failures later resolved by G1/G2.
Store-specific evidence and partial interactive task-21 evidence remain there for their own feature migrations.

Task 1 evidence: [compatibility matrix](../../notes/agent-event-compatibility.md) and
[fictional payload examples](../../notes/agent-event-examples.json).
Installed-agent runtime checks used a local mock provider. Full interactive Otty verification remains part of adapter and final workflow checks.

Task 4 implementation: `Package.swift`, `Sources/NotchPet/NotchPetApp.swift`, `Resources/Info.plist`, and `scripts/run.sh`.
The build and launch succeeded. The user's screenshot confirms the menu, and the user confirmed that selecting Quit closes the app.

Task 5 evidence: [version-1 event contract](../../contracts/agent-events-v1.md),
[fictional validation and state cases](../../contracts/agent-events-v1-cases.json), and
[accepted ordering decision 0008](../../decisions/0008-define-event-ordering.md).
`python3 scripts/check-event-contract.py` passes 68 message cases, 37 state sequences with 122 steps, and four memory-capacity checks.
The checker also verifies the document policy values and local links.
The checker remains a reference model. Task 6 supplies real transport and deadline checks.
At that checkpoint, adapters and shared-store behavior remained unimplemented.

Task 6 implementation: the shared `Sources/EventBridge/` target, `Sources/NotchPetHook/main.swift`,
app lifecycle ownership, and the bundled helper in `scripts/run.sh`.
The receiver validates one bounded envelope per connection and checks peer user IDs, endpoint ownership,
permissions, delivery age, framing, and deadlines.
The helper projects allowed fields, has one delivery attempt, and returns silently on handled failures.
It neither installs hooks nor retains messages. At that checkpoint, the app discarded validated observations.

`env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`
passes 15 tests, including all 68 existing contract message cases through the production Swift decoder.
`python3 scripts/check-event-bridge.py` passes unavailable-app, 15 fictional hook projections,
exact raw-input capacity, invalid-input, open-stdin, and busy-socket checks through actual helper processes.
`bash scripts/run.sh --build-only` builds both bundled executables with Command Line Tools.
A local smoke check also verified app startup, silent helper invocation, and owned-socket removal on Quit.
Full Xcode is needed for tests on this Mac; the selected Command Line Tools cannot import test frameworks.

The shared-store task can consume `EventBridgeServer.start(onEnvelope:)` and call `stop()` at shutdown.
The callback runs on the bridge worker and must return promptly.
`ReceivedHookEnvelope` contains `envelope`, `receiptWallMs`, and `receiptMonotonicNs`.
`HookEnvelopeV1.decode(frame:)` and `EventBridgeClient.send(_:)` are the common wire interfaces.
At that checkpoint, adapters, ordering, freshness expiry, and live session presentation remained later tasks.

Task 8 implementation: `Sources/EventBridge/CodexEventAdapter.swift` owns Codex raw payload projection.
`HookEnvelopeV1.project` routes Codex input through the adapter while retaining common parser bounds and helper deadlines.
The adapter accepts only the seven investigated version-1 hook shapes and preserves supplied source identities.
It does not copy conversation content, read transcripts, infer missing identities, or install hooks.
`SessionObservationV1`, `SessionEventInbox`, and `SessionStore` retain shared meanings, ordering, and freshness rules.
At that checkpoint, the existing Claude projection remained in place for its separate adapter task.

`Tests/EventBridgeTests/CodexEventAdapterTests.swift` checks all seven fictional Codex examples,
ten unsupported hook names, metadata and content omission, missing identities, input bounds, and parser deadlines.
`Tests/SessionStateTests/SessionStoreTests.swift` checks projected Codex session meanings and uncorrelated requests.
Its real socket check now projects through `CodexEventAdapter` before delivery to the inbox and store.
At that checkpoint, the full Swift suite passed 41 tests across four suites, including eight adapter tests and 18 store tests.
The app bundle build, helper process checks, and contract checker also passed at that checkpoint.
These checks establish implementation behavior with fictional inputs.
Task 21 must verify installed Codex in interactive Otty sessions using isolated configuration.
The planning version check found `0.164.0`; the earlier controlled runtime evidence covers `0.163.0`.

Task 9 implementation, 2026-10-24: `Sources/EventBridge/ClaudeEventAdapter.swift` owns Claude raw payload projection.
`HookEnvelopeV1.project` routes Claude input through this adapter with the existing parser bounds and helper deadline.
The adapter accepts the seven investigated hook shapes and maps `prompt_id` to the common `turn_id`.
Missing source identities remain missing. The shared store still owns question classification, ordering, and freshness.
The adapter omits conversation content and does not install hooks or read transcripts.

`Tests/EventBridgeTests/ClaudeEventAdapterTests.swift` checks all eight fictional Claude examples,
ten unsupported hook names, field omission, missing identities, invalid input, byte bounds, and parser deadlines.
The shared-store tests now cover both providers' approval, structured-question, resolution, response-ready,
end, and uncorrelated-request behavior. Real socket checks deliver both providers through the inbox to the store.
The full Swift suite passed 48 tests across five suites. Both the app and helper built with Command Line Tools and Xcode.
The contract checker passed its existing cases. No live Claude or Otty verification was performed this session.

At the 2026-10-24 checkpoint, the task remained unchecked because `python3 scripts/check-event-bridge.py` failed its existing 262144-byte raw-input boundary check.
All 15 fictional payloads passed through the actual helper before that failure, including eight Claude examples.
The check failed twice with the Command Line Tools build and once with the Xcode build.
A temporary diagnostic measured about 3 ms to read that input and about 315 ms total after projection with Command Line Tools.
The existing parser consumed the 250 ms helper budget before delivery. This diagnostic did not measure the Xcode parser separately.
The process check also timed out launching the Xcode helper during a separate comparison attempt.
No parser or deadline change was made. The later invalid-input, open-stdin, and busy-socket process assertions were not reached.
The user-invoked next-task workflow requires stopping after the same failure three times.
See the [implementation findings](../../notes/agent-event-compatibility.md#claude-adapter-implementation-2026-10-24).

### G1/G2 verification, 2026-10-28

The user activated the [bounded bridge-verification goal](../../goals/finish-bridge-verification.md), approving G1/G2 only.
The historical full 250 ms timeout did not reproduce before changes with the current Xcode 6.2 and Command Line Tools 6.3.2 Swift compilers.
Both unchanged builds passed the helper process suite. This does not establish why the historical runs were slower.

A temporary Command Line Tools debug diagnostic isolated the padding scan in `StrictJSON.whitespace()`.
The original scan took roughly 75–98 ms for 262144 whitespace bytes; full maximum-size projection took about 72–77 ms.
Replacing only the per-byte array membership expression with a byte switch in a temporary copy reduced projection to about 7–15 ms.
The original loop also lacked deadline checks. A separate fictional maximum-size projection with 5 ms remaining
returned success after 94.7 ms, failing the diagnostic assertion.

`Sources/EventBridge/HookEnvelopeV1.swift` now scans the same four JSON whitespace bytes directly,
checks the existing deadline every 1024 bytes of padding, and checks it again before returning from parsing.
Private parser calls propagate timeout errors. Public APIs, strict validation, the 262144-byte raw limit,
16384-byte frame limit, 250 ms helper deadline, silent failure behavior, and one-attempt transport remain unchanged.
No adapter, test, fixture, check script, dependency, or agent/Otty configuration changed.

The same deadline diagnostic now throws timeout at 5.1 ms. A diagnostic compiled from the corrected production sources
projects the maximum-size fictional input for each provider in 3.6–4.4 ms across three invocations per provider.
These are local parser measurements excluding process launch, not a general latency guarantee.
Temporary diagnostic sources and executables remain outside Git in `/private/tmp/notch-pet-g1-i1rtavd8/`.

Verification performed after the parser correction:

- `bash scripts/run.sh --build-only` exits 0 with both bundled executables and a valid Info.plist.
- `env DEVELOPER_DIR=/Library/Developer/CommandLineTools bash scripts/run.sh --build-only` also exits 0.
- `python3 scripts/check-event-bridge.py` exits 0 with `Bridge process checks passed` for freshly built helpers from both toolchains.
  All 15 fictional projections, exact raw-input capacity, invalid-input rejection, unavailable-app, open-stdin, and busy-socket assertions pass.
  Recorded helper process ranges are 5–397 ms for Xcode and 7–493 ms for Command Line Tools, including launch.
  These process ranges are separate from the unchanged internal deadline.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`
  exits 0: 48 tests in five suites, zero failures, including both adapters and actual socket-to-store delivery.
- `python3 scripts/check-event-contract.py` exits 0: document policy/links, 68 message cases,
  37 state sequences with 122 steps, and four memory-capacity boundaries.
- `git diff --check` exits 0 with no output.

G1 and G2 are complete on this implementation evidence. Live Claude/Otty verification remains later release work;
the seven deferred Codex checks remain R6/R7 under decision 0009. The previously documented reference-model discrepancy
and socket-test timing assumption remain separate proposed follow-ups. No later task or action-channel choice is approved by this goal.
