# Remaining skill pilots

Needs: history-view

## Goal

Extend the tested debug-issue pattern to next-task and checkpoint.
Retain their existing approvals and verification steps. Branch in both repositories: `feat/telemetry-remaining-pilots`.

## Done when

- A typed /next-task creates a separate invocation through a verified command signal or explicitly labeled fallback.
- next-task records only its reported end and step-7 check evidence beyond the observed start.
- checkpoint records its observed start and reported end without saving document bodies.
- next-task calling debug-issue preserves both outcomes but counts a related failure once at the deepest failing invocation.
- The actual app shows both pilots' project/version identity and coverage limits for each tested agent.

## Out of scope

- Every-step milestones, automatic quality scores, permission-policy changes, and additional skills.

## Verify

- Seam: real /next-task and checkpoint invocations with the interface closed, followed by app history inspection.
- Use S1's verified signals and existing agent-skills checks. Run README build/Swift checks for runtime changes and `git diff --check` in both repositories.
- Exercise nested runs, missing ends after /clear, declined emitter permission, and installed-agent differences.
- Do not mark unsupported combinations verified from fixtures alone.

## Decisions

- Keep one-person local history and three pilots, with the remaining two following the history view. See D3.

## My calls

- Reuse the pilot's normal permission prompts. Propose a narrow allowlist only through an explicit later setup review.
- Verify manual-command support independently from model-invoked Skill calls.

## Tasks

- [ ] P1: Instrument next-task using the verified manual-command signal, reported end, and step-7 check evidence, checking an actual invocation.
- [ ] P2: Instrument checkpoint start/end without document contents, checking an actual invocation and preserving record-writing behavior.
- [ ] P3: Verify nested runs and the supported two-agent matrix in app history, recording coverage, permission, and resource limits.
