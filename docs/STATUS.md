# Status

## Now

Branch: `feat/pets-built-in-pet`. This checkpoint includes the rabbit implementation, artwork, packaging and records; the earlier telemetry-planning commit `67680e4` is preserved. The user authorized committing and pushing this work without resuming tests or app checks.
Implementation through BP5 is written: independent pet core/renderer, original white lionhead artwork, pet-first startup, optional agent services, size persistence and native setup/settings with menu access and Escape handling. BP1/BP4 are checked on earlier evidence; BP2/BP3/BP5 remain open for acceptance.
The standalone-rabbit goal is blocked on deferred acceptance. The user requested implementation focus and no further tests/captures; do not retry the interrupted app-open request. This checkpoint changes records only and does not resume the goal or authorize BP6/BP7.
Telemetry D2 remains accepted; collector/history/skill-telemetry implementation tasks and battery budgets remain proposed. No telemetry or older notch/allowance goal was resumed.

## Next

1. Review and approve BP6's bounded implementation plan for animation visibility, sleep, Reduce Motion and focus behavior before coding it. Keep BP7 acceptance separate.
2. Plan Flux-like session-island opening/closing and limits presentation with their session/usage owners; retain the accepted pet-first architecture and optional services.
3. Plan `pets/agent-reactions` and `pets/detachable-pet`, preserving original P1/P2 source lines and drag-out/hide plus overlap-return. Coordinate monitoring controls with session setup and the optional collector.
4. Review the separate telemetry task lists and provisional battery budgets before starting C1 lifecycle/protocol design.
5. Resume rabbit visual/focus/Quit-relaunch and BP5 interaction acceptance only when requested. Resume the older notch/allowance goal only on explicit request.

## Blockers

- Rabbit app acceptance is incomplete. `python3 scripts/check-standalone-pet.py --app "/private/tmp/notch-pet-first/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-first/evidence` reached the first case's native window and zero production service-start snapshot, then failed with `could not create image from window` (`screencapture` exit 1). The six-case check did not pass; capture failure cause is not established. Further tests/captures are deferred by the user.
- BP5 setup/settings and a live size control are written, with compile-only evidence. Interaction acceptance is deferred. BP6 lifecycle work, agent reactions and detachment are unimplemented and require their own approved task slices. The original goal plus explicit BP5 extension authorizes no further implementation.
- Telemetry C1–C8, H1–H7 and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability and instrumentation coverage require their recorded reviews. Battery targets are provisional and unmeasured.
- Stale: the historical `ambiguous use of 'sync(execute:)'` build report in usage records does not match current NotchPanelController source. The rabbit goal's unchanged-baseline and changed-source packaged builds succeeded earlier; no separate repair was made. Review the remaining usage record before changing it.
- Migration pending: 15 area specs have no file yet. Keep the source specification and its original tasks/evidence until every requirement has a destination; confirm its final move/removal before changing it.
- Terminal independence is accepted scope, not completed compatibility verification. Optional version-1 terminal metadata remains Otty-specific. N7–N8 need planning and live acceptance.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Settle the five open Claude allowance decisions before U2c3.
- Stale: `docs/specs/usage/codex-allowance.md` leaves U3b2 unchecked despite historical goal-log evidence. Review U3b2, U1 and I2a–I2c evidence before changing those checkboxes; session-state still awaits a closure decision.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: README still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; ARCHITECTURE still describes visible session/usage and health services, plus the now-written pet boundary, as planned. Leave their unrelated edits with their owning work.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need feature planning. No deadlines are recorded.
