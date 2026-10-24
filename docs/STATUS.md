# Status

## Now

The Claude event adapter is implemented on `feat/notch-companion`, with all 48 Swift tests passing.
The app and helper build, but full helper process verification fails at the existing maximum raw-input boundary.
The adapter task remains unchecked and blocked. The user approved deferring the remaining Codex interactive checks to final workflow verification.
All changes are uncommitted. No live agent or Otty configuration was changed this session.

## Next

1. Read the Claude implementation findings in `docs/notes/agent-event-compatibility.md` before resolving the helper verification blocker.
2. Diagnose the maximum raw-input parser/deadline limit as a separate bounded change. The next-task workflow stopped after the same process-check failure three times.
3. Rerun `python3 scripts/check-event-bridge.py` after resolving the blocker. Tick the Claude adapter task only after complete verification passes.
4. The board's next unblocked task is reversible hook setup. Resolve the helper verification blocker before relying on installed hooks.
5. Keep the Codex interactive task unchecked, immediately before final workflow verification. Decision 0009 retains all seven remaining checks.
6. Preserve existing Codex, Claude Code, and Otty configuration. Keep runtime files outside Git and do not read credentials.
7. The earlier reference-model and socket-test follow-ups remain proposed work outside the approved task list.

## Blockers

- The Claude adapter is implemented but its task remains unchecked. Full helper process verification failed three times at the existing 262144-byte raw-input boundary, twice with Command Line Tools and once with Xcode. A temporary Command Line Tools diagnostic read the input in about 3 ms and completed projection at about 315 ms, beyond the 250 ms helper deadline. The Xcode parser was not separately timed. No parser, deadline, or expectation changed. The later invalid-input, open-stdin, and busy-socket process assertions were not reached. See `docs/notes/agent-event-compatibility.md` for evidence.
- A comparison attempt also exceeded the existing one-second launch timeout for the Xcode helper. Process launch remains outside the helper's internal deadline.
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

## Progress

_Generated by the progress script at checkpoint. Do not edit by hand._
| Spec | Status | Due | Done | Left | Blocked | Next task |
|---|---|---|---|---|---|---|
| notch-companion | in progress | - | 8 | 14 | 1 | Add reversible hook setup that preserves existing Otty and agent configuration. |
| **Total** | | | **8** | **14** | **1** | |

**Blocked tasks**
- notch-companion: Add the Claude Code event adapter using verified hook coverage. (blocked: helper process verification fails at the maximum raw-input boundary)

## Verification

- Results below are from 2026-10-24. Earlier interactive evidence remains in `docs/notes/agent-event-compatibility.md`.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --filter ClaudeEventAdapterTests`: the initial sandbox run failed on compiler-cache access. The approved retry failed as expected because `ClaudeEventAdapter` did not yet exist.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`: approved run exit 0, 48 tests across five suites. This includes seven Claude adapter tests and three shared-store tests parameterized over both providers.
- `bash scripts/run.sh --build-only`: the sandboxed run failed on compiler-cache access. The approved retry exited 0 and built both bundled executables with Command Line Tools. The app's Info.plist passed validation.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`: approved run exit 0. Both bundled executables also built with Xcode, and Info.plist validation passed.
- `python3 scripts/check-event-bridge.py`: the sandboxed run passed unavailable-app checks, then failed to bind the test socket. Three approved runs exited 1 at the existing 262144-byte raw-input boundary. Each first passed five silent unavailable-app invocations per provider and all 15 fictional payload projections. Two used Command Line Tools builds and the last used the Xcode build. Later process assertions were not reached.
- A temporary Python comparison using the existing listener helper exited 1 after the Xcode helper exceeded the one-second subprocess launch timeout. It did not establish comparative parser timing.
- `swiftc -swift-version 6 -Onone -g Sources/EventBridge/*.swift /private/tmp/notch-pet-claude-diagnostic/main.swift -o /private/tmp/notch-pet-claude-diagnostic/probe`: the first temporary diagnostic compile required an `@MainActor` annotation. The corrected diagnostic compiled successfully. A Python driver exited 0: a small payload completed in about 3 ms, while the maximum-size input was read in about 3 ms and finished projection at about 315 ms, then reported the expired total deadline. No production source was changed for this diagnostic.
- `python3 scripts/check-event-contract.py`: exit 0, document policy and links, 68 message cases, 37 state sequences with 122 steps, and four memory-capacity boundaries passed.
- `bash /Users/ianhoe/.agents/skills/progress/scripts/progress.sh`: exit 0, 8 done, 14 open, and 1 blocked. The Claude adapter and deferred Codex interactive tasks remain unchecked.
- `git diff --check`: exit 0 after the implementation and checkpoint updates.
- No live agent turns, hook installation, configuration changes, credential reads, or transcript reads were performed. Runtime diagnostics remain outside Git. A Python import cache created by the comparison was removed from the repository.
- Current branch: `feat/notch-companion`, created from `c77251c` after the approved Git retry. No remote or local default branch exists, so the comparison default is `main`.
- The working tree was clean at session start. No files were staged, committed, pushed, or submitted as a pull request.

## Log

- 2026-10-24: Implemented the Claude event adapter and accepted deferral of remaining Codex interactive checks under decision 0009. All 48 Swift tests and both builds passed. Full helper process verification failed three times at the existing maximum-input deadline boundary, so the adapter remains unchecked and blocked. Checkpointed the diagnostic evidence without changing parser or deadline behavior.

- 2026-10-23: Recorded partial interactive Codex 0.164.0 verification in Otty with a loopback mock provider. Confirmed main event paths and conservative interruption limits. The user questioned further probing, so cleanup restored configuration and the task remains open.

- 2026-10-23: Implemented the Codex event adapter after the approved split from interactive verification. Verified 41 Swift tests, the app build, helper process checks, and contract checker. The next task verifies installed Codex in interactive Otty sessions with isolated configuration.

- 2026-10-23: Implemented the approved shared session store, bounded bridge handoff, and lifecycle expiry handling. Verified 31 Swift tests, the contract checker, helper process checks, and the app build. Recorded two proposed reference/test follow-ups. The Codex adapter is next.

- 2026-10-23: Refreshed the checkpoint after the user's bridge commit `9be4368`. Confirmed a clean working tree before this records update, regenerated progress, and retained the verified shared-session-store handoff.

- 2026-10-23: Implemented the approved local event bridge, strict shared envelope validation, and a silent bundled hook helper. Verified 15 tests, helper subprocess checks, app startup and Quit cleanup, and the existing contract checks. The shared session store is next.

- 2026-10-22: Specified and checked the approved version-1 event contract. Recorded conservative ordering in decision 0008, documented freshness and payload bounds, and completed the contract task without implementing the bridge or store.

- 2026-10-22: Accepted architecture decisions 0002–0007 after user review and built the native menu-bar app shell. Verified local build and launch, menu rendering through the user's screenshot, and Quit through the user's confirmation. The user approved combining these tasks to begin implementation in this session.

- 2026-10-22: Completed the approved usage-source investigation. Verified read-only Codex quota access and unavailable modes; checked Claude account eligibility and installed fields. Saved compatibility findings and fictional fragments, preserved configuration, and left architecture proposals open.

- 2026-10-22: Completed the approved event and pane investigation. Saved a compatibility matrix and 15 fictional payload examples. Found a stale inherited pane identifier; preserved user configuration and left architecture proposals open.
- 2026-10-22: User approved the scope and task list. Saved the handoff for a fresh `next-task` session; no implementation started.
- 2026-10-22: Created the local planning repository, draft specification, architecture proposal, and decision records. No application code or commits.

