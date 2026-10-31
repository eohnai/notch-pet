# CI foundation: local implementation goal

The user activated this goal on 2026-10-31 and authorized a commit after each verified task.
Commit plans still require approval under AGENTS.md. The separately approved I2d repair is verified; CI tasks remain open.
F8 and completion of the whole specification remain separate hosted acceptance work.

## Paste after `/goal`

```text
GOAL: Implement and locally verify ci-foundation F1-F7 on feat/automation-ci-foundation; hand off hosted F8.

Activation approves F1-F7, local builds/tests, fictional helper checks and routine CLI details within the spec. Read docs/goals/ci-foundation-local.md first. Other goals stay paused.

Set ci_root=/private/tmp/notch-pet-ci, ci_build=/private/tmp/notch-pet-dev/build, ci_app='/private/tmp/notch-pet-dev/Notch Pet.app'; export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer. Put verified pinned actionlint on PATH.

DONE WHEN all hold, with command outputs and exit codes printed here:
1. `actionlint .github/workflows/ci.yml` and `git diff --check` exit 0. Review Workflow/Tests/Build/Contract/Helper/Required: PR-to-main/main-push/manual triggers, no path filters, PR-only cancellation, explicit macos-26/Xcode, verified pins, minimal permissions, timeouts, exact-run artifact reuse without rebuilds, failure reports, and always() Required checking all five jobs. Document runner selection; hosted qualification stays open.
2. `swift test --scratch-path "$ci_build" --enable-code-coverage` exits 0 with 0 failures; native machine-readable results preserve identity/failure/skip status. `env TMPDIR=/private/tmp bash scripts/run.sh --build-only` exits 0 with both executables, Info.plist and Pet resources. Uploaded builds stay uninstrumented, separate from coverage builds.
3. `python3 scripts/check-event-contract.py` exits 0. `python3 scripts/check-event-bridge.py` and its `--helper "$ci_root/extracted/Notch Pet.app/Contents/MacOS/NotchPetHook"` form exit 0 with 'Bridge process checks passed'; preserve assertions/socket protections.
4. `python3 scripts/ci/bundle.py --app "$ci_app" --output "$ci_root/bundle"` and `python3 scripts/ci/bundle.py --verify "$ci_root/bundle"` exit 0; extract safely for criterion 3. Print rejection-fixture outputs: missing resources, altered content, mismatched independently expected identity, and escaping archive paths all fail before execution.
5. `python3 scripts/ci/coverage.py --build-root "$ci_build" --output "$ci_root/reports"` exits 0 with real production-source HTML, JSON and module summaries. Print missing/malformed-input fixture outputs: both fail. No thresholds or fabricated results.
6. `python3 scripts/ci/required-result.py` with CI_JOB_RESULTS: only the exact five successful jobs exit 0. Five fixture groups: success; failure/cancel/skip/unknown; missing/extra jobs; malformed input; empty input. All invalid cases exit nonzero. Print commands/counts/results. Record reproduction/troubleshooting commands and 7/7 verified F1-F7 evidence. Leave F8 and the spec open.

EVERY TURN: run available checks above, print bounded output and pass/fail/incomplete per criterion; append a timestamped row to docs/goals/ci-foundation-local-log.md, continuing turn numbers. Never rerun a failed baseline to erase failure.

CONSTRAINTS: Only edit .github/workflows/ci.yml, scripts/check-event-bridge.py, scripts/ci/{bundle,coverage,required-result}.py, docs/specs/automation/ci-foundation.md, docs/STATUS.md and these two goal files. F1-F7 in order, one implementation file per task; sketch CLIs first. No weakened assertions, exclusions, retries, ignored exits, continue-on-error, app launches, captures, real agents/data/credentials, installed config changes, unrelated repairs, caches, paid services or new runtime dependencies. Keep generated data outside the repo. Preserve sockets/app instances. Commit per approved plans; no pushes, PRs, workflow dispatches or settings changes.

STOP: at 30 turns; same executed failure 3 consecutive turns without a new approach; unrelated baseline failure; missing access; or material design decision/scope split needing the user.

ON FINISH OR STOP: set log Status done/stopped/blocked and Final result; use checkpoint, tick only verified tasks; print proof and remaining F8 work; give explicit-path git add and Conventional Commit commands. Local completion is not full-spec completion.
```

## Scope and authorization

- The eight-spec automation roadmap is accepted. Seven entries still have no specification file.
- The user activated ci-foundation F1–F7 and their listed local checks on 2026-10-31.
- The user permits a commit after every completed task. Follow AGENTS.md's commit-plan approval procedure.
  No CI task has completed yet. The separate I2d repair commit plan is approved.
- After the initial baseline failure, the user separately approved I2d: serialize `IntegrationHealthProbeTests`,
  update its integration-health spec and goal records, verify isolated/full suites, then resume CI.
  That one-file test repair is verified. This explicit exception does not authorize other unrelated repairs.
- Activation replaces repeated task-by-task approval for these seven tasks and their listed local checks.
  It does not authorize broader design changes, unrelated repairs, or the other seven automation specs.
- The initial setup session ran no runtime checks. The activated run attempted F1's baseline and stopped on its failure.
- Use the existing spec branch. Do not create a branch per task.
- Keep each task's one-implementation-file boundary. Stop if an additional implementation file becomes necessary.
  Goal-log and checkpoint updates are records, not additional implementation files.
- Review signatures before writing each tool. Record the CLI sketch, caller example, expected manifest identity,
  extraction path, and bounded fixtures in the spec before implementing the owning task.
- Use Python's standard library. Pinned GitHub actions and a verified actionlint binary are allowed tooling.
  Download tooling outside the repository and use normal permission requests where required.

## Verification details

- The command block contains shell variables to shorten paths. Quote their expansions as shown.
- Install the verified actionlint release under `/private/tmp/notch-pet-ci/tools` and add that directory to PATH.
- Print exact finalized commands for machine-readable Swift results, bundle extraction, and rejection fixtures.
  Qualify toolchain-supported result flags before use. Do not invent unsupported flags or report formats.
- The manifest must verify independently supplied expected commit, run, attempt, platform, toolchain and configuration.
  Comparing a manifest to its own claims does not prove identity.
- Use distinct scratch paths for instrumented Tests and uninstrumented Build jobs.
  Local packaging may use the existing script's build directory, but coverage export must retain its valid instrumented inputs.
- Negative fixtures are disposable files outside the repository. Preserve the fixed rejection requirements.
  Do not weaken a verifier to accept a malformed fixture.
- Collect version metadata through an explicit allowlist. Never print the raw environment.
- For each criterion, log the command, exit status, relevant counts and an evidence path outside the repository.
- Planned, not-yet-implemented criteria are incomplete. They are not repeated executed failures.
- At finish, run the complete local acceptance sequence on the final files.
  A later relevant change invalidates earlier evidence for the affected criterion.

## Known stop conditions

The recorded `IntegrationHealthProbeTests.versionProbeBoundsItsProcessAndOutput` timeout is outside this goal.
A recurrence blocks the passing local baseline. Preserve the failure and request separately scoped diagnosis.
Do not retry it until it passes, increase its timeout, disable it, or change app code here.

The process checker must refuse an existing socket. Do not quit the user's app or remove its endpoint.
Stop and report the occupied endpoint without reading session data.

The event-contract check has a recorded difference from SessionStore's unseen-turn rule.
Keep that warning. Passing the reference check does not resolve the difference.

## Hosted handoff

Leave F8 unchecked and do not set `Status: done` on ci-foundation.
After the user commits and pushes, F8 must establish a passing hosted PR run, a deliberate failure,
a documentation-only run, altered-artifact rejection, and cancellation of only the older PR run.
Record commit-linked URLs and inspect the downloaded archive and HTML coverage.
Local checks cannot prove hosted runner availability, scheduling, permissions, uploads, or cancellation.

Do not activate or dispatch hosted work from this goal.
After local task commits, ask the user to push, `/clear`, and run `next-task` for F8.
