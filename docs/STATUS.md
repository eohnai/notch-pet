# Status

## Now

I2a/I2b/I2c implementation is written on `feat/notch-companion`; see the [source and verification record](specs/notch-companion.md#i2-implementation-with-verification-deferred-2026-10-28). The user explicitly approved starting I2 with I1 verification deferred and all checks paused. No I2 tests, builds, installed-agent/configuration probes, helper injections, or UI checks have run. I1 and all three I2 checkboxes remain open.
I2a is committed as `cab2c9d` and I2b as `5b0aa5e`; I2c is the final separate implementation commit for this run. The user authorized per-task implementation commits despite deferred verification. The earlier I1/goal snapshot `69b7c11` is pushed; this I2 run does not authorize new pushes. The private [GitHub repository](https://github.com/eohnai/notch-pet) remains connected as `origin`.
The [I2 goal](goals/integration-health.md) and [log](goals/integration-health-log.md) retain the unfulfilled verification criteria; implementation is not goal completion. SwiftUI/AppKit, the single-spec layout, and accepted local approval/reply scope remain. Later tasks and open design choices are not approved by this run.

## Next

1. Leave I1 and I2a/I2b/I2c unchecked. Resume their deferred verification only when the user explicitly requests it; use isolated Xcode caches and the recorded commands.
2. When checks resume, verify the ten new I2 tests, full Swift suite, app build and receiver/delivery wiring, and complete I1's running-menu checks. Review I3–I6's reversible setup/removal plans before implementation; I2's Check UI remains in I6.
3. After I/N, verify local action support and settle its response contract in A1–A2 before A3–A8; keep observation bounds intact.
4. Resolve optional sprite input in P5 before P6; SSH/cloud work is not a release dependency.
5. Keep all seven deferred Codex checks in R6–R7 immediately before R8 under decision 0009; review the earlier reference-model/socket-test follow-ups separately.

## Blockers

- I1 verification is deferred and I2 implementation is approved with all checks paused by explicit user instruction. Do not run further builds, tests, provider/configuration probes, helper injections, accessibility inspections, or UI checks until requested again. Implementation commits are not verification. I3 onward await review. Optional sprite-sheet input remains proposed; conversion at import versus a second runtime loader must be settled in P5 before P6.
- I2's new source and ten tests have not been compiled or executed. Its health refresh has no UI trigger until I6 and is not run automatically. Config shape counts do not establish app-owned installation, Codex feature enablement, hook trust, or end-to-end delivery.
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
