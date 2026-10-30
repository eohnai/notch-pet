# Status

## Now

On `feat/sessions-codex-setup`. Codex-setup R8 is done and uncommitted: the five stores and controllers use `@Observable`, and decision D5 records how controllers observe stores.
R7 is committed (`5034dfd`). The user allowed app launches on 2026-10-31. Configuration changes and older goals stay paused.

## Next

1. Do codex-setup R4 (docs only): update `docs/ARCHITECTURE.md` for stores, pure presentation functions, AppKit controllers, D3 and D5.
2. Plan R2 (split `SessionState` into `SessionState`, `Usage`, `Integration`), then R3 (typed `Agent` and `HookEvent`). Both need renewed test authorization and a design review.
3. Do R5 and R6. R6 needs a user decision on the 128-session limit before any code change.
4. Review integration-health evidence and session-island acceptance before I3b2. Start from I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`.
5. Plan I3b2 in `docs/specs/sessions/codex-setup.md` after R1–R6. Codex 0.164.0 still needs isolated qualification.

## Blockers

- Existing no-testing instruction remains in force for tests, builds, captures, helper injections, and test-only instrumentation: do not start them unless requested. The user authorized builds and tests for R7 and R8 only; both are done. The user allowed app launches on 2026-10-31, and one fictional helper injection for the R8 check. Documentation checks do not resume runtime acceptance.
- Failed check, intermittent: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build` failed 1 of 3 full runs on 2026-10-31 with `IntegrationHealthProbeTests.versionProbeBoundsItsProcessAndOutput` reporting `.unavailable(.timedOut)` instead of `.unverified("99.0.0")` for both agents. The suite alone passed 3 of 3. The probe's process timeout appears too tight under parallel test load. ^[inferred] R8 does not touch the probe.
- Stale: `docs/specs/sessions/codex-setup.md` "My calls": the bullet "Preserve the source checklist…" is joined onto the end of the R7/R8 bullet with no line break.
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
