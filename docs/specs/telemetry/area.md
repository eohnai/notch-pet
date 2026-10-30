# Telemetry

Owns optional background observation, local activity history, and skill-run measurement.
Implementation belongs in `notch-pet`; pilot skill instructions belong in `~/projects/agent-skills`.
The collector, native app, and short-lived helpers share one repository and release. No hosted backend is required.

## Specs

- `background-collection`: Continue observation with the interface closed and reconnect the app to current session evidence.
- `local-history`: Persist bounded, deduplicated records and inspect them through a local query client and minimal app history. Needs: background-collection.
- `skill-telemetry`: Measure next-task, debug-issue, and checkpoint invocations with explicit evidence sources. Needs: local-history.

## Shared context

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
