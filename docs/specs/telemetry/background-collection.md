# Background collection

## Goal

Continue agent observation while the notch/pet interface is closed, then reconnect the app to current session evidence.
The [telemetry area](area.md) owns this extraction; session semantics and the independent pet remain unchanged.
Proposed branch: `feat/telemetry-background-collection`.

## Done when

- Explicitly enabled collection survives interface closure and receives an actual helper event while the interface is absent.
- Reopening the app displays the collector's current snapshot without starting a second listener or a second session authority.
- A closed UI client cannot block hook delivery or grow an unbounded subscription queue.
- A reconnect obtains a complete snapshot with a collector epoch and revision boundary; gaps invalidate cached presentation until resynchronized.
- Restarting the collector starts with unknown live state until fresh evidence arrives. Earlier history cannot establish working state.
- Duplicate launches, stale sockets, incompatible protocol versions, and interrupted upgrades produce a bounded failure or explicit unavailable state.
- Pet-only launch does not register, enable, or start collection. Previously enabled monitoring is managed independently.
- Explicit controls distinguish Quit Interface, Pause Monitoring, Resume Monitoring, Quit All, and Disconnect.
- Quit Interface leaves enabled collection running. Pause stops new observation/telemetry intake and invalidates live freshness without resolving requests.
- Resume requires fresh evidence. Quit All stops both components and prevents immediate automatic relaunch until an explicit resume/start.
- Disconnect removes only app-owned integration and service registration. It preserves unrelated settings; retained history has a separate deletion action.
- Idle collection waits for events and meets the reviewed resource budget on the actual M2 Air.

## Out of scope

- Persistence, history queries, skill instrumentation, remote upload, and cross-device synchronization.
- Moving usage refresh or interactive approvals/replies into the collector.
- New provider hook coverage, transcript parsing, and automatic hook installation during development.
- Treating process separation as proof that reliability or energy acceptance passed.

## Constraints

- [D2](../../DECISIONS.md#d2-collect-and-inspect-telemetry-locally-with-an-optional-background-process) changes service ownership for telemetry; pet rendering stays independent.
- Reuse EventBridge validation and shared session rules. Preserve deadlines, identity, ordering, freshness, and unresolved notices.
- Preserve the existing one-way observation contract. Any new subscription/control interface has its own version and bounds.
- Retain same-user checks and private endpoints. Same-user access does not authenticate which agent produced an event.
- No network listener, database, background provider process, sleep prevention, or periodic filesystem polling is needed for this feature.
- Use additive migration: prove the collector independently, move app consumers, then remove the app-owned listener path without simultaneous endpoint owners.
- Setup changes must be owned and reversible. Installation and actual-agent configuration receive a concrete review before execution.

## Verify

- Seam: actual helper to collector, with the app closed, followed by app reconnect to a live snapshot.
- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Existing checks: `python3 scripts/check-event-bridge.py`, `python3 scripts/check-event-contract.py`, and `git diff --check`.
- C8 adds a bounded process checker with isolated endpoints and no installed hooks or login registration by default; document its exact invocation when added.
- Exercise closed UI, paused intake, duplicate instances, collector crash/restart, incompatible versions, sleep/wake, and snapshot overflow.
- Perform one separately reviewed real-agent check after setup. Fixture transport checks alone do not establish agent compatibility.
- Profile collector-only idle and app reconnect under [resource-efficiency](../notch/resource-efficiency.md).

## Decisions

- One optional collector and one optional native interface share a repository and release; local collection survives UI closure. See D2.

## My calls

- Keep the existing Unix-domain observation transport. Recommend a separately versioned local socket interface for snapshots and controls.
- Compare that design with native XPC in C1: sockets reuse framing and helper code but require explicit protocol handling; XPC adds native service integration but requires new clients and lifecycle work.
- Compare supported per-user service registration with a foreground-only development process. The latter simplifies local checks but cannot provide the accepted installed lifecycle alone.
- Freeze new source folders and public signatures during the C1 review rather than guessing them before extraction.

## Tasks

- [ ] C1: Review the service lifecycle and snapshot/control contract, including socket versus XPC tradeoffs, version mismatch, upgrade ownership, control semantics, and a real-process verification recipe.
- [ ] C2: Package a headless collector around the existing bounded event receiver; check isolated startup, actual helper delivery, and listener ownership without changing the running app path.
- [ ] C3: Apply observations to the existing session-state rules inside the collector; check fresh, unknown, ended, and unresolved-request snapshots without UI dependencies.
- [ ] C4: Add the reviewed bounded snapshot subscription; check initial snapshot, revisions, epoch changes, and a disconnected slow consumer.
- [ ] C5: Connect the app to collector snapshots and remove competing listener/state ownership; check reconnect and the unchanged pet-only path.
- [ ] C6: Add the reviewed opt-in service lifecycle with owned removal and bounded recovery; verify an isolated install/start/stop cycle without changing agent settings.
- [ ] C7: Add explicit collection controls and visible unavailable/paused states; verify interface-only quit, pause/resume, Quit All, and owned disconnect behavior.
- [ ] C8: Run the bounded closed-interface process checks and reviewed live-agent check; record M2 Air resource measurements and unresolved compatibility limits.
