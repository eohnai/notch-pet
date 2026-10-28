# Read-only integration health

Prepared 2026-10-28. The user explicitly authorized starting I2 with I1 verification deferred and all checks paused. Implementation of the I2a/I2b/I2c split is now approved; the verification loop remains paused. The user authorized a separate commit after each implementation task. Leave all verification checkboxes open and do not claim goal completion while required checks are deferred. No new push or pull request is authorized.

```text
GOAL: Complete I2 read-only integration health in three verified tasks, committing each separately on feat/notch-companion.

ENTRY: Read AGENTS.md, docs/STATUS.md, docs/specs/notch-companion.md, decisions 0002/0004/0005/0009, and docs/notes/agent-event-compatibility.md. The user authorized I2 with I1 verification deferred. ALL CHECKS ARE PAUSED: write tests but run no tests, builds, probes, helper injections or UI checks until explicitly renewed. I1 remains unchecked.

PLAN: I2a classification, I2b bounded probes, I2c app wiring preserve I2 acceptance. Each task: at most three implementation/record files, three production functions and five tests. Goal prompt/log are workflow artifacts.
I2a: Sources/SessionState/IntegrationHealth.swift, Tests/SessionStateTests/IntegrationHealthTests.swift, docs/specs/notch-companion.md.
I2b: the same three files.
I2c: Sources/NotchPet/NotchPetApp.swift, docs/specs/notch-companion.md, docs/STATUS.md. No I3+ implementation or new health UI (I6).

DONE WHEN all hold, with output/exit codes printed:
1. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-i2/build --filter IntegrationHealth` exits 0: at least 10 new passing tests, zero failures. Freeze five model and five probe tests before their implementations; demonstrate the initial failing baseline. Cover both providers; independent version/config/helper/receiver/delivery evidence; missing, malformed, oversized, unreadable config; unknown version; missing/nonexecutable helper; receiver start failure/stop; no receipt versus actual receipt; receipt retained independently of session expiry/removal; timeout/oversized process output; unchanged isolated configs. Inactivity never means disconnected, and helper success never proves receipt.
2. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-i2/build` exits 0 with at least 58 tests passing, zero failures; existing tests stay enabled.
3. `env TMPDIR=/private/tmp/notch-pet-i2 DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only` exits 0: app/helper built, valid Info.plist.
4. Print app wiring evidence: actual bridge start/error/stop and validated receipt times feed health independently of SessionStore. No sessions is not failure; configuration is not trust/delivery. Preserve observation payloads, deadlines and state rules.
5. `git diff --check` exits 0. Three I2 subtasks are checked only after relevant checks pass; spec evidence, STATUS and log are accurate English. Print the three separate task commit hashes and scoped paths.

EVERY TURN: while checks are paused, report them as not run; do not execute the commands above. Record source changes and numbered timestamped evidence in docs/goals/integration-health-log.md. After renewed authorization run applicable checks and print output/exit codes. Never claim stale results.

CONSTRAINTS: Only change listed files and goal log. Use bounded read-only probes: 2-second process deadline, 64 KiB output, 256 KiB config; no agent turns. Treat unverified versions/shapes explicitly, using recorded support, not guessed ranges. Read only hook configuration fields; never credentials, auth files, transcripts, unrelated values or command output in diagnostics. No config/hook/trust changes, dependencies, pushes, PRs, unrelated fixes or weakened tests/checks. Keep fixtures/runtime data outside Git. Preserve existing work.

AFTER EACH IMPLEMENTATION TASK: record verification as deferred, leave its checkbox open, stage exact paths plus log and commit under user authorization; print hash. After renewed check authorization, tick tasks only when verified. Preserve unrelated work.

STOP AND REPORT: 30 turns; same failure three consecutive turns; missing access, unsettled design, larger split or scope needed. After implementation use checkpoint and report deferred verification, leaving this goal incomplete. After checks resume, finalize only on evidence. No I3 work.
```

## Why this boundary

The next-task workflow identified I2 after I1 verification. I2 covers independent evidence sources and app lifecycle wiring, so it is too large for the specification's three-file limit as a single implementation task. The approved split retains its original requirements and the single-spec layout. The user's later start instruction approves implementation while deferring verification; preparing the prompt alone had not authorized implementation.

Approved replacement for the open I2 task; checks remain deferred:

- [ ] I2a: Define independent integration-health evidence and classification for both providers; freeze and pass five model tests.
- [ ] I2b: Add bounded read-only version, hook-configuration and helper checks; freeze and pass five isolated probe tests without changing configuration.
- [ ] I2c: Feed actual receiver lifecycle and recorded delivery times into health independently of session state; verify the full suite/build and checkpoint I2 completion.

I2a/I2b checkpoint their completion in the specification and goal log within their three-file implementation/record plans. The goal's final checkpoint updates STATUS.md in I2c. On an early stop, STATUS.md must still be updated to record the interruption; that is a required workflow record, not authorization to expand implementation. The prompt/log are the same workflow-artifact exception used by the earlier G1/G2 goal.

## Interface sketch

These are proposed signatures, not implemented APIs. Keep integration services outside SwiftUI view bodies even though the existing SessionState target hosts the new file. No new package target or dependency is needed.

```swift
// I2a: independent typed evidence, with explicit unavailable/unverified reasons.
public struct IntegrationHealthEvidence: Sendable {
    // Agent identity; observed version and support; hook configuration shape;
    // helper executable availability; receiver state; optional receipt time.
}
public struct IntegrationHealthSnapshot: Sendable {
    // Separate fields, not one aggregate connected/disconnected flag.
}
public enum IntegrationHealth {
    public static func evaluate(_ evidence: IntegrationHealthEvidence)
        -> IntegrationHealthSnapshot { }
}

// I2b: production I/O is bounded; tests use disposable fake executables/configs.
public enum IntegrationHealthProbe {
    public static func inspect(agent: String, executableURL: URL?,
                               configurationURL: URL?, helperURL: URL) async
        -> IntegrationHealthEvidence { }
}
```

Caller sketch:

```swift
let evidence = await IntegrationHealthProbe.inspect(
    agent: "codex", executableURL: codexURL,
    configurationURL: isolatedHooksURL, helperURL: bundledHelperURL)
// App-owned receiver and receipt evidence is merged without inferring it
// from configuration, successful helper writes, or current session snapshots.
let snapshot = IntegrationHealth.evaluate(evidence)
```

The completed types must let the app replace receiver/receipt evidence without rereading configuration or exposing private mutable internals. If the sketch needs a new architectural choice or cannot fit the per-task function/file limits, stop before implementation and present the concrete issue. Do not fold unrelated services into view code merely to fit a file count.

## Frozen checks

Use five parameterized model tests and five parameterized probe tests, named so `--filter IntegrationHealth` discovers all ten. Each row below must be asserted, not just executed:

1. Model: version support and configuration shape remain independent for both agents; an unverified version cannot be promoted by valid JSON.
2. Model: helper availability and receiver lifecycle remain separate; an executable helper does not prove a running receiver.
3. Model: no receipts and an empty session store produce no false disconnection claim.
4. Model: a real recorded delivery is retained separately from session expiry/removal, while its age remains visible and does not prove current activity.
5. Model: configured hooks do not imply trust or end-to-end delivery; receiver errors/stops do not invent agent lifecycle events.
6. Probe: recorded supported versions versus unknown/missing versions; launch failure, timeout and oversized output; no prompts or agent turns.
7. Probe: missing, valid, malformed, unreadable and oversized hook configuration; no command execution from configuration and no unrelated values in results.
8. Probe: missing/nonexecutable/executable helper; availability does not invoke the helper or inject observations.
9. Probe: both recorded provider shapes retain unrelated configuration byte-for-byte, using only isolated fixtures and selected field extraction.
10. Probe: sentinel unrelated secret-like values in fictional configuration/output never appear in health results or diagnostics; error categories are bounded and sanitized.

Freeze the test assertions before each corresponding implementation. Missing production symbols are an acceptable initial compiler failure; print that baseline and do not confuse a compile failure with an executed failing assertion. Add tests for the new behavior; never weaken existing tests or these checks. The full baseline is historically 48 tests; ten new tests require at least 58 passing tests, with no skipped existing cases. Do not rerun the unrelated bridge process script or contract model as an excuse to expand this goal into known follow-ups.

Recorded versions are evidence, not a claim that every installed version is supported. Read the compatibility record before deciding which version/shape pairs can be reported as supported. For other combinations report unverified with a reason. Routine results may contain only version, bounded health categories, receiver state and receipt time; never raw process output, hook commands, prompts or credentials.

## Commit boundaries

Use explicit paths, never `git add -A` or a blanket stash/reset. The I1 source, records, and prepared goal were committed by the user as `69b7c11` (`wip`); the subsequent push reported `Everything up-to-date`. I1 remains unchecked because its running-menu verification was interrupted. Its committed implementation is the starting baseline, not I2 work. The user explicitly deferred that verification to start I2 with checks still paused. If unrelated changes overlap an I2 path, stop and identify them before staging. The earlier push instruction applied to that saved snapshot; this goal does not automatically push later commits.

- I2a: `feat: model independent integration health evidence`
- I2b: `feat: add bounded read-only integration health probes`
- I2c: `feat: connect integration health to app lifecycle`

Include the goal log with each task commit and print the resulting hash and paths. If execution stops with an unverified task, retain its work uncommitted and report it. No automatic advance into setup/removal or another goal is authorized.

