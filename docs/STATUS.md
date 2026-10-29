# Status

## Now

Branch: `docs/observation-bridge` at `326e64f`, with uncommitted pet planning documents. Claude's five-spec migration and goal records are committed. Its goal log records completion, not new runtime acceptance.
The user accepted decision 0013: one app, an independent pet module, pet-first setup, and optional session-driven agent features. They approved separate built-in-pet and agent-reactions features.
`pets/built-in-pet` has seven proposed tasks awaiting user approval. Pet implementation has not started. Original task lines, checkbox states, and historical evidence stay unchanged.
This session changed documentation only. No builds, Swift tests, app checks, agent invocations, or configuration access ran. The notch/allowance goal remains paused at 26 of 30 turns, with its existing code edits and goal log untouched.

## Next

1. Review the seven proposed tasks and My calls in `docs/specs/pets/built-in-pet.md`. Resolve the default artwork source before implementation. Review and commit the pet planning documents when satisfied.
2. Settle the five open decisions in `usage/claude-allowance` (socket providers, stale socket recovery, receiver health, source lifetime, service ownership) before U2c3 continues.
3. Review the evidence for U3b2, U1, and I2a–I2c, recorded under Open questions in their specs, before you tick any of them. Decide whether to mark `sessions/session-state` done. Its only task is checked.
4. Run `plan-feature` for `pets/agent-reactions` next in the pet area. Keep P1 unchanged when migrating it. Plan Connect, Pause monitoring, and Disconnect with their session setup and first-use owners.
5. Resolve the reported app build failure through a separately approved fix before pet app checks. Resume the paused notch/allowance goal only on explicit request.

## Blockers

- Build failure, found by the 2026-10-30 code review: `swift build` fails at `Sources/NotchPet/NotchPanelController.swift:37` with `error: ambiguous use of 'sync(execute:)'`. The reviewer confirmed in a scratch copy that `_ =` fixes it. It is not fixed. Recorded in `usage/claude-allowance`.
- Branch scope: `docs/observation-bridge` contains 23 commits beyond `origin/feat/notch-companion`, including earlier notch and usage code. Review the full branch before merging. Its name does not describe the full diff.
- Migration pending: 15 area specs have no file yet. The source spec still owns their tasks and evidence. Missing spec files do not imply missing implementations.
- Terminal independence is accepted scope, not completed compatibility verification. The optional version-1 terminal object and helper metadata stay Otty-specific. N7–N8 need planning and live acceptance.
- Pet task approval is pending. Default artwork is not bundled. Agent monitoring pause, disconnect, resume, and notice-retention details still need feature planning.
- Keep the source spec until every task and acceptance check has a destination. Confirm its final move or removal with the user before changing it.
- Real Claude forwarding and terminal-output/cancellation preservation are incomplete. Codex reconnect, account switching, and remaining physical-notch acceptance are unverified.
- Stale: `docs/specs/usage/codex-allowance.md`: U3b2 is unchecked, but goal-log turn 19 records passing process tests and a sanitized live read. Leave it unchanged until an evidence review.
- Stale: `scripts/check-event-contract.py` lets a previously conflicting turn ID restore working state. `SessionStore` enforces the accepted unseen-turn rule.
- Known test limitation: `Tests/EventBridgeTests/ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. The byte can arrive later. Correction remains proposed.
- Stale: `docs/ARCHITECTURE.md` describes visible session/usage surfaces and integration-health services as planned. That code exists, with incomplete verification.
- Stale: `README.md` describes the notch, usage limits, and session presentation as planned. Their implementations exist, with incomplete runtime verification.
- Sprite-sheet input choice P5 remains proposed and blocks P6. No deadlines are recorded.
