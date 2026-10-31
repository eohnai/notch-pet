# Status

## Now

On `feat/automation-ci-foundation`, created from `origin/main` at `7735ec6` with the user's approval.
The user activated the 30-turn F1–F7 CI goal and authorized commits after verified tasks.
The separate I2d probe-fixture scheduling repair is committed as `7cb67f2`.
CI F1–F3 are committed. F3 is `2b12972`; F4's artifact handoff and downloaded-helper checks are locally verified.
Session-cards C1 remains on `feat/notch-session-cards` as `1f30a3c`; its implementation is not on this branch.
Installed configuration changes and older goals stay paused. Hosted F8 acceptance remains open.

## Next

1. Continue ci-foundation F5 on this branch: export real Swift coverage as HTML/JSON and per-module summaries, with missing/malformed-input rejection. Then complete F6/F7. F8 still needs the user's push.
2. Complete ci-foundation before session-cards C2. Plan automation/quality-gates next when its baseline exists; the other seven automation entries remain roadmaps.
3. Resume session-cards on its branch, retaining C1 in `1f30a3c`, then plan C2–C5 and allowance-strip A1–A5 with task-specific test authorization. Preserve the single batched visual review for C5/A5; the user supplies logo files for A3.
4. Do codex-setup R4 (architecture docs), then plan R2 (target split) and R3 (typed identities) with design review and renewed test authorization. Follow with R5/R6; R6 needs a user decision on the 128-session limit.
5. Before I3b2, review integration-health evidence and session-island acceptance using I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`. Codex 0.164.0 still needs isolated qualification.

## Blockers

- The F1–F7 goal authorizes its bounded local builds/tests and fictional helper checks. The user separately approved the I2d scheduling repair and CI resumption after verification. Broader testing, captures, app launches, installed configuration changes and other unrelated repairs remain outside authorization.
- Automation's F1–F7 implementation and local verification are approved. Hosted acceptance still requires the user's push; account-specific security capabilities and additional runner combinations remain unqualified. F1's original baseline and syntax failures were resolved and retained in its spec as historical evidence.
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
