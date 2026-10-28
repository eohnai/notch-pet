# Flux Island reference findings and adoption plan

Date: 2026-10-28

## Scope and evidence

The user requested a comparison with the Flux Island installed on this Mac, accepted retaining SwiftUI/AppKit,
and then requested specification changes that adapt useful Flux behavior while preserving this app's strengths.
This note supports the [revised companion specification](../specs/notch-companion.md).
The user subsequently accepted local approvals and replies and designated SSH/cloud support as optional future work;
[decision 0010](../decisions/0010-add-local-agent-actions.md) records that scope expansion.
It records behavioral observations and recommendations, not a license assessment, copied implementation, or runtime benchmark.

The inspected installation was `/Applications/Flux Island.app`, version `0.1.25`,
bundle identifier `com.bytedance.flux.desktop`, from `Contents/Info.plist`.
Its `Contents/Resources/app.asar` SHA-256 was
`25bf9e27fb025668d193f8323b5151bfbc37d62b2bd87bae8101cabf41f8e758`.
Selected packaged JavaScript was inspected through a temporary extraction outside this repository.
No app was launched, no user configuration or credentials were read, and no performance or end-to-end compatibility check was performed.
No packaged source, internal artwork, or captured session content is included in this repository.

References below name entries inside that archive and their inspection-time line numbers.
The extraction is temporary and is not a build input. A later Flux version may differ.

## Observed behavior worth adapting

### Reversible setup and useful connection health

`out/main/index.js` contains `ClaudeHookManager` around line 41475 and `CodexHookManager` around line 42316.
They implement installation/removal, app-managed configuration, manifests, and integration checks.
Claude quota setup includes an existing-status-line wrapper; Codex setup also manages feature/trust configuration.

Adapt installation ownership, idempotence, removal that preserves other settings, and actionable health messages.
Retain our explicit hook trust review; do not import trust-bypass behavior or assume Flux's version gates apply to the installed agents here.
Separate configured, receiver available, and delivery observed so a quiet session is not mislabeled disconnected.
Tasks I2–I6 cover this work. It does not require expanding our one-way event protocol.

### Session picker and window behavior

`IslandWindow` around line 24828 creates a transparent Electron window, uses all-workspace/fullscreen visibility,
mouse passthrough, and a native `fixPanel` helper.
`PetWindow` around line 25462 owns a separate transparent pet surface.
`enterPetMode` around line 59404 sends the current visible sessions to the pet;
`tryReturnToIsland` around line 59430 returns it when pet and notch rectangles overlap.

Adapt the accessible session picker, retained selection, transparent inactive regions, drag-out/overlap-return interaction,
and a menu-bar recovery action. Implement those behaviors using supported SwiftUI/AppKit APIs and the existing shared stores.
Do not assume Electron's native helper implementation or window constants transfer to AppKit.
Tasks I1, N1–N6, P1–P2, and R1–R4 cover the visible workflow and physical desktop checks.

### Local approvals and replies

Flux's `BridgeServer` around line 39135 supports pending questions/permissions and directives returned to hooks.
`approveSession` around line 59935 supports selected modes; terminal-native/cloud modes have different handling.
`answerSession` around line 59971 returns structured answers.
The renderer's `canContinueSessionViaTerminalPrompt` supports follow-up text only for selected local terminal/session combinations.

The user accepted adapting the ability to act inside the app: approve once/deny, answer a question, and explicitly send follow-up text.
Tasks A1–A8 verify our providers' mechanisms before choosing the action-channel structure and implementing those controls.
This does not establish feature parity with every Flux adapter or authorize terminal keystroke injection as a fallback.
Keep our lifecycle helper one-way and bounded; interaction has a separate identity/acknowledgement/cancellation contract.

### Optional sprite-sheet compatibility

`out/renderer/assets/pet-H4m9z7If.js` around lines 31–38 defines seven rows:
`idle`, `play`, `sleep`, `running`, `attention`, `complete`, `drag`.
Around line 127 it derives square cells from image height divided by seven;
around line 136 it samples alpha to locate each row's final frame.
The main bundle's sprite path logic around line 61256 supports a user-supplied PNG override.

Adapting that input layout can make user-authored artwork easier to import. ^[inferred]
It does not require using Flux's artwork or replacing our accepted manifest/frame runtime format.
The proposed choice is conversion at import versus a second runtime loader; it remains open in the spec.
Define full validation, deterministic frame detection, resource bounds, and rollback independently.
Tasks P5–P6 cover the choice and conditional implementation, with independently created fixtures.

### Independent quota refresh

`QuotaService` around line 47476 uses a Codex App Server connection, update notifications, retries, and refresh scheduling.
`CodexAppServerClient.start` around line 47319 opens a stdio App Server connection.
`loadClaudeQuota` around line 47104 reads a status-line cache; the Claude wrapper is managed separately.
Flux also has token statistics, separate from quota, in `StatsService` around line 30665.

Adapt independent refresh/cancellation/reconnect/backoff and preserving the user's status-line output.
Retain our supported-interface restriction, full bucket map, separate account confidence and timestamps, and explicit stale/unavailable states.
Flux's inspected quota normalization uses daily/weekly slots and transcript fallback; those are not additions to our plan.
Tasks U1–U6 cover the compatible behavior without conversation turns, credential copying, or private endpoints.

## Existing choices to retain

- **Native presentation:** SwiftUI/AppKit remains accepted after considering Electron/React. This choice alone does not prove better CPU or memory usage.
- **Separate responsibilities:** agent adapters, terminal navigation, usage providers, shared stores, and window controllers remain distinct. Both surfaces use one session authority.
- **Bounded observation delivery:** both apps use Unix sockets and newline JSON, but our existing helper keeps one-way, bounded, silent observations. New user actions require a separate verified response mechanism and contract.
- **Conservative evidence:** preserve event identity/order checks, bounded memory, unknown state, retained unconfirmed requests, and terminal restrictions. Missing events cannot establish completion.
- **Content minimization:** lifecycle integration continues to forward allowlisted metadata without prompts, command input, transcript reading, or credential inspection. Necessary request details and user replies remain transient action data outside routine logs.
- **Otty first:** exact-pane validation is a primary release requirement. The inspected Flux main bundle had no `otty` match; that establishes no explicit adapter there, not proof that every generic fallback fails.
- **Simple storage:** sessions stay in memory, preferences in UserDefaults, assets in Application Support. Quota display does not introduce a database.
- **Local scope:** local approvals and replies are now included. SSH/cloud integrations are optional future work; terminal keystroke injection and Feishu forwarding remain excluded.

## Behaviors not adopted

Do not adopt Flux's entire control protocol or assume action support from observed lifecycle hooks.
The accepted scope expansion adds user-facing local actions; its response-channel design and supported combinations still require A1–A2 verification.

Flux's `ClaudeTranscriptWatcher` around line 37652, `ProcessMonitor` around line 48028,
and reconciliation around line 60899 supplement hooks with transcripts, process checks, and timeout heuristics.
In the inspected paths, quiet Claude sessions can become completed after 120 seconds and certain Codex sessions after 180 seconds.
Those fallbacks are not adopted: silence and process existence do not establish an agent response or task result.
Any future source of additional lifecycle evidence needs a separate compatibility investigation and contract decision.

Flux writes recent session snapshots through `saveSessions` around line 40862, but calls `saveSessions([])` at startup around line 58972.
The inspection therefore does not establish restoration of old snapshots into live sessions.
Our restart behavior continues to require fresh evidence.

## Planning outcome

The spec retains the user's existing single-spec layout and completed foundation tasks.
Remaining work is grouped into bridge verification, setup/visible sessions, Otty/notch, local actions/replies, pet imports, usage, and desktop acceptance.
New tasks are proposed for review; choosing to update the plan does not complete verification or accept the open sprite-format choice.
The helper maximum-input/deadline failure remains the first implementation blocker.
The earlier reference-model and socket-boundary test corrections remain separate proposed follow-ups.
