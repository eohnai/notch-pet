# Sessions

Owns terminal-independent agent observation, session state, integration setup and health, and optional terminal navigation.
Code: `Sources/EventBridge/`, session and integration-health services in `Sources/SessionState/`, and app integration controls.

## Specs

- `observation-bridge`: Deliver agent events through the helper into the running app, preserving the native shell and bridge foundation.
- [`session-state`](session-state.md): Distinguish concurrent sessions, requests, response-ready notices, and unknown state. Needs: observation-bridge.
- [`integration-health`](integration-health.md): Report version, configuration, helper, receiver, and delivery evidence separately. Needs: observation-bridge.
- `codex-setup`: Install and remove owned Codex hooks without overwriting user changes. Needs: integration-health.
- `claude-setup`: Install and remove owned Claude lifecycle hooks while preserving the status line. Needs: integration-health.
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

## Open questions

- Codex setup interruption recovery remains proposed. See the [setup contract](../../contracts/codex-hook-setup.md).
- During feature migration, divide shared acceptance checks without losing any original requirement or checkbox state.
