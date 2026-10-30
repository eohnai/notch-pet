# Extensible agent integrations

Needs: observation-bridge

## Goal

Register Codex and Claude Code behind a common integration boundary so the connections screen
and session island can support another agent without another provider-specific UI flow.
This is the first feature of the [agent-session workflow goal](../../goals/agent-session-workflow.md).
See the [sessions area](area.md). Proposed branch: `feat/sessions-agent-adapters`.

## Done when

- A catalog describes the two implemented providers, their display names, supported observations,
  question-tool mappings, setup driver and independently verified capabilities.
- Existing Codex and Claude event adapters remain responsible for their payload differences.
  Shared session ordering, freshness and request retention remain in SessionStore.
- The helper, validator and semantic mapping use explicit provider registration instead of
  assuming every non-Codex event is Claude. Unknown providers are still rejected by v1.
- A test-only third registration appears through the same catalog/connection presentation path
  without adding UI branches. It has no executable hook or falsely supported wire capability.
- Existing fixtures still pass through the actual helper, receiver and session store for both agents.
- Pet-only startup creates no integration probes, receivers or provider refresh processes.

## Out of scope

- Implementing Cursor, OpenCode, Kimi, Gemini, Copilot, Hermes, Aiden, Sara or other agents.
- Loading executable plugins, downloading adapters, accepting arbitrary provider IDs, or widening v1.
- Adding allowance, action channels, terminal adapters, telemetry or a collector to this abstraction.

## Constraints

- Retain the accepted event contract and independently supplied pet module.
- A catalog entry describes supported evidence, not an assertion that an agent is installed or active.
- A future provider needs its own payload investigation, contract/validator update and conformance tests.
- Each implementation slice: at most three changed files, three added production functions and five
  added test cases. Proposed workflow-record exemption is described in the goal; split before coding.

## Verify

- Seam: registered adapter through NotchPetHook, EventBridgeServer and SessionStore.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-agent-workflow/build --filter AgentAdapterTests`:
  proposed five tests, zero failures; preserve existing adapter and contract tests.
- `python3 scripts/check-event-bridge.py` and `python3 scripts/check-event-contract.py`: exit 0.
  The known reference-model conflict must be reported, not silently repaired in this feature.
- Full suite/build and no-capture native checks are specified in the goal and need renewed approval.

## Decisions

- **Built-in adapter catalog, accepted 2026-10-30.** Both considered structures provide a common boundary.
  Built-in adapters reuse the current release and type checking, but adding one requires a release.
  Runtime plugins allow separate distribution, but require loading, trust, compatibility and lifecycle machinery.
  The user approved the recommended built-in structure and activated the goal; runtime plugins remain out of scope.
- The user requested extensibility after confirming Codex and Claude plus the session island on
  2026-10-30. This accepts the requirement, not a particular protocol or extra provider coverage.

## Proposed structure

Built-in option: EventBridge owns event projection and provider event metadata; SessionState owns
setup drivers and health; the app owns registration, lifecycle and controls. Views consume descriptors
and shared snapshots. Dependencies continue to point toward EventBridge, never toward the app or Pet.

Plugin option: an app-owned host loads versioned external providers and mediates event/setup requests.
It needs a separate plugin protocol, isolation and failure policy before providers can participate.
This is a different ownership structure, not a flag added to the built-in catalog.

Proposed signatures for the built-in option, finalized before implementation:

```swift
// EventBridge: bounded projection only; no service or configuration access.
protocol AgentEventAdapter {
    var descriptor: AgentEventDescriptor { get }
    func project(rawHook: Data, paneSelector: String?) throws -> HookEnvelopeV1
}
// SessionState: explicit inputs; apply/remove revalidate current files.
protocol AgentSetupDriver {
    func plan(_ request: AgentSetupRequest) -> AgentSetupPlan
    func apply(_ request: AgentSetupRequest) -> AgentSetupResult
    func remove(_ request: AgentRemovalRequest) -> AgentSetupResult
}
// A provider registration binds these capabilities; it does not start services.
// Example: catalog[.codex].setup.plan(disposableRequest)
```

Do not put usage refresh, terminal navigation or sending approvals into one mandatory agent interface.
Those are separate optional capabilities with separate evidence and owners.

## My calls

- Use the existing two projection implementations rather than replacing their validated field mappings.
- Keep test-only registrations private to tests; production lists only implemented providers.
- The screenshot is behavioral reference for one settings list, not evidence of Flux's internal architecture.

## Tasks

- [x] AD1: Settle the adapter ownership/design and descriptor contract, with five isolated catalog tests covering duplicate/unknown IDs, capability independence and a test-only third registration.
- [x] AD2: Route Codex projection through the registered event adapter, preserving the bounded helper and v1 allowlist with existing fixtures and at most five added tests.
- [x] AD3a: Register Claude projection and remove the temporary direct route, preserving existing adapter and deadline tests within three production files.
- [x] AD3b: Route question-tool mapping, helper provider validation and v1 provider validation through catalog metadata, preserving missing identities and request semantics within three production files.
- [x] AD4a: Add catalog-driven connection-row values with independent monitoring and health evidence, checking both real descriptors and a test-only third row without I/O in at most five tests.
- [ ] AD4b: Bind implemented setup drivers to app-owned connection presentation after CX/CL setup exists; preserve unavailable capability states and add no startup probes.
- [ ] AD5: Verify both providers through the real helper/receiver/store seam and record the additional-provider extension recipe without claiming third-provider transport support.

## Execution evidence, 2026-10-30

AD1 changed two implementation/test files: `Sources/EventBridge/AgentCatalog.swift` and
`Tests/EventBridgeTests/AgentAdapterTests.swift`. Added three production functions (descriptor initializer,
catalog initializer and lookup) and five tests. Initial focused compilation failed because catalog types
were absent. The first implementation compile exposed an unqualified existing validator call; qualifying
`HookEnvelopeV1.validString` resolved it. Focused command from Verify exited 0: five tests, zero failures.
The unchanged full baseline passed 129 tests before edits. `python3 scripts/check-event-contract.py`
passed 68 message cases, 37 state sequences/122 steps and four capacity boundaries; its recorded
unseen-turn disagreement is still not repaired by this work.

AD3 is split before coding: registration and semantic/helper validation otherwise touch four files.
The split preserves its scope and existing cases; no architecture choice is changed.

AD2 changed three production files and added one production function plus an internal protocol
requirement. No tests were added. Focused filter `AgentAdapterTests|CodexEventAdapterTests` exited 0:
13 tests in two suites passed, including deadlines, source mapping, unknown IDs and missing identity.

AD3a changed three production files, added no functions/tests and passed the focused filter
`AgentAdapterTests|CodexEventAdapterTests|ClaudeEventAdapterTests`: 20 tests, zero failures.

AD3b changed three production files with no new functions/tests. Focused adapter, EventBridge,
contract/socket and SessionStore suites passed 54 tests (36 bridge + 18 store), zero failures.
AD4 is split into metadata presentation now and setup-driver binding after those drivers exist;
this makes the prerequisite explicit rather than inventing placeholder installers.

AD4a changed two implementation/test files: `AgentConnectionRows.swift` and its five-test suite.
Added two production functions. The focused suite first failed with missing-type errors, then exited 0:
five tests, zero failures. The subsequent full suite and packaged build both exited 0. No app was launched.

The process checker initially failed before its cases because its `*/debug/NotchPetHook` glob found
no binary with the current Swift Xcode build layout. The built product at `out/Products/Debug/NotchPetHook`
and packaged helper have identical SHA-256. The user explicitly approved a fallback to that location;
the checker assertions remain unchanged. This is a separate one-file compatibility slice, not a weakened check.

The rebuilt helper checker subsequently exited 0 outside the sandbox (socket binding was denied inside):
15 fictional projections, both exact-size raw inputs, invalid/unsupported inputs, absent/busy receiver,
and bounded open stdin all passed. Actual helper process timing was 7–276 ms in the latest run.
Full current Swift checks passed 144 tests, zero failures; packaged build exited 0 with `Info.plist: OK`.
AD5 remains open until the combined helper/production-receiver/store seam is established; the process
checker uses its own listener and must not be described as native app acceptance.

The implemented internal event protocol uses static projection to retain the existing enum adapters
and helper deadline. This is the approved built-in structure; setup-driver signatures remain proposals
until their owning setup tasks establish concrete types. No executable runtime plugin loading is added.
