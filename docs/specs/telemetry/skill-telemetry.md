# Skill telemetry

Needs: local-history

## Goal

Learn which skills run, where their workflows stop, and which verification checks execute.
Pilot `next-task`, `debug-issue`, and `checkpoint` from `~/projects/agent-skills`, with the local collector as their destination.
See the [telemetry area](area.md). Proposed branch in both repositories: `feat/telemetry-skill-telemetry`.

## Done when

- Each invocation has its own run ID and optional parent invocation ID, separate from its source agent session.
- One session can contain repeated and nested skill invocations without merging their runs.
- Records carry skill name, actual SKILL.md content hash, producer/agent version when available, project identity, and evidence source.
- Content hashes reflect the linked skill's actual bytes, including uncommitted edits; an absent value is unknown rather than invented.
- Milestones distinguish started, checkpointed steps, checks executed, blocked, failed, and completed. Missing closure stays unknown.
- Reading a skill is separate from invoking it. Agent-reported milestones remain labeled as reports, not runtime proof of compliance.
- Deterministic verification records identify an allowlisted check and its exit result. They do not capture raw commands or command output.
- A stop event, a passing check, or successful emitter delivery cannot alone establish that the user's goal succeeded.
- Running an instrumented skill with the interface closed creates a run inspectable after reopening the app.
- The three pilots work under the verified installed Codex and Claude combinations, or expose a specific unsupported boundary that remains an acceptance gap.
- Collector absence, pause, or telemetry failure does not fail the skill's actual work. Coverage gaps remain visible.
- Summaries show observed usage, known completion/check outcomes, duration coverage, recurring failure categories, and skill-version filters without claiming causal improvement.

## Out of scope

- Instrumenting every skill, detecting every implicit invocation, transcript analysis, automatic quality scoring, or estimating time saved.
- Token usage, subscription allowance, and costs without an independently verified source.
- Rewriting skill behavior unrelated to instrumentation, changing automatic invocation policy, or installing new hooks without a reviewed setup step.

## Constraints

- The runtime, producer client, and report/query support belong in notch-pet. Only pilot instruction changes belong in agent-skills.
- Use the local-history producer contract and outbox. Do not add independent collectors or network destinations to individual skills.
- Preserve existing symlink setup and both tools' configurations. No new global telemetry instructions are silently installed.
- First inspect supported hook/runtime signals for actual installed versions. A hypothetical event name is not a verified instrumentation point.
- If instructions ask the agent to call the emitter, label that evidence self-reported even when the emitter reliably stores it.
- Record completion and verification separately; error categories use an allowlist rather than raw exception messages.
- Follow existing user confirmation, verification, and checkpoint requirements in each pilot. Instrumentation cannot bypass them.
- Emitter calls use bounded local work. Replay/backfill reaches history only and cannot mutate live session state.

## Verify

- Seam: actual instrumented invocation in each supported agent, recorded by the background collector and inspected in app history.
- Runtime build and checks: `bash scripts/run.sh --build-only`, `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`, and `git diff --check`.
- Pilot documentation: inspect the exact diffs in agent-skills, preserve frontmatter and linking, and run its applicable existing skill checks after identifying their commands in S1.
- Use one real invocation per pilot and supported agent, plus bounded cases for nested/repeated runs, a failed check, a blocked run, and missing closure.
- Keep the interface closed during at least one real run. Reopen it and verify skill hash, run identity, evidence source, and outcome.
- Disable or stop collection during a run and verify normal skill work continues with an honest gap.
- Do not claim fictional event fixtures establish real-agent hook compatibility or complete invocation coverage.

## Decisions

- The three pilot skills and local-only collection are confirmed in D2.

## My calls

- Prefer explicit opt-in producer calls for a small pilot where supported runtime signals cannot establish skill invocation.
- S1 compares supported automatic signals with explicit calls: automatic signals reduce instruction dependence but may omit identity; explicit calls provide milestones but can be skipped.
- Reuse structured history queries for version comparisons. Usage frequency and elapsed time are diagnostics, not proof of skill quality.
- No owner or deadline is assigned because none was supplied.

## Tasks

- [ ] S1: Verify installed-agent signal coverage and existing skill validation commands; review evidence labels and the instrumentation seam for each pilot without changing installed configuration.
- [ ] S2: Add invocation-aware emitter/report support with actual skill hashes; check repeated/nested invocation IDs and separation of reported outcomes from executed-check evidence.
- [ ] S3: Instrument next-task's invocation and existing workflow milestones while preserving its approvals and task boundaries; verify one real recorded run.
- [ ] S4: Instrument debug-issue's invocation and existing investigation/check outcomes without capturing command contents; verify one real recorded run.
- [ ] S5: Instrument checkpoint's invocation and record-writing outcome without storing document bodies; verify one real recorded run.
- [ ] S6: Verify the supported two-agent pilot matrix, closed-interface collection, failure/gap cases, and version-filtered summaries; record resource costs and remaining coverage gaps.
