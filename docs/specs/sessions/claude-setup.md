# Connect and remove Claude Code observation

Needs: agent-adapters, codex-setup, integration-health

## Goal

Connect Claude Code through the same connections workflow while preserving its settings and status line.
Reuse reviewed provider-independent setup machinery, with Claude-specific lifecycle policy in its adapter.
See the [sessions area](area.md). Proposed branch: `feat/sessions-claude-setup`.

## Done when

- The adapter describes and installs only supported Claude lifecycle hooks through explicit setup.
- Existing hook values/order, Otty integration and the complete statusLine value survive setup/removal.
- Unchanged reinstall adds no entries and leaves settings bytes unchanged.
- Version/shape/path/helper failures and ownership conflicts produce bounded errors without writes.
- Installation, interruption recovery and targeted removal use the reviewed ownership rules and
  shared guarded primitives, without treating Codex's schema as Claude's schema.
- Actual disposable installer/helper processes deliver an observation; installed live-agent coverage
  is recorded separately by the connections workflow.

## Out of scope

- Claude quota/status-line wrapping, action responses, transcripts, additional hook events,
  production configuration edits during development or automatic feature enablement.

## Constraints

- Original source I4/I5/I6 requirements remain intact. These tasks refine the Claude portions only.
- Never inspect or print unrelated settings or credentials as diagnostics.
- Use current official [Claude hooks](https://code.claude.com/docs/en/hooks) and
  [settings](https://code.claude.com/docs/en/settings) as documentation evidence, then verify selected
  installed-version behavior in isolated configuration. Reviewed 2026-10-30; no new runtime proof here.
- Each slice stays within three files, three added production functions and five added tests.

## Verify

- Seam: Claude setup driver through guarded file operations, helper and event bridge in temporary paths.
- Swift filters `ClaudeHookSetupPlannerTests` and `ClaudeHookInstallerTests`: at most five added cases
  per slice, all passing; include a fictional statusLine value and unrelated hooks.
- Full Swift/build and process checks are specified in the goal; no checks run during planning.

## Decisions

- **Open: Claude ownership/recovery representation.** Recommend reusing the accepted Codex external
  ownership principle through shared guarded primitives, with a provider-specific record and policy.
  Finalize this choice before coding. Lifecycle setup never includes quota forwarding.

## My calls

- Codex setup is a build dependency for shared guarded machinery, not a required Codex installation/account.
- Preserve statusLine as an uninterpreted value. Do not execute an existing status-line command in tests.

## Tasks

- [ ] CL1: Define Claude-specific version, hook, timeout, ownership and recovery rules behind the shared setup interface, checking a disposable configuration contract.
- [ ] CL2: Add the bounded Claude setup planner with at most five tests for initial setup, idempotence, unrelated hooks/statusLine preservation, malformed settings and ownership conflicts.
- [ ] CL3: Apply Claude setup through reviewed guarded primitives with at most five isolated tests for fresh revalidation, unsafe paths, helper failure and interruption handling.
- [ ] CL4: Add owned Claude removal with at most five tests covering unrelated later edits, repeated removal and missing/edited/duplicate ownership conflicts.
- [ ] CL5: Verify actual isolated setup, reinstall, helper delivery and removal, recording lifecycle coverage separately from live-agent and status-line forwarding acceptance.
