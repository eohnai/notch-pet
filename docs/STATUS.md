# Status

## Now

Branch: `docs/observation-bridge` at `1b992b3`, with uncommitted documentation on top. The `migrate-implemented-specs` goal is done. `python3 docs/goals/check-spec-migration.py` printed 10/10 criteria pass with exit 0 this session.
Five retrospective specs now exist: `sessions/session-state`, `sessions/integration-health`, `notch/session-island`, `usage/codex-allowance`, and `usage/claude-allowance`. They moved 19 task lines and their evidence from the source spec, with checkbox states unchanged. Four stale single-spec and I2 lines in the source spec are marked superseded.
`usage/claude-allowance` records five open usage receiver decisions and one proposed task to settle them. That task awaits user approval. No code, build, test, or configuration access happened this session.
The notch/allowance goal remains paused after 26 of 30 turns. The uncommitted edits in `NotchPanelController.swift`, `NotchPetApp.swift`, and `docs/goals/notch-agent-limits-log.md` are unchanged.

## Next

1. Review the five new specs and the proposed settle task in `docs/specs/usage/claude-allowance.md`. Then commit the documentation. Choose whether to stack it on `docs/observation-bridge` or move it to a new branch first.
2. Settle the five open decisions in `usage/claude-allowance` (socket providers, stale socket recovery, receiver health, source lifetime, service ownership) before U2c3 continues.
3. Review the evidence for U3b2, U1, and I2a–I2c, recorded under Open questions in their specs, before you tick any of them. Decide whether to mark `sessions/session-state` done. Its only task is checked.
4. Run `plan-feature` for the next unwritten spec in area build order. Carry decision 0012 and N7–N8 into navigation and first-use planning.
5. Resolve P0 and proposed decision 0013 before pet implementation. Resume the paused goal only on explicit request.

## Blockers

- Build failure, found by the 2026-10-30 code review: `swift build` fails at `Sources/NotchPet/NotchPanelController.swift:37` with `error: ambiguous use of 'sync(execute:)'`. The reviewer confirmed in a scratch copy that `_ =` fixes it. It is not fixed. Recorded in `usage/claude-allowance`.
- Branch scope: `docs/observation-bridge` contains 21 commits beyond `origin/feat/notch-companion`, including earlier notch and usage code. Review the full branch before merging. Its name does not describe the full diff.
- Migration pending: 15 area specs have no file yet. The source spec still owns their tasks and evidence. Missing spec files do not imply missing implementations.
- Terminal independence is accepted scope, not completed compatibility verification. The optional version-1 terminal object and helper metadata stay Otty-specific. N7–N8 need planning and live acceptance.
- Standalone pet scope and packaging remain open in P0 and decision 0013.
- Keep the source spec until every task and acceptance check has a destination. Confirm its final move or removal with the user before changing it.
- Real Claude forwarding and terminal-output/cancellation preservation are incomplete. Codex reconnect, account switching, and remaining physical-notch acceptance are unverified.
- Stale: `docs/specs/usage/codex-allowance.md`: U3b2 is unchecked, but goal-log turn 19 records passing process tests and a sanitized live read. Leave it unchanged until an evidence review.
- Stale: `scripts/check-event-contract.py` lets a previously conflicting turn ID restore working state. `SessionStore` enforces the accepted unseen-turn rule.
- Known test limitation: `Tests/EventBridgeTests/ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. The byte can arrive later. Correction remains proposed.
- Stale: `docs/ARCHITECTURE.md` describes visible session/usage surfaces and integration-health services as planned. That code exists, with incomplete verification.
- Stale: `README.md` describes the notch, usage limits, and session presentation as planned. Their implementations exist, with incomplete runtime verification.
- Sprite-sheet input choice P5 remains proposed and blocks P6. No deadlines are recorded.
