# Status

## Now

The first-release specification remains at [notch-companion](specs/notch-companion.md), on `feat/notch-companion`.
The user chose to undo the area-folder migration. Keep the existing single-spec layout.
The Claude adapter is committed in `69e75f4`, but its task remains unchecked because maximum-input helper verification is blocked.
The private [GitHub repository](https://github.com/eohnai/notch-pet) is connected as `origin`.

## Next

1. Read the [Claude implementation findings](notes/agent-event-compatibility.md#claude-adapter-implementation-2026-10-24). Propose a bounded task list for the helper parser/deadline blocker and get approval before implementation.
2. After the approved fix, run `python3 scripts/check-event-bridge.py`. Tick the Claude adapter task only after complete verification passes.
3. Continue with reversible hook setup in [notch-companion](specs/notch-companion.md) after resolving the helper blocker.
4. Keep the remaining Codex interactive checks immediately before final workflow verification, under accepted decision 0009.
5. Review the proposed reference-model and socket-test follow-ups separately from the approved task list.

## Blockers

- The Claude adapter is implemented but its task remains unchecked. `python3 scripts/check-event-bridge.py` failed three times at the existing 262144-byte raw-input boundary, twice with Command Line Tools and once with Xcode. A temporary Command Line Tools diagnostic read the input in about 3 ms and completed projection at about 315 ms, beyond the 250 ms helper deadline. The Xcode parser was not separately timed. No parser, deadline, or expectation changed. The later invalid-input, open-stdin, and busy-socket process assertions were not reached. See `docs/notes/agent-event-compatibility.md` for evidence.
- A temporary Python comparison attempt also exceeded the existing one-second launch timeout for the Xcode helper. Process launch remains outside the helper's internal deadline.
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
