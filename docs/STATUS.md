# Status

## Now

Branch: `feat/pets-built-in-pet`, continuing from `20802c4`. This checkpoint includes BP6b1 rendering, three new tests and project records; the user authorized committing and pushing these four files on the same branch. The pre-existing STATUS checkpoint update is incorporated here.
The user approved the BP6b1/BP6b2/BP6b3 split and BP6b1 implementation only. PetView now uses the playback policy with monotonic elapsed time, cancellable scheduling, visibility/sleep inputs and Reduce Motion. BP6b1 verification commands and results are in `docs/specs/pets/built-in-pet.md`.
Native visibility/sleep wiring and actual scheduling/focus acceptance remain proposed in BP6b2/BP6b3. BP2/BP3/BP5 acceptance remains incomplete; prior BP1/BP4/BP6a evidence is retained.
No full-suite run, app launch or capture occurred. Older goals, deferred app acceptance, telemetry implementation and battery budgets were not resumed. Communicate in English as requested.

## Next

1. Review and approve a bounded BP6b2 plan from `docs/specs/pets/built-in-pet.md` for app-owned panel/settings visibility and sleep wiring. Keep BP6b3 actual-app playback/focus acceptance and BP7 standalone-flow acceptance separate.
2. Plan Flux-like session-island opening/closing and limits presentation with their session/usage owners; retain the accepted pet-first architecture and optional services.
3. Plan `pets/agent-reactions` and `pets/detachable-pet`, preserving original P1/P2 source lines and drag-out/hide plus overlap-return. Coordinate monitoring controls with session setup and the optional collector.
4. Review the separate telemetry task lists and provisional battery budgets before starting C1 lifecycle/protocol design.
5. Resume rabbit visual/focus/Quit-relaunch and BP5 interaction acceptance only when requested. Resume the older notch/allowance goal only on explicit request.

## Blockers

- Rabbit app acceptance remains incomplete. The earlier command `python3 scripts/check-standalone-pet.py --app "/private/tmp/notch-pet-first/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-first/evidence` reached the first case's native window and zero production service-start snapshot, then failed with `could not create image from window` (`screencapture` exit 1). The six-case check did not pass; its capture failure cause remains unknown. Further tests/captures and the interrupted app-open request remain deferred by the user.
- BP5 setup/settings and live resizing are written, but interaction acceptance is deferred. BP6a verifies the independent policy; BP6b1 adds rendering and component frame-selection checks. Existing callers still default to visible/awake. Actual scheduling, native lifecycle, appearance, focus, Escape, Quit/relaunch and service isolation are not established by these tests. BP6b2/BP6b3, agent reactions and detachment require their own approved task slices.
- The sandboxed BP6b1 command `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --filter 'Pet(ViewPlayback|PlaybackPolicy)Tests'` failed with `error opening '/Users/bytedance/.cache/clang/ModuleCache/Swift-7JL1KBZ3A6V3.swiftmodule' for output` / `Operation not permitted`. Outside-sandbox execution resolved this tooling restriction; use the approval mechanism if future Swift commands require the user cache. The expected pre-implementation missing-view-API failure was resolved by implementation; details remain in the spec.
- CodeGraph tooling was unavailable this session: `codegraph-remote explore "Locate built-in pet lifecycle rendering visibility sleep Reduce Motion focus implementation and related symbols"` first failed endpoint probes (TLS timeout/DNS); its approved outside-sandbox retry reported `repoId is not set`. Local source reads were used instead; no repository configuration was added.
- Telemetry C1–C8, H1–H7 and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability and instrumentation coverage require their recorded reviews. Battery targets are provisional and unmeasured.
- Stale: historical `ambiguous use of 'sync(execute:)'` reports in usage records do not match current NotchPanelController source and prior rabbit build evidence. No separate repair was made; review the owning usage record before changing it.
- Migration pending: 15 area specs have no file yet. Keep the source specification and its original tasks/evidence until every requirement has a destination; confirm its final move/removal before changing it.
- Terminal independence is accepted scope, not completed compatibility verification. Optional version-1 terminal metadata remains Otty-specific. N7–N8 need planning and live acceptance.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Settle the five open Claude allowance decisions before U2c3.
- Stale: `docs/specs/usage/codex-allowance.md` leaves U3b2 unchecked despite historical goal-log evidence. Review U3b2, U1 and I2a–I2c evidence before changing those checkboxes; session-state still awaits a closure decision.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Its correction remains proposed.
- Stale: `README.md` still calls implemented session/notch/usage surfaces planned and decision 0013 proposed; `docs/ARCHITECTURE.md` still describes visible session/usage and health services, plus the now-written pet boundary, as planned. Leave their unrelated edits with their owning work.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need feature planning. No deadlines are recorded.
