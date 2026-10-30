# Connect Codex through owned lifecycle hooks

Needs: integration-health, notch/session-island

## Goal

Let users connect Codex, check integration health, and remove app-owned hooks from the menu.
A real Codex session must reach the visible notch through the bundled helper.
This starts the approved Sessions → Notch → Usage path. See the [sessions area](area.md) for shared context.

The user confirmed this scope and menu-first controls on 2026-10-30.
The user approved the eight-task list on 2026-10-30. Start with I3b1's design review.
Task approval does not accept the open design proposals, close prerequisites, or resume runtime verification.

## Done when

- Pet-only startup needs no agent setup. Connect is explicit and optional; Check and Remove hooks are available for Codex.
- Connect installs only the seven supported lifecycle hooks using the bundled helper and an accepted version/configuration shape.
  Unsupported versions, disabled hooks, missing helpers, unsafe paths, and invalid configuration produce bounded, useful messages without configuration changes.
- Repeating Connect with unchanged owned entries leaves hook bytes unchanged and creates no duplicate entries.
- Setup and removal preserve unrelated handlers, their order, unrelated JSON values, and later user edits.
  Edited, missing, copied, or ambiguous managed entries produce a conflict without destructive cleanup.
- The accepted ownership file records only app-created data. Interrupted updates recover under a reviewed protocol or stop with recovery instructions.
  The approved design states its concurrent-writer guarantees and limitations before implementation.
- Normal Codex hook trust review remains intact. Installation, trust, receiver availability, and actual delivery remain distinct outcomes.
  Check is read-only and does not submit agent work. An empty session list does not imply broken setup.
- After explicit setup, the existing optional services receive real Codex observations and show the correct session in the notch.
  No manual mode switch is required for each session. Missing terminal metadata does not block observation.
- Disposable real-agent acceptance proves Connect, repeated Connect, Check, visible session delivery, and targeted removal.
  Unrelated configuration remains intact after cleanup. An isolated conflict case leaves edited configuration untouched.

## Out of scope

- Claude setup, its status line, and Claude acceptance.
- Pause/resume/disconnect monitoring semantics, including service-wide controls and notice-retention policy.
- The Settings window and its later Agents page. This feature owns reusable Codex setup actions.
- Usage changes, allowance acceptance, approvals, answers, follow-up replies, pet reactions, and terminal navigation.
- Completing the deferred R6–R7 interactive matrix, N8 terminal matrix, or final R8 first-use workflow.
- Automatic hook installation at startup, trust bypasses, and edits to `config.toml` to enable hooks.

## Constraints

- Keep SwiftUI/AppKit, shared session state, the version-1 event contract, and the silent helper's existing deadline.
- Follow the preservation requirements in the [setup contract](../../contracts/codex-hook-setup.md).
  Only its separate ownership-file representation is accepted. Schema, recovery, timeout, and file-update proposals still need review.
- Keep the pure planner separate from file operations. Bound hook input, candidate output, ownership records, and recovery data to 262144 bytes each.
  Reject duplicate JSON keys and preserve unrelated numeric values without floating-point conversion.
- Use the effective bounded absolute `CODEX_HOME` path. Reject invalid overrides without falling back to another configuration directory.
  Read no credentials, authentication files, or transcripts. Diagnostics must omit raw configuration and command contents.
- Validate helper quoting, supported timeout syntax, path safety, permissions, and concurrent updates before writing configuration.
  A process-shared app lock does not coordinate independent editors. Atomic replacement alone does not resolve that race.
- Keep preferences separate from evidence. A saved opt-in or successful installation does not prove hook delivery or a current session.
  Removing hooks must not resolve requests or claim session completion. Broader runtime controls remain separately owned.
- Keep runtime files, isolated configuration, ownership records, and captures outside the repository.
  Do not change installed Codex, Claude Code, or Otty configuration during planning or disposable verification.
- Keep tests, builds, probes, app launches, helper injections, captures, and test-only instrumentation paused until explicitly requested.
  Prerequisite evidence and closure must be reviewed before dependent implementation.

## Verify

- Seam: menu actions → setup service → isolated Codex hooks → bundled helper → production receiver → visible notch.
- Documentation: `git diff --check` exits 0. The progress board resolves both `Needs:` entries and lists the eight approved tasks.
- Swift checks, after renewed authorization: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
  Passing means exit 0 with no failing tests. Fixture checks cover preservation, ownership conflicts, bounds, stale plans, and each durable interruption boundary.
- Build, after renewed authorization: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`.
  Passing means exit 0 and a packaged app plus helper outside the repository.
- Real app, after renewed authorization: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh` is the existing launch command.
  I6b must first freeze the isolated app/CLI launch recipe, explicit configuration and ownership paths, preference suite, and cleanup commands.
  The ordinary launch command alone does not isolate setup and must not be used to write the normal configuration.
- In disposable configuration, use the menu to Connect, repeat Connect, and Check. Complete normal Codex trust review.
  Start a real Codex session and verify its identity and observed state in the notch. A silent helper exit alone is insufficient.
  Remove hooks after adding unrelated data, then verify that only unchanged owned entries were removed.
  Repeat with a managed-entry edit and verify a conflict with no configuration changes.
- Preserve original Otty acceptance from I6 and the terminal-independent requirement. Record the exact tested terminal and version.
  These checks do not complete the broader R6–R7 or N8 matrix. Do not request screenshots or retry the prohibited capture path.

These are future verification requirements. No runtime verification ran while writing this specification.

## Decisions

- **Use menu controls first.** The user accepted this on 2026-10-30 to avoid waiting for the planned Settings window.
  Waiting for Settings was considered and deferred. The later Settings feature can reuse these actions.
- **Use a separate ownership file.** Accepted on 2026-10-28. Entry markers alone were rejected because they lack verified compatibility and edit detection.
  See the [existing decision and proposed recovery contract](../../contracts/codex-hook-setup.md#ownership-alternatives-requiring-a-decision).
- [0004: Receive lifecycle hooks](../../decisions/0004-receive-agent-hook-events.md).
- [0005: Use the local observer helper](../../decisions/0005-use-a-local-unix-socket.md).
- [0011: Preserve feature ownership and historical evidence](../../decisions/0011-organize-records-by-feature.md).
- [0012: Support terminal-independent observation](../../decisions/0012-support-terminal-independent-operation.md).
- [0013: Keep agent setup optional](../../decisions/0013-separate-standalone-pet-scope.md).
- **Open:** Which ownership schema, collision rules, and interruption protocol make installation and removal safe?
  Review the proposed journal against alternatives and enumerate every interruption state in I3b1.
- **Open:** Is the proposed advisory-lock/recheck/replace limitation acceptable against independent writers, or is another write strategy required?
  Settle this in I3b1 before file-operation implementation. Preservation must not be promised beyond the chosen guarantees.
- **Open:** Which selected Codex version verifies hook enablement, configuration shape, helper invocation, and agent-enforced timeout?
  Settle the gate and unavailable guidance in I3b1. Historical version evidence is not a supported-version range.

## My calls

- Use `feat/sessions-codex-setup` for eventual implementation. This planning session creates no branch.
- Reuse `IntegrationHealthController`, `AgentServiceOwner`, and `AgentServices`; concrete interfaces receive task-level review.
  The current menu exposes Show Pet, Pet Settings, and Quit. The health controller is private and has no menu action.
- Label removal as Remove hooks so it does not define the separately planned Disconnect behavior.
  Exact wording and health presentation receive interface review in I6a.
- Use eight approved session-sized tasks. Keep each task within the existing three-file, three-function, and five-test limits, including required records.
  Review exact files, interfaces, and checks per task. Split any oversized task with user approval before coding.
- Preserve the source checklist until shared Codex/Claude checks have complete destinations. This spec's tasks refine that work; they are not extra source requirements.
  Do not add source and refinement counts as independent work estimates.

## Tasks

- [ ] I3b1: Review prerequisite evidence and settle the Codex version/enablement gate, timeout, ownership schema, recovery states, and concurrent-writer guarantees using the contract's fictional cases; record accepted choices before coding.
- [ ] I3b2: Add bounded lossless hook-JSON scanning with duplicate-key, malformed-input, numeric-value, and size-limit fixture checks.
- [ ] I3b3: Add the pure setup planner with seven separately owned groups, safe helper invocation, unchanged reinstall, and ownership/conflict fixture checks.
- [ ] I3c1: Add guarded configuration and ownership writes with the approved durable-update order, path/permission checks, and stale-state fault checks; keep the service unavailable to menu callers until recovery passes.
- [ ] I3c2: Add interrupted-update recovery covering every approved durable boundary, uncertain state, and retry without duplicate adoption or later-edit overwrite.
- [ ] I5a: Add Codex-only targeted removal with exact ownership checks, preserved unrelated edits, and unchanged output on malformed, missing, or conflicting ownership.
- [ ] I6a: Add menu Connect, Check, and Remove hooks actions with bounded health/recovery messages and explicit optional-service activation; verify action routing without installed configuration changes.
- [ ] I6b: Freeze the disposable verification recipe and verify real Codex setup, repeat setup, trust review, visible-notch delivery, removal, and conflict cleanup; run the approved suite/build and record evidence.

## Source task coverage and historical evidence

The [source specification](../notch-companion.md#i-see-sessions-and-manage-agent-setup) remains unchanged.
Its original task IDs, wording, checkboxes, and shared acceptance obligations remain authoritative during migration.

| Source task | Existing state | Coverage here |
|---|---|---|
| I3a | Checked, documentation only | Existing setup contract and fictional review cases; no new implementation or verification claim. |
| I3b | Open | I3b1–I3b3 settle design and implement the pure planner. |
| I3c | Open | I3c1–I3c2 implement guarded installation and recovery. |
| I5 | Open, shared | I5a covers Codex only. Claude removal remains with Claude setup. |
| I6 | Open, shared | I6a–I6b cover Codex controls and live acceptance. Claude and original Otty obligations remain preserved. |

The contract records I3a's documentation review and the separate ownership-file choice.
No Codex installer, planner, removal service, or connection menu is present in the inspected source.
The app already has an opt-in service owner and receiver/delivery health wiring; their existing acceptance remains open in the prerequisite specs.
Earlier helper-to-menu screenshots established partial fictional delivery only. See [session-island historical evidence](../notch/session-island.md#historical-evidence).
They do not establish real-provider setup or complete I6b.
