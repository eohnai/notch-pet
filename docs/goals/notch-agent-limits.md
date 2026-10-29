# Notch sessions and provider allowance

Prepared 2026-10-29, not activated. The user cleared the previous menu/setup goal.
This goal follows the accepted notch-first direction and requested Claude Code/Codex limits.
It does not resume I3 setup or claim that its design choices are settled.

```text
GOAL: Make the notch the session interface and show real Claude Code/Codex 5-hour and weekly allowance for agents in use.

ENTRY: Read AGENTS.md, docs/STATUS.md, docs/specs/notch-companion.md, docs/ARCHITECTURE.md, decisions 0002/0003/0007/0008 and docs/notes/usage-source-compatibility.md. Stay on fix/reconcile-local-bridge-checks unless a branch change is approved.

PLAN: (1) N3 native compact/expandable panel; (2) N4 session details and removal of menu session rows; (3) N5 shared selection/priority; (4) U1 usage model/store; (5) U2 Claude forwarding; (6) U3 Codex read-only source; (7) U4/U5 bounded refresh and notch usage; (8) U6 actual-app acceptance/checkpoint. Before each stage, name files/interfaces/tests. Split before exceeding three implementation/record files, three added production functions or five tests. Goal/log are workflow exceptions.

DONE WHEN all hold, with fresh output/evidence printed:
1. `env TMPDIR=/private/tmp/notch-pet-notch-limits DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only` exits 0 with app/helper and valid Info.plist. Create temp root first.
2. `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-notch-limits/notch-pet-dev/build` exits 0: at least 79 tests, zero failures, existing tests enabled. Include five new tests each in NotchPresentationTests, UsageStoreTests, ClaudeUsageProviderTests and CodexUsageProviderTests; parameterize all cases in criteria 3–4. Freeze tests before corresponding implementation; never weaken existing tests or check scripts.
3. Launch via the same build environment and `bash scripts/run.sh`. Print actual-notch evidence for compact/expanded views, both agents, same-folder identities, working/question/approval/response-ready/ended/unknown states, retained unconfirmed notices, stable selection, nonactivating alerts, transparent hit testing and no menu session list. Keep Quit/Show Notch. One batched visual pass plus at most one correction pass; no repeated user screenshot requests.
4. Print actual-app evidence: active-only providers (Codex-only hides Claude, Claude-only hides Codex), both and empty; independently missing windows; used percentages/reset/freshness; stale/failure/reconnect behavior; no per-session duplicate allowance. Show live supported-source quota from each provider in the notch. Fixtures/unavailable labels do not complete live verification.  Claude terminal output/cancellation must be preserved; Codex reads must start no thread/turn. No paid prompts for verification.
5. `git diff --check` exits 0. Tick N3–N5, I1 retirement and U1–U6 only on evidence. Update spec, architecture, STATUS and log; old goal stays incomplete/cleared.

EVERY TURN: run applicable checks; print output and pass/fail/not-run per criterion; append timestamped numbered evidence to docs/goals/notch-agent-limits-log.md. No stale results as fresh.

CONSTRAINTS: Only change Package.swift, Sources/NotchPet/**, Sources/SessionState/**, new Sources/NotchPetUsageHook/**, new related Tests/SessionStateTests/**, docs/ARCHITECTURE.md, docs/specs/notch-companion.md, docs/notes/usage-source-compatibility.md, docs/STATUS.md and this goal/log. No dependencies, commits, pushes, PRs, credentials, transcripts, private endpoints or token estimates. Preserve lifecycle wire/helper deadlines. Quota uses separate data/transport. Real config writes need a reversible plan and explicit approval. Runtime data stays outside Git. No I3, pet, navigation or agent actions. Preserve truthful nonstandard/missing windows; never fabricate 5h/week values or reset-to-zero.

STOP AND REPORT: 30 turns; same failure three consecutive turns; missing access/live source, undecided design, unapproved config write or task split. ON FINISH/STOP: set log Status and Final result, run checkpoint, report proof/gaps and explicit git add/commit commands for user review. Do not mark partial verification complete.
```

## Plan notes

The goal's one user outcome is an actual notch session/allowance interface. It spans the N and U
feature slices already planned in the single specification, rather than setup/removal or the whole app.
Each stage must remain reviewable and within the repository's file/function/test limits. A necessary
split is reviewed before code, not silently converted into an oversized task.

The full-suite floor is the current 59-test baseline plus 20 new tests. New tests cover presentation,
usage classification, Claude forwarding, and Codex snapshots/updates. Add further tests when needed;
the minimum does not replace the behavior checklist. The initial failing run precedes each implementation.

Provider visibility defaults to non-ended observed sessions. Unknown observations remain visibly
uncertain. Multiple anonymous Claude sources are not merged into an asserted account total.
Current-source compatibility is established before implementation; historical version evidence is not
support for every future version. Test bounded transport, malformed/missing windows, source loss,
output preservation, duplicate/sparse updates and account changes using disposable fixtures.

Suggested interfaces, to refine before the corresponding stage:

```swift
@MainActor final class NotchPanelController {
    init(sessionStore: SessionStore) { }
    func show() { }
    func updatePlacement() { }
}
struct NotchSessionView: View { /* observes shared session/presentation state */ }
@MainActor final class UsageStore: ObservableObject {
    func apply(_ observation: UsageObservation) { }
}
protocol UsageProvider { /* bounded observation stream with cancellation */ }
```

Caller example: the app owns one session store and one usage store, injects both into notch content,
and retains its panel controller. Views render snapshots; provider services perform I/O. The usage
connection must not become a second source of lifecycle state. Bounded quota transport stays separate
from the version-1 observer socket protocol. The exact provider-service signatures and transport must
be reviewed at their stage, using verified source capabilities.

Live Claude forwarding may require user-approved configuration setup or an existing source invocation.
Do not silently modify settings to avoid that gate. If live evidence cannot be obtained, stop with
an explicit unmet criterion; a polished fixture-only display is not completion.
