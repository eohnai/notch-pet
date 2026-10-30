# Goal: Verified pull request CI

Prepared and activated: 2026-10-30. PR1-PR6 locally verified; user requested commit/push and deferral of remaining acceptance.
The user approved all four CI task lists and their scoped local verification, then requested goal preparation.
This first goal covers PR1-PR7; it does not cancel the other 16 approved CI tasks.

## Paste after /goal

```text
GOAL: Complete PR1-PR7 in docs/specs/ci/pull-request-checks.md: a verified GitHub Actions pipeline for notch-pet.

DONE WHEN all hold, with command output/evidence printed here:
1. All seven original IDs PR1-PR7 meet their full Done-when checks, with no unchecked subdivisions. Print an ID-to-evidence ledger; checkbox edits alone are not proof.
2. In an isolated CI worktree, with full Xcode selected and TMPDIR=/private/tmp/notch-pet-ci-core/, run:
   bash scripts/run.sh --build-only
   swift test --scratch-path /private/tmp/notch-pet-ci-core/notch-pet-dev/build --enable-code-coverage
   python3 scripts/check-event-contract.py
   python3 scripts/check-event-bridge.py
   git diff --check
   All exit 0; the full four-target Swift suite discovers tests and reports zero failures; build-only launches no GUI; reference and real helper/socket checks pass.
3. Workflow native run steps and new checker regression commands exit 0. LLVM reports cover Pet, EventBridge, SessionState and NotchPet, with nonempty production data and toolchain/revision metadata. Missing/malformed/empty reports fail; unmeasured helper coverage is labelled.
4. Required-gate fixtures prove success passes and failure/cancelled/skipped/missing results fail. Workflow has PR-to-main, main-push and manual triggers, explicit macOS/Xcode selection, bounded logs, full-SHA action pins, read-only permissions, credential-free checkout, timeouts and per-ref cancellation.
5. An authorized hosted run on the CI revision passes every mandatory job and CI / Required, with logs/coverage artifacts verified. Print run URL, revision and per-job results from read-only GitHub tools or gh run view "$CI_RUN_ID" --json headSha,status,conclusion,jobs. Set CI_RUN_ID to the verified run; local success cannot replace this criterion.
6. Reproduction commands, required-check setup and evidence limits are documented; goal log and STATUS reflect verified work.

EVERY TURN: print relevant changed checks, exit codes/test counts, PR1-PR7 evidence and remaining criteria; append a numbered row to docs/goals/ci-pull-request-checks-log.md. Run the full suite after integration changes/finally; retain unchanged passing evidence. Do not rerun expensive checks with no new reason.

CONSTRAINTS:
- CI tasks/local checks were approved. First use a separate worktree on feat/ci-pull-request-checks from committed ec1d5b2; copy only approved CI planning records. Preserve the active agent-session worktree, agent settings and unrelated changes.
- Scope: .github/, scripts/ci/, scripts/check-event-contract.py, scripts/check-event-bridge.py, Tests/SessionStateTests/, Tests/EventBridgeTests/ContractAndSocketTests.swift, README.md, docs/specs/ci/, this goal/log and STATUS. No app feature implementation.
- Keep task limits: 3 changed files including records, 3 production functions, 5 added tests; split before coding if needed, retaining all original criteria. No blanket record exemption.
- Only the approved reference/socket corrections and meaningful new CI checks may change tests/checkers. No deleted cases, hidden failures, widened timeouts, invented coverage floors or regenerated growing style baselines.
- No GUI launch/capture, live agents, credentials, hooks, app dependencies, commits, pushes, PRs, dispatches, signing or hosted rule edits without separate explicit authorization. Finish all local work before presenting concrete publication actions for approval.
- Do not resume or replace another goal.

STOP AND REPORT at 30 logged execution turns, or after the same failure blocks 3 consecutive turns without progress, or when final hosted publication/required access needs the user. Stop is not completion; keep unverified IDs open and follow native goal status rules.

ON FINISH/STOP: checkpoint STATUS; set log to done/stopped/blocked with evidence and remaining work. Supply scoped git add/commit commands for review only; execute neither.
```

## Why this is the first goal

The four CI specs are separately reviewable, and compatibility, artifacts, and maintenance each declare `Needs: pull-request-checks`.
A single goal across all 23 tasks would cross those merge/hosted-acceptance boundaries. Complete the core pipeline first,
then prepare the next goal from the actual working pipeline. The later scopes remain approved, not dropped or counted complete.

Recommended chain:

1. This goal: [pull request checks](../specs/ci/pull-request-checks.md), PR1-PR7.
2. [Compatibility](../specs/ci/compatibility.md), CM1-CM4, after the prerequisite is accepted/merged.
3. [Development artifacts](../specs/ci/development-artifacts.md), DA1-DA5, after the prerequisite is accepted/merged.
4. [Maintenance](../specs/ci/maintenance.md), MT1-MT7, after the prerequisite is accepted/merged.

The latter three depend on the first, not on each other. The order above is a recommendation, not a new dependency.
Do not create goals for the later scopes from guessed future commands; tighten their proof commands once the base exists.

## Approval and activation boundary

- The user's approval authorizes the existing task lists and the local verification those tasks need. Do not ask for that approval again.
- Goal preparation creates documentation and an empty prepared log. It does not start a native goal, create/switch a worktree or branch,
  execute implementation, or run local runtime checks in this turn.
- To activate, paste the entire block above after `/goal` in the CI thread. Goal state is thread-local; do not clear, replace,
  resume or edit the concurrently active agent-session goal.
- A separate worktree is necessary because `feat/agent-session-workflow` contains active unrelated edits. Use the existing proposed
  `feat/ci-pull-request-checks` branch from the original committed baseline `ec1d5b2`, copying the approved CI area/specs and this goal/log only.
  Do not copy the agent workflow's production code, source tests, goals, or private/local configuration.
- Creating a worktree or writing git metadata outside the sandbox may require the execution tool's normal approval mechanism.
  Do not change permission settings or use another mechanism to bypass it.
- No commit/push/PR/dispatch/rule change is approved. Reach a concrete local review point first, then show the exact scoped diff,
  verified commands and proposed publication actions for approval. Hosted acceptance remains incomplete until a real authorized run proves it.
  GitHub may require a published branch/PR or an already-known workflow before dispatch is possible; do not assume a local YAML file is dispatchable.
- The 30-turn clause is a review/stop instruction in the goal text, not a claim that Codex provides a native turn or wall-clock budget.
  Use native lifecycle rules; stopping or reaching a limit never justifies marking an incomplete goal complete.

## Context to read at activation

- Allowlist correction at PR5: the approved process-check task necessarily owns its existing checker, `scripts/check-event-bridge.py`.
  The original block accidentally omitted that file. It is now named explicitly to support actual SwiftPM output discovery;
  no app code, hook timeout, delivery contract or test acceptance is added or relaxed by this correction.

- [Project instructions](../../AGENTS.md), [status](../STATUS.md), and [CI area](../specs/ci/area.md).
- [Pull request checks](../specs/ci/pull-request-checks.md), including its accepted boundaries and all Done-when checks.
- [Event contract](../contracts/agent-events-v1.md), production session-state implementation and its regression tests,
  and [observation bridge evidence](../specs/sessions/observation-bridge.md) before changing either recorded test discrepancy.
- Read-only reference: `~/projects/personal-website/.github/` and its CI scripts. Do not modify that repository.
- Try CodeGraph first for new code investigations; this checkout previously reported `repoId is not set`, so use local source if unavailable.

## Verification environment and evidence

Create the temporary root before runtime commands; select full Xcode explicitly for each local command:

```bash
mkdir -p /private/tmp/notch-pet-ci-core
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export TMPDIR=/private/tmp/notch-pet-ci-core/
bash scripts/run.sh --build-only
swift test --scratch-path /private/tmp/notch-pet-ci-core/notch-pet-dev/build --enable-code-coverage
python3 scripts/check-event-contract.py
python3 scripts/check-event-bridge.py
git diff --check
```

These commands are for execution in the isolated CI worktree after activation, not evidence of checks already run.
Record the observed test count; do not borrow the 129-test result from the separate agent worktree or invent a baseline count.
Keep build/coverage files out of the checkout, including LLVM raw profiles generated by any instrumented helper process.
The bridge checker uses the shared per-user endpoint, so a separate worktree does not isolate that endpoint.
Refuse an existing listener and coordinate conflicting synthetic process checks rather than stopping another process or deleting its socket.

Coverage export/checker and gate regression commands are implemented by PR4/PR6. Record their exact final invocations in the spec and log,
then execute them; do not add a placeholder command or a permissive checker as evidence. Require the negative cases in the goal block.
Use read-only GitHub plugin tools where sufficient; the `gh run view` command in the block is an equivalent proof surface when a CLI fallback is needed.
No GitHub mutation or credential content inspection is needed to read authorized run results.

Preserve the original PR1-PR7 acceptance IDs when splitting oversized implementation tasks. Count source/config/test/spec/goal-log changes
against each bounded slice; there is no implicit record-file exemption. Record a split before coding and retain the original parent requirement
until all subdivisions pass. Use a separate records-only checkpoint slice when needed. Do not relax the acceptance standard to fit the file budget.

## Initial evidence ledger

| Criterion | Initial state | Evidence still needed |
|---|---|---|
| Original PR1-PR7 | Not started | Implementation and per-ID checks |
| Native local build/suite/process checks | Not run for CI | Actual commands, counts and exit codes |
| Coverage and new checker regressions | Not implemented | Valid reports and negative-case failures |
| Required gate and workflow configuration | Not implemented | Real definitions and result fixtures |
| Hosted execution | Not authorized or run | Authorized revision, run URL, all jobs and artifacts |
| Documentation handoff | Prepared only | Implementation commands and final checkpoint |

## Sources for the goal workflow

- [Official OpenAI documentation: Using Goals in Codex](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex):
  draft/review before activation, observable evidence, thread-scoped goal state and honest blocked outcomes.
- [make-goal skill](/Users/bytedance/projects/agent-skills/dev/make-goal/SKILL.md): a self-contained block, per-turn evidence log,
  and explicit stop limits. This file is preparation, not native goal activation.


## Latest user instruction

The user required main as default and sole CI branch target, then said "just commit and push first, settle later".
Commit/push of this isolated CI worktree is explicitly authorized. Do not create a PR or run further runtime verification now.
After successful commit/push, pause the native goal and leave PR7 open for a later resume. This does not authorize merging or changing feature branches.
