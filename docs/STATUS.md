# Status

## Now

CI F1–F7 merged in PR #8 as `51d9b86`. F8a diagnosed the subsequent hosted deadline-test failure. F8r repaired the test locally; it is uncommitted.
On `feat/automation-ci-foundation`, recreated from fetched `origin/main` at `51d9b86` with approval.
The former local branch is preserved as `archive/automation-ci-foundation-f7` at `a45d0ae`.
Installed configuration changes and older goals stay paused. F8b hosted acceptance remains open.

## Next

1. The user reviews, commits, and pushes F8r (`Tests/EventBridgeTests/ContractAndSocketTests.swift` plus records). Then authorize F8b's remaining hosted drills and final passing baseline. Keep the existing failed run visible.
2. Complete ci-foundation before session-cards C2. Plan automation/quality-gates next when its baseline exists; the other seven automation entries remain roadmaps.
3. Resume session-cards on its branch, retaining C1 in `1f30a3c`, then plan C2–C5 and allowance-strip A1–A5 with task-specific test authorization. Preserve the single batched visual review for C5/A5; the user supplies logo files for A3.
4. Do codex-setup R4 (architecture docs), then plan R2 (target split) and R3 (typed identities) with design review and renewed test authorization. Follow with R5/R6; R6 needs a user decision on the 128-session limit.
5. Before I3b2, review integration-health evidence and session-island acceptance using I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`. Codex 0.164.0 still needs isolated qualification.

## Blockers

- Hosted baseline failed: `gh run view 41275848518 --log-failed` shows main commit `51d9b86`, 131 passed tests and one failed test. `receiverDeadlineDoesNotResetForEachByte()` reported `Expectation failed: (successfulWrites → 1) >= 2` at `ContractAndSocketTests.swift:178`. Required rejected the failure. F8a reproduced the assertion with a 150 ms sender pause against unchanged receiver sources. The exact hosted scheduling remains unobserved. F8r's local repair retries attempts a sender pause leaves inconclusive and still fails a per-byte deadline reset; hosted confirmation waits for F8b. Evidence is in `docs/specs/automation/ci-foundation.md#f8a-hosted-baseline-diagnosis-2026-11-01` and `#f8r-deadline-test-repair-2026-11-01`.
- The user approved F8a's read-only hosted inspection, one focused local test, and disposable scheduling probes, then F8r's repair, focused test, disposable probes, and one full local suite run. Further repairs, broader tests, hosted drills, app launches, captures, and installed configuration changes need separate authorization. No workflow was dispatched, rerun, or cancelled in F8a or F8r. Account-specific security capabilities and additional runner combinations remain unqualified.
- Stale: `docs/goals/ci-foundation-local-log.md` still says F7 awaits commit approval. F7 is committed as `a45d0ae` and merged in PR #8. Preserve that historical goal record until its owning update.
- Stale: `docs/specs/sessions/codex-setup.md` "My calls": the bullet "Preserve the source checklist…" is joined onto the end of the R7/R8 bullet with no line break.
- Full built-in-pet acceptance is deferred: setup/slider/menu interaction, actual multi-frame scheduling, Reduce Motion changes and visual appearance remain unverified. Keep BP2/BP3/BP5/BP6b3/BP7 open; agent reactions and detachment remain separate unimplemented features. The implementation-only goal is closed.
- Capture reproduction command: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 scripts/check-standalone-pet.py --app "/private/var/folders/t3/6n_zw1rn5nn6vv7ccx9r6s240000gn/T/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-completion/evidence/standalone` failed with `could not create image from window` / screencapture exit 1. The native preflight returned screenCaptureAuthorized=false; the user explicitly prohibited further captures and later all further testing. Do not request that permission or retry the failing capture.
- Telemetry C1–C8, H1–H7 and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability and instrumentation coverage require their recorded reviews. Battery targets are provisional and unmeasured.
- Stale: `docs/specs/usage/codex-allowance.md` describes view-owned reads. AgentUsageController now owns those reads; NotchPanelController still owns the store/controller. Reconcile during feature review.
- Stale: `docs/specs/usage/claude-allowance.md` describes uncommitted receiver wiring and an `ambiguous use of 'sync(execute:)'` build error. Current app code has no UsageReceiver startup path or that closure. Review its five open decisions against current code before U2c3.
- I3b1's design is accepted, including the final independent-editor race and indistinguishable identical replacement. Codex 0.164.0 is a qualification candidate, not a qualified installer release. Effective enablement/policy evidence and timeout enforcement still need isolated verification. `integration-health` and `notch/session-island` acceptance remain open before dependent implementation.
- Migration pending: planned area specs still have no file, including monitoring-controls and the five settings/reference additions. Derive counts from the progress board. Codex setup maps its source obligations without removing shared I5/I6 tasks. Keep the source specification and its original tasks/evidence until every requirement has a destination; confirm its final move/removal before changing it.
- Terminal independence is accepted scope, not completed compatibility verification. Optional version-1 terminal metadata remains Otty-specific. N7–N8 need planning and live acceptance.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Settle the five open Claude allowance decisions before U2c3.
- Stale: `docs/specs/usage/codex-allowance.md` leaves U3b2 unchecked despite historical goal-log evidence. Review U3b2, U1 and I2a–I2c evidence before changing those checkboxes.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: `README.md` still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; `docs/ARCHITECTURE.md` still describes visible session/usage and health services, plus the now-written pet boundary, as planned. It also describes view models for every view; the code has none, and D3 now sets the rule (codex-setup R4). Leave their unrelated edits with their owning work.
- Stale: `docs/specs/sessions/integration-health.md` describes health supplied through the menu environment. Current `AgentServices` keeps its health controller private and the menu has no health controls; codex-setup I6a owns exposing those actions.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need planning in sessions/monitoring-controls. No deadlines or owners are recorded.
- Activity counting and token-counter sources remain unverified. Define coverage, units, deduplication, and time boundaries before statistics implementation. Hook events do not establish chat-message totals, and tokens do not establish remaining allowance.
