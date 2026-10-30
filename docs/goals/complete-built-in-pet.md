# Complete built-in pet

Status: implementation complete under the user's revised scope; full feature acceptance remains incomplete.
Scope: pets/built-in-pet only. The conversation goal was created once after approval.

## User override after activation

On 2026-10-30, after the permission probe and capture failure, the user said: "don't screen record, just skip this part of testing and go ahead with the rest of the implementation". This supersedes the original block's capture/visual-inspection requirements and missing-screen-access stop. Continue other implementation and native checks without recording/capturing the screen. Add an explicit skip-capture mode to the existing harness; report skipped visual checks as skipped, not passed. Do not request Screen Recording again. Full visual acceptance remains unverified. All other constraints and checks remain in force.

The user then instructed: "no need to test, just implement". This later instruction narrows the remaining deliverable to production implementation and its checkpoint, and supersedes the block's remaining verification/acceptance work for this run. No new tests, builds, app launches or diagnostics are to run. The already-started no-capture harness finished normally; its five nonvisual checks passed and its visual check was explicitly skipped. Do not create the proposed twelve-group harness or test-only production instrumentation merely to complete the original test plan. BP6b2 completes the remaining production task; BP2/BP3/BP5/BP6b3/BP7 acceptance stays open. Close only the revised implementation goal, not the feature's acceptance or the spec.

## Goal block

```text
GOAL: Complete pets/built-in-pet: BP2/BP3/BP5 acceptance, BP6b2 lifecycle, BP6b3 playback/focus, BP7 flow and all ten Done-when items.

ENTRY: Read AGENTS.md, docs/STATUS.md, docs/specs/pets/{area,built-in-pet}.md and decisions 0001/0002/0003/0006/0013. Stay on feat/pets-built-in-pet. Activation approves this task list, deferred tests/app launches/captures and the exceptions below. Leave older goals untouched.

TASKS: (1) Add shared app-owned window playback state/wrapper; wire pet panel. (2) Wire settings preview. (3) Extend native harnesses/opt-in production diagnostics. (4) Diagnose capture failure; verify BP2/BP3/BP5/BP7. (5) Verify BP6b3 on packaged renderer with temporary multi-frame fixtures. (6) Audit Done-when items; checkpoint.
Before slices print files, APIs/caller and checks. Limit each to 3 code/test/asset/script files, 3 added production members and 5 new tests; goal/log/STATUS/spec records exempt. Activation permits bounded slices without reapproval; new design/scope choices need approval. Prefer shared wrapper over duplicated observers.

DONE WHEN fresh evidence proves ALL:
1. With DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer, run `swift build --target Pet --scratch-path /private/tmp/notch-pet-dev/build` and `swift test --scratch-path /private/tmp/notch-pet-dev/build`: exits 0, zero failures, all existing tests enabled; Pet has no EventBridge/SessionState imports/dependencies.
2. `bash scripts/run.sh --build-only` exits 0, Info.plist OK, app/helper/rabbit resources bundled. Set APP to the printed bundle path and OUT to a unique /private/tmp evidence directory.
3. `python3 scripts/check-standalone-pet.py --app "$APP" --artifacts "$OUT/standalone"` exits 0, 6/6, captures inspected.
4. Add/freeze `python3 scripts/check-built-in-pet.py --app "$APP" --artifacts "$OUT/feature"`: exits 0, 12/12 native case groups: first-use rabbit preview/size; Start reaches ordinary pet with no agent panels/warnings; slider resizes/persists; default/invalid/saved sizes survive Quit/relaunch; Show Pet preserves focus; explicit Settings focuses; Escape/close dismisses without false setup completion and reopens; menu Quit terminates; hidden panel stops playback/resumes; hidden preview stops/resumes; sleep/wake delivery stops/resumes both; Reduce Motion and single-frame/missing-animation/missing-resource fallbacks retain stable visible artwork. Show actual scheduling/frame evidence on the production renderer; model tests alone fail acceptance. Label injected lifecycle/environment signals; never claim physical sleep acceptance from injection.
5. Diagnostics show zero event/usage receiver, provider process, config probe and agent-refresh starts throughout pet-only flows. Inspect rabbit/preview captures. Never bypass capture or substitute a demo.
6. `git diff --check` exits 0; all built-in-pet task boxes checked only against evidence; Results map all ten Done-when requirements to artifacts; mark spec done only after all pass.

EVERY TURN: print applicable fresh check output and pass/fail/not-run; append a numbered timestamped row to docs/goals/complete-built-in-pet-log.md. Rerun checks for relevant changes/unresolved failures.

CONSTRAINTS: Only change Pet/app sources, their tests, Package.swift, scripts/run.sh, the two named harnesses and feature/goal/STATUS records. Freeze case requirements before implementation; never weaken/skip checks. Preserve optional services and all hook/config files; no credentials, new dependencies/artwork, commits, pushes or PRs. Runtime data/fixtures/captures stay outside Git. No reactions, detachment, imports, telemetry, allowances or unrelated repairs.

STOP: 30 turns; same failure 3 consecutive turns; missing GUI/access; unrelated baseline failure; new design/scope choice. Partial work is incomplete. ON FINISH/STOP: fill log status/result, use checkpoint, report proof/gaps and git add/commit commands; draft closure/PR text only on full success.
```

## Approval and execution

This replaces the single-task next-task workflow only after activation. It does not resume the old standalone-rabbit or notch/allowance goals. Prior evidence remains historical until rerun against the final code.

Activation approves the six tasks above, this feature's deferred verification and bounded implementation sub-slices. Keep three implementation/test/asset/script files, three added production members and five new tests per slice; mandatory records are exempt. Print each slice's plan before code, and split internally within that limit. No further approval is needed for routine fixes inside the accepted behavior. New scope, design choices or environment permissions still require their applicable approvals.

The user approved the recommended shared wrapper rather than duplicate observers; the decision is recorded in the feature spec.

## Ordered task map

1. **BP6b2 panel lifecycle:** new Sources/NotchPet/PetWindowPlayback.swift, existing PetPanelController.swift, new Tests/NotchPetTests/PetWindowPlaybackTests.swift. Add app-owned notification subscriptions and observable playback inputs. Filter window notifications to the bound window, handle occlusion/miniaturization/close and workspace sleep/wake, and release subscriptions with the owner. Use a weak window reference and avoid subscription retain cycles.
2. **BP6b2 settings lifecycle:** PetSettingsController.swift, PetSettingsView.swift and the lifecycle test file if needed. Wrap the real settings root and forward visibility/sleep to its PetView. Preserve slider state and persisted size across lifecycle changes. Close/Escape must stop preview work; reopen must restore it.
3. **Acceptance preparation:** extend scripts/check-standalone-pet.py where required; add scripts/check-built-in-pet.py and production opt-in diagnostics in separate bounded slices. Freeze the assertions below before changing the related behavior. Diagnostics must observe the actual panel/settings/PetView, remain off in normal operation, and never enable agent services. Reuse the existing temporary-directory guard for evidence. Any diagnostic fixture must use the same production rendering path.
4. **BP2/BP3/BP5/BP7 native acceptance:** use debug-issue for the known capture failure before proposing its fix. Establish the cause; do not silently drop captures or declare instrumentation a visual check. Exercise setup, Start, slider, settings, Escape, Show Pet and menu Quit through actual native controls where available. Isolate preferences, agent configuration and test processes; never terminate the user's existing instance.
5. **BP6b3 playback acceptance:** mount the production renderer in the actual packaged app with temporary multi-frame inputs. Observe real frame selections/scheduling and cancellation/resumption for each surface. The normal rabbit is single-frame, so its stable output alone cannot prove scheduling. Use explicitly labelled injected sleep/wake notifications or Reduce Motion environment values if needed; distinguish these from physical machine sleep or OS-setting delivery. Never change the user's global accessibility preferences just for the check.
6. **Completion audit:** run the Pet build, full Swift suite, package build, both native harnesses and diff check on the final relevant code. Map all ten Done-when requirements to evidence in the spec Results. Tick only proven tasks. Follow next-task finishing guidance to mark the spec done and draft PR text in chat, without committing or opening a PR.

## First-slice API sketch

Bodies are intentionally omitted; signatures are proposed, not implemented.

```swift
@MainActor
final class PetWindowPlaybackState: ObservableObject {
    @Published private(set) var isVisible = false
    @Published private(set) var isSleeping = false

    init(
        window: NSWindow,
        windowNotifications: NotificationCenter = .default,
        workspaceNotifications: NotificationCenter =
            NSWorkspace.shared.notificationCenter,
        readVisibility: @escaping (NSWindow) -> Bool
    ) {}
}

struct PetWindowPlayback<Content: View>: View {
    init(
        window: NSWindow,
        @ViewBuilder content: @escaping (Bool, Bool) -> Content
    ) {}

    var body: some View { /* observe state and render content */ }
}
```

Caller:

```swift
PetWindowPlayback(window: panel) { visible, sleeping in
    PetView(presentation: presentation,
            isVisible: visible, isSleeping: sleeping)
}
```

The wrapper supplies the production visibility reader. The internal state initializer permits injected notification centers and visibility sampling for isolated tests. Count the two initializers and wrapper body as the three added production members. If safe notification ownership requires additional members, split before coding rather than compressing unrelated work into closures to evade the limit.

Up to five first-slice tests cover initial visibility, hidden/visible/occluded transitions, sleep/wake, unrelated-window filtering and subscription cleanup. Capture failing results before production implementation. They establish the notification/state seam, not native scheduling acceptance.

## Frozen native acceptance groups

The existing six-case harness must still pass, and its captures require inspection. Its current seeded-preference relaunch check does not establish slider behavior.

The new harness must report all twelve groups individually; every subcondition in a group must pass. A JSON summary includes bundle path, PID/window identity, isolated preference suite, artifact paths and per-group assertions; the same information is printed as concise pass/fail output. Permission failures or unobservable controls are failures/blocked evidence, never skipped passes.

1. **First use:** missing preferences show a visible rabbit, usable size and setup preview/size control; no agent setup is required.
2. **Start:** clicking Start persists setup completion and reveals ordinary pet behavior without empty session/quota panels or setup warnings.
3. **Resize:** the native slider changes live pet size, retains the top-center anchor and writes a valid size. Lifecycle input changes must not reset the slider.
4. **Preferences/relaunch:** normal Quit and a new process restore the slider-selected size and completion state; separate missing/invalid-size cases show the usable default.
5. **Show Pet:** the actual menu action reveals the real pet; frontmost application and key-window evidence show no unsolicited focus.
6. **Explicit Settings:** the native menu action opens settings and permits key focus.
7. **Dismiss/reopen:** Escape and window close dismiss the settings preview, do not falsely finish first use, and permit reopening.
8. **Quit:** the menu action terminates the test instance normally and leaves no test-owned renderer work/processes.
9. **Pet visibility:** temporary multi-frame inputs show advancing frame/scheduler evidence when visible; hiding/occlusion cancels work; showing resumes. Include a sufficiently long settled hidden observation interval to rule out a remaining periodic loop.
10. **Preview visibility:** perform the same advance/stop/resume observations on the actual settings preview, including closure while the host controller remains alive.
11. **Sleep/wake:** delivery through the production workspace notification subscriptions stops both surfaces and wake resumes only visible surfaces. Label injected events. This establishes native notification handling, not physical system sleep/recovery.
12. **Motion/fallback:** Reduce Motion yields a stable visible pose and no periodic playback; disabling it resumes eligible multi-frame playback. Single-frame art remains visible without scheduling; missing optional animations use idle, missing requested-frame resources use the idle asset, and a wholly unavailable asset uses the visible unavailable-artwork fallback.

Record zero production starts in all five prohibited service categories throughout these groups. The absence of an observed session or child process is not sufficient proof. Preserve the existing explicit optional-service path and its tests.

No shared physical recovery/resource-profile requirement is claimed by these cases; those remain with their owning specs. Captures must be limited to test-owned windows. If access is unavailable, stop and report the unmet criterion with its command/error.

## Scope boundaries

Allowed paths are Package.swift; Sources/Pet/**; Sources/NotchPet/**; Tests/PetTests/**; Tests/NotchPetTests/**; scripts/run.sh; scripts/check-standalone-pet.py; scripts/check-built-in-pet.py; docs/specs/pets/built-in-pet.md; docs/STATUS.md; and this goal/log. Existing source P0-P8 task text and checkbox states are preserved.

Do not change existing unrelated tests or repair unrelated baseline failures to obtain a green full suite. A meaningful harness extension or correction may strengthen detection but may not weaken the frozen requirements. No new dependencies, original artwork generation, global OS-setting changes, source configuration edits, commits, pushes or PR creation are authorized.

## Preparation evidence

Read the current feature spec, status, accepted architecture decisions already inspected in this session, the existing native harness, renderer/callers and build script. BP6b1 is committed as ada1984 and the working tree was clean before preparation. The six-case harness lacks setup/slider/menu and animation acceptance. No implementation, build, Swift test, app launch, capture or deferred-goal resumption occurred during preparation.

## Git authorization after implementation handoff

The user subsequently requested a checkpoint and explicitly instructed "commit and push for me". This supersedes the original goal's no-commit/no-push restriction for saving these feature changes and records on `feat/pets-built-in-pet`. Exclude the unrelated `.vscode/launch.json`. The instruction does not resume tests, captures, older goals or unfinished acceptance, and does not authorize a PR.

