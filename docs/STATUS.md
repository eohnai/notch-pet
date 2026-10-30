# Status

## Now

On `feat/sessions-codex-setup`. Codex-setup R1 is done and uncommitted: `docs/SWIFT-PRACTICES.md` exists and `AGENTS.md` links it.
On 2026-10-31 the user removed the three-file, three-function, and five-test task limits. Each task must now fit one session.
The user also chose to raise the target to macOS 14 and move to `@Observable`. These are new tasks R7 and R8.
The user authorized builds and tests for R7 and R8 only. Other runtime checks, configuration changes, and older goals stay paused.

## Next

1. Do codex-setup R7: raise the target to macOS 14 and record the decision. Verify with the spec's build command.
2. Do R8: move the five `ObservableObject` classes to `@Observable`. Verify with the spec's `swift test` command.
3. Plan R2 (split `SessionState` into `SessionState`, `Usage`, `Integration`), then R3 (typed `Agent` and `HookEvent`). Both need renewed test authorization.
4. Review integration-health evidence and session-island acceptance before I3b2. Start from I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`.
5. Do R4–R6 in any order, then plan I3b2 in `docs/specs/sessions/codex-setup.md`. Codex 0.164.0 still needs isolated qualification.

## Blockers

- Existing no-testing instruction remains in force: do not start tests, builds, app launches/captures, or test-only instrumentation unless requested. The user authorized builds and tests for codex-setup R7 and R8 only, on 2026-10-31. Documentation checks do not resume runtime acceptance.
- Full built-in-pet acceptance is deferred: setup/slider/menu interaction, actual multi-frame scheduling, Reduce Motion changes and visual appearance remain unverified. Keep BP2/BP3/BP5/BP6b3/BP7 open; agent reactions and detachment remain separate unimplemented features. The implementation-only goal is closed.
- Capture reproduction command: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 scripts/check-standalone-pet.py --app "/private/var/folders/t3/6n_zw1rn5nn6vv7ccx9r6s240000gn/T/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-completion/evidence/standalone` failed with `could not create image from window` / screencapture exit 1. The native preflight returned screenCaptureAuthorized=false; the user explicitly prohibited further captures and later all further testing. Do not request that permission or retry the failing capture.
- Telemetry C1–C8, H1–H7 and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability and instrumentation coverage require their recorded reviews. Battery targets are provisional and unmeasured.
- Stale: `docs/specs/usage/codex-allowance.md` describes view-owned reads. AgentUsageController now owns those reads; NotchPanelController still owns the store/controller. Reconcile during feature review.
- Stale: `docs/specs/usage/claude-allowance.md` describes uncommitted receiver wiring and an `ambiguous use of 'sync(execute:)'` build error. Current app code has no UsageReceiver startup path or that closure. Review its five open decisions against current code before U2c3.
- I3b1's design is accepted, including the final independent-editor race and indistinguishable identical replacement. Codex 0.164.0 is a qualification candidate, not a qualified installer release. Effective enablement/policy evidence and timeout enforcement still need isolated verification. `integration-health` and `notch/session-island` acceptance remain open before dependent implementation.
- Migration pending: 20 planned area specs have no file yet, including monitoring-controls and the five settings/reference additions. Codex setup maps its source obligations without removing shared I5/I6 tasks. Keep the source specification and its original tasks/evidence until every requirement has a destination; confirm its final move/removal before changing it.
- Terminal independence is accepted scope, not completed compatibility verification. Optional version-1 terminal metadata remains Otty-specific. N7–N8 need planning and live acceptance.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Settle the five open Claude allowance decisions before U2c3.
- Stale: `docs/specs/usage/codex-allowance.md` leaves U3b2 unchecked despite historical goal-log evidence. Review U3b2, U1 and I2a–I2c evidence before changing those checkboxes.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: `README.md` still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; `docs/ARCHITECTURE.md` still describes visible session/usage and health services, plus the now-written pet boundary, as planned. It also describes view models for every view; the code has none, and D3 now sets the rule (codex-setup R4). Leave their unrelated edits with their owning work.
- Stale: `docs/specs/sessions/integration-health.md` describes health supplied through the menu environment. Current `AgentServices` keeps its health controller private and the menu has no health controls; codex-setup I6a owns exposing those actions.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need planning in sessions/monitoring-controls. No deadlines or owners are recorded.
- Activity counting and token-counter sources remain unverified. Define coverage, units, deduplication, and time boundaries before statistics implementation. Hook events do not establish chat-message totals, and tokens do not establish remaining allowance.
