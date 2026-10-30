# Pull request checks

## Goal

Give contributors a repeatable GitHub Actions result before merging: compile and test the native app, exercise the real hook process,
and expose failures through one dependable required check. This is the first end-to-end feature in the [CI area](area.md).
It exercises existing pet/session/usage behavior without claiming completion of their deferred acceptance. Proposed branch: `feat/ci-pull-request-checks`.

## Done when

- Pull requests targeting `main`, pushes to `main`, and explicit manual dispatch run the workflow without source-path filters that can strand a required check.
  Newer runs cancel obsolete runs for the same pull request/ref without cancelling unrelated branches.
- A primary hosted macOS lane selects and reports an explicit available Xcode/Swift version and architecture,
  compiles both executable products, and runs all four Swift test targets. Compiler failures, test failures, or zero discovered tests fail the lane.
- Source validation checks shell/Python syntax, the plist, and tracked-change whitespace without generating runtime files in the checkout.
  Swift style enforcement belongs to [maintenance](maintenance.md), not an unreviewed global reformat in this feature.
- A coverage run produces a readable summary and machine-readable report for the four production modules exercised by the Swift suite
  (Pet, EventBridge, SessionState, and NotchPet), with toolchain/revision metadata. Missing, malformed, or empty production coverage fails;
  no percentage floor is invented. Report NotchPetHook process coverage separately as unmeasured unless it is actually collected.
- The debug bundle is built without launching the app, then the actual NotchPetHook executable passes the fictional helper-process checker.
  The reference-contract checker and production socket/inbox/store tests pass; a Python reference result alone is insufficient.
- The reference-model unseen-turn discrepancy and maximum-frame test assumption are addressed with checkable regressions consistent with the accepted contract.
  Do not change the production unseen-turn rule or socket timeouts to make CI green.
- `CI / Required` succeeds only when every expected mandatory job succeeds. Failed, cancelled, skipped, or missing results cannot produce green.
  Matrix jobs added by later specs must feed the gate as well. Gate logic is exercised against all five result classes.
- Actions are pinned to verified full commit SHAs, checkout does not retain credentials, permissions default to `contents: read`,
  every job has a finite timeout, and jobs requiring check execution run only in ordinary PR/push/dispatch contexts, never `pull_request_target`.
- Bounded logs and coverage artifacts are retained for diagnosis, including failed checks when files exist; artifact collection cannot conceal the originating failure.
  At least one authorized hosted run executes the full pipeline successfully before acceptance, with any missing hosted evidence stated explicitly.

## Out of scope

- Additional architectures or toolchain combinations, release-mode artifact delivery, Swift lint policy, workflow lint tooling, and Dependabot: sibling CI specs.
- Changing pet/session/usage product behavior, completing existing feature acceptance, installed-agent compatibility, live account access, or provider configuration.
- UI launches, visual checks, capture, signing, notarization, publication, branch-protection changes, commits, pushes, or pull-request creation.
- Arbitrary coverage floors, timing relaxations, automatic test retries, blanket exclusions, or suppressing an existing failure to make the gate pass.

## Constraints

- Follow the [shared CI boundaries and decisions](area.md), including existing local verification restrictions and hosted-action authorization.
- Each implementation task changes at most three files, including config and its spec updates, adds at most three production functions,
  and adds at most five test cases. Split before coding if implementation or an unexpected failure exceeds that limit; no standing record-file exemption is assumed.
- Keep existing test targets and fixtures as the baseline. Reproduce unexpected failures and plan bounded fixes instead of adding unrelated repairs to a CI task.
- Use one source of expected mandatory job IDs for gate validation. An empty result object must never pass through a vacuous all-success check.
- Treat process timing as a bounded check in a hosted environment, not a guarantee of real-time scheduling or battery efficiency.

## Verify

- Seam: GitHub Actions checks execute the production Swift products/tests and the real fictional-input helper/socket process path.
- Existing build: `bash scripts/run.sh --build-only`.
- Existing Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
  CI will select its verified Xcode path explicitly and use an isolated temporary scratch path shared only where the process checker needs the debug helper.
- Coverage: the same Swift suite with `--enable-code-coverage`; use that toolchain's LLVM tools to produce a report and validate production-file coverage.
  Final exact export commands and the known-primary runner pair are recorded during implementation.
- Existing process/reference commands: `python3 scripts/check-event-bridge.py` and `python3 scripts/check-event-contract.py`.
  The process checker currently locates the debug helper under `${TMPDIR:-/private/tmp}/notch-pet-dev/build`; do not point it at a nonexistent CI build.
- Validate script syntax without execution/capture or bytecode writes in the checkout; `git diff --check` checks whitespace.
- Exercise gate inputs for success, failure, cancellation, skip, and missing expected results using fictional local fixtures.
  Inspect an authorized hosted run to establish that its actual `needs` mapping matches those expectations and that failure logs survive a failed lane.
- Planning only: none of the build, test, process, or hosted commands above ran while writing this spec.

## Decisions

- Scope, hosted execution, and baseline coverage are accepted in the [area decisions](area.md#decisions).
  The user subsequently approved the task list and its scoped local verification on 2026-10-30.
  [Goal preparation](../../goals/ci-pull-request-checks.md) does not activate execution or authorize publication.

## My calls

- Use `.github/workflows/ci.yml` and the stable job display name `Required`, matching the reference project's gate pattern.
- Begin with clean temporary builds rather than caching compiled products. The package currently downloads no external Swift dependencies.
- Collect LLVM coverage without a third-party upload service. Count production code, exclude tests/generated build files, and retain module-level visibility.
  Do not conflate execution of an uninstrumented helper with measured helper coverage.
- Retain diagnostic artifacts for three days initially; use distinct run/attempt/job names and upload only allowlisted outputs.
- Keep baseline reconciliations ahead of workflow wiring so the pipeline starts from honest tests rather than encoded exceptions.
- The user explicitly requires `main` as the intended default and sole automated CI branch target. Keep PR/push filters on `main`;
  current GitHub default metadata does not authorize expanding CI to feature branches.

## Tasks

The user approved these tasks and their scoped local verification on 2026-10-30. None has started in this planning session.
Each task includes its own verification and spec update within the three-file limit. The first goal is prepared, not active.

- [x] PR1: Align the Python reference model with the accepted unseen-turn recovery rule; cover conflicting-turn replay and genuinely new-turn recovery with at most five regression cases, preserving production semantics.
- [x] PR2: Replace the maximum-frame socket test's extra-byte buffering assumption with deterministic setup for the accepted buffered-input contract; verify the affected socket tests without changing deadlines.
- [x] PR3: Add the primary macOS workflow running both executable builds, all four Swift test targets, script/plist/whitespace validation, and bounded failure logs; verify its commands locally when authorized.
- [x] PR4: Add LLVM coverage export and validation to the primary suite, publishing a production/module summary and raw report; verify valid output and rejection of missing, malformed, or empty reports.
- [x] PR5: Add the debug-bundle and real helper-process job with a matching temporary build layout, plus the reference checker; verify fictional delivery and existing bounded failure cases with no app launch or installed-agent changes.
- [x] PR6: Add the stable Required job and expected-job validation, checking success, failure, cancellation, skip, and missing-result fixtures; verify that it always evaluates dependencies and preserves upstream failures.
- [ ] PR7: Verify an authorized hosted run and its actual gate/artifact behavior, documenting reproducible local commands and the required-check setup; record pending hosted evidence explicitly if publication or dispatch is not yet authorized.

## Execution evidence: PR1 and PR2 (2026-10-30)

- Worktree: `/private/tmp/notch-pet-ci-worktree`, branch `feat/ci-pull-request-checks`, committed base `ec1d5b2`. No concurrent agent-workflow code was copied.
- PR1 reproduction: a one-off reference sequence submitted `a`, conflicting `b`, then `b` again. It incorrectly returned `applied`/`working`; the assertion failed with exit 1. The new permanent recovery cases also failed before the correction.
- PR1 correction: record whether a turn was known before inserting it, matching Swift SessionStore. `python3 scripts/check-event-contract.py` now exits 0: 68 message cases, 37 sequences/122 steps, four capacity boundaries and four new recovery cases across both providers. Production state behavior is unchanged.
- Baseline full suite: the committed Swift code passed all four test targets with coverage enabled (exit 0). This run used local Apple Swift 6.4/Xcode 27; its output is not borrowed from the active agent worktree.
- PR2: replace the concurrent maximum-frame/extra-byte assumption with a direct production-reader boundary check that prequeues the bytes before reading. It verifies both queued-extra rejection and valid maximum-frame receipt before a later byte. The remaining callback rejection cases stay in place.
- The first test-only probe stalled because a default Unix socket buffer accepted only 8192 of 16385 bytes before a read. A separate nonblocking Python probe confirmed that limit (exit 1). The corrected test explicitly sizes the send buffer to 65536 and uses nonblocking writes; no production deadline or buffer was changed.
- Focused command: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer TMPDIR=/private/tmp/notch-pet-ci-core/ CLANG_MODULE_CACHE_PATH=/private/tmp/notch-pet-ci-core/clang-cache SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/notch-pet-ci-core/swift-cache swift test --scratch-path /private/tmp/notch-pet-ci-core/notch-pet-dev/build --enable-code-coverage --filter 'ContractAndSocketTests|SessionStoreTests.recoveryRequiresAnUnseenTurnIdentity|SessionStoreTests.freshTurnRecoversOnlyAfterRequestsResolve'`. Exit 0: two recovery tests and 15 contract/socket tests, zero failures.
- The initial sandboxed Swift command failed at manifest execution with `sandbox-exec: sandbox_apply: Operation not permitted`. Approved outside-sandbox execution succeeded; no sandbox setting was changed.
- Slice budgets: PR1 changes its Python checker and this spec (one added check function, four recovery cases); PR2 changes its Swift test file and this spec (one added test method, two boundary inputs). Goal/STATUS updates are separate records-only slices.

## PR3 and PR4 slice plan

- PR3a: add the source checker and initial quality/native workflow, updating this spec (three files; two new Python functions). The source checker passes on the real checkout and rejects invalid Python, shell, plist, JSON and whitespace probes. Workflow YAML parses.
- PR3b: run local build/test/discovery commands and retain full output before marking PR3 checked. Local Swift 6.4 is separate from selected hosted Xcode 26.3/Swift 6.2; the latter's actual run remains PR7 evidence.
- PR3c: cap retained top-level diagnostic logs at 2 MiB each before artifact upload, with an explicit truncation header; coverage JSON/summary remains intact. Changes are source checker, workflow and this spec (three files; source checker totals three production functions).
- PR4a: implement LLVM collection/validation plus five Python regression tests, updating this spec (three files; three production functions). Actual export from the four local test executables succeeds and finds all four production modules. All five regression tests pass.
- PR4b: wire the verified coverage command/tests/report into the workflow and this spec (two files); only then finish PR4. Records-only goal-log/STATUS checkpoint work is separate.
- The selected primary pair is standard `macos-15` (arm64), `/Applications/Xcode_26.3.app/Contents/Developer`, expecting the Swift 6.2 compiler family. Verified available labels/Xcode installation in the official runner image documentation; no runtime claim is made before PR7.
- Official sources checked 2026-10-30: https://github.com/actions/runner-images#available-images and https://github.com/actions/runner-images/blob/main/images/macos/macos-15-arm64-Readme.md.
- Action pins verified against their official release commit pages: checkout v7.0.1 `3d3c42e5aac5ba805825da76410c181273ba90b1`, upload-artifact v7.0.2 `cf430e030ddbb5b0abf93d22962f4752f3646cd9`. The connected GitHub fetch tool returned Unknown tool; official web sources were used as fallback.

## PR5 and PR6 slice plan

- PR5a: correct the existing process checker's discovery for the actual Swift 6.4 Swift Build layout (`out/Products/Debug`) while preserving native SwiftPM layout support and refusing ambiguous products. Before this correction, the actual built bundle succeeded but the process checker exited 1 at its helper-discovery assertion. Changes are checker, this spec and correction of the goal's accidental checker-file omission (three files, no new production function).
- PR5b: wire the build-only/process/reference job into the workflow and this spec (two files), then verify actual fictional helper delivery. Production helper behavior, deadlines and endpoint ownership are unchanged.
- PR6a: add three gate-checker functions and five regression tests, updating this spec (three files). All five tests pass for successful, failed, cancelled, skipped and missing/empty results. Dependency declarations omitted from the gate also fail.
- PR6b: wire Required into the workflow and verify its actual declaration/result shape, updating this spec (two files). The JSON-compatible `needs` list is the source of expected IDs; it must equal all other declared jobs. The small checker refuses unsupported syntax rather than treating it as an empty set.

## Local integration evidence: PR3-PR6 (2026-10-30)

- PR3: `bash scripts/run.sh --build-only` completed with exit 0 and printed `/private/tmp/notch-pet-ci-core//notch-pet-dev/Notch Pet.app`. The full suite with coverage completed with exit 0: SessionState 73 tests, Pet 17, NotchPet 8, EventBridge 32; total 130, zero failures. Full log: `/private/tmp/notch-pet-ci-core/full-tests.log`.
- Actual manifest discovery plus that saved log: `python3 -B scripts/ci/check-source.py --test-log /private/tmp/notch-pet-ci-core/full-tests.log --manifest-json /private/tmp/notch-pet-ci-core/package.json` exits 0 and reports four test targets and 130 passed tests. Syntax/JSON/plist/changed-whitespace validation exits 0. Retained log-cap probing verified a 2 MiB maximum, final diagnostic preservation and untouched coverage JSON.
- PR4: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer python3 -B scripts/ci/check-coverage.py --scratch-path /private/tmp/notch-pet-ci-core/notch-pet-dev/build --output-dir /private/tmp/notch-pet-ci-core/coverage` exits 0 using one actual merged profile and four test executables. Production data covers 36 files across all four modules. Coverage artifacts remain outside the checkout, with `dirty: true` and committed base recorded honestly.
- Coverage baseline: EventBridge 534/578 executable lines (92.39%); NotchPet 84/1563 (5.37%); Pet 89/151 (58.94%); SessionState 1215/1259 (96.51%). No percentage floor is enforced; helper process coverage is unmeasured. These are local Swift 6.4 results, not hosted or visual acceptance.
- PR5: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer TMPDIR=/private/tmp/notch-pet-ci-core/ python3 -B scripts/check-event-bridge.py` exits 0: unavailable app, 15 fictional hook projections, exact 262144-byte stdin capacity, malformed/oversized/unsupported/pane rejection, open stdin, busy socket and silent zero-exit cases. Observed process times were 7-18 ms including launch. Sandbox binding was denied (`Operation not permitted`); the approved outside-sandbox run passed without product changes.
- PR6: all five actual CLI result fixtures against the real workflow behaved correctly: success exit 0; failed, cancelled, skipped and missing job result exit 1. The dependency-list reader rejects a declared job omitted from Required. Workflow YAML parses with quality/tests/bridge/required and the expected dependency set.
- `python3 -B -m unittest discover -s scripts/ci -p 'test_*.py' -v`: ten tests passed, covering five coverage-report and five gate-result cases. `git diff --check`: exit 0.
- PR7 remains open. Local runtime is Apple Swift 6.4/Xcode 27. Selected hosted macOS 15/Xcode 26.3 execution, upload/download visibility and the hosted Required result have not run. README now supplies local reproduction, artifact limits, required-check setup and evidence boundaries; no hosted rule was edited.
- Live metadata read: `gh repo view --json nameWithOwner,defaultBranchRef` returned repository `eohnai/notch-pet`, default `feat/notch-companion`. The initial `main` assumption was corrected without dropping `main` coverage. Every PR target is covered, enabling a proposed CI-only stacked draft PR against the already-pushed `feat/pets-built-in-pet` at the committed baseline; publication still requires user approval.

## User steering and publication handoff (2026-10-30)

- The user explicitly required `main` as the intended default and the only automated branch target. The temporary all-PR/feature-default implementation was reverted before committing. PRs targeting `main` and pushes to `main` trigger CI; feature branches do not. Main-only trigger validation passed.
- Live branch inspection found no remote `main`. Following the requested default correction, `main` was created at the existing default branch's commit `1c5d9cf7e2f698357b05230832071aa097621133`, then set as default. Read-back verified both `main` and the preserved `feat/notch-companion` still point to that same commit. No new source commit or feature-branch rewrite was made by this correction.
- The later user instruction is explicit: "just commit and push first, settle later". It authorizes committing/pushing only this isolated CI worktree. Do not open the previously proposed stacked PR, change additional settings or restart runtime verification.
- PR1-PR6 are locally verified. PR7 remains open: hosted Xcode 26.3 execution and artifacts are deferred. The goal is paused after the requested commit/push; no spec is marked done from local checks alone.
