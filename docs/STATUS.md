# Status

## Now

The user approved five areas and their feature lists, including implemented features. See `docs/specs/*/area.md` and decision 0011.
Area indexes are written. Feature specs and task/evidence migration remain unfinished; `docs/specs/notch-companion.md` remains their source.
Branch: `fix/reconcile-local-bridge-checks`. Existing receiver wiring remains unverified in two uncommitted source files. No app code changed or builds/tests ran during this planning work.
The notch/allowance goal remains paused after 26 logged turns of its 30-turn limit. Planning does not resume it.

## Next

1. Run `plan-feature` for `sessions/observation-bridge`, preserving completed foundation tasks and bridge evidence rather than implementing them again.
2. Continue feature migration in area build order. Preserve all task IDs, checkbox states, requirements, and verification evidence, including implemented but unverified work.
3. Confirm the original spec's final move or removal only after every task and acceptance check has a destination. Update links and reconcile the progress board.
4. Before implementation resumes, plan the unfinished usage receiver wiring within `usage/claude-allowance`; review the interrupted build and app lifecycle checks.
5. Resume the paused goal only on explicit request. Reconcile its records and remaining budget first.

## Blockers

- Migration pending: the progress board shows planned area specs as `no spec yet`. Counts still come from the original specification and do not imply missing implementations.
- Interrupted check: `env TMPDIR=/private/tmp/notch-pet-notch-limits DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`. Its result was not captured before pause. The saved tool handle now reports `exec cell 190 not found`. The current source wiring is unverified.
- Real Claude forwarding and terminal-output/cancellation preservation remain incomplete. Fixtures cannot establish live-source acceptance.
- Codex reconnect/account switching and remaining physical-notch acceptance are unverified. Existing usage sockets have no crash-stale endpoint recovery.
- Stale: `docs/specs/notch-companion.md`: U3b2 remains unchecked although bounded Codex process I/O and a sanitized live read were verified earlier. Leave unchanged until an evidence review.
- Stale: `scripts/check-event-contract.py` permits a previously conflicting turn ID to restore working state. SessionStore enforces the accepted unseen-turn rule.
- Sprite-sheet input choice P5 remains proposed and blocks P6. No deadlines are recorded.
