# Migrate implemented features into area specs

Requested by the user on 2026-10-30 ("for all 3 steps"), after a spec review.
Step 1: mark the old single-spec rules and the stale I2 statement in the source spec as superseded.
Step 2: write retrospective specs for the five features that already have code.
Step 3: record the usage receiver gaps from the code review as open decisions before any receiver fix.

```text
GOAL: Write retrospective specs for the five implemented features (sessions/session-state, sessions/integration-health, notch/session-island, usage/codex-allowance, usage/claude-allowance), move their tasks and evidence out of docs/specs/notch-companion.md, and supersede its stale single-spec rules.

DONE WHEN all hold, shown by output printed in this conversation:
1. `shasum docs/goals/check-spec-migration.py` → 9f065e29feb09de7944e39ad83e8829e5e6e47f4
2. `python3 docs/goals/check-spec-migration.py; echo "exit $?"` → "10/10 criteria pass" and "exit 0". Its criteria: C1 stale single-spec/I2 lines marked superseded; C2 five specs with Goal/Done when/Out of scope/Verify/Decisions/My calls/Tasks/evidence sections and area-index Needs lines, none Status: done; C3 all 66 original task lines exist once, unchanged, 19 moved per the script's map; C4 added tasks unchecked, only in new specs, max 9 tasks per spec; C5 claude-allowance records five open (not accepted) decisions labelled "Usage socket providers", "Stale usage socket recovery", "Usage receiver health", "Usage source lifetime", "Usage service ownership", and codex-allowance records the NotchUsageView refresh against decision 0002; C6 each moved ID cited in evidence text, goal-log evidence cited; C7 area indexes and source spec link new specs; C8 historical source evidence lines kept; C9 local links resolve; C10 git diff --check clean, Sources/Tests/notch-agent-limits-log diff unchanged, existing decisions/ARCHITECTURE/README/contracts/notes unchanged.
3. Print a table: each new spec → task count → checked count → open decisions. Checked counts must equal the original states.

EVERY TURN: run criteria 1–2, print output, state which criteria pass and fail, and append one row to docs/goals/migrate-implemented-specs-log.md (turn, time, criteria passing, what changed). Continue existing numbering.

CONSTRAINTS:
- Read AGENTS.md, docs/STATUS.md, decision 0011, the area files, observation-bridge.md (the pattern), and ~/.claude/skills/plan-feature/references/spec-template.md first.
- Only change docs/specs/**, docs/STATUS.md, this goal's log, and new docs/decisions files marked "Status: proposed".
- Do not edit the check script. Copy task lines byte-for-byte. Never tick, untick, reword, or delete a task. Never change historical evidence; copy it, adjusting relative links only.
- Requirements come from the source spec, area files, and accepted decisions, not from code alone. Implemented but unverified stays unchecked.
- Record user choices only as proposed or open. Label your own judgment under My calls. New tasks are proposals awaiting user approval.
- Write in plain English: short sentences, active voice, no semicolons.
- No code changes, builds, tests, app runs, agent invocations, or configuration access. No commits or pushes. Do not resume the paused notch-agent-limits goal.

STOP AND REPORT (do not keep trying) IF:
- 30 turns have passed
- the same criterion fails 3 turns in a row with no new approach
- a task line cannot be placed without rewording it, evidence contradicts a checkbox state, or a requirement needs a user decision to write at all

ON FINISH OR STOP: set the log's Status to done, stopped, or blocked and fill in its Final result; run the checkpoint skill to update STATUS.md; list each new spec's proposed tasks for user approval; then summarize what passed, what didn't, and why, and give git add and git commit -m "docs: <summary>" commands for the user to review and run.
```

## Context

Read in this order:

- `AGENTS.md` and `docs/STATUS.md`.
- [Decision 0011](../decisions/0011-organize-records-by-feature.md): migration rules for tasks, checkbox states, and evidence.
- The area files under `docs/specs/*/area.md`: each lists which task IDs move to which spec.
- [Observation bridge](../specs/sessions/observation-bridge.md): the finished migration pattern. Copy its structure, not its `Status: done`.
- [Source spec](../specs/notch-companion.md): tasks, requirements, and historical evidence.
- [Paused goal log](notch-agent-limits-log.md): evidence for N3–N5, I1, U1, U3b2, and U5 that the source spec lacks. Read it, but do not edit it.

## Task map

The check script enforces this map. Every other task line stays where it is.

| Spec | Tasks moved |
|---|---|
| `sessions/session-state` | Completed "Add the shared session store" foundation task |
| `sessions/integration-health` | I2a, I2b, I2c |
| `notch/session-island` | I1, N3, N4, N5 |
| `usage/codex-allowance` | Completed usage-source investigation, U1, U3a, U3b1, U3b2, U5 |
| `usage/claude-allowance` | U2a, U2b, U2c1, U2c2, U2c3 |

Stays in the source spec: the architecture-records task, I3–I6, N1–N2, N6–N8, A1–A8, P0–P8, U3c, U4, U6, and R1–R8.
U5 covers both providers but has one task line, so it goes to codex-allowance. Claude-allowance cites it in Done when.
U6 spans three specs and stays in the source spec until `refresh-recovery` is written.

## Gaps for claude-allowance

From the 2026-10-30 code review of the uncommitted receiver wiring. Record each as an open decision with options, one pro and one con each.

- **Usage socket providers:** the receiver accepts `codex`, so another local process can replace the in-app Codex reading. Option: accept only `claude`.
- **Stale usage socket recovery:** `UsageReceiver.start` refuses an existing socket file, so a crash blocks every later start. `EventBridgeServer` probes and removes its own dead socket.
- **Usage receiver health:** start failure is dropped, and `usageReceiverAvailable` is never read. Integration health reports only the event bridge.
- **Usage source lifetime:** `UsageStore` keeps at most 128 sources and never removes one. The Claude `sourceID` scheme is not defined.
- **Usage service ownership:** `NotchPanelController` owns the usage store and receiver, and `NotchUsageView` runs the Codex refresh loop. Decision 0002 and the goal plan put I/O in services and give ownership to the app delegate.

The build error at `NotchPanelController.swift:37` is a code fix, not a spec gap. Record it as known in claude-allowance, but do not fix it.
