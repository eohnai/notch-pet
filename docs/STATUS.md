# Status

## Now

G1/G2 are complete on `feat/notch-companion`: the parser scans padding directly and checks its existing deadline during padding and before returning. The [specification evidence](specs/notch-companion.md#g1g2-verification-2026-10-28) records the diagnostics and verification; the [goal log](goals/finish-bridge-verification-log.md) records the completed run.
The user approved G1/G2 by activating the bounded goal. Remaining revised implementation tasks, local action-channel structure, and optional sprite-sheet conversion await review; see [decision 0010](decisions/0010-add-local-agent-actions.md) and the [reference findings](notes/flux-island-adoption.md).
SwiftUI/AppKit, the existing single-spec layout, and accepted local approval/reply scope remain. SSH/cloud support is optional future work. No agent/Otty configuration changed, and live-provider acceptance remains open.
The private [GitHub repository](https://github.com/eohnai/notch-pet) remains connected as `origin`.

## Next

1. Review and approve I1's task plan in [notch-companion](specs/notch-companion.md#tasks): display real shared-store sessions in the existing menu-bar shell.
2. Review I2–I6's integration health and reversible setup/removal tasks before implementation. The completed G1/G2 goal does not approve these tasks.
3. After I/N, verify local action support and settle its response contract in A1–A2 before A3–A8; keep observation bounds intact.
4. Resolve optional sprite input in P5 before P6; SSH/cloud work is not a release dependency.
5. Keep all seven deferred Codex checks in R6–R7 immediately before R8 under decision 0009; review the earlier reference-model/socket-test follow-ups separately.

## Blockers

- Revised remaining implementation tasks await review. Optional sprite-sheet input remains proposed; conversion at import versus a second runtime loader must be settled in P5 before P6.
- Local approvals/replies are accepted scope, not verified capabilities. A1–A2 must establish exact-session response mechanisms and a separate action contract; any missing release-required path remains explicitly blocked rather than silently reducing the feature to terminal navigation.
- Remaining Codex interactive checks are deferred to immediately before final workflow verification under accepted decision 0009. Controlled hook trust, default-mode question dispatch, explicit denial, graceful end, controlled abrupt loss, prose questions, and interactive unavailable-receiver behavior remain required.
- Installed Codex `0.164.0` now has partial interactive Otty evidence with a mock provider. Real-provider behavior remains unverified.
- Stale: `scripts/check-event-contract.py` allows a previously conflicting turn ID to restore working state. The accepted contract requires an unseen turn ID. The production store enforces that rule through `recoveryRequiresAnUnseenTurnIdentity`. A reference-model correction is proposed follow-up work.
- The existing `invalidFramesNeverReachCallback` test has a timing assumption at the frame-size boundary. One full run observed two callbacks instead of one. A temporary probe measured writes of 8192, 4096, 4096, and 1 bytes. Delaying only the final extra byte by 5 ms allowed the complete valid prefix in all ten trials. The contract rejects extra bytes only when already buffered. The final full run passed. The bridge and existing test remain unchanged, and the temporary probe was removed. A test correction is proposed follow-up work.
- The app has no live session presentation or installed user hooks. Temporary isolated hooks exercised the helper and production state path only.
- Clock and wake tests use injected values. Physical sleep/wake, fullscreen, Spaces, and display changes remain later checks.
- Without a verified heartbeat, observations become unknown after two minutes. Reused source IDs after an observed end remain unknown.
- Inbox overflow makes nonterminal sessions unknown. The inbox retains at most 128 queued observations alongside one active batch.
- The helper has bounded waits and a shared deadline. Process launch time is additional. Future hook setup must bound execution through each agent's configuration.
- Peer checks use a real same-user socket and a mismatched expected user ID. A process running under a second actual user remains untested.
- The listener polls every 10 ms when idle. The app checks clocks during receipt and through an expiry timer while observations remain fresh. CPU and memory costs remain for profiling.
- Full Xcode is required for tests on this Mac. Command Line Tools still build the app and helper.
- Claude live quota forwarding and output preservation remain checks for the forwarding task. Anonymous observations must remain separate.
- Codex long-running coexistence, cross-process quota notifications, account changes, and other account modes remain unverified.
- The event investigation found a stale inherited `OTTY_PANE_ID`. Future navigation must validate live identity.
- Interactive approval cancellation emitted unsupported `Interrupt` without a resolving `Stop`. The retained approval notice kept later activity unknown. This matches version 1 but limits recovery. No contract or code change is accepted.
