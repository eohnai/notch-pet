# Agent session workflow

Current state: paused by explicit user request on 2026-10-30; incomplete. The user separately
authorized checkpointing and committing/pushing the current partial milestone, then clarified
"just commit and push first". PR creation is deferred. The save does not resume implementation,
deferred app acceptance or captures.

```text
GOAL: Connect Codex and Claude through extensible adapters and show their sessions in the native island.

ENTRY: Read AGENTS.md and docs/STATUS.md. Activated by explicit user approval on 2026-10-30, including task list, built-in adapters, Off-as-pause, integration branch and renewed tests/builds/isolated app checks. Preserve the no-capture instruction; do not resume older goals.

DONE WHEN all hold, with fresh output, exit codes and evidence printed:
1. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-agent-workflow/build` exits 0: >=129 tests, zero failures, all existing cases retained; new adapter/setup/control tests also pass.
2. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer TMPDIR=/private/tmp/notch-pet-agent-workflow bash scripts/run.sh --build-only` exits 0 with Info.plist: OK.
3. `python3 scripts/check-event-bridge.py`, `python3 scripts/check-event-contract.py` and `git diff --check` each exit 0. Stop/report unrelated pre-existing checker conflicts; do not silently repair them.
4. Add then run `python3 scripts/check-agent-workflow.py --app '/private/tmp/notch-pet-agent-workflow/notch-pet-dev/Notch Pet.app' --artifacts /private/tmp/notch-pet-agent-workflow/evidence --skip-capture`. Exit 0, exactly 12/12 frozen groups pass, none skipped:
G1 pet-only zero agent starts;
G2 two real catalog registrations plus test-only third descriptor and unknown-wire rejection;
G3 Codex setup/reinstall preservation;
G4 Claude setup/reinstall/statusLine preservation;
G5 both removals, conflicts and approved interruption recovery;
G6 independent pause/resume and retained unknown notices;
G7 actual helper delivery with distinct same-folder sessions;
G8 working/question/approval/response-ready/ended/unknown native presentation;
G9 priority and retained selection;
G10 production open/Show Sessions/Escape actions and no unsolicited activation;
G11 isolated installed-Codex lifecycle dispatch into the app;
G12 isolated installed-Claude lifecycle dispatch into the app.
Every group needs production-path evidence; fixture replay cannot substitute for G11/G12. No screenshots; report visual/physical acceptance deferred. Unverified live event modes remain gaps, never passes.

EVERY TURN: Run approved applicable checks, print output and pass/fail/not-run for each criterion, and append a numbered timestamped row to docs/goals/agent-session-workflow-log.md. Do not rerun expensive unchanged checks without a relevant change; no unapproved checks.

CONSTRAINTS: Only change EventBridge/SessionState/NotchPet sources, related Tests, scripts/run.sh, the approved build-location fix in scripts/check-event-bridge.py, the new workflow checker, owning session/notch specs/contracts and goal/STATUS records. Per slice <=3 implementation/test/config files, <=3 added production functions, <=5 added tests; mandatory spec/STATUS/goal records exempt. Split before exceeding limits. Freeze acceptance before implementation; never weaken it or skip/delete tests to pass. Preserve existing configuration; installer/live checks use isolated paths. No credentials/transcripts, trust bypass, paid agent calls, captures, extra agents, executable plugins, v1 widening, new dependencies, usage/action/pet/telemetry features, commits, pushes or PRs.

STOP AND REPORT: 30 execution turns; same failure 3 consecutive turns without a new approach; missing access, unverified provider syntax, unresolved design/branch choice, unsafe preservation or failed live seam. Preparing files does not activate this goal.

ON FINISH/STOP: Set log Status and Final result honestly; use checkpoint; tick only verified requirements, leave deferred acceptance open, report evidence/gaps and provide exact git add/git commit commands for user review.
```

## Preparation status

Prepared on 2026-10-30 after the user confirmed both agents plus a Flux-like session island and
requested future-provider extensibility. This approves planning the milestone, not the new task list,
unsettled architecture, configuration writes or resumed verification. No goal was activated here.

## Specs and build order

1. Review existing [session state](../specs/sessions/session-state.md) and
   [integration health](../specs/sessions/integration-health.md) evidence. Preserve unchecked acceptance
   and the all-ticked session-state closure question; no silent Status: done.
2. [Agent adapters](../specs/sessions/agent-adapters.md), AD1–AD5.
3. [Codex setup](../specs/sessions/codex-setup.md), CX1–CX7.
4. [Claude setup](../specs/sessions/claude-setup.md), CL1–CL5.
5. [Agent connections](../specs/sessions/agent-connections.md), CN1–CN6 (including CN5a/CN5b), and the new
   [session-island](../specs/notch/session-island.md) SI1–SI4 tasks in dependency order.
6. Run the frozen native/live groups and checkpoint. Existing I1/N3–N5, I2 and source I3–I6/N8/R6–R8
   remain governed by their full original requirements; partial evidence does not close them.

A task is a bounded slice, not necessarily a whole execution turn. A turn may finish several independent
approved slices, but no slice exceeds its limit. Review actual code/file/function footprints before each
slice. CN5a/CN5b separate setup/control from native presentation; split further before coding if either
exceeds its footprint. Adding tests cannot be used to hide oversized work.
If the reviewed splits cannot fit the 30-turn run, checkpoint the unfinished goal at its limit.

## Approval and remaining design gates

The user explicitly approved the task list, recommended built-in catalog, Off-as-pause, temporary
integration branch, workflow-record file-limit exemption and listed tests/builds/isolated app checks,
then requested starting the goal. Created `feat/agent-session-workflow` from the current pet branch.
The reviewed alternatives below are retained as context. Installer recovery/concurrency details still
receive CX1 review before file writes; activation does not silently settle that documented limitation.

The user subsequently selected automatic setup after the simultaneous-settings-edit risk was explained
in plain language. Keep guarded writes, conflict detection and an instruction to close settings editors.
They also approved adding only the Xcode helper-location fallback in `scripts/check-event-bridge.py`
after its pre-existing legacy-layout assumption blocked process checks. This narrowly extends the file
allowlist; every existing assertion and acceptance criterion remains unchanged.

- **Adapter ownership:** recommend built-in registrations rather than a runtime plugin host.
  EventBridge owns projection, SessionState owns setup/health and the app owns services/UI.
  Each optional usage, navigation or action capability retains its own interface and evidence.
- **Switch semantics:** recommend Off = pause, with Disconnect as a separate owned-removal action.
  Pausing does not resolve notices. Resume starts unknown until new evidence arrives.
- **Installer recovery/concurrency:** separate Codex ownership is accepted; detailed recovery and the
  noncooperating-writer race are not. CX1 must settle these before file writes. Claude reuses shared
  primitives only after CL1 reviews its own policy.
- **Branch strategy:** the normal convention is one branch per spec. A multi-spec, no-commit run
  needs an explicit exception or a staged handoff. Recommend a temporary integration branch
  `feat/agent-session-workflow` based on the current pet implementation, followed by per-spec review
  splits at handoff. This is proposed, not permission to create commits, merge branches or open PRs.
  Alternative: retain per-spec branches and stop at each dependency for the user's commit/stack handoff;
  that preserves the convention but makes the entire milestone a sequence of goal runs.
- **Verification renewal:** the earlier no-testing instruction still applies. Obtain explicit approval
  for the named Swift/build/checker commands, isolated native launches and test-only evidence work.
  The screen-capture prohibition remains regardless. Production hook installation needs its own
  concrete preview and approval; this goal only uses disposable agent configuration.

## Frozen native groups and evidence rules

The checker's CLI above is proposed; the checker does not yet exist. Freeze assertions before implementing
production behavior. A test harness may invoke the real controller actions and observe accessibility,
window visibility/geometry and rendered state, but must not render a parallel demo UI or assign a passing
session snapshot instead of delivering an event through the production seam.

- G1: Start with isolated preferences and both integrations off; inspect production service-start counts.
- G2: Exercise two production registrations and a test-only descriptor; transport still rejects unknown IDs.
- G3/G4: Invoke each production setup driver through a process boundary; verify exact unchanged reinstall
  bytes, unrelated fields/order and Claude statusLine. Never execute fictional unrelated hook commands.
- G5: Exercise both production removal drivers and every approved recovery row; changed/duplicate owned
  entries and malformed records must leave configuration untouched with a bounded conflict.
- G6: Invoke actual app monitoring controls; one provider's pause must not stop the other. Verify retained
  requests become unconfirmed and resume cannot infer working state from old evidence.
- G7: Deliver real helper processes into the production receiver; same-folder sessions have distinct keys.
- G8: Observe actual app view/accessibility presentation for the six named meanings using labeled fixture
  events. Model-only results cannot establish native presentation.
- G9: Deliver priority-changing events and inspect preserved selection and retained unconfirmed requests.
- G10: Invoke production open/recovery/close actions and observe real window state plus activation events.
  Test keyboard dispatch where the app explicitly receives it; never intercept global Escape.
- G11/G12: Use actual selected installed agents with explicit disposable configuration and ordinary trust
  review, then observe dispatched events in the production app. Prefer a reviewed deterministic local test
  provider where supported; do not use account credentials or paid turns. Freeze exact process commands
  after selected-version evidence is checked, before running. If that seam cannot be exercised under these
  constraints, stop blocked with the missing version/mode/trust capability. A fixture is not a live-agent pass.

G11/G12 prove the selected installed-agent event paths only. Do not claim every event or launch mode is
supported. The G8 fixture-state matrix remains separate from live coverage, and historical R6/R7 requirements
remain open unless their own acceptance is established.

## Scope and record handling

The goal reuses current native presentation and pet-first startup. It adds no quota completion, interactive
approval/reply channel, terminal navigation, pet reaction/detachment, background collector or telemetry.
Existing optional usage code keeps its owning feature; its acceptance is not completed by enabling observation.
A later provider needs its own compatibility study and explicit contract review, even with the catalog.

Keep the source specification and all original task lines/evidence. New feature tasks refine those requirements.
Do not merge the separate `docs/local-telemetry` worktree or overwrite its accepted D3 revision.
Preserve unrelated `.vscode/` and Codex/Claude/Otty configuration.

No acceptance, tests, builds, probes, app launches or captures ran during goal preparation.

## Verification environment

For criterion 3, run the bridge checker with `TMPDIR=/private/tmp/notch-pet-agent-workflow`, matching
criterion 2's build root: `env TMPDIR=/private/tmp/notch-pet-agent-workflow python3 scripts/check-event-bridge.py`.
This selects the newly rebuilt helper rather than unrelated artifacts from another task. Assertions are unchanged.
