# Status

## Now

On `feat/notch-session-cards`, preserving committed C1 `1f30a3c` and C2 `c25c699`. C3 is complete and uncommitted.
The expanded panel now requests 620 points wide and 240 points below the header. C3 evidence is in the session-cards spec.
Earlier CI cleanup and the plan remain in stash `0a6cb22a2cc1058c44ff87e01f8a1842ac6fdd60`.
No main merge ran. Existing agent configuration and older goals remain paused.

## Next

1. Review and commit C3, then plan session-cards C4's card UI and timer scheduling. C5 and allowance-strip A1–A5 follow separately. Preserve the single batched visual review for C5/A5; the user supplies logo files for A3.
2. Restore the CI cleanup on `feat/automation-ci-foundation` from stash `0a6cb22a2cc1058c44ff87e01f8a1842ac6fdd60`. Preserve completed C1–C3 when integrating its session-cards plan. Bring in latest main separately before PR review. Further automation work stays deferred while features take priority.
3. Do codex-setup R4 (docs only): update `docs/ARCHITECTURE.md` for stores, pure presentation functions, AppKit controllers, D3 and D5.
4. Plan codex-setup R2 (split targets), then R3 (typed agent/hook identities), with design review and renewed test authorization. Follow with R5 and R6; R6 needs a user decision on the 128-session limit.
5. Before I3b2, review integration-health evidence and session-island acceptance (start from I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`), then plan I3b2. Codex 0.164.0 still needs isolated qualification.

## Blockers

- C3's task list and focused placement tests were approved and are complete. Later tests, builds, helper injections, and runtime acceptance need their own task approval. The capture prohibition remains in force.
- The earlier CI cleanup and C2 plan are saved in stash `0a6cb22a2cc1058c44ff87e01f8a1842ac6fdd60`, named `preserve ci cleanup and c2 plan before feature work`. A patch backup is `/private/tmp/notch-pet-c2-documentation-before-switch.patch`. The saved cleanup drops F8b's remaining hosted acceptance work and records F10's passing PR/main baseline. Restore it on its owning CI branch. The temporary worktree was removed.
- This feature branch predates main's CI and socket-test repairs. Its old deadline and maximum-frame tests remain unchanged. C2 and C3 ran only their approved focused suites.
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
- Usage datagram limit remains unfixed: observations above the default 2,048-byte send limit or the receiver's 4,096-byte buffer can be silently dropped. The advertised 8,192-byte limit is unreachable with the current defaults. Main's records contain the probe evidence. Choosing a fix needs a separate decision.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: `README.md` still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; `docs/ARCHITECTURE.md` still describes visible session/usage and health services, plus the now-written pet boundary, as planned. It also describes view models for every view; the code has none, and D3 now sets the rule (codex-setup R4). Leave their unrelated edits with their owning work.
- Stale: `docs/specs/sessions/integration-health.md` describes health supplied through the menu environment. Current `AgentServices` keeps its health controller private and the menu has no health controls; codex-setup I6a owns exposing those actions.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need planning in sessions/monitoring-controls. No deadlines or owners are recorded.
- Activity counting and token-counter sources remain unverified. Define coverage, units, deduplication, and time boundaries before statistics implementation. Hook events do not establish chat-message totals, and tokens do not establish remaining allowance.
