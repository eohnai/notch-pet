# Status

## Now

On `feat/sessions-codex-setup` at `622158c`, with the accepted I3b1 documentation review uncommitted.
Priority remains Sessions → Notch → Usage: optional Codex setup, a visible real session, and real Codex limits.
I3b1 is complete as a documentation review. The user accepted its version, timeout, ownership, recovery, and writer/identity choices on 2026-10-30.
This session changed documentation only. Pet acceptance, runtime checks, configuration changes, and older goals remain paused.

## Next

1. Review session-state closure, integration-health evidence, and remaining session-island acceptance before dependent implementation. Start from I3b1's prerequisite table in `docs/contracts/codex-hook-setup.md`. Do not resume runtime checks without an explicit request.
2. After those gates are resolved, plan I3b2 in `docs/specs/sessions/codex-setup.md` on this spec branch. Codex 0.164.0 still needs isolated qualification before installation can become available.
3. Review `usage/codex-allowance` evidence and remaining requirements for the first session-and-limits milestone. Preserve unchecked tasks until their acceptance is established.
4. Plan Claude setup/forwarding and monitoring controls in the approved area order. Keep configuration ownership separate from runtime control semantics.
5. After the session-and-limits path, plan settings/settings-window and general-preferences, notch/attention-behavior, and telemetry activity/token statistics with their listed dependencies. Keep actions, pets, and existing telemetry scope; resume older goals or deferred testing only on request.

## Blockers

- Existing no-testing instruction remains in force: do not start tests, builds, app launches/captures, or test-only instrumentation unless requested. Documentation checks do not resume runtime acceptance.
- Full built-in-pet acceptance is deferred: setup/slider/menu interaction, actual multi-frame scheduling, Reduce Motion changes and visual appearance remain unverified. Keep BP2/BP3/BP5/BP6b3/BP7 open; agent reactions and detachment remain separate unimplemented features. The implementation-only goal is closed.
- Capture reproduction command: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 scripts/check-standalone-pet.py --app "/private/var/folders/t3/6n_zw1rn5nn6vv7ccx9r6s240000gn/T/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-completion/evidence/standalone` failed with `could not create image from window` / screencapture exit 1. The native preflight returned screenCaptureAuthorized=false; the user explicitly prohibited further captures and later all further testing. Do not request that permission or retry the failing capture.
- Telemetry C1–C8, H1–H7 and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability and instrumentation coverage require their recorded reviews. Battery targets are provisional and unmeasured.
- Stale: `docs/specs/usage/codex-allowance.md` describes view-owned reads. AgentUsageController now owns those reads; NotchPanelController still owns the store/controller. Reconcile during feature review.
- Stale: `docs/specs/usage/claude-allowance.md` describes uncommitted receiver wiring and an `ambiguous use of 'sync(execute:)'` build error. Current app code has no UsageReceiver startup path or that closure. Review its five open decisions against current code before U2c3.
- I3b1's design is accepted, including the final independent-editor race and indistinguishable identical replacement. Codex 0.164.0 is a qualification candidate, not a qualified installer release. Effective enablement/policy evidence and timeout enforcement still need isolated verification. `integration-health`, session-state closure, and `notch/session-island` acceptance remain open before dependent implementation.
- Migration pending: 20 planned area specs have no file yet, including monitoring-controls and the five settings/reference additions. Codex setup maps its source obligations without removing shared I5/I6 tasks. Keep the source specification and its original tasks/evidence until every requirement has a destination; confirm its final move/removal before changing it.
- Terminal independence is accepted scope, not completed compatibility verification. Optional version-1 terminal metadata remains Otty-specific. N7–N8 need planning and live acceptance.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Settle the five open Claude allowance decisions before U2c3.
- Stale: `docs/specs/usage/codex-allowance.md` leaves U3b2 unchecked despite historical goal-log evidence. Review U3b2, U1 and I2a–I2c evidence before changing those checkboxes; session-state still awaits a closure decision.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: `README.md` still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; `docs/ARCHITECTURE.md` still describes visible session/usage and health services, plus the now-written pet boundary, as planned. Leave their unrelated edits with their owning work.
- Stale: `docs/specs/sessions/integration-health.md` describes health supplied through the menu environment. Current `AgentServices` keeps its health controller private and the menu has no health controls; codex-setup I6a owns exposing those actions.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need planning in sessions/monitoring-controls. No deadlines or owners are recorded.
- Activity counting and token-counter sources remain unverified. Define coverage, units, deduplication, and time boundaries before statistics implementation. Hook events do not establish chat-message totals, and tokens do not establish remaining allowance.
