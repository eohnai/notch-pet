# macOS and Swift compatibility checks

Needs: pull-request-checks

## Goal

Show whether the same source and tests work on declared Apple Silicon, Intel, and Swift toolchain combinations before merging.
Extend the [CI area](area.md)'s primary pipeline while preserving the app's existing macOS deployment target and native architecture.
Proposed branch: `feat/ci-compatibility`.

## Done when

- A documented matrix names exact hosted runner labels, native architectures, Xcode selections, and observed Swift versions.
  Available image manifests are checked when selecting pairs; moving `macos-latest` and an unreported default Xcode are not the compatibility contract.
- The matrix contains native Apple Silicon and Intel lanes. Each compiles both executable products and runs all four existing Swift test targets.
  Inspecting a cross-compiled binary or running under translation is not reported as native runtime coverage.
- On at least one native architecture, a second explicitly selected toolchain exercises the declared compatibility range beyond the primary toolchain.
  Document the oldest tested compiler separately from the manifest's Swift tools 6.0 requirement; an unavailable Swift 6.0 toolchain cannot be called tested.
- Toolchain selection fails clearly if the declared installation is missing or reports a different compiler than expected.
  No silent fallback, `continue-on-error`, or retries convert unsupported/unverified pairs into green.
- Every declared mandatory matrix lane participates in `CI / Required`; one failed or skipped lane makes the gate fail.
  Matrix failure does not cancel sibling lanes before their useful diagnostic evidence can be collected.
- All declared lanes complete in an authorized hosted run, with runner/compiler versions and bounded failure logs visible.
  Claims distinguish runtime-tested hosted OS versions, compile-time deployment targeting, and untested macOS 13 runtime behavior.

## Out of scope

- Supporting Linux/Windows, changing `Package.swift` platform requirements, requiring local users to install several Xcodes, or replacing SwiftUI/AppKit.
- Claiming runtime coverage on the minimum macOS version when that version is not actually used by a runner.
- Universal-binary distribution, visual desktop/notch/focus acceptance, installed-agent compatibility, or battery profiling on hosted hardware.
- Expanding every architecture/toolchain combination into an unbounded Cartesian matrix without an independently useful coverage reason.

## Constraints

- Follow the [shared CI boundaries](area.md). The user approved this task list and its scoped local verification on 2026-10-30;
  this spec still awaits its prerequisite and execution. Planning alone does not activate a goal.
- Keep the primary coverage run once; additional compatibility lanes need not duplicate coverage collection.
- Each task changes at most three files including its spec update, adds at most three production functions and at most five test cases.
  Unexpected cross-platform product failures need their own bounded diagnosis before any change to production code.
- Preserve existing deadlines and socket ownership semantics. Tests on slower hardware may reveal bugs; weakening the checks is not compatibility work.
- Runner/Xcode retirement must fail visibly until the declared pair is intentionally updated and reverified.

## Verify

- Seam: actual hosted native execution of the existing Swift test products, including their real disposable socket/process tests.
- Use the working build/test commands from [pull-request-checks](pull-request-checks.md#verify) with each declared developer directory and temporary scratch path.
- Log `uname -m`, `sw_vers`, `xcodebuild -version`, and `swift --version`, then assert the selected environment before compiling.
- Compare the matrix with official runner-image manifests and available repository runner labels at implementation time.
- Observe per-lane results and prove the Required dependency result fails when a matrix member fails or is skipped.
  Local schema/fixture checks support gate logic; actual hosted evidence is still required for native runtime claims.
- Run `git diff --check`; no runtime commands were executed in this planning session.

## Decisions

- Hosted native checks and the separately reviewable scope follow the [area decisions](area.md#decisions).

## My calls

- Reuse the primary lane and add the missing native architecture first, followed by one additional useful toolchain lane.
  Choose their exact versions when current runner availability can be checked.
- Keep `fail-fast: false` for the matrix and use lane-specific temporary paths and diagnostic artifact names.
- Do not add compiled-build caches in this feature; a cache must not mask a missing architecture/toolchain build.
- Keep the existing minimum OS declaration unchanged and publish the narrower actual runtime coverage honestly.

## Tasks

- [ ] CM1: Establish and document the primary lane's explicit runner, native architecture, Xcode, and Swift assertions against current hosted availability; verify it fails on an unavailable or mismatched developer directory.
- [ ] CM2: Add the other native architecture to both executable builds and the full Swift suite, with isolated diagnostics; verify real execution and include its result in Required.
- [ ] CM3: Add a second supported Swift toolchain on a selected architecture, documenting the tested compiler range and minimum-OS evidence limits; verify its complete suite without relying on primary build output.
- [ ] CM4: Verify every declared lane in an authorized hosted run and the gate's failure/skip handling, recording the compatibility table and update procedure without claiming untested OS or provider support.
