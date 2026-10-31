# Build and test changes through GitHub Actions

## Goal

Give each pull request a reproducible build-and-test result, useful reports, and an identifiable native build.
Exercise the packaged helper from that build before reporting success.
This is the first feature in the approved [automation roadmap](area.md), ahead of session-cards C2.

The user approved the roadmap on 2026-10-31 and activated the F1–F7 local implementation goal later that day.
That activation authorizes those tasks and their bounded local checks. The user also permits per-task commits,
subject to AGENTS.md's commit-plan approval procedure. F8 hosted work and repository settings changes remain unauthorized.

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
python3 scripts/ci/bundle.py --app "/private/tmp/notch-pet-ci/package/notch-pet-dev/Notch Pet.app" --output /private/tmp/notch-pet-ci/bundle --identity /private/tmp/notch-pet-ci/identity.json
python3 scripts/ci/bundle.py --verify /private/tmp/notch-pet-ci/bundle --identity /private/tmp/notch-pet-ci/identity.json
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

- [x] F1: Add `.github/workflows/ci.yml` with a qualified macOS/Xcode selection, existing Swift/build/contract checks, pinned workflow validation, bounded jobs, and PR supersession cancellation; validate syntax and the local baseline.
- [x] F2: Add an explicit packaged-helper path option to `scripts/check-event-bridge.py`, preserving the default path, socket protections, and existing assertions; verify both invocation modes with fictional input.
- [x] F3: Add `scripts/ci/bundle.py` to validate and archive the actual app bundle with its identity/checksum manifest; verify a valid bundle and bounded rejection cases.
- [x] F4: Wire Build and Helper in `.github/workflows/ci.yml` to upload, download, and verify the same build artifact, then run F2 against its helper without rebuilding; verify the local artifact round trip and workflow syntax.
- [ ] F5: Add `scripts/ci/coverage.py` to export real Swift coverage as HTML, JSON, and per-module summaries; verify real output and missing/malformed-input rejection without adding thresholds.
- [ ] F6: Add `scripts/ci/required-result.py` accepting exactly the expected successful job results; verify the five grouped success/failure fixture cases in the Verify section.
- [ ] F7: Complete `.github/workflows/ci.yml` with machine-readable test results, coverage export, failure-report uploads, summaries, and the always-evaluated Required job; finalize this spec's reproduction/troubleshooting recipes and verify syntax plus local checks.
- [ ] F8: Verify hosted passing and deliberate-failure runs, a documentation-only PR, artifact rejection, and superseded-run cancellation after the user pushes; record commit-linked evidence and restore a final passing run.

## F1 partial evidence, 2026-10-31

- A four-job workflow draft exists. It is not accepted or verified.
- Selected Xcode 26.5 build 17F42 to match the local toolchain and an installed version in GitHub's
  [macOS 26 Apple Silicon image inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md).
  Hosted availability and execution remain unverified. The candidate uses `/Applications/Xcode_26.5.app/Contents/Developer`.
- Verified checkout v7.0.1 as `3d3c42e5aac5ba805825da76410c181273ba90b1` using `git ls-remote`.
  Verified actionlint 1.7.12 asset digests against its release metadata:
  Darwin arm64 `aba9ced2dee8d27fecca3dc7feb1a7f9a52caefa1eb46f3271ea66b6e0e6953f`,
  Linux amd64 `8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8`.
- `python3 scripts/check-event-contract.py` exited 0: 68 message cases, 37 sequences/122 steps, four memory boundaries.
  Its existing SessionStore evidence limit remains unchanged.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --enable-code-coverage`
  exited 1: 132 tests in 24 suites, four issues in `IntegrationHealthProbeTests`.
  Both provider cases of `versionProbeBoundsItsProcessAndOutput(agent:)` and
  `diagnosticsDiscardUnrelatedFictionalValues(agent:)` returned `.unavailable(.timedOut)` instead of their expected results.
  Log: `/private/tmp/notch-pet-ci/reports/f1-swift-test.log`. This is an unrelated baseline failure, so the goal stopped.
- `/private/tmp/notch-pet-ci/tools/actionlint .github/workflows/ci.yml` exited 1:
  `.github/workflows/ci.yml:75:19: context "runner" is not allowed here`.
  The partial Build job uses `runner.temp` in job-level `env`, where that context is unavailable.
  This introduced syntax error remains pending with the unverified workflow draft.
- Packaging and all subsequent F2–F7 checks have not run. No tasks were ticked and no commits were made.
- The user then authorized a separate diagnosis, recorded in
  [integration-health](../sessions/integration-health.md#probe-timeout-diagnosis-2026-10-31).
  A temporary instrumented source copy reproduced four issues.
  Serializing only its probe suite passed all 132 tests without changing assertions or the production timeout.
  The user approved a separate repair task. The repository's probe suite now uses `@Suite(.serialized)`.
  Its isolated five-test suite and full 132-test coverage-enabled suite both passed without changing assertions or product code.
  The original failure remains recorded above. F1 can resume; its workflow syntax check and packaging remain pending.

## F1 verified local baseline, 2026-10-31

The separate I2d repair is committed as `7cb67f2`. F1's local requirements are now verified.
Hosted qualification remains F8 and is not established by the published image inventory or local checks.

- `/private/tmp/notch-pet-ci/tools/actionlint .github/workflows/ci.yml` exited 0 with actionlint 1.7.12.
  Build's `TMPDIR` now uses step-level `env`, where `runner.temp` is available.
- `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --enable-code-coverage`
  exited 0 after I2d: 132 tests, 24 suites, zero issues.
- `env TMPDIR=/private/tmp/notch-pet-ci/package DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`
  exited 0, yielding `/private/tmp/notch-pet-ci/package/notch-pet-dev/Notch Pet.app`.
  Both packaged executables are regular executable files. Info.plist parses and passes plutil.
  `Contents/Resources/NotchPet_Pet.bundle` contains packaged resource files.
- `python3 scripts/check-event-contract.py` exited 0: 68 messages, 37 sequences/122 steps, four memory boundaries.
- `git diff --check` exited 0.

Packaging uses a separate scratch root so it cannot replace the instrumented test build.
The workflow uses the same separation through runner-temporary `test-build` and `package` paths.
No app was launched. No cache, repository settings, or installed integration configuration changed.

The four stable F1 job names are Workflow, Tests, Build and Contract.
Every eligible PR, main push and manual run schedules all four without path filters.
Only PR runs share a cancelling concurrency group. Main and manual runs use their run ID.
All checkout calls use the verified immutable pin with persisted credentials disabled.
F4 will add Helper, and F7 will add Required and reports. This intermediate workflow is not full-spec acceptance.

Evidence: `/private/tmp/notch-pet-ci/reports/repair-full-suite.log` and
`/private/tmp/notch-pet-ci/reports/f1-build.log`.

## F2 CLI sketch

Keep `main() -> None` and all existing process assertions.
Add standard-library argparse parsing with one optional `--helper PATH` argument.
Without that argument, retain the existing single-helper lookup under `$TMPDIR/notch-pet-dev/build`.
With it, require an existing executable regular file and use its absolute path without searching the build directory.
Reject an invalid explicit path before creating or locking any runtime endpoint.

Caller examples:

```bash
env TMPDIR=/private/tmp python3 scripts/check-event-bridge.py
python3 scripts/check-event-bridge.py --helper "/private/tmp/notch-pet-ci/package/notch-pet-dev/Notch Pet.app/Contents/MacOS/NotchPetHook"
```

Verify both real invocation modes serially with fictional input.
Each must exit 0 with `Bridge process checks passed` and retain every original assertion.
Verify missing/non-executable explicit paths fail, and a pre-existing owned fictional listener is refused without replacement.
Do not remove or stop any pre-existing user endpoint or app to run these checks.

### F2 verification

Both invocation examples exited 0 with `Bridge process checks passed`.
Each retained all original assertions and verified 15 fictional hook projections, maximum input size,
invalid-input omission, silent zero exits, open-stdin deadlines and busy-socket behavior.
The final default mode measured 4–13 ms per invocation. Packaged mode measured 4–20 ms.
Open-stdin checks completed in 71–76 ms across both modes and providers.

`python3 /private/tmp/notch-pet-ci/diagnosis/check-f2-cli.py` exited 0.
It checked missing, non-executable, directory and symlink paths, each rejected with exit 2.
It created and owned a fictional listener at the normal endpoint, then verified both modes refused it with exit 1
and preserved its inode. The harness removed only its own listener after verifying identity.
No existing user endpoint or app was removed or stopped.

The initial sandboxed default run could not bind a Unix socket (`Operation not permitted`).
Running with approved socket access completed the actual checks. This was an environment permission failure.
Logs: `/private/tmp/notch-pet-ci/reports/f2-default-helper.log` and
`/private/tmp/notch-pet-ci/reports/f2-packaged-helper.log`.
`git diff --check` exited 0. No Swift source changed, so the full suite was not repeated.

The first default run used a coverage-instrumented local helper and created `default.profraw` in the checkout.
F2 now routes `LLVM_PROFILE_FILE` for every child into a checker-owned temporary directory and cleans it on exit.
The generated checkout file was removed. Both real invocation modes and all six rejection/preservation checks
passed again on the final script. No repository profile was created by those final checks.

## F3 CLI and manifest contract

Later tasks use this CLI surface, not an imported Python API:

```bash
python3 scripts/ci/bundle.py --app "/private/tmp/notch-pet-ci/package/notch-pet-dev/Notch Pet.app" --output /private/tmp/notch-pet-ci/bundle --identity /private/tmp/notch-pet-ci/identity.json
python3 scripts/ci/bundle.py --verify /private/tmp/notch-pet-ci/bundle --identity /private/tmp/notch-pet-ci/identity.json --extract-to /private/tmp/notch-pet-ci/extracted
```

The required `--identity` file is independently supplied to both jobs from trusted workflow context and selected toolchain metadata.
It has exactly these fields: `commit` (40 lowercase hex characters), `run_id` (bounded identifier),
`run_attempt` (positive integer), `platform` (`macos`), `architecture` (`arm64`), `configuration` (`debug`),
`xcode_build` (bounded identifier), and `swift_version` (bounded version output).
Creation checks actual host architecture and toolchain against that input.
Verification compares all identity fields before extraction. It never takes expected identity from the manifest itself.
The manifest also records actual macOS and Python versions through an explicit allowlist.

Implementation sketch:

```python
def create_bundle(app: Path, output: Path, identity: dict) -> None: ...
def verify_bundle(bundle: Path, identity: dict, extract_to: Path | None = None) -> None: ...
def main() -> int: ...
```

The output directory contains only `app.tar.gz` and `manifest.json`.
Manifest schema 1 stores identity, allowed version metadata, archive checksum/size and every entry's type/mode.
Regular files also have size and SHA-256. Entries live beneath the exact `Notch Pet.app` root.
Validate the two executable files, the app plist and its executable/package identity, and the Pet bundle's manifest/artwork.
Accept only normal directories and regular files. Reject links, special files, duplicate/escaping/noncanonical paths,
unsafe mode bits, oversized input, and any mismatch between archive entries and the manifest.
Limits: 4096 entries, 240 UTF-8 bytes per path, 4 MiB manifest, 64 MiB per file and 256 MiB total/archive.
These bounds comfortably contain the inspected five-file, 3.75 MB debug app.

Outputs and extraction destinations must be outside the checkout and must not exist already.
Validate the entire archive and payload before creating an extraction destination.
Extract manually into a new private temporary directory, preserve approved modes, then publish it at `--extract-to`.
Never execute either bundled binary from this tool. The Helper job runs F2 only after verification.
Checksums detect changes and do not provide signed provenance.

F3 verification will use the actual F1 bundle plus disposable missing-resource, modified-content,
independent-identity, unsafe-path/link, malformed-manifest and extraction-preservation cases outside the repository.

### F3 verification

The real F1 app produced a five-file archive of 1,955,809 bytes.
Its independently supplied identity names the original build commit `7cb67f2`, fictional run `local-f3`,
attempt 1, macOS/arm64/debug, Xcode build `17F42` and stdout from the explicitly selected Swift toolchain.
Creation validates actual host/toolchain values against that input. F4 will construct the same shape from workflow context.

Both CLI examples above exited 0. The verifier reproduced all source file bytes and permission modes after extraction.
`env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 /private/tmp/notch-pet-ci/f3/check-bundle.py`
exited 0: `F3 bundle acceptance passed: 28 checks; no bundled binary executed`.

The checks cover actual creation/extraction, source and archived missing artwork, changed archive bytes,
changed file content with an updated outer checksum, five independently expected identity mismatches,
boolean/integer identity confusion, malformed/duplicate/unknown-schema/oversized metadata,
an oversized file declaration, escaping/absolute/backslash paths, duplicate and case-colliding entries,
symbolic/hard links, FIFO, setuid mode, wrong binary architecture despite consistent checksums,
malformed plist despite consistent checksums, and preservation of existing output/extraction destinations.
Every invalid verification case failed before publishing an extraction destination.

The added malformed-plist fixture initially exposed an uncaught `xml.parsers.expat.ExpatError`.
The final tool categorizes that parser exception without a traceback or raw decoder details.
The same fixture then passed with the other checks. No requirement or assertion was weakened.

Python syntax validation and `git diff --check` exited 0.
No Swift source, app configuration, or existing test changed. Swift tests and packaging were not repeated.
Evidence: `/private/tmp/notch-pet-ci/reports/f3-bundle-checks.log`.
The independent input is `/private/tmp/notch-pet-ci/identity.json`, the archive is under
`/private/tmp/notch-pet-ci/bundle`, and verified extraction is under `/private/tmp/notch-pet-ci/extracted`.
The expected identity must come from outside the downloaded artifact. A missing `--identity` is a CLI error.

On creation failure, check the selected toolchain, source app layout/modes and resource references.
On verification failure, preserve the failed artifact and inspect the bounded error category before regenerating it.
Do not replace expected identity with the manifest's identity or execute its helper to diagnose a rejected archive.
On an existing destination error, select a new disposable destination instead of overwriting existing files.

## F4 workflow contract

Keep `build`/Build stable and add `helper`/Helper with `needs: build`.
Build exposes `artifact-id` from its upload step. Helper requires a nonempty decimal ID before downloading,
so an empty output cannot fall back to downloading every artifact.
Upload name: `notch-pet-<commit>-<run_id>-<run_attempt>`; retention: one day.
Download that single ID within the current run, with digest mismatch set to `error` and no cross-run token.
The uploaded directory contains F3's archive and manifest only.

Both jobs independently write `notch-pet-ci/identity.json` under runner temporary storage.
Use `GITHUB_SHA`, `GITHUB_RUN_ID`, integer `GITHUB_RUN_ATTEMPT`, fixed macOS/arm64/debug,
selected Xcode build `17F42`, and actual selected Swift stdout.
Build creates and verifies the bundle before upload.
Helper verifies and extracts it before running the unchanged F2 checker against the extracted executable.
Helper contains no build or test command and does not launch the app.

Use verified immutable pins: upload-artifact v7.0.2 at `cf430e030ddbb5b0abf93d22962f4752f3646cd9`,
download-artifact v8.0.2 at `9000827ccba6bdab643e8b6fd33ac0654aef8333`.
Both tag targets were verified with `git ls-remote`.
Their [upload inputs](https://github.com/actions/upload-artifact/blob/cf430e030ddbb5b0abf93d22962f4752f3646cd9/action.yml)
and [download inputs](https://github.com/actions/download-artifact/blob/9000827ccba6bdab643e8b6fd33ac0654aef8333/action.yml)
define these bindings. Hosted action execution remains F8.

Local verification: run the actual YAML shell steps with fictional workflow identity and separate Build/Helper roots,
copy the archive and manifest between them to model transfer, verify identical archive checksums,
and run the extracted helper. Confirm no build directory appears in Helper's root.
Reject missing/modified artifacts before invoking the helper. Run pinned actionlint and `git diff --check`.
The local copy does not establish GitHub service upload/download behavior.

### F4 verification

`python3 /private/tmp/notch-pet-ci/f4/check-roundtrip.py` exited 0:
`F4 local artifact round trip passed`.
The harness used installed PyYAML to select the actual YAML shell blocks; no project dependency was added.
It executed those blocks with separate temporary Build and Helper roots and fictional workflow context.
Local `DEVELOPER_DIR` used `/Applications/Xcode.app/Contents/Developer`, whose version/build matches the selected
hosted Xcode 26.5/17F42. The hosted installation path itself still needs F8.

- Fresh packaging and archive verification exited 0: five files, 1,955,965 archive bytes.
- Both jobs independently generated identical expected identity from commit `2b12972`, fictional run `10404`,
  attempt 1, and their selected toolchain. No expected identity was read from the copied artifact.
- The copied archive and manifest retained exactly the original SHA-256 values.
  Verification and extraction exited 0 after the copy.
- The actual extracted helper passed every F2 process assertion and printed `Bridge process checks passed`.
  It handled 15 fictional hook projections; invocation times were 6–606 ms and open-stdin checks were 71–72 ms.
  Its bytes and mode matched Build's helper. Helper's root contained no build directory.
  Static review also found no build/test/run.sh command in Helper's shell steps.
- A decimal artifact ID passed. Empty, nonnumeric and multiple-ID inputs failed the pre-download guard.
- Missing, modified and wrong-attempt artifacts each failed verification with exit 1.
  None published an extraction directory or reached the helper-execution step.
- Pinned actionlint 1.7.12 and `git diff --check` exited 0.
  No Swift source or tests changed, so the full suite was not repeated.

Evidence: `/private/tmp/notch-pet-ci/reports/f4-roundtrip.log` and the per-step logs under
`/private/tmp/notch-pet-ci/f4/roundtrip-i5udl7ek`.
This is local file-transfer and workflow-shell evidence. No GitHub upload, download, dispatch or push was performed.

For a direct local reproduction using the existing verified F3 output, choose a new temporary root:

```bash
ci_transfer_root=/private/tmp/notch-pet-ci/manual-transfer-1
mkdir -p "$ci_transfer_root"
cp -R /private/tmp/notch-pet-ci/bundle "$ci_transfer_root/downloaded"
python3 scripts/ci/bundle.py --verify "$ci_transfer_root/downloaded" --identity /private/tmp/notch-pet-ci/identity.json --extract-to "$ci_transfer_root/extracted"
python3 scripts/check-event-bridge.py --helper "$ci_transfer_root/extracted/Notch Pet.app/Contents/MacOS/NotchPetHook"
```

Use a fresh root on each run. If the normal socket exists, stop and leave it intact.
For a missing artifact ID or download failure, inspect Build's upload result before rerunning anything.
For identity/checksum rejection, retain the failed files and compare the expected context with the Build run/attempt.
Never rebuild in Helper, switch to another artifact, or copy expected identity out of its manifest to obtain a pass.
