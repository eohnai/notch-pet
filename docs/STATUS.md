# Status

## Now

The user cleared the menu/setup goal and requested updated planning, checkpointing and a replacement goal on 2026-10-29. Sessions belong in the notch, not the menu bar. The notch will show provider-specific 5-hour and weekly limits, initially for Claude Code and Codex. Only active providers appear: Codex-only hides Claude, Claude-only hides Codex, and both active shows both. Other agents are deferred.

The [notch/allowance goal](goals/notch-agent-limits.md) is active again. Placement, panel, width, session details and presentation rules are committed through aa552d6. U1's bounded in-memory usage store and five tests are implemented; provider sources and actual-notch quota display remain pending. No installed configuration changed. Branch: `fix/reconcile-local-bridge-checks`.

## Next

1. Review the U1 usage-store commit, then implement the Claude/Codex source adapters. Keep actual-app acceptance open; latest animation/width and detailed session behavior are not fully verified.
2. Implement U1–U6 alongside the notch: real Claude forwarding, read-only Codex quota and truthful provider-aware windows.
3. Keep I3 installation/recovery separate. Review a reversible plan before changing installed configuration.
4. Continue local actions and pet work after the notch/usage milestone. Settle sprite-sheet input before P6.
5. Retain all seven deferred Codex checks in R6–R7 before R8 under decision 0009.

## Blockers

- Goal active; U1 usage-store work is not committed yet. The old menu/setup goal remains cleared incomplete. No N3–N5 acceptance checkbox is ticked from build/unit checks alone.
- Real Claude quota forwarding, output preservation and cancellation remain unverified. Live data may require user-approved reversible status-line setup. Fixtures/unavailable labels cannot complete live-source acceptance.
- Codex long-running coexistence, sparse/cross-process updates and account switching remain unverified. Historical 300/10080-minute windows are not universal guarantees.
- Computer Use exact-bundle access returned `Computer Use server error -10005: timeoutReached`. Guided screenshots verify five I1 groups. Remaining menu checks are retired in favor of notch acceptance, not counted as passed. Do not request repeated screenshots.
- Earlier `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-codex-setup/notch-pet-dev/build` initially failed at IntegrationHealthTests.swift:206: `timedOut` instead of `invalidOutput` for both agents. Unchanged reruns passed; cause unresolved. No runtime checks ran during this planning update.
- I2 app-wiring acceptance remains incomplete. I3's ownership file is accepted, but recovery/concurrency, version gates and timeout design remain proposed.
- Stale: scripts/check-event-contract.py permits a previously conflicting turn ID to restore working state; SessionStore enforces the accepted unseen-turn rule. Correction remains separate work.
- invalidFramesNeverReachCallback retains its documented frame-boundary timing assumption. The test and bridge are unchanged.
- Physical desktop behavior, profiling, action channels, final live-agent checks and optional sprite-sheet choice remain later requirements.

Usage-store implementation choice: five-minute receipt-age stale threshold, plus stale status after a supplied reset passes, source failure, or backward clock. Missing provider measurement time stays missing. This threshold is local display policy, not proof of provider measurement freshness.
