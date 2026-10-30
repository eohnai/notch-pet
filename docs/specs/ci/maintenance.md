# CI maintenance and incremental style checks

Needs: pull-request-checks

## Goal

Keep the [CI area](area.md)'s workflows and action dependencies checkable as the repository grows,
and prevent new Swift style findings while making existing style debt visible. Use the toolchain formatter chosen by the user,
with no repository-wide reformat. Proposed branch: `feat/ci-maintenance`.

## Done when

- The primary selected Swift toolchain runs its bundled swift-format linter over tracked Swift source, tests, and Package.swift.
  The formatter version and lint scope are reported; a missing tool or scan failure fails the check instead of appearing as zero findings.
- A checked-in baseline inventories pre-existing findings and their toolchain/style-policy identity.
  New files are scanned automatically; new findings fail. Existing findings remain visible in a report rather than being globally ignored.
- Baseline comparison tolerates unrelated line-number shifts but distinguishes a new finding from a previously accepted one.
  Removed findings must be pruned so a stale baseline cannot authorize their reintroduction; routine CI never grows or silently regenerates the baseline.
- Intentional toolchain/style-policy upgrades have an explicit baseline review path, showing diagnostic additions/removals.
  A malformed baseline or incompatible policy/version fails with a repair instruction; it does not fall back to suppressing all diagnostics.
- A pinned workflow validator checks all workflow definitions and local composite actions; ShellCheck checks shell scripts and workflow shell blocks.
  Invalid job dependencies, malformed expressions, or invalid shell code fail a mandatory quality job connected to `CI / Required`.
- A workflow policy check rejects unpinned remote action references and permission escalation outside the accepted allowlist.
  Local action references remain valid; validation uses fictional configurations to prove unsafe variants fail and valid pinned configurations pass.
- Dependabot proposes weekly grouped GitHub Actions updates with a bounded number of open pull requests.
  There is no empty Swift/npm dependency audit, invented lockfile, automatic merge, or extra write-token permission in the CI jobs.
- A weekly default-branch run executes the same mandatory CI graph to reveal runner/toolchain drift between source changes.
  Scheduled/manual runs retain read-only permissions and ordinary failure semantics; they do not send chat/email messages or create issues.
- An authorized hosted run validates the real repository definitions and style baseline; documentation explains tool versions, updating pins,
  baseline review, and scheduled failures. Fixture checks demonstrate that malformed configuration/new lint findings fail the gate.

## Out of scope

- SwiftLint, bulk source formatting, global suppression of existing findings, semantic Swift refactors, or changing app behavior to appease a style tool.
- Hosted security-scanning services, credential inspection, PR commenting, issue automation, auto-merge, branch-rule changes, or notifications to others.
- Audits of nonexistent external Swift packages, adding an application dependency to support tooling, or replacing tests with lint success.
- Treating lint, scheduled CI, or an unsigned artifact as release, physical-device, visual, installed-provider, or minimum-OS acceptance.

## Constraints

- Follow the [shared CI boundaries](area.md). The user confirmed swift-format plus an existing-findings baseline on 2026-10-30;
  they subsequently approved the task list and its scoped local verification. Execution still awaits this spec's prerequisite and goal activation.
- Each task changes at most three files including its spec update, adds at most three production functions and at most five test cases.
  Include baseline/config/test files in that budget; split before coding if needed.
- Tool acquisition uses explicit versions and verified provenance/checksums or immutable action SHAs. Never execute an unverified moving install script.
- Keep baseline data limited to source diagnostics/policy metadata; keep generated reports and runtime outputs outside the repository.
- A toolchain-specific formatter baseline belongs to one selected quality lane. Other compatibility lanes still compile and test without imposing conflicting formatter versions.
- Do not add blanket ShellCheck exceptions or silently skip unsupported workflow files. Investigate findings and keep any necessary exception narrow and reviewed.

## Verify

- Seam: the actual selected toolchain formatter and workflow/shell validators scan this repository, then their job result reaches Required.
- Use the bundled formatter's lint command as supported by the pinned primary toolchain; record its exact invocation, version, baseline path,
  and generated report location when implemented. No formatter or baseline file exists merely because this plan names one.
- Check baseline behavior with at most five focused cases: existing finding with shifted lines; new finding/new file; removed then reintroduced finding;
  malformed or incompatible baseline; and missing-tool/scan failure. Exercise failure exit status, not only report text.
- Validate the real workflow/composite definitions with pinned actionlint and shell code with ShellCheck; record exact versions/commands during implementation.
- Check pin/permission policy against valid pinned/local actions, mutable action references, elevated permissions, and malformed configuration;
  the same checker must scan the actual workflow files, not only fixtures.
- Verify Dependabot configuration and default-branch scheduling against the supported GitHub schema, then inspect an authorized hosted run's checks and gate.
  A local check cannot establish that GitHub has ingested the Dependabot config or executed a scheduled run; retain those limits in the evidence.
- `git diff --check`; this planning session performs documentation validation only.

## Decisions

- **Use bundled swift-format with an existing-findings baseline.** The user selected this over separately pinned SwiftLint on 2026-10-30,
  choosing fewer dependencies and mainly style checks. The shared decision is recorded in the [area](area.md#decisions).
- Coverage remains a measured baseline without an accepted percentage floor: see [area open questions](area.md#open-questions).
  Formatter findings and test coverage are separate baselines with separate meanings.

## My calls

- Start from the selected toolchain's default style rather than designing a new repository layout policy during CI setup.
  Tie the diagnostic baseline to that policy and toolchain so upgrades remain reviewable.
- Run actionlint and policy checks in a small Linux quality job; use the primary macOS toolchain for Swift style checks.
- Check remote action pins and least-privilege declarations locally without API credentials or write access.
- Match the reference project's weekly maintenance convention: Monday 00:00 Asia/Singapore for Dependabot,
  with a weekly CI schedule on the default branch. This is an automation cadence, not a project deadline or an inferred owner.
- Group GitHub Actions updates and initially limit outstanding dependency pull requests to three.
  If Swift dependencies appear later, add their supported maintenance workflow when a real dependency inventory exists.

## Tasks

- [ ] MT1: Add bounded swift-format baseline comparison and failure reporting, with at most five focused regression cases for existing/new/removed findings, malformed policy data, and tool failure.
- [ ] MT2: Inventory existing findings with the selected toolchain and wire baseline enforcement into the primary quality checks; verify new-file scanning and rejection of new findings without reformatting source or silently growing the baseline.
- [ ] MT3: Add workflow pin/permission policy validation with at most five focused valid/invalid configuration cases, verifying failure exit statuses without tokens or hosted mutations.
- [ ] MT4: Add pinned actionlint and ShellCheck plus the workflow-policy checker as mandatory quality checks; verify actual definitions and deliberate malformed fixtures cannot bypass Required.
- [ ] MT5: Configure weekly grouped Dependabot updates for GitHub Actions with bounded open pull requests; validate the actual configuration and document intentional pin-update review without enabling auto-merge.
- [ ] MT6: Add weekly default-branch execution of the existing mandatory CI graph with bounded diagnostics; verify scheduled/manual trigger configuration and preserved read-only gate behavior.
- [ ] MT7: Verify an authorized hosted maintenance run and document formatter-baseline review, tool/pin upgrades, and scheduled-failure triage; distinguish configured automation from future runs or update PRs not yet observed.
