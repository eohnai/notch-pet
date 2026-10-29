# Verify the session menu and add safe Codex setup

Historical goal: cleared by the user on 2026-10-29. Incomplete, not active. Superseded in priority by the notch-and-allowance plan; do not restart its old menu acceptance loop.

Activated by the user on 2026-10-28. The combined task list and its checks are authorized.
The separate ownership file is accepted. I3's recovery/concurrency design, schema, settings,
interfaces and implementation splits still require the goal's separate review before coding.
This goal never authorizes commits or pushes.

Run status: resumed on 2026-10-29. Guided screenshots verify part of I1. Remaining UI cases
and the explicit I3 design approval gate remain open. See the goal log.

```text
GOAL: Verify I1's existing session menu and implement I3b–I3c Codex setup services with a separate ownership file.

ENTRY: Read AGENTS.md, docs/STATUS.md, docs/specs/notch-companion.md, docs/contracts/codex-hook-setup.md, and decisions 0004/0005/0009. Require task-list and check approval before starting. Stay on fix/reconcile-local-bridge-checks unless a branch change is approved. Before I3 coding, obtain approval of schema, recovery/concurrency design, verified timeout/enablement syntax, interfaces and task splits.

DONE WHEN all hold, with current output and exit codes printed:
1. `env TMPDIR=/private/tmp/notch-pet-codex-setup DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only` exits 0; app/helper built and Info.plist valid.
2. Launch using the same environment and `bash scripts/run.sh`. Through the bundled helper send fictional events only. Print an evidence table with all 10 I1 cases passing: both providers; same-folder sessions distinct; idle/working; question/approval; response ready; ended; unknown with retained unconfirmed request; evidence time; long paths/session IDs; empty state after restart. Cite fresh visible-menu observations, never store tests alone. Keep harness/captures in /private/tmp/notch-pet-codex-setup.
3. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-codex-setup/notch-pet-dev/build --filter CodexHookSetupPlannerTests` exits 0: five new tests, zero failures. Assert seven entries, repeat byte identity, preservation/order, ownership conflicts, and version/shape/resource gates; include duplicate keys and numeric preservation.
4. Same Swift command with `--filter CodexHookInstallerTests` exits 0: at least five new tests, zero failures. Assert safe paths/permissions/helper checks; stale-plan and concurrent-writer handling; missing/changed/duplicate ownership conflicts; every approved interruption/recovery state; unchanged isolated config on rejection. No installed config access.
5. Same Swift command without `--filter` exits 0: at least 68 tests, zero failures, existing cases enabled. Incidental I2 test execution does not complete I2's separate wiring acceptance.
6. `git diff --check` exits 0. Print I1/I3b/I3c acceptance evidence; tick only verified tasks. Update spec, STATUS and log. No claim of installed hooks, trust, live-provider delivery, removal UI or I6 completion.

EVERY TURN: run applicable checks, print output and pass/fail/not-run for all criteria, and append a numbered timestamped row to docs/goals/codex-setup-log.md. Continue existing numbering. Never run checks still awaiting approval or present old results as current.

CONSTRAINTS: Only change Sources/SessionState/CodexHookSetup.swift, Sources/SessionState/CodexHookInstaller.swift, corresponding new Tests/SessionStateTests/CodexHookSetupTests.swift and CodexHookInstallerTests.swift, docs/contracts/codex-hook-setup.md, docs/specs/notch-companion.md, docs/STATUS.md and these two goal files. Per task: at most three implementation/record files, three added production functions and five new tests; split before exceeding limits. Goal/log are workflow artifacts. Freeze new tests before implementation; never weaken tests/checks. Pure planner has no I/O. Installer only touches explicit disposable paths; preserve unrelated values/order and hook trust. Ownership/journal retain app-created entries and bounded identity metadata only. No credentials, auth files, real config writes, startup installation, new dependencies, commits, pushes, PRs, I4+ work or observation-contract changes.

STOP AND REPORT: 30 turns; same failure three consecutive turns; missing access, ambiguous design, unapproved split/scope or unsafe preservation. ON FINISH OR STOP: set log Status to done/stopped/blocked and Final result; use checkpoint; report proof and gaps and give explicit git add/git commit commands for user review. Never mark deferred verification complete.
```

## Proposed task plan

1. **I1 verification:** build, run the existing Swift suite, then inspect the rebuilt native menu using fictional helper events. Change only the specification and STATUS for evidence. UI fixes need a separate approved plan.
2. **I3b design gate:** review the ownership schema and recovery protocol below. Confirm supported Codex timeout and feature-enablement syntax from authoritative version-specific evidence before coding. Do not infer installation support from I2's configuration counts. This review may require smaller tasks.
3. **I3b planner:** add `Sources/SessionState/CodexHookSetup.swift`, `Tests/SessionStateTests/CodexHookSetupTests.swift`, and specification evidence. Freeze five parameterized tests before implementation. Use explicit input bytes, version/enablement evidence, helper path, installation ID and ownership evidence. Return a candidate, unchanged result, or bounded failure.
4. **I3c installer:** add `Sources/SessionState/CodexHookInstaller.swift`, `Tests/SessionStateTests/CodexHookInstallerTests.swift`, and specification evidence. Freeze five parameterized tests. Test file operations and interruption states using disposable directories. If this cannot fit the function/test limits, present a split before starting.
5. **Final verification/checkpoint:** run all applicable criteria and update records. No production configuration installation or automatic commits.

The scope restriction is deliberate: I3 supplies services. I5 owns removal, and I6 owns UI and live setup/delivery acceptance.
The full suite necessarily runs I2 tests, but this goal does not authorize installed-provider health probes or mark I2 complete.

## Proposed interfaces for review

These sketches are documentation, not implementation. Field names and result cases must be finalized before tests are frozen.

```swift
// Codable ownership record: schema version, installation ID, target identity,
// helper identity, and exact app-created groups/handlers. No user config copy.
public struct CodexHookOwnership: Codable, Sendable { /* fields */ }
public struct CodexHookPlanInput: Sendable { /* explicit immutable evidence */ }
public enum CodexHookPlan: Sendable { /* update, unchanged, unavailable, conflict */ }
public enum CodexHookSetupPlanner {
    public static func plan(_ input: CodexHookPlanInput) -> CodexHookPlan { }
}

// Installer revalidates fresh bounded input. It does not trust an old plan.
public struct CodexHookInstallRequest: Sendable { /* explicit target/record/helper URLs */ }
public enum CodexHookInstallResult: Sendable { /* installed, unchanged, unavailable, conflict */ }
public enum CodexHookInstaller {
    public static func install(_ request: CodexHookInstallRequest) -> CodexHookInstallResult { }
}
```

Caller example, using only disposable paths:

```swift
let plan = CodexHookSetupPlanner.plan(fixtureInput)
// Review the plan. Installation rereads and validates current files.
let result = CodexHookInstaller.install(disposableRequest)
// Report configuration outcome separately from trust and observed delivery.
```

## Recovery proposal requiring approval

Keep a durable pending journal with exact app-created entries and bounded target identities/digests.
Prepare and validate the candidate before writes. Persist pending intent before replacing hook bytes,
then persist ownership completion. Clear pending intent only after a durable completed state.
Do not retain a whole copy of unrelated configuration in the journal.

Classify restart states as no installation, completed installation, or uncertain partial installation.
Any ambiguity stops with recovery instructions. Never adopt lookalike hooks, duplicate installation,
overwrite a changed file, or restore an old whole-file backup.

Before approval, enumerate each write boundary, the exact recovery action, safe-path rules, file permissions,
locking and durability operations, and limits with noncooperating external writers.
A comparison followed by rename is not proof of an atomic compare-and-swap.
If safe guarantees cannot be established within the task limits, split or stop rather than weakening preservation.

## Frozen verification coverage

Planner's five tests may parameterize cases but must assert all named requirements:

1. Missing configuration produces exactly seven separate managed event entries with correctly quoted helper invocation and approved timeout.
2. Unchanged ownership plus matching managed entries yields byte-identical reinstall. No existing lookalike is adopted.
3. Otty/unrelated values and handler order survive edits, including numeric values and reordered unrelated groups.
4. Missing, copied, duplicated or edited owned entries and malformed ownership yield a bounded conflict without a candidate write.
5. Missing/unverified version or enablement evidence, malformed/duplicate-key/oversized JSON, unknown unsafe shapes and oversized output are rejected.

Installer's five tests must cover the five groups in criterion 4, including every approved recovery state.
If five tests or three functions cannot cover this safely, obtain approval for a split before implementation.
Never edit an existing check to make this goal pass. Unrelated bridge/reference-model fixes remain separate.
