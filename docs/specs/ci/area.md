# CI

Owns automated merge checks, macOS/toolchain compatibility, validated development artifacts, and maintenance of the CI itself.
Code will live in `.github/`, `scripts/ci/`, and the existing packaging and bridge-check scripts in this repository.
The app, session, pet, and usage areas retain ownership of product behavior and feature acceptance.

## Specs

- `pull-request-checks`: Run Swift tests, coverage, source validation, and fictional helper/socket checks behind a reliable required gate.
- `compatibility`: Verify declared Apple Silicon, Intel, and Swift toolchain combinations. Needs: pull-request-checks.
- `development-artifacts`: Produce and validate downloadable unsigned release-mode app bundles. Needs: pull-request-checks.
- `maintenance`: Check workflow definitions, enforce incremental Swift style, and maintain pinned action dependencies. Needs: pull-request-checks.

## Shared context

- The user requested comprehensive CI comparable to `~/projects/personal-website`, then explicitly selected `plan-feature` before implementation.
  On 2026-10-30 they confirmed these four independently reviewable features and their scope, then approved all 23 tasks and their scoped local verification.
  They requested `make-goal` preparation next; [the first goal](../../goals/ci-pull-request-checks.md) and its log are prepared, not active.
- The reference has separate quality, compatibility, build, and runtime checks, a single required gate, pinned actions, minimal permissions,
  timeouts, concurrency cancellation, short-lived artifacts, and Dependabot. Translate those practices to Swift/macOS rather than copying web-specific tools.
- [Package.swift](../../../Package.swift) declares Swift tools 6.0, macOS 13, two executables, and four test targets.
  There are no external Swift package dependencies. Do not add an empty npm-style audit or a package download cache without a dependency to audit/cache.
- [run.sh](../../../scripts/run.sh) currently creates a debug development bundle outside the repository.
  [README](../../../README.md#verify-the-bridge) documents the current build, Swift, helper-process, and reference-contract commands.
- The existing real helper/socket seam supplies process-level coverage without screen capture, installed agents, or an app UI launch.
  [Observation bridge](../sessions/observation-bridge.md) records what that seam establishes and its existing limitations.
- Keep build products, coverage, test logs, disposable sockets, and extracted artifacts in runner/local temporary directories outside the repository.
  Checked-in fixtures and CI configuration are source; captured session data, imported packs, and runtime files are not.
- Preserve installed Codex, Claude Code, and Otty configuration. Use fictional inputs and disposable test environments; do not inspect credentials,
  launch installed providers, install hooks, or contact provider accounts for CI acceptance.
- The user's subsequent CI task-list approval renews the build/test/process checks needed for these tasks. These planning documents run none of them.
  That approval does not resume other deferred feature acceptance, permit app launches/capture, or activate a goal by itself.
- No commit, push, pull request, workflow dispatch, branch-protection edit, or release publication is authorized by this plan.
  Hosted acceptance needs the user's later publication/dispatch authorization or a run they trigger themselves.
- Each spec is a proposed branch and reviewable change. Do not create those branches during planning or treat a dependency as complete merely because code exists locally.

## Decisions

- **Plan core checks, compatibility, development artifacts, and maintenance as four specs.** A single comprehensive CI change was considered;
  the user confirmed the separate reviewable scopes on 2026-10-30 after requesting the personal-website pattern. This accepts scope, not implementation tasks.
- **Use GitHub Actions with hosted macOS execution for native checks.** The user confirmed the proposed hosted checks patterned on personal-website;
  local-only verification would not supply the agreed hosted merge evidence. Select available runner/Xcode versions before implementation, not from a moving default.
- **Use toolchain swift-format with a baseline for existing findings.** The user chose fewer dependencies and style checks over a separately pinned SwiftLint tool on 2026-10-30.
  Existing findings remain visible; the baseline must prevent new findings without requiring a repository-wide reformat. See [maintenance](maintenance.md).
- **Keep the first artifacts unsigned and exclude visual acceptance.** The user confirmed downloadable development bundles and automated process checks;
  signing, notarization, publishing, screen capture, and visual pet/notch acceptance belong to separate work.
- **Measure coverage before choosing a minimum percentage.** The user confirmed an initial baseline with any minimum remaining an explicit choice;
  missing or corrupt coverage is still a failed check. A successful coverage job does not prove deferred app acceptance.

- **Use main as the default branch and sole automated CI target.** The user explicitly corrected the temporary feature-default interpretation on 2026-10-30. PR/push filters remain main-only; the existing feature branch is preserved.

## Open questions

- No minimum coverage percentage is accepted. Review the first valid report before proposing a threshold in a later decision.
- Exact supported runner/Xcode/Swift combinations must be verified against current hosted images when implementation starts.
  Keep deployment-target validation distinct from runtime testing on macOS 13.
- Repository rules must eventually require the stable `CI / Required` check. Document the setup; changing hosted rules needs separate authorization.
