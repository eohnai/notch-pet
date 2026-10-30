# Telemetry

Owns local skill history and later background agent monitoring.
Runtime code belongs in notch-pet. Pilot skill instructions belong in agent-skills.

## Specs

- `local-history`: Write immutable records to local files and import them into SQLite without a running app.
- `skill-telemetry`: Verify real hook signals and instrument debug-issue first. Needs: local-history.
- `history-view`: Inspect the first pilot in the native app. Needs: skill-telemetry.
- `remaining-pilots`: Extend measurement to next-task and checkpoint. Needs: history-view.
- `background-collection`: Later, keep live monitoring active while the interface is closed. Optional after the pilots.

## Shared context

- [D3](../../DECISIONS.md#d3-record-skill-history-before-extracting-live-monitoring) replaces the collector-first order in D2.
- Recording history while the app is closed needs files, not a daemon. Live monitoring while the interface is closed remains a separate goal.
- Start with run_start, run_end, and check records. Add intermediate milestones only when a pilot shows a useful question they answer.
- [Local history](local-history.md) defines examples, atomic publication, commit-before-removal, identity, versioning, and metric rules once.
- [Battery requirements](../notch/resource-efficiency.md) apply to emitter calls, import, presentation, and any later collector.
- Keep data on this Mac and outside both repositories. Project folder names are useful labels. Conversation bodies and credentials stay out.
- Existing live event delivery, usage refresh, and interactive actions keep their current owners during the pilot.
- The version-1 socket contract is unchanged. A telemetry hook adapter writes its selected fields through the emitter, not through that envelope.

## Open questions

- S1 must capture actual hook payloads in isolated configuration before choosing an automatic start signal.
- The proposed pilot accepts normal emitter permission prompts. A narrowly scoped allowlist would require a separate reviewed setup change.
- Collector registration, IPC, and live-state ownership wait until the pilot and history view are useful.
