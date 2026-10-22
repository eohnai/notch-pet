# Architecture proposal

## Recommendation

Use Model-View-ViewModel (MVVM) for presentation, with separate services for integration and storage.
A view draws the interface. A view model prepares its state and handles user actions.
Models describe sessions, alerts, usage limits, and pets.
Services receive events, track state, open terminal panes, and access files.

This recommendation is proposed. SwiftUI and AppKit are the only accepted technology choices so far.

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

| Data | Proposed storage | Reason |
|---|---|---|
| Active sessions and alerts | Memory | They describe live processes |
| Size, selected pet, sounds, placement | `UserDefaults` | Small preference values |
| Imported pets and manifests | Application Support files | Images already use files |
| Optional last usage snapshot | Small JSON file in Application Support | Useful after restart, with a stale label |
| Credentials | Existing provider-managed authentication | The app does not copy tokens |

Do not persist a session as still working after the app restarts without fresh evidence.
Use SQLite later only if searchable history or persistent analytics becomes a requirement.
Adding quota display alone does not require a database.

## Decisions to review

| Choice | Recommendation | Alternative and tradeoff |
|---|---|---|
| Presentation structure | MVVM plus services and shared stores | View-owned state is quicker initially, but duplicates session state |
| Persistence | Memory, preferences, and files | SQLite supports history queries, but adds schemas and migrations |
| Event source | Official agent hooks | Transcript reading catches other details, but depends on changing formats |
| Local event delivery | Unix-domain socket and small helper | Localhost HTTP is easier to inspect, but needs port management |
| Custom pet format | JSON manifest and transparent PNG frame sequences | Sprite atlases reduce file count, but are harder to author |
| Usage source | Provider-supported interfaces | Private endpoints may expose more data, but add authentication and compatibility work |

No dependency-injection framework, event broker, backend service, or web account is proposed.
Pass service dependencies explicitly. Keep the first version small.

## State and attention rules

- Identify sessions by agent and source session identifier, rather than project folder alone.
- Keep pane identity separate from session identity.
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

## Limits display

- Keep context usage, token usage, subscription allowances, and API rate limits separate.
- Show only windows returned by the provider. Do not assume Codex always uses five-hour and weekly windows.
- Label percentages explicitly as used or remaining.
- Retain the source timestamp and reset timestamp for each window.
- Mark cached observations stale. A reset time passing does not prove a new allowance value.
- Account allowance is shared across sessions; never add the same allowance across panes.
- Keep snapshots isolated by provider and account when identity is available.
- Do not combine sessions into an account total when account identity cannot be established.
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

Verify hook payloads and pane identity on the installed versions.
Verify a read-only Codex usage connection alongside normal CLI sessions without starting a conversation.
Verify Claude Code status-line forwarding without replacing existing output.
Record unsupported account modes explicitly rather than using private endpoint fallbacks.

