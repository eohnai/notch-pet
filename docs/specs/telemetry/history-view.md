# History view

Needs: skill-telemetry

## Goal

Open Notch Pet after the first pilot and inspect the recorded debug-issue run.
Use the local-history importer and query API. Keep history separate from live session presentation.
Branch: `feat/telemetry-history-view`.

## Done when

- Opening history imports a bounded batch of ready files and shows a paginated run list.
- A run shows its project label, skill, agent, time, readable version, and attempted/loaded/closed/unknown state.
- Detail separates reported outcome from check results and explains incomplete or conflicting evidence.
- Version filters show hash first-seen time. History never changes the pet's live session state.
- Closing the view stops discretionary work. No periodic import or background process is required.

## Out of scope

- A dashboard, charts, live-state extraction, and the other two pilot skills.

## Verify

- Seam: launch the actual app after the closed-interface debug-issue pilot and inspect the imported run.
- Run the README build/Swift checks for changed code and `git diff --check`.
- Check pagination, conflicting/unknown states, same-name projects, import failures, and view closure with isolated history.
- Record idle CPU and memory after closing history on the M2 Air.

## Decisions

- Follow the successful first pilot with a small native history surface. See D3 in the telemetry area.

## My calls

- Put import on explicit history open/refresh, off the main actor, and publish bounded results.
- Show a project folder name and short Git SHA with dirty state beside the hash.

## Tasks

- [ ] V1: Connect a paginated history list to bounded import/query on explicit open or refresh, checking actual imported pilot data.
- [ ] V2: Add run detail and version filtering, checking separate outcome/check evidence and incomplete or conflicting records.
- [ ] V3: Verify the actual history flow and idle resource use after closure, recording remaining limits.
