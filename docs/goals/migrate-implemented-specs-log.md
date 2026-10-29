# Goal log: Write retrospective specs for the five implemented features and supersede stale single-spec rules

- Goal file: docs/goals/migrate-implemented-specs.md
- Created: 2026-10-30 00:19 +0800
- Turn limit: 30
- Status: done

## Turns

| Turn | Time | Criteria passing | What changed / evidence |
|---|---|---|---|
| 0 | 2026-10-30T00:19+08:00 | 4/10 (C4, C8, C9, C10) | Baseline before the run. Check script frozen at sha 9f065e29. No spec changes yet. |
| 1 | 2026-10-30T00:40+08:00 | 10/10 (C1–C10), script sha 9f065e29 unchanged | Wrote five retrospective specs with copied evidence ranges and goal-log summaries. Moved 19 task lines byte-for-byte. Marked four stale source-spec lines superseded. Linked new specs from area files and the source spec. Recorded five open usage receiver decisions and one proposed settle task in claude-allowance. No code, build, test, or config access. |

## Final result

Done after one working turn. `python3 docs/goals/check-spec-migration.py` printed 10/10 criteria pass with exit 0, and the script hash was unchanged.

| Spec | Tasks | Checked | Open decisions |
|---|---|---|---|
| sessions/session-state | 1 | 1 | 0 |
| sessions/integration-health | 3 | 0 | 0 |
| notch/session-island | 4 | 0 | 0 |
| usage/codex-allowance | 6 | 3 | 0 |
| usage/claude-allowance | 6 | 3 | 5 |

One new task awaits user approval: settle the five open usage receiver decisions before U2c3.
Not done here: U3b2, U1, and I2 evidence reviews. Their checkboxes stay unchanged. The specs record them as open questions.
No builds, tests, app runs, or configuration reads ran. The checks are documentation checks only.
