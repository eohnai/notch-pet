# Status

## Now

Branch: `feat/pets-built-in-pet`, saving the BP6b2 lifecycle implementation and records after `ada1984`. The user explicitly requested this checkpoint and then committing/pushing the feature changes on this branch; unrelated `.vscode/launch.json` is excluded and preserved.
The planned built-in-pet implementation is complete, including panel/settings visibility and sleep wiring. The implementation-only goal is closed; full feature acceptance remains incomplete and the spec stays open. Details are in `docs/specs/pets/built-in-pet.md` and `docs/goals/complete-built-in-pet-log.md`.
The user prohibited screen recording, then requested implementation without testing. Do not restart tests, builds, app launches/captures or test-only instrumentation unless requested. No new implementation or verification ran for this checkpoint.
Older goals and other feature work remain untouched. Communicate in English as requested.

## Next

1. Review the completed built-in-pet implementation and the goal/spec handoff. Keep BP2/BP3/BP5/BP6b3/BP7 acceptance deferred until the user requests it; do not treat them as pending coding tasks.
2. Plan Flux-like session-island opening/closing and limits presentation with their session/usage owners; retain the accepted pet-first architecture and optional services.
3. Plan `pets/agent-reactions` and `pets/detachable-pet`, preserving original P1/P2 source lines and drag-out/hide plus overlap-return. Coordinate monitoring controls with session setup and the optional collector.
4. Review the separate telemetry task lists and provisional battery budgets before starting C1 lifecycle/protocol design.
5. Resume the older notch/allowance goal only on explicit request.

## Blockers

- Full built-in-pet acceptance is deferred by the user's latest instruction: setup/slider/menu interaction, actual multi-frame scheduling, Reduce Motion changes and visual appearance remain unverified. Keep BP2/BP3/BP5/BP6b3/BP7 open; agent reactions and detachment remain separate unimplemented features.
- Capture reproduction command: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 scripts/check-standalone-pet.py --app "/private/var/folders/t3/6n_zw1rn5nn6vv7ccx9r6s240000gn/T/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-completion/evidence/standalone` failed with `could not create image from window` / screencapture exit 1. The native preflight returned screenCaptureAuthorized=false; the user explicitly prohibited further captures and later all further testing. Do not request that permission or retry the failing capture.
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
- Stale: `docs/specs/pets/area.md` summarizes implementation only through BP1–BP5 and the earlier capture failure. BP6b2 lifecycle wiring and later no-capture evidence are recorded in `built-in-pet.md`; retain that current feature-level handoff when selecting future work.
- Sprite-sheet input choice P5 remains proposed and blocks source P6. Monitoring pause/disconnect/resume and notice retention need feature planning. No deadlines are recorded.
