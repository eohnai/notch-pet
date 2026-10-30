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

- Status: superseded by D3
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

## D3: Record skill history before extracting live monitoring

- Status: accepted
- Date: 2026-10-30

**Context.** The user requested a revision after reviewing the collector-first plan.
Skill records must survive interface closure. That requires durable local writes, not a running collector.
Live monitoring with the interface closed remains a separate later requirement.

**Options.**
- **Collector-first ingestion:** centralizes live state and history, but delays the first skill measurement behind service and IPC work.
- **Direct SQLite writes from every producer:** avoids import, but makes short-lived hooks contend on the database.
- **Ready files and later SQLite import:** records with the app closed and keeps hooks short, but requires atomic publication and commit-before-removal import.

**Decision.** Start with immutable run_start, run_end, and check files, then import them into local SQLite.
Verify real hook signals and pilot debug-issue first. Follow with a minimal history view, then next-task and checkpoint.
Keep the optional live collector last, in the same repository/release. Pet rendering, usage refresh, and actions retain their existing boundaries.

**Reasoning.** The user asked to apply the reviewed simpler order and concrete record rules before building background infrastructure.

**Consequences.** [Telemetry specs](specs/telemetry/area.md) now separate those five results.
The emitter owns skill-folder version hashing. Starts distinguish attempts from confirmed loads, and end reports stay separate from executed checks.
Project labels remain readable locally. No hosted service, sync, transcript bodies, or credentials are introduced.
The pilot proposes normal emitter permission prompts. Any allowlist change needs its own review.
D1's measured battery requirements remain in force. Task lists are proposals, not implementation or setup approval.
