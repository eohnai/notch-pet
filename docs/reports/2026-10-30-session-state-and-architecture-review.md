# Session-state and architecture review, 2026-10-30

## Scope

This review answers three questions:

1. Does `sessions/session-state` meet its Done-when list, so that it can close?
2. Is the session-state code correct, clean, and good Swift practice?
3. Is the codebase structure sound, or does it need a refactor or rewrite?

The review read all of `Sources/` and the session-state tests. It changed no code.
Findings are proposals. Nothing in this report is an accepted decision until the user accepts it.

## Checks run

The user authorized tests for this review.

| Command | Result |
|---|---|
| `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build` | Exit 0. 129 tests in 23 suites passed. One compiler warning, in a test (see L7). |
| `python3 scripts/check-event-contract.py` | Exit 0. 68 message cases, 37 state sequences (122 steps), 4 capacity boundaries passed. |

No build, app launch, capture, or live agent ran.

## Lenses used

- Single responsibility: each type has one reason to change.
- Dependency inversion: a type receives its dependencies, so a test can replace them.
- Invalid states cannot be represented: enums, not strings, and no force unwraps that depend on rules in another file.
- Concurrency safety: actor isolation and each `@unchecked Sendable`.
- Lifecycle symmetry: `stop()` undoes everything that `start()` did.
- Error visibility, Swift API Design Guidelines naming, and no duplicated rules.

Inheritance-based object-oriented rules and most of open/closed, Liskov, and interface segregation do not apply here.
The code uses value types, enums, and two small protocols. It has no class hierarchies.

## 1. Session-state closure

| Done-when item | Evidence | Result |
|---|---|---|
| Two concurrent sessions stay distinct, also in one folder | `SessionKey` is agent plus session ID. The project path is not part of identity. `concurrentInboxProducersKeepSessionsSeparate` passes for 64 sessions. That test sets no `cwd`, so the same-folder case is met by construction, not by a test. | Met |
| Finished response gives a response-ready notice, not success | `Stop` maps to `.responseReady`. No success state exists. | Met |
| Unknown and ended stay distinct; retained requests are unconfirmed | Separate `.unknown` and `.ended` states. `SessionRequest.isConfirmed` is false while unknown. | Met |
| Closed pane or restart cannot show a stale session as working | State is in memory only. Records expire to unknown after 120 s without evidence. | Met |
| Ordering, identity, freshness, and memory limits; 37 sequences and 4 limits as Swift tests | `allContractStateSequences` reads `docs/contracts/agent-events-v1-cases.json`. Four capacity tests pass. | Met |
| Sleep, wake, and clock changes stop old evidence restoring fresh state | `AgentServices` observes the three notifications. Clock tests pass. Physical sleep/wake belongs to R3, as the spec's My calls state. | Met for this spec |
| Production bridge delivers both providers through the inbox to the store | `actualBridgeCallbackReachesSharedStore(agent:)` runs a real `EventBridgeServer` for `codex` and `claude`. | Met with fictional events. Live providers belong to N6 and R6–R7. |

**Recommendation:** close the spec with `Status: done`.
Every item has code and current test evidence. The checks that remain are assigned to other features by the spec itself.
The open question about the Python reference model does not block closure. It is a proposed fix to a check script, not to the store.

Finding H1 below is a product concern with the accepted contract. It is not a gap in this spec, because the spec requires the contract's limits.

## 2. Findings

Severity: **High** can affect users or block the next planned work. **Medium** makes change harder or risks a future bug. **Low** is cleanup.

### High

**H1. A long-running app stops showing new sessions after 128 sessions.**
`SessionStore.swift:86-89` refuses new session keys at `sessionLimit`. Ended records are never removed.
This follows the accepted contract (`docs/contracts/agent-events-v1.md:187`): "Refuse new session keys; do not evict a live session or terminal record".
Example: a user starts 20 agent sessions a day and leaves the app running. On day 7, new sessions no longer appear in the notch.
Nothing tells the user, because `applyBatch` discards the `.sessionCapacity` result.
The notch count also includes every ended session from that run.
Proposal: review the contract limit. One option is to evict the oldest ended record when the store is full. Another is to show a visible "capacity reached" state.

**H2. The `SessionState` module has no clear owner for the codex-setup planner.**
`SessionState` holds four concerns: session state, usage (`UsageStore`, two providers, `CodexUsageConnection`, `UsageReceiver`, `UsageDelivery`), integration health, and notch layout (`NotchPlacement`).
Task I3b2 adds hook-JSON scanning, and I3b3 adds a setup planner. Neither fits the module name.
Proposal: decide the module layout before I3b2 (see section 3).

### Medium

**M1. Integration-health logic lives in the app file and no test can reach it.**
`NotchPetApp.swift:21-93` holds `IntegrationHealthController`, about 75 lines. It searches `PATH`, reads `CODEX_HOME` and `CLAUDE_CONFIG_DIR`, and resolves configuration paths.
The same file holds the `App` scene, `AgentServices`, and the menu. The controller is `private`, so tests cannot reach the path rules.
Task I6a must expose it, and codex-setup must reuse the same `CODEX_HOME` rule.

**M2. The executable search is written twice, with different rules.**
`NotchPetApp.swift:40-49` falls back to `/usr/bin:/bin:/usr/sbin:/sbin`.
`AgentUsageController.swift:33-46` falls back to `/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin` and also adds `~/.local/bin`, `/opt/homebrew/bin`, and `/usr/local/bin`.
Example: `codex` is installed only in `~/.local/bin` and is not on the app's `PATH`. Usage finds it, but health reports `executableNotFound`.

**M3. Agent identity and hook names are plain strings across modules.**
`HookEnvelopeV1.agent`, `SessionKey.agent`, and `UsageObservation.provider` are `String`. `IntegrationAgent` is an enum in `SessionState`.
Hook names live in four places: `HookEnvelopeV1.hooks`, `CodexEventAdapter.supportedHooks`, `ClaudeEventAdapter.supportedHooks`, and the `switch` in `SessionObservationV1.swift:33-41`.
That switch ends with `default: kind = .sessionEnded`. If the validator ever accepts an eighth hook, those events silently end sessions.
Proposal: add `Agent` and `HookEvent` enums in `EventBridge`, the lowest module. Decode the wire strings into them once. The wire contract stays unchanged.

**M4. `ARCHITECTURE.md` describes view models that do not exist.**
The document and decision 0002 describe MVVM. The code has no view models.
Views observe stores directly, and pure enums (`NotchPresentation`, `NotchPlacement`, `PetPresentation`) prepare the presentation state. AppKit controllers own windows.
That pattern is testable and fits this app size. Proposal: update the document to describe it, and do not add view models.
This needs a decision, because it amends decision 0002.

**M5. Verification instrumentation runs in the production app.**
`ServiceStartLedger` is shared, mutable, static state. `PetPanelController.writeEvidence` writes JSON when `NOTCH_PET_EVIDENCE_DIR` is set. `PetAppController` reads `NOTCH_PET_PREFERENCES_SUITE`.
Each one has a safeguard: the evidence directory must be under a temporary root. They are still spread over three files.
Proposal: collect them in one `VerificationEvidence` type with one entry point. Whether to use `#if DEBUG` depends on whether isolated real-app checks use a release build. This review did not check that.

**M6. `SessionStore.reduce` is one function of about 110 lines.**
`SessionStore.swift:68-180` validates input, tracks the clock, allocates records, checks identity capacity, and applies lifecycle rules.
The rules are correct and tested. Their order matters, and that makes the function hard to change safely.
Proposal: split it into named steps: `validate`, `record(for:)`, `admitIdentity`, and `applyLifecycle`. Do this only when the next change to the store is planned, and keep every test unchanged.

**M7. Force unwraps depend on rules in other files.**
`SessionStore.swift:90` `records[key]!`, `:102` `turn!`, `:191` `event.toolName!`, and `EventBridgeServer.swift:61` `identity!`.
Each is safe today, because the validator or an earlier line guarantees the value. A future change to the validator could crash the app.
Proposal: use `guard let` with a bounded result such as `.invalidObservation`. M3's typed hook events make the `toolName` rule a type guarantee.

### Low

**L1. The same rules are written more than once.**
- The delivery-age window `30_000` / `-2000` ms: `EventBridgeServer.swift:111` and `SessionStore.swift:77`.
- Version-string validation: `IntegrationHealth.swift:100-103` and `:213-216`.
- Notch screen and width: `NotchPanelController.swift:23-28` and `:47-51`. Screen choice also appears in `PetPanelController.swift:26`.

**L2. After `AgentServices.stop()`, an inbox batch already queued can still reach the store.**
`stop()` does not drop `inbox`. A queued main-actor task then applies its batch after the bridge stops. The effect is small, because a stopped service hides the notch.

**L3. The expiry timer jumps to the main actor twice.**
`NotchPetApp.swift:166-171` creates a `Task { @MainActor in }` inside a handler that already runs on the main queue. `MainActor.assumeIsolated` removes the extra hop.

**L4. Store refusals leave no trace.**
`applyBatch` discards every `SessionApplyResult`. A bounded count by result, available to integration health, would explain an empty notch. It must not log event content.

**L5. Some lines pack several statements.**
Examples: `if let turn, let toolID { ... } else { ... }` on one line in `SessionStore.swift:193-194`, and `let a = rank(left), b = rank(right)` in `NotchPresentation.swift:21`. Write one statement per line.

**L6. `NotchPresentation.ordered` puts question and approval status in the same rank as unknown.**
`NotchPresentation.swift:16`. This is correct today, because those statuses always have confirmed requests and rank 0 first. The grouping is still confusing to read. A comment or an explicit rank would make the intent clear.

**L7. One compiler warning in the tests.**
`Tests/NotchPetTests/PetWindowPlaybackTests.swift:108`: "weak variable 'released' was never mutated; consider changing to 'let' constant".

## 3. Structure: refactor or rewrite?

**No rewrite.** The codebase is about 5,400 lines. Its dependency direction is sound, and its tests pass.

What is good:
- The dependency direction is one-way: `EventBridge` → `SessionState` → `NotchPet`. `Pet` imports no agent code, as decision 0013 requires. The hook helper depends only on `EventBridge`.
- Domain rules are in pure functions or main-actor stores, with tests. AppKit controllers are small.
- Swift 6 language mode is on. Only two types use `@unchecked Sendable`, and both protect their state with locks.
- Inputs are bounded by named constants. Diagnostics are enums, so raw configuration cannot leak.
- There are no third-party dependencies.

Proposed targeted refactors, most useful first:

1. **Split `SessionState` before I3b2.** Fixes H2 and M1.
   - `SessionState`: store, inbox, observation mapping, `NotchPresentation`.
   - `Usage`: usage store, providers, connection, receiver, delivery.
   - `Integration`: health model and probe, the executable and configuration-directory locator from the app target (fixes M2), and later the codex-setup scanner and planner.

   This costs one task of file moves and `Package.swift` changes. It leaves behavior unchanged. The alternative, one renamed module, keeps four concerns in one place.
2. **Add typed `Agent` and `HookEvent` enums in `EventBridge`.** Fixes M3 and part of M7.
3. **Align `ARCHITECTURE.md` with the actual pattern.** Fixes M4. Record it as an amendment to decision 0002.
4. **Collect verification instrumentation in one type.** Fixes M5.
5. **Clean up L1–L7** where a planned task already touches the file.

M6 waits for the next store change.

## 4. Practices file

**Recommendation:** add `docs/SWIFT-PRACTICES.md` and link it from `AGENTS.md`, because agents read `AGENTS.md` at the start of every session.
Write it from the conventions that the code already follows, plus the findings the user accepts. The conventions are:

- Keep stores `@MainActor`. Publish `Equatable`, `Sendable` value snapshots.
- Put domain rules in pure functions or static enums, with no AppKit or I/O, so tests can reach them.
- Bound every external input with a named constant. Report failures as small enums, and never include raw content.
- Use Swift Testing. Use parameterized tests for per-agent cases. Use fictional data only.
- Comment the reason for a rule, not what the code does.
- Use no force unwraps outside tests. Write one statement per line.
- Keep agent and hook identity typed. Decode wire strings once, at the boundary.

A linter (SwiftLint or swift-format) is not recommended now. It adds tooling and configuration for a small codebase. Revisit it if contributors increase.

## Proposed follow-up tasks

These are proposals. None is approved or added to a spec.

- Review the 128-session contract limit and its user-visible behavior (H1).
- Split `SessionState` into `SessionState`, `Usage`, and `Integration`, and move the locator out of the app target (H2, M1, M2). Do this before I3b2.
- Add typed `Agent` and `HookEvent` enums at the bridge boundary (M3, M7).
- Amend decision 0002 and `ARCHITECTURE.md` to match the store-and-presentation pattern (M4).
- Collect verification instrumentation in one type (M5).
- Write `docs/SWIFT-PRACTICES.md` and link it from `AGENTS.md`.

## Outcome, 2026-10-30

- The user closed `sessions/session-state` with `Status: done`.
- The user accepted all six follow-ups. They are tasks R1–R6 in [codex-setup](../specs/sessions/codex-setup.md).
- For M4, the user chose view models only where a view owns state. See [D3](../DECISIONS.md#d3-add-view-models-only-where-a-view-owns-state).
