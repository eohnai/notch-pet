# Status

## Now

The working tree is on `feat/pets-built-in-pet` at `b747da2`, with earlier uncommitted pet code, artwork, packaging, and planning changes preserved.
The user confirmed D2: one optional collector, local SQLite history, and next-task/debug-issue/checkpoint telemetry in one repository/release.
Three telemetry feature specs and their proposed task lists are saved alongside the battery requirements. Runtime contracts and task implementation still need review.
This planning work ran no builds, runtime profiles, Swift tests, service installs, hook changes, goal resumes, or agent-skills edits.

## Next

1. Review the three telemetry task lists in `docs/specs/telemetry/area.md`; start with C1's lifecycle/protocol design after approval. Review E1–E5 and initial battery budgets alongside them.
2. Review the existing standalone-rabbit goal and its current implementation/evidence with its owning work. Do not infer activation or resume it from telemetry planning.
3. Settle the five open decisions in `usage/claude-allowance` before U2c3. Review U3b2, U1, I2a–I2c, and session-state evidence before changing completion states.
4. Plan `pets/agent-reactions` and `pets/detachable-pet` when reached, preserving original P1/P2 lines. Coordinate monitoring controls with telemetry/background-collection.
5. Reassess the historical build-failure report during approved verification. Resume the paused notch/allowance goal only on explicit request.

## Blockers

- Telemetry scope and SQLite direction are confirmed; C1–C8, H1–H7, and S1–S6 remain proposed implementation tasks. Service lifecycle, IPC, schema/durability, and instrumentation coverage require their recorded reviews. Battery targets remain provisional and unmeasured.
- Stale: earlier standalone-pet records describe no implementation or artwork, but the working tree now contains both. Their activation, verification, and task completion need evidence review by the owning work; this session did not run or complete that goal.

- Stale: the historical `swift build` failure (`ambiguous use of 'sync(execute:)'` at `NotchPanelController.swift:37`) does not match current source: that file contains no `sync` call. No build ran to establish current build status. The BP3 blocker and `usage/claude-allowance` report still need review before editing their records.
- Migration pending: 15 area specs have no file yet. The source spec still owns their tasks and evidence. Missing spec files do not imply missing implementations.
- Terminal independence is accepted scope, not completed compatibility verification. The optional version-1 terminal object and helper metadata stay Otty-specific. N7–N8 need planning and live acceptance.
- The standalone-rabbit goal is not activated. Its proposed checkpoint-file budget exception and bounded BP1-BP4 task slices await approval. Original white lionhead artwork is chosen but not generated or bundled. Agent pause, disconnect, resume and notice retention still need planning.
- Stale: `docs/specs/pets/built-in-pet.md` still says the default artwork source needs resolution. The user has now chosen newly created original white lionhead rabbit artwork, recorded in the pets area decisions. The rest of the seven-task list is unchanged and still proposed.
- Keep the source spec until every task and acceptance check has a destination. Confirm its final move or removal with the user before changing it.
- Real Claude forwarding and terminal-output/cancellation preservation are incomplete. Codex reconnect, account switching, and remaining physical-notch acceptance are unverified.
- Stale: `docs/specs/usage/codex-allowance.md`: U3b2 is unchecked, but goal-log turn 19 records passing process tests and a sanitized live read. Leave it unchanged until an evidence review.
- Stale: `scripts/check-event-contract.py` lets a previously conflicting turn ID restore working state. `SessionStore` enforces the accepted unseen-turn rule.
- Known test limitation: `Tests/EventBridgeTests/ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. The byte can arrive later. Correction remains proposed.
- Stale: `docs/ARCHITECTURE.md` describes visible session/usage surfaces and integration-health services as planned. That code exists, with incomplete verification.
- Stale: `README.md` describes the notch, usage limits, and session presentation as planned. Their implementations exist, with incomplete runtime verification.
- Sprite-sheet input choice P5 remains proposed and blocks P6. No deadlines are recorded.
