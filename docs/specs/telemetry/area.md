# Telemetry

Owns optional background observation, local activity history and statistics, verified token statistics, and skill-run measurement.
Implementation belongs in `notch-pet`; pilot skill instructions belong in `~/projects/agent-skills`.
The collector, native app, and short-lived helpers share one repository and release. No hosted backend is required.

## Specs

- `background-collection`: Continue observation with the interface closed and reconnect the app to current session evidence.
- `local-history`: Persist bounded, deduplicated records and inspect them through a local query client and minimal app history. Needs: background-collection.
- `skill-telemetry`: Measure next-task, debug-issue, and checkpoint invocations with explicit evidence sources. Needs: local-history.
- `activity-statistics`: Show local activity totals, the most-used agent, and Today/Last 7 Days charts with explicit counting and coverage rules. Needs: local-history, settings/settings-window.
- `token-statistics`: Show local token totals and trends from verified provider counters, with explicit units, deduplication, and coverage. Needs: local-history, settings/settings-window.

## Shared context

- Later priority after the session-and-limits delivery path, approved on 2026-10-30. Collector, history, and pilot-skill scope remain intact.
- Coordinate collector lifecycle with sessions/monitoring-controls. Interface visibility and monitoring state remain separate concerns.
- The next session/usage milestone does not require collector extraction or local history.
- The user approved activity-statistics and token-statistics on 2026-10-30, using the supplied settings Statistics pages as references.
- Statistics belong in the shared native settings window. Show summaries and per-agent time-series charts with Today and Last 7 Days filters.
- Define each activity unit before naming a total. An observed hook event is not proof of a chat message, user action, or successful task.
- Activity summaries use bounded queries over retained local records and report gaps, partial coverage, and retention limits.
- Token statistics require verified provider counters. Do not infer token totals from quota percentages or estimate remaining allowance from token totals.
- Review cumulative versus incremental counters, cache/input/output units, reset boundaries, and duplicate observations before aggregation. Missing source coverage stays unavailable.
- These additions extend the roadmap beyond local-history's minimal run list. Its existing scope and tasks remain unchanged.
- Existing source and content restrictions remain in force. Token-source planning does not authorize transcript reads, credential access, raw content persistence, or new provider support.
- [D2: Confirmed telemetry scope](../../DECISIONS.md#d2-collect-and-inspect-telemetry-locally-with-an-optional-background-process).
- [Battery requirements](../notch/resource-efficiency.md) apply to every app-owned process. Budgets remain provisional until measured.
- Existing [observation contract](../../contracts/agent-events-v1.md) remains bounded, one-way, and without acknowledgements or retries.
- Observation delivery and durable telemetry ingestion are separate contracts. A successful socket write is not proof of persistence.
- The collector owns authoritative live session evidence after migration. The app presents snapshots instead of maintaining competing lifecycle truth.
- Durable history is queried separately. It never restores working state or replays decisions, questions, or replies.
- Usage refresh and interactive actions retain their existing owners. Collector extraction does not imply moving their processes or response channels.
- Pet-only use requires no agent, hook, collector, database, or account. An independently enabled collector is not stopped by displaying a pet.
- Keep runtime data outside both repositories. Exclude conversation bodies, commands, raw tool input, transcripts, and credentials.
- The scope is confirmed. The new task lists still need approval before implementation; existing goals and checkboxes remain unchanged.
- Plan each task within three changed files, three added production functions, and five added test cases. Split before coding if needed.

## Decisions

- Keep collection independent of interface visibility, with local-only SQLite history and three pilot skills. See D2.
- Borrow Rico's explicit events/runs/steps, stable IDs, and retryable delivery. Do not copy its drain-before-send crash window or unbounded metadata fields.

## Open questions

- The service registration mechanism, development lifecycle, upgrade handoff, and snapshot protocol are settled in C1 before extraction.
- H1 settles the telemetry schema, acknowledgement contract, retention defaults, and deletion behavior before adding persistence.
- S1 establishes installed-agent observation coverage; reading a skill file never proves invocation or compliance.
- Verify available token counters before defining the token-statistics contract. Unsupported providers or periods must remain explicit.
- Define activity counting, most-used-agent ranking, time zones, daily boundaries, and chart behavior for empty or incomplete periods.
