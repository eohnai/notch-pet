# Status

## Now

Branch: `docs/observation-bridge`. Commit `7564d7e` contains the first retrospective spec, `docs/specs/sessions/observation-bridge.md`. Its completed tasks and historical evidence are preserved. The spec awaits user review before `Status: done`.
The user requested specs based on approved requirements and accepted decisions, with code review to assess support, gaps, and feature boundaries. Existing code alone must not define the features. Other feature migrations remain unfinished.
The local `fix/reconcile-local-bridge-checks` branch was deleted at the user's request. Its commits remain on the current branch. The remote branch was not deleted. Existing edits in `NotchPanelController.swift`, `NotchPetApp.swift`, and `docs/goals/notch-agent-limits-log.md` remain uncommitted and untouched.
The notch/allowance goal remains paused after 26 logged turns of its 30-turn limit. Planning does not resume it. No app code changed or builds/tests ran during this planning and branch cleanup.

## Next

1. Review `sessions/observation-bridge` against its approved requirements, implementation review, and migrated evidence before marking the retrospective spec done.
2. Run `plan-feature` for `sessions/session-state`, then continue in area build order. Compare approved concurrent-session, pending-request, response-ready, and unknown-state behavior with the implementation. Preserve task IDs, checkbox states, requirements, and evidence, including implemented but unverified work.
3. Confirm the original spec's final move or removal only after every task and acceptance check has a destination. Update links and reconcile the progress board.
4. Before implementation resumes, plan the unfinished usage receiver wiring within `usage/claude-allowance`; review the interrupted build and app lifecycle checks.
5. Resume the paused goal only on explicit request. Reconcile its records and remaining budget first.

## Blockers

- Migration pending: other area specs still need feature files. The board combines migrated observation-bridge tasks and unmigrated tasks in the source specification. Missing spec files do not imply missing implementations.
- Interrupted check: `env TMPDIR=/private/tmp/notch-pet-notch-limits DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`. Its result was not captured before pause. The saved tool handle now reports `exec cell 190 not found`. The current source wiring is unverified.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Fixtures cannot establish live-source acceptance.
- Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Existing usage sockets have no crash-stale endpoint recovery.
- Stale: `docs/specs/notch-companion.md`: U3b2 remains unchecked although bounded Codex process I/O and a sanitized live read were verified earlier. Leave unchanged until an evidence review.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state. SessionStore enforces the accepted unseen-turn rule.
- Known test limitation: `Tests/EventBridgeTests/ContractAndSocketTests.swift` assumes a maximum-size frame's extra byte is already buffered. Historical diagnostics showed that byte can arrive later. The contract rejects buffered extra bytes. Correction remains proposed.
- Stale: `docs/ARCHITECTURE.md` describes visible session/usage surfaces and integration-health services as planned. Notch session/usage surfaces and integration-health code now exist, with incomplete verification recorded in the source spec and area indexes.
- Stale: `README.md` describes the notch, usage limits, and session presentation as planned. Their implementations exist with incomplete runtime verification. Review these descriptions during the owning feature migrations.
- Sprite-sheet input choice P5 remains proposed and blocks P6. No deadlines are recorded.
