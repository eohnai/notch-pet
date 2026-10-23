# Notch companion for terminal coding agents

## Goal

Show when Codex CLI or Claude Code in Otty needs attention on the user's M2 MacBook Air.
Let a customizable pet move between the notch and desktop while sharing the same session state.
Show reported usage limits and reset times so the user can monitor available allowance.

## Done when

- A local SwiftUI/AppKit app launches with a menu-bar control and notch interface on the user's Mac.
- An approval request from each supported agent appears with the correct agent, project, and session.
- Each agent's finished response produces a response-ready notice without claiming the task succeeded.
- Dedicated input events are shown where verified; uncovered question types have documented limitations.
- Alerts from two concurrent sessions remain distinct, including sessions in the same project.
- Clicking each live-session alert focuses its recorded Otty pane.
- Closing a pane or restarting the app cannot present an unverified session as still working.
- The user can drag the pet onto the desktop and return it to the notch.
- A valid custom pet imports and responds to working, attention, response-ready, and idle states.
- A missing optional animation falls back safely; an invalid pet pack leaves the selected pet intact.
- Pet selection, size, sound preference, and valid placement survive an app restart.
- Both providers show real usage percentages and reset times for verified supported account modes.
- The compatibility record identifies modes without usage data; those modes show unavailable with a reason.
- Usage windows show freshness and used/remaining labels, and are not double-counted across sessions.
- Setup and removal preserve existing Otty hooks, unrelated agent settings, and Claude Code status-line output.
- App unavailability cannot auto-approve a tool or leave the terminal waiting indefinitely for this app.
- Documented checks cover sleep, wake, fullscreen, Space changes, external-display removal, and Reduce Motion.
- A five-minute idle profile and an animated-pet profile record CPU and memory measurements on the target Mac.

## Out of scope

- Entering replies, approving commands, or sending keystrokes through the island.
- Codex desktop, other coding apps, other terminals, SSH hosts, and remote computers in the first release.
- A cloud backend, user accounts, synchronization, searchable session history, or a pet marketplace.
- In-app artwork generation, a pet drawing editor, three-dimensional pets, and scripted pet plugins.
- Reading private usage endpoints, copying provider tokens, or estimating subscription quota from tokens.
- Guaranteed notification of arbitrary questions without a verified event source.
- Reuse of Flux Island code or internal assets. The user withdrew that reference.

## Decisions

- [0001: Use SwiftUI and AppKit](../decisions/0001-use-swiftui-and-appkit.md) — accepted.
- [0002: Use MVVM with services and shared stores](../decisions/0002-use-mvvm-with-services.md) — accepted.
- [0003: Store local state without a database](../decisions/0003-store-state-without-a-database.md) — accepted.
- [0004: Receive events through agent hooks](../decisions/0004-receive-agent-hook-events.md) — accepted.
- [0005: Deliver events through a Unix socket](../decisions/0005-use-a-local-unix-socket.md) — accepted.
- [0006: Import asset-only pet packs](../decisions/0006-import-asset-only-pet-packs.md) — accepted.
- [0007: Read usage through supported interfaces](../decisions/0007-read-supported-usage-data.md) — accepted.
- [0008: Use conservative event ordering](../decisions/0008-define-event-ordering.md) — accepted.

## My calls

- Use `notch-pet` as a working name and a separate local Git repository.
- Keep project records in `docs/` because this is a single repository.
- Use `planning/initial-scope` as the initial branch. Create no remote or commits.
- Include limits after the notification and pet foundations; retain both providers in the planned first release.
- Start with one selected pet, with custom artwork supplied through imports.
- Use response ready as the default completion label.
- Treat detailed colors, animation timings, usage layout, and performance budgets as prototype decisions.
- Track no deadline or assigned owner because the user supplied neither.

## Tasks

The user approved this scope and task list on 2026-10-22.
The user approved architecture recommendations 0002–0007 and proceeding directly to the app shell on 2026-10-22.
Each task should fit one work session; split it if the investigation shows otherwise.
The user approved splitting Codex implementation from interactive Otty verification on 2026-10-23.

- [x] Verify installed agent event coverage and Otty pane identity; save a compatibility matrix and sanitized example payloads.
- [x] Verify both providers' usage sources and account-mode limitations without exposing credentials or starting agent turns.
- [x] Settle proposed architecture records using the compatibility findings and user review.
- [x] Add the native app shell with a menu-bar quit action and a reproducible local launch command.
- [x] Specify the versioned event contract with session identity, ordering, freshness, and bounded payload behavior.
- [x] Add the local event bridge with checks for malformed input and an unavailable app.
- [x] Add the shared session store with checks for duplicate, delayed, concurrent, and terminal-state events.
- [x] Implement the Codex event adapter and verify it with fictional inputs.
- [ ] Verify installed Codex in interactive Otty sessions using isolated configuration.
- [ ] Add the Claude Code event adapter using verified hook coverage.
- [ ] Add reversible hook setup that preserves existing Otty and agent configuration.
- [ ] Add the Otty navigation adapter with checks for correct-pane and closed-pane behavior.
- [ ] Add the notch view with session selection and unresolved-input priority.
- [ ] Add the detachable pet window with drag-out, return, and shared alert state.
- [ ] Add pet-pack validation with safe animation fallbacks and a documented example pack.
- [ ] Add settings persistence for pet selection, size, sound, and valid screen placement.
- [ ] Add Claude Code usage forwarding while preserving the existing status-line output.
- [ ] Add the read-only Codex usage provider using the verified connection method.
- [ ] Add the limits view with distinct windows, reset times, account grouping, and stale/unavailable states.
- [ ] Add window recovery for sleep, wake, fullscreen, Spaces, and display changes.
- [ ] Profile idle and animated operation on the M2 Air; address measured issues and Reduce Motion behavior.
- [ ] Verify the first-use workflow and document local packaging, supported versions, setup, removal, and known limits.

## Coverage check

Task 1 evidence: [compatibility matrix](../notes/agent-event-compatibility.md) and
[fictional payload examples](../notes/agent-event-examples.json).
Installed-agent runtime checks used a local mock provider. Full interactive Otty verification remains part of adapter and final workflow checks.

Task 2 evidence: [usage-source compatibility](../notes/usage-source-compatibility.md).
Codex account reads returned real quota windows without agent turns.
Claude field support and account eligibility were checked; live quota forwarding remains unverified until the forwarding task.

Task 3 evidence: decisions 0002–0007 are accepted after user review on 2026-10-22.
The architecture preserves the investigations' coverage limits and distinguishes unknown account identity from confirmed account grouping.

Task 4 implementation: `Package.swift`, `Sources/NotchPet/NotchPetApp.swift`, `Resources/Info.plist`, and `scripts/run.sh`.
The build and launch succeeded. The user's screenshot confirms the menu, and the user confirmed that selecting Quit closes the app.

Task 5 evidence: [version-1 event contract](../contracts/agent-events-v1.md),
[fictional validation and state cases](../contracts/agent-events-v1-cases.json), and
[accepted ordering decision 0008](../decisions/0008-define-event-ordering.md).
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

Task 8 implementation: `Sources/EventBridge/CodexEventAdapter.swift` owns Codex raw payload projection.
`HookEnvelopeV1.project` routes Codex input through the adapter while retaining common parser bounds and helper deadlines.
The adapter accepts only the seven investigated version-1 hook shapes and preserves supplied source identities.
It does not copy conversation content, read transcripts, infer missing identities, or install hooks.
`SessionObservationV1`, `SessionEventInbox`, and `SessionStore` retain shared meanings, ordering, and freshness rules.
The existing Claude projection remains in place for its separate adapter task.

`Tests/EventBridgeTests/CodexEventAdapterTests.swift` checks all seven fictional Codex examples,
ten unsupported hook names, metadata and content omission, missing identities, input bounds, and parser deadlines.
`Tests/SessionStateTests/SessionStoreTests.swift` checks projected Codex session meanings and uncorrelated requests.
Its real socket check now projects through `CodexEventAdapter` before delivery to the inbox and store.
The full Swift suite passes 41 tests across four suites, including eight adapter tests and 18 store tests.
The app bundle build, helper process checks, and contract checker also pass.
These checks establish implementation behavior with fictional inputs.
Task 9 must verify installed Codex in interactive Otty sessions using isolated configuration.
The planning version check found `0.164.0`; the earlier controlled runtime evidence covers `0.163.0`.

Task 9 partial evidence, 2026-10-23: Codex `0.164.0` ran interactively in two isolated Otty panes with a loopback mock provider.
Actual helper events reached the production bridge, inbox, and store through a temporary receiver.
Observed paths include text turns, command approval and cancellation, an accepted marker write, structured-question selection,
concurrent same-folder sessions, freshness expiry, and an unsupported `Interrupt` event.
Interruption left an unresolved approval notice and prevented later same-session activity from restoring known state.
This follows the accepted contract and remains a documented usability limit.
The user questioned further probing, so cleanup restored configuration and closed only disposable panes.
The task remains unchecked because controlled trust, default-mode question dispatch, explicit denial,
graceful end, controlled abrupt loss, prose questions, and interactive unavailable-receiver checks remain incomplete.
See the [partial interactive findings](../notes/agent-event-compatibility.md#partial-interactive-codex-verification-2026-10-23).

| Acceptance area | Tasks |
|---|---|
| Source feasibility and architecture | 1–3 |
| Local launch and event delivery | 4–6 |
| Honest session state and both agents | 7–10 |
| Reversible setup and terminal behavior | 11–12 |
| Session alerts and notch presentation | 13 |
| Pet interaction, imports, and preferences | 14–16 |
| Both providers' usage limits | 2, 17–19 |
| Desktop recovery and resource use | 20–21 |
| End-to-end acceptance and handoff | 22 |

