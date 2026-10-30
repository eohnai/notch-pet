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
- Preserve all source P0–P8 task lines and checkbox states. BP1–BP4 were approved through the standalone-rabbit goal; the user later approved BP5 implementation with tests deferred. The user approved the BP6a/BP6b split and BP6a implementation with focused tests and a packaged build on 2026-10-30. BP6b and BP7 remain proposed.
- Before each implementation task, confirm a limit of three changed files, three added production functions, and five added test cases.
- Include assets, package configuration, and packaging scripts in that file budget. Split a task before coding if it cannot fit.
- The approved [standalone-rabbit goal](../../goals/standalone-rabbit.md), including its later BP5 extension, permits bounded implementation slices and exempts mandatory goal/log, STATUS and spec checkpoint edits from the three-file limit. It separately authorizes original artwork preparation.
- The separately approved BP6a goal permits two implementation/test files and three added production members, plus mandatory STATUS and spec records. It does not resume the older goal, app launches/captures, or other deferred acceptance.

## Verify

- Seam: the actual bundled app launched with isolated preferences and no configured agents.
- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Real app: `bash scripts/run.sh`, with runtime data and isolated preferences outside the repository.
- Check first launch, size changes, Quit and relaunch, Show Pet, explicit Settings focus, and an ordinary launch without agent services.
- Inspect service ownership and instrument isolated service factories to establish that pet-only startup starts no agent I/O.
- Check single-frame fallback and hidden, asleep, and Reduce Motion behavior with focused checks and one batched actual-app pass.
- Existing physical recovery and five-minute resource measurements remain in source R1–R5 and their later feature owners.
- Run builds, tests, and app checks only during approved implementation. BP6a authorizes the focused command `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --filter PetPlaybackPolicyTests` (five tests, zero failures) and the packaged build above. Actual app checks remain deferred.

## Decisions

- [0013: Use one app with an independent pet module](../../decisions/0013-separate-standalone-pet-scope.md). Accepted on 2026-10-30 for pet-first use and optional session-driven features.
- [0001: Retain SwiftUI and AppKit](../../decisions/0001-use-swiftui-and-appkit.md).
- [0002: Keep shared state and service ownership explicit](../../decisions/0002-use-mvvm-with-services.md).
- [0003: Use preferences and files without a database](../../decisions/0003-store-state-without-a-database.md).
- [0006: Use asset-only packs with optional-animation fallbacks](../../decisions/0006-import-asset-only-pet-packs.md).
- [0011: Preserve original tasks and evidence during migration](../../decisions/0011-organize-records-by-feature.md).
- **BP6 split, approved 2026-10-30:** implement the independent playback policy as BP6a, then separately plan BP6b view/lifecycle/focus wiring. The policy owns no timer or window. Only visible, awake, multi-frame playback with Reduce Motion off may advance; otherwise use the first frame. Invalid elapsed values also return the first frame. The caller owns monotonic elapsed time and scheduling. This approval covers BP6a's five focused tests and packaged build, not actual app acceptance.

## My calls

- Use the existing compact notch location for this first slice. Desktop placement remains in detachable-pet.
- Start with one default pet and a size control. Custom appearance selection arrives with custom-packs.
- Make ordinary behavior an idle pose or supplied idle animation. Roaming, games, and autonomous play are not required here.
- Use a stable fallback pose when optional animations are absent. Do not invent missing art or agent status.
- Pet-only is the first-use default. Later explicit agent setup enables monitoring without a per-session mode switch.
- Keep agent connection entry points with their owning features. Do not add dead setup buttons before those features exist.
- Keep the original integrated P1 task in the source spec until agent-reactions is written. Do not split or reword it here.
- The user chose original white lionhead rabbit artwork on 2026-10-30. Its first idle PNG and manifest are now bundled through the independent pet target.
- Track no deadline or owner because none was supplied.

## Tasks

The user approved BP1–BP4 and a separate original-artwork step through the standalone-rabbit goal on 2026-10-30. The user subsequently approved BP5 implementation with tests deferred, then approved splitting BP6 and implementing BP6a as a bounded goal with focused verification. BP6b and BP7 remain proposals. Written implementation is distinguished from completed verification below.

- [x] BP1: Add standalone idle presentation and missing-animation fallback in an agent-free pet module, with focused behavior checks and required package configuration.
- [ ] BP2: Bundle and render independently supplied default pet artwork through the pet module, checking the packaged resource and visible fallback.
- [ ] BP3: Launch the pet through an app-owned presentation path that starts no agent or usage services, checking isolated startup and preserving the optional integration path.
- [x] BP4: Save and restore pet size with safe defaults, checking missing and invalid preferences without persisting session state.
- [ ] BP5: Add minimal pet setup and settings with a preview and size control, plus menu actions to open settings and reveal the pet without agent setup.
- [x] BP6a: Add an independent playback policy with five focused tests covering normal playback, single-frame artwork, hidden state, sleep and Reduce Motion; verify the packaged build.
- [ ] BP6b: Wire the playback policy into pet rendering and app-owned visibility/sleep lifecycle, stop unnecessary animation, honor Reduce Motion, and check stable visible artwork plus no unsolicited focus. Review the bounded implementation and verification plan before coding.
- [ ] BP7: Verify first launch, setup, settings, size restoration, fallback, and pet-only service isolation in the actual app, recording results and remaining limitations.

Coverage: BP1–BP2 cover module independence, artwork, and fallback. BP3 covers pet-only startup and service isolation.
BP4–BP5 cover setup, preferences, and basic controls. BP6a covers playback policy; BP6b retains animation lifecycle, Reduce Motion, stable visible artwork and focus acceptance.
BP7 checks the complete standalone flow in the real app.

## Planning evidence (before implementation)

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

## Implementation checkpoint, 2026-10-30

BP1–BP4 implementation is written on `feat/pets-built-in-pet`. No new tests or app launches ran during this checkpoint; the user requested skipping tests and focusing on implementation.

- BP1 is verified by the independent Pet target build and three focused presentation tests run earlier in this session. Pet imports no EventBridge or SessionState types.
- BP2 has an original white lionhead rabbit idle PNG, a versioned manifest, resource lookup, SwiftUI rendering and packaged SwiftPM resources. Two artwork tests passed earlier. It remains unchecked because actual visual/fallback acceptance is incomplete.
- BP3 has a nonactivating pet panel, pet-first app delegate, lazy optional-service owner and production service-start instrumentation. Existing session handling remains in optional AgentServices; usage I/O moved out of the view. Three lifecycle tests passed earlier. The isolated app recorded a visible 120-point window, loaded artwork, monitoring disabled and zero starts across event receiver, usage receiver, provider process, configuration probe and agent refresh. Full real-app acceptance remains incomplete, so BP3 stays unchecked.
- BP4 is verified by four earlier preference tests: missing/invalid/nonfinite values use 120 points, writes accept 64–256 points, a new preference instance restores the saved size, and only pet size is persisted. Actual Quit/relaunch size acceptance remains with the deferred app check.
- The full Swift command from the approved goal passed earlier with 116 tests and zero failures (104 existing plus 12 new). Module and packaged-app builds also exited 0. These are historical results from this session, not checks rerun for this checkpoint.
- The six-case app harness did not pass: `python3 scripts/check-standalone-pet.py --app "/private/tmp/notch-pet-first/notch-pet-dev/Notch Pet.app" --artifacts /private/tmp/notch-pet-first/evidence` reached window capture, where `screencapture` exited 1 with `could not create image from window`. The first case's diagnostic snapshot is in `.../evidence/b76eca08a3884cd9a610263ca73ba2ca/missing-preferences/pet.json`; it is not a screenshot or proof of all six cases.
- The earlier build-error report was not reproduced: both unchanged-baseline and changed-source packaged builds passed. No separate build repair was made. The temporary-directory diagnostic guard was fixed after a direct Foundation probe confirmed `/private/tmp` canonicalizes to `/tmp` on this Mac.

The user prefers Flux-like opening, Escape-to-close and limits presentation. Those preferences guide later setup/session interface work. Drag-out/hide and overlap-return stay accepted for detachable-pet; neither is implemented here.

## BP5 implementation, 2026-10-30

The user explicitly approved BP5 setup/settings, preview, size control, menu access and Escape-to-close, with tests deferred. Implementation is written in three bounded slices:

1. PetSettingsView (initializer and body) plus PetSettingsWindow.cancelOperation: two files, three production members. Preview uses the existing PetView; the view forwards actions to its app-owned controller.
2. PetSettingsController.init(defaults:onSizeChange:), show(activate:) and close(): one file, three functions. Size changes persist through PetPreferences and update the live pet. Start/Done sets pet.setupComplete; Escape/window close dismisses without claiming setup completion. First-use show uses activate:false; explicit settings requests activation.
3. PetAppController/NotchPetApp/PetPanelController wiring: three files, two added functions (showSettings and setSize). Added Pet Settings… with Command-comma. Resizing retains the pet's top-center anchor. Agent connection and monitoring configuration remain with their owning features.

The compile-only packaged build exited 0 with valid Info.plist after these changes. No new tests, captures or app launches ran for BP5. Its checkbox remains open until setup, persistence, focus, Escape and menu behavior are verified. The next proposed implementation task is BP6; it is not authorized by this BP5 approval.

## BP6a verification, 2026-10-30

The user approved BP6a as a separate bounded goal after reviewing its task split, API,
five-test plan and packaged-build command. This does not resume the standalone-rabbit goal.

- Added `PetPlaybackPolicy` in `Sources/Pet/PetPresentation.swift`, with three production members: `init(animation:isVisible:isSleeping:reduceMotion:)`, `shouldAnimate`, and `frame(at:)`. Added exactly five tests in `Tests/PetTests/PetPlaybackPolicyTests.swift`; no other production or test files changed.
- The first focused test attempt was blocked by sandbox compiler-cache access. The outside-sandbox retry exited 1 with `cannot find 'PetPlaybackPolicy' in scope`, establishing the expected failure before implementation.
- After implementation, `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build --filter PetPlaybackPolicyTests` exited 0: `Test run with 5 tests in 1 suite passed`. The cases cover frame timing/looping, single-frame playback, hidden state, sleep and Reduce Motion. Normal playback also checks invalid and very large elapsed values.
- `bash scripts/run.sh --build-only` exited 0 with `Info.plist: OK`. The packaged app is at `/var/folders/t3/6n_zw1rn5nn6vv7ccx9r6s240000gn/T/notch-pet-dev/Notch Pet.app`; it was not launched.
- Both successful commands ran outside the sandbox because Swift requires its user compiler cache. The full test suite, app checks and captures were not run.
- BP6a is complete. `PetView` still selects its first frame; the policy is not yet connected to rendering. Actual scheduling, visibility/sleep signals, Reduce Motion updates and focus/visible-artwork acceptance remain open in BP6b and BP7. BP2/BP3/BP5 acceptance states are unchanged.
