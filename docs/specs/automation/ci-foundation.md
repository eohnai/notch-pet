# Build and test changes through GitHub Actions

## Goal

Give each pull request a reproducible build-and-test result, useful reports, and an identifiable native build.
Exercise the packaged helper from that build before reporting success.
This is the first feature in the approved [automation roadmap](area.md), ahead of session-cards C2.

The user approved the roadmap on 2026-10-31. The eight tasks below are proposed and need approval before implementation.
No workflow, tooling, build, test, helper injection, or repository settings change is authorized by this document.

## Done when

- PRs targeting `main`, pushes to `main`, and manual runs execute the workflow without path filters.
  A documentation-only PR also receives a result.
- A newer run cancels an older run for the same PR. Runs for `main` finish independently.
- An explicit macOS image and Xcode selection build the package and app bundle, and run the complete existing Swift suite.
  Reports record the selected and actual macOS, architecture, Xcode, Swift, Python, and workflow-validator versions.
- The build verifies both executables, `Info.plist`, and the packaged Pet resource bundle before uploading one archive and manifest.
  The manifest identifies the commit, run, attempt, toolchain, configuration, and file checksums.
- A separate job downloads that run's archive, verifies its identity and checksums, and runs fictional process checks against its helper.
  It does not rebuild either executable. Missing or altered artifacts fail before execution.
- Contract reference checks run separately. Their known difference from SessionStore remains explicit pending its owning fix.
- Swift tests produce machine-readable test results, coverage JSON, and readable HTML coverage for production Swift sources.
  Coverage summaries identify modules. Missing or malformed expected reports fail after an otherwise successful test run.
- Available test, coverage, build, and process reports upload after failures, with a summary identifying failed jobs and missing evidence.
  Early setup failure or cancellation can leave no report. Neither condition establishes a passing run.
- `Required` runs after all required jobs and accepts only the exact expected set of successful results.
  Failure, cancellation, skipping, missing jobs, malformed input, and unknown states fail it.
- A hosted passing PR run, deliberate failure, documentation-only run, artifact rejection, and supersession check demonstrate the contracts above.
  Evidence identifies the tested commit and final result. A cancelled run cannot satisfy acceptance.
- Every check has a local reproduction command and a troubleshooting recipe in this spec.
  Remote actions/tools are pinned, permissions are minimal, job times are bounded, and no release secrets are needed.

## Out of scope

- Coverage thresholds and comparisons: coverage-gates. Formatting, linting, and broad script/document checks: quality-gates.
- Expanded architecture/OS/toolchain matrices: compatibility-matrix. Sanitizers and repeated/generated-input checks: robustness-checks.
- Secret scanning, tracked-runtime-data guards, dependency maintenance, and CodeQL: security-maintenance.
- App launches, GUI interactions, focus/capture checks, and live agents: native-acceptance and existing feature acceptance.
- Branch protection and merge enforcement: merge-gates. No repository settings are changed here.
- Signing, notarization, release publishing, paid services, and caching.
- Fixing unrelated product or test defects. Record a failure and propose its separate repair instead of weakening assertions.

## Constraints

- Preserve pet-first startup, optional integrations, module ownership, and existing Codex, Claude Code, and Otty configuration.
- Use fictional input and disposable runner state. Do not discover installed agents, inspect credentials, or read real session data.
- Store builds, reports, temporary fixtures, extracted artifacts, and runtime files outside the checkout.
  Never upload home directories, environment dumps, configuration files, or captured sessions.
- Use `pull_request`, not privileged execution of PR code. Default to `contents: read`, with checkout credentials disabled.
  Pin external actions by verified full commit SHA, and separately verify any downloaded tool binary.
- Use no retry, test exclusion, `continue-on-error`, or ignored exit code to hide a failure.
  Preserve the original exit status when collecting output. Missing data does not count as zero failures.
- Existing task-specific test/build authorization remains required. Hosted checks begin only after the user commits and pushes approved workflow changes.
  Do not dispatch workflows, open PRs, or push failure probes on the user's behalf without explicit instructions.
- Keep the eight implementation tasks within the plan-feature size limits, including spec/STATUS updates.
  Each task below changes at most one implementation file. Review signatures and any needed split in its next-task plan.

## Workflow contract

| Job | Work | Time limit |
|---|---|---|
| Workflow | Validate workflow syntax with a pinned actionlint release | 5 minutes |
| Tests | Full Swift suite, machine-readable results, coverage export, report upload | 20 minutes |
| Build | Package the app/helper and validate the archive and manifest | 15 minutes |
| Contract | Run `scripts/check-event-contract.py`, preserving its known evidence limit | 5 minutes |
| Helper | Download and verify Build's artifact, then run actual helper process checks | 10 minutes |
| Required | Validate every expected upstream result, then summarize the outcome | 2 minutes |

Use Linux for Workflow, Contract, and Required. Tests, Build, and Helper use the qualified macOS image and Xcode.
Helper depends on Build. Required depends on all five other jobs and uses `always()`.
It cannot convert an interrupted workflow into success. Give job and workflow names stable, unique identities.

Run every required job for every eligible PR. Change-based skipping is deferred.
Group PR concurrency by workflow and PR number. Give default-branch runs distinct groups so they do not cancel each other.
Set matrix fail-fast off when compatibility-matrix later adds independent required combinations.

The initial macOS candidate is the explicit `macos-26` Apple Silicon image.
F1 qualifies its installed Xcode versions and pins one exact supported selection. Fail if that selection disappears.
Do not silently use another Xcode or substitute `macos-latest`. This foundation does not establish macOS 14 runtime compatibility.

## Artifact and report contract

- Build uses the existing `scripts/run.sh --build-only` packaging path without launching the app.
  Foundation validates the current debug bundle. Release configuration belongs to compatibility-matrix.
- Preserve executable modes and the resource bundle when archiving. Validate archive paths and reject escaping entries before extraction.
- Name the build artifact with commit, run ID, and run attempt. Use the same identity for upload and download.
  Verify platform/configuration identity and the manifest's checksums before running the downloaded helper.
  Checksums detect altered content. They do not constitute signed provenance.
- F2 adds an explicit helper-path option to the existing process checker while preserving its default local behavior.
  It must refuse existing runtime endpoints. The tests retain their deadlines, omission checks, and silent helper behavior.
- Store binaries for one day and reports for three days. Missing required build files fail upload.
  Report uploads run after earlier failure when the job is not cancelled. Missing expected reports are visible in the summary.
- Archive text logs with bounded output. Report publication cannot mask the original test, build, or process exit status.
- Coverage includes production sources, excluding generated/test code by a documented rule.
  Keep instrumented tests separate from the uninstrumented build artifact. Export only supported formats from the pinned toolchain.
  Normalize source paths for readable HTML and record tool failures. Do not invent coverage after a failed test execution.
- Use native Swift Testing output supported by the selected toolchain for machine-readable test results.
  A converter, if needed, must retain test identity, failure, and skipped status. Do not report a disabled test as passed.
- Keep a small allowlist for environment metadata. Store no raw environment or secrets in reports.

## Verify

Seam: the real GitHub Actions PR run, through uploaded build artifacts to the packaged helper process.
Local commands provide reproduction. They do not establish hosted scheduling, cancellation, permissions, or artifact acceptance.

Existing commands, only after task-specific authorization:

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --enable-code-coverage
env TMPDIR=/private/tmp DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only
python3 scripts/check-event-bridge.py
python3 scripts/check-event-contract.py
```

The process checker requires the app to be quit and refuses an existing socket.
Do not quit another app instance or remove its socket to make the check run.
Passing means zero exit status, no failed Swift tests, and `Bridge process checks passed` from the process checker.
The contract reference checker must exit zero. Its own output is not proof that its model matches SessionStore.

Proposed foundation CLI commands, to implement and finalize in their owning task plans:

```bash
actionlint .github/workflows/ci.yml
python3 scripts/ci/bundle.py --app "/private/tmp/notch-pet-dev/Notch Pet.app" --output /private/tmp/notch-pet-ci/bundle
python3 scripts/ci/bundle.py --verify /private/tmp/notch-pet-ci/bundle
python3 scripts/check-event-bridge.py --helper "/private/tmp/notch-pet-ci/extracted/Notch Pet.app/Contents/MacOS/NotchPetHook"
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 scripts/ci/coverage.py --build-root /private/tmp/notch-pet-dev/build --output /private/tmp/notch-pet-ci/reports
python3 scripts/ci/required-result.py
git diff --check
```

The bundle verifier must reject missing resources, altered contents, mismatched identity, and escaping archive paths.
F3's task plan specifies extraction paths and manifest identity inputs before code is written.
The coverage exporter must reject missing/malformed input and produce HTML, JSON, and a module summary from real coverage.
`required-result.py` reads `CI_JOB_RESULTS` and succeeds only for Workflow, Tests, Build, Contract, and Helper's exact successful results.
F6's fixtures cover all-success, non-success states, missing/extra jobs, malformed input, and empty input in at most five grouped cases.
The script reports job names and bounded result labels, not raw input.

F8 records hosted URLs and commit IDs for the passing run and the failure drills.
Use disposable reviewed changes for drills, and restore them before the final passing run.
Verify that a deliberate test/build failure rejects Required, a modified artifact is rejected before execution,
and two pushes to one PR cancel only the older run. Inspect the downloaded archive and HTML coverage.
Record incomplete drills as incomplete. Do not mark F8 done from local checks or written configuration alone.

## Known evidence limits

- The full suite has a recorded intermittent `IntegrationHealthProbeTests.versionProbeBoundsItsProcessAndOutput` timeout.
  Keep it enabled. A recurrence blocks a passing baseline and needs a separately approved diagnosis or repair.
- `scripts/check-event-contract.py` permits a conflicting turn ID to restore working state, unlike SessionStore's accepted unseen-turn rule.
  Preserve this warning until its own repair is approved. CI running that checker does not resolve the mismatch.
- `ContractAndSocketTests.swift` assumes the extra byte in its maximum-size frame check is already buffered.
  Its correction remains separate from this feature.
- No captures or native GUI acceptance run here. Existing deferred feature checkboxes stay unchanged.

## Decisions

- [0014: Use comprehensive GitHub Actions CI](../../decisions/0014-use-comprehensive-github-actions-ci.md).
- [0015: Adopt formatting and selected lint rules later](../../decisions/0015-adopt-swift-format-and-selected-swiftlint-rules.md).
- **Cancel superseded PR runs and finish default-branch runs, 2026-10-31.** The user approved this SMRT pattern over cancelling every older branch run.
- **Report coverage before setting thresholds, 2026-10-31.** The user approved a measured baseline followed by enforcement in coverage-gates.

## My calls

- Implementation branch: `feat/automation-ci-foundation`, created from `origin/main` at `7735ec6` after the user's explicit branch-transfer approval.
  The six planning documents moved here without session-cards C1 (`1f30a3c`), which remains on its own branch.
- Keep lightweight Python CLI tooling in `scripts/ci/`, using the standard library initially.
  Keep process checks in the existing script to avoid duplicating their assertions.
- Keep the initial reproduction/troubleshooting guide here. merge-gates can create a broader operations guide when the remaining checks exist.
- Start without caches or external coverage services. Use the job limits and retention above as initial bounded settings.
- Each implementation task reserves two file changes for this spec and STATUS.md.
  A task that needs a second implementation file must be split and reviewed before coding.

## Tasks

- [ ] F1: Add `.github/workflows/ci.yml` with a qualified macOS/Xcode selection, existing Swift/build/contract checks, pinned workflow validation, bounded jobs, and PR supersession cancellation; validate syntax and the local baseline.
- [ ] F2: Add an explicit packaged-helper path option to `scripts/check-event-bridge.py`, preserving the default path, socket protections, and existing assertions; verify both invocation modes with fictional input.
- [ ] F3: Add `scripts/ci/bundle.py` to validate and archive the actual app bundle with its identity/checksum manifest; verify a valid bundle and bounded rejection cases.
- [ ] F4: Wire Build and Helper in `.github/workflows/ci.yml` to upload, download, and verify the same build artifact, then run F2 against its helper without rebuilding; verify the local artifact round trip and workflow syntax.
- [ ] F5: Add `scripts/ci/coverage.py` to export real Swift coverage as HTML, JSON, and per-module summaries; verify real output and missing/malformed-input rejection without adding thresholds.
- [ ] F6: Add `scripts/ci/required-result.py` accepting exactly the expected successful job results; verify the five grouped success/failure fixture cases in the Verify section.
- [ ] F7: Complete `.github/workflows/ci.yml` with machine-readable test results, coverage export, failure-report uploads, summaries, and the always-evaluated Required job; finalize this spec's reproduction/troubleshooting recipes and verify syntax plus local checks.
- [ ] F8: Verify hosted passing and deliberate-failure runs, a documentation-only PR, artifact rejection, and superseded-run cancellation after the user pushes; record commit-linked evidence and restore a final passing run.
