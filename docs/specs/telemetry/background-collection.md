# Background collection

## Goal

Later, keep live agent monitoring active while the notch/pet interface is closed.
This remains wanted, but it is independent of durable skill history and follows the pilots.
See the [telemetry area](area.md). Eventual branch: `feat/telemetry-background-collection`.

## Done when

- An explicitly enabled collector receives a real observation with the interface closed.
- Reopening the app reconnects to one authoritative live session snapshot without a second endpoint owner.
- Collector restart, missing evidence, and sleep/wake preserve unknown state and unresolved notices.
- Slow or disconnected UI clients cannot block observations or grow an unbounded queue.
- Pet-only use starts no collector. Usage refresh and interactive action channels keep their separate owners.
- Closing the interface, pausing monitoring, quitting all components, and disconnecting have clear, verified lifecycle effects.
- The collector meets reviewed M2 Air resource limits and waits for events while idle.

## Out of scope

- Prerequisites for skill history, hosted ingestion, cross-device sync, and moving approvals or quota refresh into the collector.

## Constraints

- Reuse existing session semantics and bounded hook delivery. Historical run files never establish live working state.
- Preserve current app-owned live monitoring until an approved migration replaces it.
- Compare socket snapshots with XPC when this feature is planned. Define registration, upgrade, stop, and recovery behavior before implementation.
- Preserve agent configuration and the independent pet. Service setup must be explicit, owned, and reversible.

## Verify

- Seam: a real helper event delivered with the interface closed, followed by app reconnection to current evidence.
- Use README build/Swift/bridge checks and an isolated process lifecycle check when implemented.
- Exercise duplicate launches, restart, version mismatch, slow clients, pause/resume, Quit All, and sleep/wake.
- Record collector-only idle CPU, memory, and wakeups on the M2 Air.

## Decisions

- Keep the collector as later live-monitoring work, not a dependency of local history. See [D3](../../DECISIONS.md#d3-record-skill-history-before-extracting-live-monitoring).

## Tasks

The earlier unstarted C1–C8 proposals are withdrawn by D3. No completed work is removed.
Use plan-feature after the pilots to size the lifecycle and extraction tasks from the then-current app.
No service is installed or enabled by this plan.
