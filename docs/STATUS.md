# Status

## Now

Branch: `feat/pets-built-in-pet`, continuing from `b71b2fe`. This checkpoint includes BP6a implementation, tests and records; the user authorized committing and pushing these changes on the same branch.
The user approved the BP6a/BP6b split and a bounded BP6a goal. The independent playback policy is complete; verification commands and results are recorded in `docs/specs/pets/built-in-pet.md`. PetView still selects the first frame; BP6b rendering/lifecycle/focus wiring is unimplemented and needs its own approved plan.
Source inspection supports the earlier BP1–BP5 implementation. BP1/BP4 retain historical completion evidence; BP2/BP3/BP5 acceptance remains incomplete. The earlier standalone-rabbit goal and deferred app acceptance were not resumed.
This session resumed only BP6a's focused tests and packaged build; no full-suite run, app launch or capture occurred. Other goals, telemetry implementation and battery budgets remain as previously recorded. Communicate in English as requested.

## Next

1. Plan BP6b from `docs/specs/pets/built-in-pet.md`: bound the rendering/lifecycle/focus wiring and verification to the task limits, and obtain approval before implementation or resuming actual app checks. Keep BP7 acceptance separate.
2. Plan Flux-like session-island opening/closing and limits presentation with their session/usage owners; retain the accepted pet-first architecture and optional services.
3. Plan `pets/agent-reactions` and `pets/detachable-pet`, preserving original P1/P2 source lines and drag-out/hide plus overlap-return. Coordinate monitoring controls with session setup and the optional collector.
4. Review the separate telemetry task lists and provisional battery budgets before starting C1 lifecycle/protocol design.
5. Resume rabbit visual/focus/Quit-relaunch and BP5 interaction acceptance only when requested. Resume the older notch/allowance goal only on explicit request.

## Blockers

- Rabbit app acceptance remains incomplete. The earlier command `python3 scripts/check-standalone-pet.py --app "/private/tmp/notch-pet-first/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-first/evidence` reached the first case's native window and zero production service-start snapshot, then failed with `could not create image from window` (`screencapture` exit 1). The six-case check did not pass; its capture failure cause remains unknown. Further tests/captures and the interrupted app-open request remain deferred by the user.
- BP5 setup/settings and live resizing are written, but interaction acceptance is deferred. BP6a proves the independent playback policy only; it does not verify appearance, scheduling, focus, Escape, Quit/relaunch or actual service isolation. BP6b, agent reactions and detachment require their own approved task slices.
- The sandboxed command `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --filter PetPlaybackPolicyTests` failed with `error opening '/Users/bytedance/.cache/clang/ModuleCache/Swift-7JL1KBZ3A6V3.swiftmodule' for output` / `Operation not permitted`. Approved outside-sandbox execution resolved this tooling restriction for BP6a; use the same approval mechanism if future Swift commands require the user cache. The subsequent expected missing-policy failure was resolved by implementation; details remain in the spec.
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
