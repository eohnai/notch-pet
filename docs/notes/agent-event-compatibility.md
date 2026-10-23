# Agent events and Otty pane compatibility

Checked on 2026-10-22 for the first task in the [specification](../specs/notch-companion.md).

Both installed agents dispatched approval, response-stop, and structured-question hooks in isolated runtime checks.
Fresh Otty pane identifiers selected the correct panes, including two panes in the same folder.
The parent process had a stale `OTTY_PANE_ID`, so an inherited identifier needs live validation.

The application remains a native SwiftUI/AppKit project. These checks add no application code.
The Python probes are temporary investigation tools outside this repository.
All architecture proposals remain open for the scheduled decision task.

## Evidence boundaries

- **Runtime** means the installed agent dispatched a hook during a controlled local run.
- **Installed** means a local schema, configuration inventory, or bundled script established the interface.
- **Documented** means an official source describes behavior that this session did not exercise.
- **Unverified** means the tested paths do not establish the behavior.

The mock provider listened only on `127.0.0.1` and supplied fixed responses and tool requests.
The runs used temporary agent configuration directories and placeholder authentication.
They did not use provider accounts or paid model calls.
Claude's cost fields reflect its own calculation from mock token counts; they are not billing evidence.

Codex ran through the app-server shipped with its CLI. Claude ran through print mode and its streaming permission host.
These checks establish installed hook dispatch, not complete interactive terminal behavior.
The checks did not run a normal interactive agent turn inside Otty.
The adapter tasks and final workflow task must cover that path before release.

## Installed versions and configuration

| Component | Checked result | Evidence |
|---|---|---|
| Codex CLI | `0.163.0` | `codex --version` |
| Claude Code | `2.1.306` | `claude --version` |
| Otty | `1.6.2` | `CFBundleShortVersionString` in `/Applications/Otty.app/Contents/Info.plist` |
| Codex hooks | Feature enabled; 12 event names in the generated installed schema | `codex features list`; `v2/HooksListResponse.json` |
| Codex default-mode questions | `default_mode_request_user_input` disabled in the normal configuration | `codex features list`; enabled only in the isolated question check |
| Existing hook configuration | Both agents have Otty handlers and unrelated handlers | Structural inventory of `~/.codex/hooks.json` and `~/.claude/settings.json` |
| Configuration preservation | All three inspected user configuration files have unchanged SHA-256 fingerprints | Before/after comparison of both hook files and `~/.codex/config.toml` |

The inventory printed event names, matchers, handler counts, Otty membership, and state arguments only.
It did not print unrelated commands or settings. No authentication files or transcript histories were inspected.

## Compatibility matrix

| Capability | Codex 0.163.0 | Claude Code 2.1.306 | Limit for the companion |
|---|---|---|---|
| Start and session identity | **Runtime:** `SessionStart`, `session_id`, `cwd`, `source` | **Runtime:** same fields | Use agent plus source session ID. A folder is not a session ID. |
| User submitted a turn | **Runtime:** `UserPromptSubmit`, with `turn_id` | **Runtime:** `UserPromptSubmit`, with `prompt_id` | Do not forward prompt text into routine logs. |
| Permission needed | **Runtime:** `PermissionRequest` before the host approval request; `tool_name: Bash` | **Runtime:** `PermissionRequest` before the host approval request; `tool_name: Write` | The probe hook returned `{}`. The test host denied the request. No test write occurred. |
| Response ready | **Runtime:** `Stop`, including after a denied command | **Runtime:** `Stop`, including after a denied write | A stopped response does not prove task success. |
| Structured question opens | **Runtime:** `PreToolUse` with `tool_name: request_user_input`; then host question request | **Runtime:** `PreToolUse` with `tool_name: AskUserQuestion`; also `PermissionRequest` for that tool | Classify the tool before treating a permission event as command approval. |
| Structured question resolves | **Runtime:** `PostToolUse` after the host supplied an answer | **Runtime:** `PostToolUse` after the host supplied an answer | Preserve tool identity to match question opening and resolution. |
| Question availability | **Runtime:** exercised with the isolated default-mode feature enabled | **Runtime:** the question reached hooks with a streaming permission host; plain print mode did not expose it | Do not promise the same question coverage for every launch mode. |
| Ordinary prose question | **Unverified:** no dedicated event established | **Unverified:** no dedicated event established | Keep the response-ready label when a response contains an ordinary question. |
| Graceful end | **Runtime:** `SessionEnd` after archiving each test thread | **Runtime:** `SessionEnd` after each print process finished | Abrupt process loss was not tested. Missing end events cannot prove continued activity. |
| Interruption | **Installed/documented:** `Interrupt` exists; not triggered | **Unverified:** no interruption hook was exercised | Do not infer reliable interruption detection from `Stop`. |
| Failure-specific end | **Unverified:** no failure hook established by these checks | **Installed/documented:** `StopFailure`; not triggered | Failure handling needs its own adapter checks. |
| Delayed notifications and MCP questions | No `Notification` or `Elicitation` member in the installed hook event enum | **Documented:** `Notification`, `Elicitation`, and `ElicitationResult`; not triggered | Do not treat a notification or MCP question as runtime verified here. |

The generated Codex enum contains `preToolUse`, `permissionRequest`, `postToolUse`, `preCompact`, `postCompact`,
`sessionStart`, `sessionEnd`, `userPromptSubmit`, `subagentStart`, `subagentStop`, `stop`, and `interrupt`.
These protocol names differ in capitalization from hook configuration names.

Codex documents merged hook sources and trust review. A configured hook can be skipped until trusted.
The probe's initial app-server run listed its hooks as untrusted and dispatched none.
The successful runs used `config.bypass_hook_trust: true` only for the reviewed temporary capture script.
Do not carry this bypass into normal setup. See [Codex hooks](https://learn.chatgpt.com/docs/hooks).

Claude documents delayed `Notification` events and immediate `PermissionRequest` hooks.
Its `permission_prompt` notification can wait about six seconds; `idle_prompt` can wait about 60 seconds.
These delays were not measured here. See [Claude hooks](https://code.claude.com/docs/en/hooks).

## Payload examples

[agent-event-examples.json](agent-event-examples.json) contains fictional values reconstructed from observed payload shapes.
It contains no captured session identifiers, user paths, transcript contents, or real pane identifiers.
Its wrapper records the provider, installed version, and evidence type. The wrapper is not an application event contract.

The observed hook JSON did not contain an Otty pane field.
The collector separately checked whether `OTTY_PANE_ID` was inherited.
The inherited value was stale, so its presence did not establish a valid mapping.
Do not read `transcript_path` merely because the hook supplies it.

## Otty identity and navigation

Two disposable shell panes used the same temporary working folder.
Each wrote its own environment identifier into a separate temporary file.
Both environment selectors resolved to different canonical `p_...` IDs through `otty pane show`.
The canonical ID and environment selector were different representations of the same live pane.

| Check | Result |
|---|---|
| Inherited parent `OTTY_PANE_ID` | Did not resolve: `No pane matched selector` |
| Parent `CODEX_THREAD_ID` | Matched a live `agent_session_id` in `otty pane list` |
| Two fresh environment identifiers | Distinct; each resolved to its own canonical pane ID |
| Two panes in the same folder | Remained distinct |
| `otty pane focus otty://pane/<environment-id>` | Selected the expected pane for both test panes |
| `/usr/bin/open otty://pane/<environment-id>` | macOS URL dispatch selected the expected pane for both test panes |
| Closed-pane CLI link | Exit `4`; did not recreate the pane |
| Closed-pane macOS URL | `open` returned successfully; the closed pane stayed absent and no replacement appeared |
| Cleanup | Closed only disposable test panes and restored the original live pane's focus |

The current-session match is one observation, not a guarantee that every launch mode supplies `CODEX_THREAD_ID`.
Otty's pane list includes canonical ID, agent session ID, agent state, folder, tab, and window.
The `active` field was true for multiple panes; it was not used as proof of global focus.
Focus checks compared `otty pane show` without a selector against the expected canonical ID.

The OS URL check waited 250 ms before listing panes after the stale link.
It verifies the observed handling, not every future timing or restart case.
Otty documents pane links and a no-op fallback for stale selectors in its [URL scheme reference](https://docs.otty.sh/reference/url-scheme).

## Existing Otty integration

The installed hook scripts are readable inside `/Applications/Otty.app/Contents/Resources/agent-integration/`.
The configuration inventory found these Otty state mappings:

| Source event | Codex state | Claude state |
|---|---|---|
| `SessionStart` | `idle` | `idle` |
| `UserPromptSubmit` | `processing` | `processing` |
| `PreToolUse` | `processing` | `processing` |
| `PermissionRequest` | `awaiting` | `awaiting` |
| `PostToolUse` | No Otty handler found | `processing` |
| `Stop` | `idle` | `idle` |
| `StopFailure` | No Otty handler found | `error` |

Both hook commands pass `$PPID`. The bundled scripts forward that process ID and the session ID to `otty-cli`.
They background the forwarding call and suppress its errors.
The Claude script also accounts for running background subagents when choosing a state from `Stop`.
These are source-inspection findings, not a timeout or failure-isolation test of Otty's helper.

Otty describes its hook installation in [agent setup](https://docs.otty.sh/agents/setup).
The companion's future setup task must preserve all existing Otty and unrelated handlers.
No hook installation or removal was performed in this investigation.

## Implications for later tasks

These are findings to review during the architecture task, not accepted architecture decisions.

- Keep pane identity separate from source session identity. Validate any inherited selector against live Otty state.
- A verified agent-session match may help when a parent environment identifier is stale. Ambiguous matches need an unavailable navigation state.
- Define structured-question handling separately from command approval. General prose questions remain response ready.
- Carry optional source turn and tool identifiers when present. Do not require every event to supply them.
- Treat graceful end events as useful evidence, not a guarantee after crashes or pane closure.
- Test normal interactive CLI sessions in Otty during adapter verification and final acceptance.
- Add trust review to future Codex setup verification. Listing a hook alone does not establish that it runs.

## Codex adapter implementation, 2026-10-23

The user approved separate implementation and interactive verification tasks.
`CodexEventAdapter` now projects the seven hook shapes recorded above into the existing version-1 envelope.
The helper routes `--agent codex` through this adapter with its existing bounded parser and shared deadline.
Source turn and tool-call IDs remain optional. The adapter never substitutes `prompt_id`, a pane ID, or a generated source identity.
Generated event UUIDs identify helper invocations only.
The shared contract mapping and store still own question classification, ordering, request matching, and freshness.

Fictional checks cover all seven reconstructed Codex payloads and ten unsupported hook names.
They also cover omitted content, untrusted source metadata, byte bounds, malformed input, missing identities, and parser deadlines.
Store checks cover approval, structured questions, matching resolution, response-ready prose questions, graceful end, and uncorrelated requests.
A real local socket check sends a projected fictional Codex submit through the inbox to the shared store.
The existing helper process checks exercise the adapter route and unavailable-app behavior.

`codex --version` reported `codex-cli 0.164.0` during planning on 2026-10-23.
The earlier runtime investigation used `0.163.0`. These fictional checks do not extend that runtime evidence to `0.164.0`.
The next task must verify installed Codex in interactive Otty sessions using isolated configuration.
It must include hook trust, approval handling, structured-question availability, concurrent sessions, and lifecycle limits.
`Interrupt` remains outside version 1. Abrupt loss must not imply an observed graceful end.
No live hooks, agent settings, credentials, or captured sessions were read or changed during this implementation.

## Commands and retained local evidence

The temporary investigation directory is `/private/tmp/notch-pet-events-sx8yq6zw`.
It is outside Git and is disposable. It contains mock-provider scripts, raw probe output, and temporary agent state.
The repository examples and this matrix are the durable record; temporary files may disappear.

Commands run successfully:

```bash
codex --version
claude --version
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' /Applications/Otty.app/Contents/Info.plist
codex features list
codex app-server generate-json-schema --experimental --out /private/tmp/notch-pet-events-sx8yq6zw/schema
python3 /private/tmp/notch-pet-events-sx8yq6zw/probe-agents.py
python3 /private/tmp/notch-pet-events-sx8yq6zw/probe-claude-stream.py
python3 /private/tmp/notch-pet-events-sx8yq6zw/probe-panes.py
```

The provider scripts need permission to bind a loopback listener.
The pane script needs Otty socket and macOS URL-dispatch access.
They isolate configuration using the tools' designated configuration-directory settings; they do not change the user's configuration directories.

The first pane-list attempt failed inside the sandbox with `Operation not permitted`.
An approved retry succeeded. This was an access restriction, not an absent Otty instance.
An early Codex check tried to archive an ephemeral thread and received `no rollout found`.
The successful check used temporary persisted threads outside the repository instead.
The first macOS URL rerun reused stale temporary captures; clearing those two files corrected the probe.

Pass evidence:

- `probe-agents.py`: three completed Codex scenarios; three Claude print scenarios exited `0`.
- `probe-claude-stream.py`: denied-write and answered-question scenarios returned successful final responses; denied file absent.
- Both agents dispatched seven distinct hook event types across successful scenarios.
- `probe-panes.py`: all identity, same-folder, correct-focus, macOS URL, and closed-pane checks passed; exit `0`.
- Configuration fingerprints matched after the probes.

Not checked: usage sources, account modes, full interactive TUI behavior, abrupt termination, MCP elicitation,
notification timing, hostile input bounds, app-unavailable delivery, and full sleep/restart behavior.
Those limits do not change the approved scope or settle the proposed transport.
