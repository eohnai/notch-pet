# Status

## Now

I1's native menu presentation is written on `feat/notch-companion` and remains unchecked because its running-menu verification is incomplete; see the [implementation and verification evidence](specs/notch-companion.md#i1-implementation-awaiting-verification-2026-10-28). The user renewed verification, then requested stopping checks and explicitly committing and pushing the current work. Do not run further builds, tests, helper injections, or UI checks without a renewed request.
The current changes are being recorded under that explicit commit/push instruction, with I1 still incomplete. The private [GitHub repository](https://github.com/eohnai/notch-pet) remains connected as `origin`; G1/G2 were previously committed and pushed as `1fb4f5e`.
I2 remains the next bounded-goal candidate after I1 verification. Its proposed task split and goal preparation do not implement I2 or approve later tasks. SwiftUI/AppKit, the single-spec layout, and accepted local approval/reply scope remain.

## Next

1. Leave I1 unchecked. Resume its [pending verification](specs/notch-companion.md#i1-implementation-awaiting-verification-2026-10-28) only when the user requests it; remaining checks were explicitly skipped.
2. After I1 verification, review and activate a bounded I2 integration-health goal. Review I3–I6's reversible setup/removal plans before implementation.
3. After I/N, verify local action support and settle its response contract in A1–A2 before A3–A8; keep observation bounds intact.
4. Resolve optional sprite input in P5 before P6; SSH/cloud work is not a release dependency.
5. Keep all seven deferred Codex checks in R6–R7 immediately before R8 under decision 0009; review the earlier reference-model/socket-test follow-ups separately.

## Blockers

- I1 implementation is approved, but the user stopped the renewed verification and requested commit/push of the current work. Do not run further builds, tests, helper injections, accessibility inspections, or UI checks until requested again. Commit/push is not acceptance or verification. Other revised task plans await review. Optional sprite-sheet input remains proposed; conversion at import versus a second runtime loader must be settled in P5 before P6.
- `bash scripts/run.sh --build-only` failed in the default scratch directory: Swift 6.2 cannot import cached Swift 6.3.2 modules. An isolated Xcode build completed; its exact command and temporary artifact path are in the spec. Keep toolchains isolated when verification resumes.
- The earlier accessibility denial no longer reproduced: the same `osascript` probe returned `NotchPet, 2`. The running older app still showed its old placeholder menu. The rebuilt app's fictional-observation and visible-menu verification was interrupted and remains incomplete.
- Local approvals/replies are accepted scope, not verified capabilities. A1–A2 must establish exact-session response mechanisms and a separate action contract; any missing release-required path remains explicitly blocked rather than silently reducing the feature to terminal navigation.
- Remaining Codex interactive checks are deferred to immediately before final workflow verification under accepted decision 0009. Controlled hook trust, default-mode question dispatch, explicit denial, graceful end, controlled abrupt loss, prose questions, and interactive unavailable-receiver behavior remain required.
- Installed Codex `0.164.0` now has partial interactive Otty evidence with a mock provider. Real-provider behavior remains unverified.
- Stale: `scripts/check-event-contract.py` allows a previously conflicting turn ID to restore working state. The accepted contract requires an unseen turn ID. The production store enforces that rule through `recoveryRequiresAnUnseenTurnIdentity`. A reference-model correction is proposed follow-up work.
- The existing `invalidFramesNeverReachCallback` test has a timing assumption at the frame-size boundary: extra bytes can arrive after the receiver accepts a complete valid prefix. The contract rejects extra bytes only when already buffered. A test correction remains proposed follow-up work; the bridge and test are unchanged. The [specification](specs/notch-companion.md#historical-implementation-evidence) retains the diagnostic evidence.
- I1's rebuilt session menu has not completed running-app verification. The resumed changed-source Swift suite is recorded in the specification; it does not establish menu behavior. User hooks remain uninstalled; live-provider acceptance remains open.
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
