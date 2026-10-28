# Finish bridge verification

Prepared 2026-10-28. This is a goal prompt awaiting activation; no implementation has started.
Paste the entire block after `/goal`. Submitting it approves the G1/G2 task list and bounded plan below; it does not approve the remaining proposed tasks.

```text
GOAL: Complete notch-companion G1 and G2: fix the maximum-input helper deadline failure and verify the existing Claude adapter, preserving the accepted observation contract.

DONE WHEN all hold, with command output and exit codes printed in this conversation:
1. `bash scripts/run.sh --build-only` exits 0 and reports a built app bundle with a valid Info.plist.
2. `python3 scripts/check-event-bridge.py` exits 0 with `Bridge process checks passed`, including all 15 fictional projections, exactly 262144 bytes accepted, malformed/oversized input dropped, and unavailable-app/open-stdin/busy-socket checks. Use the newly built helper, with the app stopped; never remove another listener's socket.
3. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build` exits 0 with at least 48 tests passing and zero failures, including Claude adapter, shared-store, and real-socket checks.
4. `python3 scripts/check-event-contract.py` exits 0 with 68 message cases, 37 sequences (122 steps), four capacity checks, and document-policy/link checks passing.
5. `git diff --check` exits 0 with no output.
6. G1/G2 are ticked in docs/specs/notch-companion.md only after verification; its evidence and docs/STATUS.md describe actual results and retained limitations in English. Print the changed task lines and checkpoint summary.

EVERY TURN: run the five command checks in order, print their output and exit codes, state which of the six criteria pass/fail, and append a numbered, timestamped row with evidence/changes to docs/goals/finish-bridge-verification-log.md. Continue existing numbering. Never count stale build results after a failed build.

PLAN AND CONSTRAINTS:
- Read AGENTS.md, docs/STATUS.md, docs/specs/notch-companion.md, docs/contracts/agent-events-v1.md, relevant decisions 0004/0005/0008/0009/0010, and the Claude implementation findings in docs/notes/agent-event-compatibility.md. Stay on feat/notch-companion.
- Use debug-issue: reproduce first, isolate parser cost with a temporary probe outside Git, test one hypothesis, then correct the confirmed bottleneck. The existing process assertion is the regression check. No new public types or signatures are planned.
- Only change Sources/EventBridge/HookEnvelopeV1.swift, docs/specs/notch-companion.md, docs/STATUS.md, and the goal log. The log is the required goal-workflow artifact; keep implementation/checkpoint changes within the three-file plan. Preserve existing uncommitted edits. Work on G1, then verify G2; no later tasks.
- Keep raw input at 262144 bytes, frame limit at 16384 bytes, the 250 ms internal deadline, strict JSON/duplicate-key/UTF-8/depth validation, field allowlisting, silent failures, one delivery attempt, and conservative state semantics. Measure launch separately from the internal deadline.
- Do not edit tests, fixtures, check scripts, acceptance criteria, dependencies, user hooks, agent/Otty configuration, or credentials. No commits, pushes, or pull requests. Keep probes/runtime data outside Git. Keep all output and records in English. Preserve decision 0009's deferred live Codex checks and the documented reference-model/socket-test follow-ups.

STOP AND REPORT IF 15 turns elapse, the same failure persists for three consecutive turns, or progress needs missing access, an out-of-scope change, a new interface/design decision, or a larger task split. Print the exact blocker and leave unverified tasks open.

ON FINISH OR STOP: set the log Status to done, stopped, or blocked and fill Final result; use checkpoint to update STATUS.md; summarize evidence and limitations, and provide explicit git add paths and a git commit command for user review. Do not execute them. Stop after G1/G2 and tell the user to commit, /clear, and run next-task.
```

## Why this goal

G1 and G2 share one outcome: a verified bridge foundation. G1 removes the already-recorded helper blocker; G2 verifies existing adapter/store code rather than adding a second feature. The tests and acceptance contract already exist, and no UI or provider-response design choice is required.

The historical maximum-input measurement points to parsing, but does not identify the exact hot path. Reproduction and a small diagnostic must establish the cause before an implementation change. The present three-file implementation plan is the parser source, specification evidence, and status checkpoint. This setup adds the goal prompt/log required by make-goal; it does not expand implementation scope.

## Assessment of the remaining tasks

- **Ready for this goal:** G1, followed by G2 once its blocker is actually resolved. Both remain unchecked until the goal verifies them.
- **Candidates for later bounded goals after prerequisite contracts and acceptance tests are fixed:** I2-I5 (integration health and reversible setup/removal), N1/N5 (pane validation and shared priority), A3-A6 (action service and provider adapters after A1/A2), P3/P4/P7 (pack validation/import/preferences), U1-U4 (usage state and provider refresh). These are separate objectives; do not bundle them into this goal. Agent setup/response support still needs the specified isolated verification.
- **Blocked on a choice:** P6 requires P5's sprite-import decision; A3-A6 require A1/A2's verified channels and accepted contract. P3 needs its format rules specified before its implementation can become a test-driven goal. A2 and P5 require user decisions rather than an unattended implementation loop.
- **Keep hands-on at present:** I1/I6, N2-N4/N6, A1/A2/A7/A8, P1/P2/P5/P8, U5/U6, and R1-R8. Their current acceptance includes visual/interaction judgment, installed-agent behavior, physical displays/sleep/Spaces, or real profiling. Automatable subchecks can later support them; green unit tests alone cannot complete them.

This assessment neither approves revised task lists nor splits/rewrites the existing single specification. SSH/cloud work remains optional and outside the goal.

## Historical evidence and known limits

- Read [Claude implementation findings](../notes/agent-event-compatibility.md#claude-adapter-implementation-2026-10-24) and [the specification](../specs/notch-companion.md).
- Previous runs passed 48 Swift tests, but the complete helper process suite failed at maximum input. These are historical results, not fresh verification.
- The reference model's unseen-turn discrepancy and the socket test's buffered-extra-byte timing assumption are documented follow-ups. Stop and report an unrelated failing check instead of weakening it or modifying unrelated behavior.
- Real Claude/Otty integration, remaining Codex interactive checks, and release acceptance are excluded. Completing G2 establishes implementation verification only.
