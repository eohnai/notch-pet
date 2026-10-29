# Built-in pet

## Goal

Let someone launch and set up a pet without coding agents, terminal software, or hook configuration.
Ship the standalone pet in the existing native app through an independent pet module.
See the [pets area](area.md) for later detachment, custom artwork, and agent reactions.

## Done when

- The actual app shows independently supplied default artwork with no agent installed or configured.
- First-use pet setup previews the default pet and lets the user choose its size without connecting an agent.
- Completing pet setup reveals ordinary pet behavior without agent setup warnings or empty session and quota panels.
- Pet-only startup starts no event receiver, usage receiver, provider process, configuration probe, or agent refresh loop.
- The pet module imports no `SessionState` or `EventBridge` types. It builds and its behavior checks run independently of agent services.
- Size survives Quit and relaunch. Missing or invalid preferences use a usable default.
- A single idle frame works. Missing optional animations retain a visible pose.
- Hidden or sleeping surfaces stop unnecessary animation. Reduce Motion uses a stable visible pose.
- Showing the pet does not take keyboard focus. Settings can take focus when explicitly opened.
- Basic menu controls open pet settings, reveal the pet, and quit the app without requiring an agent connection.

## Out of scope

- Session detection, agent reactions, request cards, allowance display, navigation, and provider actions.
- Connect, Pause monitoring, and Disconnect implementation. The owning session setup and first-use features provide those controls later.
- A second app, background service, repository split, or new installation format.
- Desktop drag-out, notch overlap return, placement persistence, and full display or Spaces recovery.
- Custom pack import, artwork selection across packs, sprite-sheet conversion, sound controls, or new pet artwork generation.
- Completing shared physical-desktop acceptance or resource profiling through model tests alone.

## Constraints

- Follow [decision 0013](../../decisions/0013-separate-standalone-pet-scope.md) and retain SwiftUI/AppKit.
- Keep the pet independent from agent models. A later adapter supplies agent-driven presentation.
- The app owns lifecycle and optional services. A SwiftUI pet view does not start monitoring or usage I/O.
- Never infer that no agent process exists from an empty observed-session list.
- Preserve existing hook configuration. Completing or skipping pet setup does not install, remove, or rewrite hooks.
- Use the accepted [asset-only format](../../decisions/0006-import-asset-only-pet-packs.md) and independently supplied artwork.
- Do not copy Flux artwork or execute pet-pack scripts. Keep imported packs and runtime files outside the repository.
- Keep preferences in UserDefaults. No database or persisted live session state is added.
- Preserve all source P0–P8 task lines and checkbox states. The tasks below are new proposals awaiting approval.
- Before each implementation task, confirm a limit of three changed files, three added production functions, and five added test cases.
- Include assets, package configuration, and packaging scripts in that file budget. Split a task before coding if it cannot fit.

## Verify

- Seam: the actual bundled app launched with isolated preferences and no configured agents.
- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Real app: `bash scripts/run.sh`, with runtime data and isolated preferences outside the repository.
- Check first launch, size changes, Quit and relaunch, Show Pet, explicit Settings focus, and an ordinary launch without agent services.
- Inspect service ownership and instrument isolated service factories to establish that pet-only startup starts no agent I/O.
- Check single-frame fallback and hidden, asleep, and Reduce Motion behavior with focused checks and one batched actual-app pass.
- Existing physical recovery and five-minute resource measurements remain in source R1–R5 and their later feature owners.
- Run builds, tests, and app checks only during approved implementation. This planning session runs documentation checks only.

## Decisions

- [0013: Use one app with an independent pet module](../../decisions/0013-separate-standalone-pet-scope.md). Accepted on 2026-10-30 for pet-first use and optional session-driven features.
- [0001: Retain SwiftUI and AppKit](../../decisions/0001-use-swiftui-and-appkit.md).
- [0002: Keep shared state and service ownership explicit](../../decisions/0002-use-mvvm-with-services.md).
- [0003: Use preferences and files without a database](../../decisions/0003-store-state-without-a-database.md).
- [0006: Use asset-only packs with optional-animation fallbacks](../../decisions/0006-import-asset-only-pet-packs.md).
- [0011: Preserve original tasks and evidence during migration](../../decisions/0011-organize-records-by-feature.md).

## My calls

- Use the existing compact notch location for this first slice. Desktop placement remains in detachable-pet.
- Start with one default pet and a size control. Custom appearance selection arrives with custom-packs.
- Make ordinary behavior an idle pose or supplied idle animation. Roaming, games, and autonomous play are not required here.
- Use a stable fallback pose when optional animations are absent. Do not invent missing art or agent status.
- Pet-only is the first-use default. Later explicit agent setup enables monitoring without a per-session mode switch.
- Keep agent connection entry points with their owning features. Do not add dead setup buttons before those features exist.
- Keep the original integrated P1 task in the source spec until agent-reactions is written. Do not split or reword it here.
- Resolve the default artwork source before implementation. No pet artwork is bundled in the current repository.
- Track no deadline or owner because none was supplied.

## Tasks

These seven tasks are proposals. Approval of the direction does not authorize implementation.

- [ ] BP1: Add standalone idle presentation and missing-animation fallback in an agent-free pet module, with focused behavior checks and required package configuration.
- [ ] BP2: Bundle and render independently supplied default pet artwork through the pet module, checking the packaged resource and visible fallback.
- [ ] BP3: Launch the pet through an app-owned presentation path that starts no agent or usage services, checking isolated startup and preserving the optional integration path. (blocked: reported app build failure needs a separate fix)
- [ ] BP4: Save and restore pet size with safe defaults, checking missing and invalid preferences without persisting session state.
- [ ] BP5: Add minimal pet setup and settings with a preview and size control, plus menu actions to open settings and reveal the pet without agent setup.
- [ ] BP6: Pause unnecessary animation while hidden or asleep and honor Reduce Motion, checking that the pet remains visible and does not take unsolicited focus.
- [ ] BP7: Verify first launch, setup, settings, size restoration, fallback, and pet-only service isolation in the actual app, recording results and remaining limitations.

Coverage: BP1–BP2 cover module independence, artwork, and fallback. BP3 covers pet-only startup and service isolation.
BP4–BP5 cover setup, preferences, and basic controls. BP6 covers animation lifecycle, Reduce Motion, and focus.
BP7 checks the complete standalone flow in the real app.

## Planning evidence

The user approved pet-first setup, optional one-time agent connection, automatic session-driven features, and one app with an independent pet module.
They also approved separate built-in-pet and agent-reactions specs, with only this first spec written now.

Static inspection found no pet target or pet artwork in `Package.swift` or `Resources/`.
The current app starts the event bridge and notch panel during launch.
The notch controller starts the usage receiver, and current session presentation depends on `SessionState`.
These are implementation constraints, not evidence that standalone behavior exists.

Source P0 records the packaging discussion. Its direction is now accepted in decision 0013.
P0 stays unchecked pending final planning review. P1 remains unchecked and belongs to the future agent-reactions spec.
P2–P8 and shared R1–R5 requirements remain with their existing source lines and later feature owners.
No historical evidence is moved or rewritten by this plan.

Known prerequisite: the current app has a reported `ambiguous use of 'sync(execute:)'` build error in `NotchPanelController.swift`.
It was not reproduced or fixed here. Resolve that separate blocker before requiring an app build for these tasks.
No build, runtime check, Swift test, configuration access, or paused-goal work ran in this planning session.
