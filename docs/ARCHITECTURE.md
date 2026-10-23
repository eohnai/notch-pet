# Architecture

## Accepted structure

Use Model-View-ViewModel (MVVM) for presentation, with separate services for integration and storage.
A view draws the interface. A view model prepares its state and handles user actions.
Models describe sessions, alerts, usage limits, and pets.
Services receive events, track state, open terminal panes, and access files.

The user accepted decisions 0002–0007 on 2026-10-22 after reviewing the compatibility findings.
SwiftUI and AppKit were already accepted in decision 0001.
Acceptance chooses the design; the compatibility records still define what has and has not been verified.

## Boundaries

| Part | Responsibility | Does not own |
|---|---|---|
| SwiftUI views | Notch content, pet, settings, usage display | Hook parsing and account access |
| View models | Presentation state and user actions | Independent copies of session truth |
| Session store | Authoritative session state and alert selection | Window placement |
| Agent adapters | Translate Codex and Claude Code events | Otty navigation |
| Terminal adapters | Return to a known pane or application | Agent lifecycle detection |
| Usage providers | Read supported quota sources and report freshness | Estimating limits from token counts |
| AppKit controllers | Window placement, focus, screen changes, dragging | Agent business rules |
| Preferences and pet services | Save preferences and validate local assets | Session history queries |

Both the notch and pet observe the same stores.
Window controllers remain small; view models do not become process managers.
Start with source folders in one project. Separate packages only when a real boundary needs independent reuse.

## Data flow

An agent event reaches a small local helper through a configured hook.
The helper sends a bounded message to the app through the chosen local transport.
An agent adapter converts it to a shared event.
The session store applies the event once and publishes updated presentation state.
The notch and pet reflect that state.
A click asks the terminal adapter to focus the recorded pane.

Usage providers send account snapshots to a separate usage store.
They do not create agent lifecycle events or start agent turns.

## Data without a database

| Data | Storage | Reason |
|---|---|---|
| Active sessions and alerts | Memory | They describe live processes |
| Size, selected pet, sounds, placement | `UserDefaults` | Small preference values |
| Imported pets and manifests | Application Support files | Images already use files |
| Optional later usage cache | Small JSON file in Application Support | Must retain receipt time, source measurement time if supplied, and a stale label |
| Credentials | Existing provider-managed authentication | The app does not copy tokens |

Do not persist a session as still working after the app restarts without fresh evidence.
Use SQLite later only if searchable history or persistent analytics becomes a requirement.
Adding quota display alone does not require a database.
Keep runtime files, imported packs, and captured session data outside this repository.

## Accepted decisions

| Choice | Accepted approach | Alternative and tradeoff |
|---|---|---|
| Presentation structure | MVVM plus services and shared stores | View-owned state is quicker initially, but duplicates session state |
| Persistence | Memory, preferences, and files | SQLite supports history queries, but adds schemas and migrations |
| Event source | Official agent hooks | Transcript reading catches other details, but depends on changing formats |
| Local event delivery | Unix-domain socket and small helper | Localhost HTTP is easier to inspect, but needs port management |
| Custom pet format | JSON manifest and transparent PNG frame sequences | Sprite atlases reduce file count, but are harder to author |
| Usage source | Provider-supported interfaces | Private endpoints may expose more data, but add authentication and compatibility work |

No dependency-injection framework, event broker, backend service, or web account is needed for this scope.
Pass service dependencies explicitly. Keep the first version small.

Local delivery can lose events while the app is closed. Do not replay unverified activity as live state after restart.
The [version-1 event contract](contracts/agent-events-v1.md) defines message fields, bounds, and ordering before bridge implementation.
[Decision 0008](decisions/0008-define-event-ordering.md) records conservative ordering without persistent helper state.

## Local app shell

The first executable is a dependency-free Swift package targeting macOS 13 or later with Swift 6 tools.
`NotchPetApp` owns the SwiftUI `MenuBarExtra` scene. Its private `CompanionMenu` presents status and Quit.
Quit calls AppKit's application termination action. The bundle's `LSUIElement` flag keeps it out of the Dock.
`bash scripts/run.sh` builds and launches a development app bundle under the user's temporary directory.
This keeps build products outside the repository and works with installed Command Line Tools.
This is a local development launch path; distribution packaging remains a later task.

## State and attention rules

- Identify sessions by agent and source session identifier, rather than project folder alone.
- Keep pane identity separate from session identity.
- Validate inherited Otty pane selectors against live state. Ambiguous matches make pane navigation unavailable.
- Include event identity, source ordering where available, and observation time in the event contract.
- Define rules for duplicate events, delayed events, and restarted sessions before integrating the UI.
- Distinguish working, approval needed, response ready, failed, interrupted, ended, and unknown states.
- Claim a dedicated question state only when a verified source identifies it.
- Treat a finished response containing a question as response ready when no dedicated signal exists.
- Do not claim task success from a stop event.
- Give unresolved input requests priority over response-ready notices.
- Keep every session accessible when several need attention.
- Mark stale sessions unknown when their state cannot be confirmed.
- A stale Otty pane link may only activate Otty; never create a replacement session automatically.

The version-1 contract specifies these requirements as provisional observations with a two-minute freshness limit.
Unknown state retains unresolved requests as unconfirmed notices.
It does not support working-state recovery after an observed end reuses the same source session ID.
The bridge is implemented in the shared `EventBridge` Swift target.
`NotchPetHook` projects raw hook input and makes one bounded delivery attempt.
`BridgeAppDelegate` starts the receiver and stops it during normal app termination.
The receiver hands validated envelopes and receipt times to a callback on its worker queue.
The app now owns one observable `SessionStore` in the `SessionState` target.
`SessionObservationV1.init(received:)` maps the seven accepted hooks into shared event meanings.
This mapping implements the version-1 contract. It does not verify provider compatibility or install agent hooks.
The separate Codex and Claude adapter tasks still own provider coverage and live integration checks.

`SessionEventInbox.receive(_:)` enqueues observations without waiting for the main actor.
The inbox retains at most 128 queued observations and schedules one drain at a time.
One active batch can coexist with the next queued batch.
Each batch preserves enqueue order. Receipt order does not prove source order.
An overflow drops excess observations and makes all nonterminal sessions unknown after applying the retained batch.
This avoids retaining an unbounded UI queue or claiming complete evidence after a local drop.

The main actor serializes store changes and publishes immutable `SessionSnapshot` values.
The store checks delivery age, duplicate identity, ordering, requests, freshness, and the accepted memory limits.
It retains SHA-256 digests for event comparisons instead of complete old envelopes.
Source identities compare UTF-8 bytes so distinct Unicode forms cannot merge sessions, turns, or requests.
Snapshots retain project paths and unverified pane hints only from compatible observations.
Unknown sessions expose pending requests as unconfirmed notices.
Recovery requires a different, previously unseen turn identity with no unresolved requests.
An observed end retains its terminal restriction for the app run.

`SessionStore.apply(_:)` applies one normalized observation.
`applyBatch(_:observationsLost:wallMs:monotonicNs:)` expires delayed observations before publishing the batch.
`advance(monotonicNs:)` checks expiry. `checkClocks(wallMs:monotonicNs:)` also checks clock continuity.
Backward clock samples and wall/monotonic elapsed-time differences above two seconds invalidate nonterminal observations.
New evidence after a monotonic reset uses deadlines in the new clock range.
The app checks clocks during receipt and schedules a timer while fresh observations exist.
The timer checks after one second or at the nearest expiry, whichever comes first.
An empty or entirely unknown store has no expiry timer.
Sleep, wake, and system clock notifications invalidate live observations and exclude earlier queued receipts.
`invalidateClocks()` retains unresolved notices and terminal restrictions.
These injected lifecycle checks do not establish physical sleep/wake or window recovery behavior on the target Mac.

The app holds a user-owned `listener.lock` file while it owns the socket.
It never removes the lock file, which prevents separate processes from locking different replacement files.
It recovers only an owned socket whose connection is refused and whose file identity remains unchanged.
Shutdown checks that identity before removing its socket.
These checks coordinate local instances within the accepted same-user boundary; they do not authenticate an agent.
Runtime files remain under `/private/tmp/notch-pet-<uid>/`.

## Limits display

- Keep context usage, token usage, subscription allowances, and API rate limits separate.
- Show only windows returned by the provider. Do not assume Codex always uses five-hour and weekly windows.
- Label percentages explicitly as used or remaining.
- Retain the source timestamp and reset timestamp for each window.
- Mark cached observations stale. A reset time passing does not prove a new allowance value.
- Account allowance is shared across sessions; never add the same allowance across panes.
- Keep snapshots isolated by provider and account when identity is available.
- Do not combine sessions into an account total when account identity cannot be established.
- Keep Claude observations separate and label them account unverified when supported identity is absent.
- Record local receipt time separately from provider measurement time, which the investigated quota shapes do not establish.
- Repeated status-line delivery does not prove a fresh provider measurement.
- Prefer Codex's full bucket map when present; do not count its compatibility view as another allowance.
- Merge sparse Codex updates into a full snapshot, or read a new full snapshot.
- Preserve the user's existing Claude Code status-line output when adding a forwarding wrapper.
- Use bounded refreshes with backoff; avoid frequent account requests while idle.

## Desktop behavior to settle

- Start with the built-in MacBook display. Test an external display and display removal before release.
- Define fullscreen and Space behavior through supported AppKit window behavior.
- Provide a menu-bar control when the overlay is hidden or inaccessible.
- Keep inactive transparent regions from intercepting normal clicks.
- Pause unnecessary animation when hidden or asleep, and support Reduce Motion.
- Clamp saved placement to a connected display after resolution changes.
- Treat pet packs as data. Reject invalid paths and oversized image sets.
- Keep routine logs bounded and exclude prompts, command contents, and credentials by default.
- Preserve unrelated hooks and status-line settings during setup and removal.

## Verified documentation and remaining checks

Checked on 2026-10-22. Documentation establishes interfaces; it does not prove this app's integration works.

- [Codex hooks](https://learn.chatgpt.com/docs/hooks) documents `PermissionRequest`, `Stop`, session identifiers, and hook trust.
- [Claude Code hooks](https://code.claude.com/docs/en/hooks) documents approvals, response stops, and notification types with different timing.
- [Otty pane links](https://docs.otty.sh/reference/url-scheme) documents `OTTY_PANE_ID` and `otty://pane/<id>` navigation.
- [Otty setup](https://docs.otty.sh/getting-started/first-launch) describes existing agent hook installation.
- [Claude Code status lines](https://code.claude.com/docs/en/statusline#rate-limit-usage) expose eligible accounts' usage percentages and reset timestamps.
- [Codex App Server](https://learn.chatgpt.com/docs/app-server) documents `account/rateLimits/read` and rate-limit update notifications.

The [event compatibility record](notes/agent-event-compatibility.md) verifies controlled hook dispatch and fresh Otty pane navigation.
It also records a stale inherited pane selector. Normal interactive Otty event behavior remains unverified.
The [usage-source record](notes/usage-source-compatibility.md) verifies short read-only Codex quota reads without conversations.
Claude eligibility and installed fields were checked; live forwarding and output preservation remain unverified.
Later adapter tasks must check interactive behavior, abrupt process loss, and hook trust.
Later usage tasks must check long-running coexistence, account changes, and Claude forwarding behavior.
Unsupported account modes remain explicit limitations. Do not introduce private endpoint fallbacks.

