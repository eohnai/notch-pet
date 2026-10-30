# Sessions

Owns terminal-independent agent observation, session state, integration setup and health, and optional terminal navigation.
Code: `Sources/EventBridge/`, session and integration-health services in `Sources/SessionState/`, and app integration controls.

## Specs

- `observation-bridge`: Deliver agent events through the helper into the running app, preserving the native shell and bridge foundation.
- [`session-state`](session-state.md): Distinguish concurrent sessions, requests, response-ready notices, and unknown state. Needs: observation-bridge.
- [`integration-health`](integration-health.md): Report version, configuration, helper, receiver, and delivery evidence separately. Needs: observation-bridge.
- `agent-adapters`: [Register extensible agent integrations](agent-adapters.md) while preserving bounded observation and independent capabilities. Needs: observation-bridge.
- `codex-setup`: [Install and remove owned Codex hooks](codex-setup.md) without overwriting user changes. Needs: agent-adapters, integration-health.
- `claude-setup`: [Install and remove owned Claude lifecycle hooks](claude-setup.md) while preserving the status line. Needs: agent-adapters, codex-setup, integration-health.
- `agent-connections`: [Manage enabled agents and verify their live session workflow](agent-connections.md). Needs: agent-adapters, codex-setup, claude-setup, integration-health.
- `pane-navigation`: Report exact-pane, application-only, or unavailable navigation through optional terminal adapters. Needs: session-state.
- `first-use`: Verify setup, live alerts, navigation, removal, and release instructions. Needs: codex-setup, claude-setup, pane-navigation, notch/desktop-recovery, notch/accessible-controls, usage/refresh-recovery, actions/structured-answers, actions/follow-up-replies, pets/detachable-pet, pets/custom-packs.

## Shared context

- [Record layout decision](../../decisions/0011-organize-records-by-feature.md).
- [Terminal independence](../../decisions/0012-support-terminal-independent-operation.md) is accepted. Otty is one optional navigation adapter.
- Monitoring, alerts, pet reactions, and supported allowance reads must work without terminal metadata or an Otty installation.
- Missing navigation does not imply broken agent setup or unavailable provider actions. Report those capabilities separately.
- [Observation bridge](observation-bridge.md) owns its migrated completed tasks and historical evidence.
- [Source specification](../notch-companion.md): unmigrated tasks and evidence remain authoritative until their feature migration.
- Implemented: native app shell, bounded event bridge, both agent adapters, session store, and inbox. Preserve completed foundation tasks and G1–G2 evidence.
- Implemented but awaiting verification: I2a–I2c integration-health code. I3a setup proposal is completed documentation, not an implemented installer.
- Migrate I3b–I3c and the Codex portion of I5–I6 into codex-setup. Migrate I4 and the Claude portion into claude-setup.
- N1–N2 own exact-pane navigation. Live event coverage includes N6 and R6–R7. R8 owns final first-use acceptance.
- Preserve those Otty-specific checks. N7 defines general navigation capabilities; N8 adds live checks for both agents in another local terminal.
- Migrate N7 into pane-navigation and N8 into first-use. The terminal matrix records tested combinations, not universal compatibility.
- The first feature preserves the existing real helper-to-app path. Do not treat fixture checks as live-provider acceptance.
- Review features against approved behavior and accepted decisions, then check code for support and gaps. Existing code alone does not define scope.
- Keep agent configuration intact and captured session data outside the repository.
- Current priority is Codex and Claude connections plus the session island, confirmed 2026-10-30.
  [The prepared goal](../../goals/agent-session-workflow.md) coordinates these specs. Its task list,
  structural choices, branch strategy and renewed verification authorization still need review.
- The new setup/control task IDs refine the source I3b/I3c/I4/I5/I6 requirements. Original source
  lines and states remain intact; finishing one refinement does not complete an aggregate source task.
- More providers should use the same integration boundary. Only Codex and Claude ship in this goal;
  a new catalog entry alone never establishes new agent compatibility.

## Decisions

- **Prioritize both agents and the session island before telemetry, allowance completion and pet reactions.**
  The user confirmed this first goal on 2026-10-30 after considering Codex-first and a broader allowance milestone.
  The user wants Flux-like connections and future-agent extensibility; implementation and verification remain separately gated.
- **Use built-in providers registered in a catalog.** Accepted 2026-10-30 when the user approved the
  prepared goal and requested activation. Keep event, setup and optional capabilities separate.
  Runtime plugins were considered but deferred; this goal covers extensibility for the two built-in agents.
  See [the two structures](agent-adapters.md#proposed-structure).

## Open questions

- Codex setup interruption recovery remains proposed. See the [setup contract](../../contracts/codex-hook-setup.md).
- During feature migration, divide shared acceptance checks without losing any original requirement or checkbox state.
- Off-as-pause versus Off-as-uninstall, installer concurrency guarantees and the exact provider-version
  gates must be settled before their implementation. No choice is inferred from Flux's Active label.
