# Decisions

Earlier accepted decisions remain in [decisions/](decisions/0013-separate-standalone-pet-scope.md). No records are moved.

## D1: Make low idle energy use a release requirement

- Status: accepted
- Date: 2026-10-30

**Context.** The user wants telemetry and companion features to remain practical on an M2 MacBook Air with 16 GB RAM.
They requested battery-efficient operation after discussing a native UI and a local collector.

**Options.**
- **Event-driven native components with bounded work:** minimize idle activity; require lifecycle coordination and profiling.
- **Frequent polling and continuously updated surfaces:** simpler periodic updates; cause unnecessary work while idle.

**Decision.** Require low idle activity, bounded storage and memory, paused unnecessary rendering, and adaptive provider refresh.
Measure the actual app and any collector or child processes on the target Mac before claiming efficiency.

**Reasoning.** The user explicitly prioritizes battery and resource efficiency for their existing Mac.

**Consequences.** [Resource efficiency](specs/notch/resource-efficiency.md) defines proposed implementation tasks and initial measurement targets.
The user wants collection to continue when the interface closes. Collector installation, persistence, lifecycle, and IPC need a separate reviewed design.
This decision does not install a service, add a database, change the hook contract, or supersede existing storage and pet decisions.

## D2: Collect and inspect telemetry locally with an optional background process

- Status: accepted
- Date: 2026-10-30

**Context.** The user confirmed a telemetry plan separate from battery work, including collection while the interface is closed.
They confirmed local-only history and the next-task, debug-issue, and checkpoint pilots.

**Options.**
- **App-owned collection and file-only state:** one process and simple lifecycle; loses collection when the interface quits and lacks history queries.
- **Optional collector with local SQLite history:** works without the interface and supports queries; adds IPC, lifecycle, migrations, and retention.
- **Hosted telemetry or separate projects:** can support sharing and independent releases; adds infrastructure and coordination outside the confirmed scope.

**Decision.** Use one native app and one optional local collector in the notch-pet repository and release.
Add bounded, deduplicated local SQLite history and instrument the three pilots in agent-skills.
Usage refresh and interactive actions retain their existing owners. Keep the pet independent and require no collector for pet-only use.

**Reasoning.** The user wants useful skill history when the interface is closed, with low battery cost on their M2 Air.
They confirmed this first-release scope instead of hosted ingestion or cross-device synchronization.

**Consequences.** The [telemetry area](specs/telemetry/area.md) defines three feature specs with proposed task lists.
This updates decision 0013's app-owned service boundary for telemetry and decision 0003's no-database scope for history only.
Their independent pet, preferences/assets, and fresh live-evidence requirements remain intact. Earlier implementation evidence is not rewritten.
D1's measured resource requirements apply to every new process. Exact registration, IPC, schemas, and limits receive task-level review.
This accepts scope and storage direction, not implementation tasks, service installation, hook edits, or goal resumption.

## D3: Add view models only where a view owns state

- Status: accepted (its `ObservableObject` line is replaced by D4)
- Date: 2026-10-30

**Context.** Decision 0002 and `ARCHITECTURE.md` describe MVVM, but the code has no view models.
Read-only views observe stores directly. Pure functions such as `NotchPresentation` and `PetPresentation` prepare their state.
`AgentUsageController` and `PetSettingsController` already publish status and handle actions.
The [2026-10-30 review](reports/2026-10-30-session-state-and-architecture-review.md) (M4) raised the mismatch.

**Options.**
- **A view model for every view:** one uniform structure; most would pass store properties through, and cached derived state can become a stale copy of session truth.
- **No view models:** least code now; async action state would move into views or AppKit controllers once Codex setup actions and Settings arrive.
- **View models only where a view owns state:** read-only views stay thin and testable through pure functions; needs a stated rule for when to add one.

**Decision.** Read-only views observe stores directly and use pure presentation functions.
A view gets a view model when it owns state the store does not hold: actions with async results, in-progress flags, drafts, or validation.
Use `ObservableObject`, because `@Observable` needs macOS 14 and the package targets macOS 13.

**Reasoning.** The user accepted this on 2026-10-30. Pure functions already do the view-model job for read-only views and are easier to test.
The views that need action state either already have a controller for it or are still planned.

**Consequences.** This updates the view-model consequence of decision 0002. Services, shared stores, and explicit dependencies remain as accepted.
Codex setup menu actions (I6a), the Settings window, and the reply composer are expected to get view models.
Existing `…Controller` types that act as view models keep their names until a task touches them.
Revisit if read-only views start to duplicate derivation logic, or when the deployment target reaches macOS 14.

## D4: Target macOS 14 so stores and controllers can use `@Observable`

- Status: accepted
- Date: 2026-10-31

**Context.** The package targeted macOS 13, and no record explains why.
D3 kept `ObservableObject` because `@Observable` needs macOS 14.
The R1 review of two external Swift skills found that both assume `@Observable`. `docs/SWIFT-PRACTICES.md` adopts it as the rule.

**Options.**
- **Stay on macOS 13 with `ObservableObject`:** supports one more macOS release, but the practices guide and both skills would describe a model the code cannot use.
- **Raise the target to macOS 14 and move to `@Observable`:** code matches the practices guide; drops macOS 13 users and replaces APIs deprecated in macOS 14.

**Decision.** Target macOS 14 in `Package.swift` and `Info.plist`. Move the five `ObservableObject` classes to `@Observable` in codex-setup R8.
This replaces D3's `ObservableObject` line. The rest of D3 stands.

**Reasoning.** The user chose this on 2026-10-31, so the code can follow the practices guide and the Swift skills it is reviewed against.
The development Mac runs macOS 26, and no record names a macOS 13 user. ^[inferred]

**Consequences.** R7 replaced two `onChange(of:perform:)` calls and `activate(ignoringOtherApps:)` with their macOS 14 forms.
`activate()` asks for focus instead of forcing it. Pet Settings opens from a menu click, so it should still come to the front, but this is unverified in the running app.
R8 can now move the stores and controllers to `@Observable`. Revisit if a supported user needs macOS 13.
