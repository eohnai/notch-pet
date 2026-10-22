# Notch companion for terminal coding agents

## Goal

Show when Codex CLI or Claude Code in Otty needs attention on the user's M2 MacBook Air.
Let a customizable pet move between the notch and desktop while sharing the same session state.
Show reported usage limits and reset times so the user can monitor available allowance.

## Done when

- A local SwiftUI/AppKit app launches with a menu-bar control and notch interface on the user's Mac.
- An approval request from each supported agent appears with the correct agent, project, and session.
- Each agent's finished response produces a response-ready notice without claiming the task succeeded.
- Dedicated input events are shown where verified; uncovered question types have documented limitations.
- Alerts from two concurrent sessions remain distinct, including sessions in the same project.
- Clicking each live-session alert focuses its recorded Otty pane.
- Closing a pane or restarting the app cannot present an unverified session as still working.
- The user can drag the pet onto the desktop and return it to the notch.
- A valid custom pet imports and responds to working, attention, response-ready, and idle states.
- A missing optional animation falls back safely; an invalid pet pack leaves the selected pet intact.
- Pet selection, size, sound preference, and valid placement survive an app restart.
- Both providers show real usage percentages and reset times for verified supported account modes.
- The compatibility record identifies modes without usage data; those modes show unavailable with a reason.
- Usage windows show freshness and used/remaining labels, and are not double-counted across sessions.
- Setup and removal preserve existing Otty hooks, unrelated agent settings, and Claude Code status-line output.
- App unavailability cannot auto-approve a tool or leave the terminal waiting indefinitely for this app.
- Documented checks cover sleep, wake, fullscreen, Space changes, external-display removal, and Reduce Motion.
- A five-minute idle profile and an animated-pet profile record CPU and memory measurements on the target Mac.

## Out of scope

- Entering replies, approving commands, or sending keystrokes through the island.
- Codex desktop, other coding apps, other terminals, SSH hosts, and remote computers in the first release.
- A cloud backend, user accounts, synchronization, searchable session history, or a pet marketplace.
- In-app artwork generation, a pet drawing editor, three-dimensional pets, and scripted pet plugins.
- Reading private usage endpoints, copying provider tokens, or estimating subscription quota from tokens.
- Guaranteed notification of arbitrary questions without a verified event source.
- Reuse of Flux Island code or internal assets. The user withdrew that reference.

## Decisions

- [0001: Use SwiftUI and AppKit](../decisions/0001-use-swiftui-and-appkit.md) — accepted.
- [0002: Use MVVM with services and shared stores](../decisions/0002-use-mvvm-with-services.md) — proposed.
- [0003: Store local state without a database](../decisions/0003-store-state-without-a-database.md) — proposed.
- [0004: Receive events through agent hooks](../decisions/0004-receive-agent-hook-events.md) — proposed.
- [0005: Deliver events through a Unix socket](../decisions/0005-use-a-local-unix-socket.md) — proposed.
- [0006: Import asset-only pet packs](../decisions/0006-import-asset-only-pet-packs.md) — proposed.
- [0007: Read usage through supported interfaces](../decisions/0007-read-supported-usage-data.md) — proposed.

## My calls

- Use `notch-pet` as a working name and a separate local Git repository.
- Keep project records in `docs/` because this is a single repository.
- Use `planning/initial-scope` as the initial branch. Create no remote or commits.
- Include limits after the notification and pet foundations; retain both providers in the planned first release.
- Start with one selected pet, with custom artwork supplied through imports.
- Use response ready as the default completion label.
- Treat detailed colors, animation timings, usage layout, and performance budgets as prototype decisions.
- Track no deadline or assigned owner because the user supplied neither.

## Tasks

The user approved this scope and task list on 2026-10-22.
Proposed architecture records remain open for the scheduled decision task.
Each task should fit one work session; split it if the investigation shows otherwise.

- [x] Verify installed agent event coverage and Otty pane identity; save a compatibility matrix and sanitized example payloads.
- [ ] Verify both providers' usage sources and account-mode limitations without exposing credentials or starting agent turns.
- [ ] Settle proposed architecture records using the compatibility findings and user review.
- [ ] Add the native app shell with a menu-bar quit action and a reproducible local launch command.
- [ ] Specify the versioned event contract with session identity, ordering, freshness, and bounded payload behavior.
- [ ] Add the local event bridge with checks for malformed input and an unavailable app.
- [ ] Add the shared session store with checks for duplicate, delayed, concurrent, and terminal-state events.
- [ ] Add the Codex event adapter using verified hook coverage.
- [ ] Add the Claude Code event adapter using verified hook coverage.
- [ ] Add reversible hook setup that preserves existing Otty and agent configuration.
- [ ] Add the Otty navigation adapter with checks for correct-pane and closed-pane behavior.
- [ ] Add the notch view with session selection and unresolved-input priority.
- [ ] Add the detachable pet window with drag-out, return, and shared alert state.
- [ ] Add pet-pack validation with safe animation fallbacks and a documented example pack.
- [ ] Add settings persistence for pet selection, size, sound, and valid screen placement.
- [ ] Add Claude Code usage forwarding while preserving the existing status-line output.
- [ ] Add the read-only Codex usage provider using the verified connection method.
- [ ] Add the limits view with distinct windows, reset times, account grouping, and stale/unavailable states.
- [ ] Add window recovery for sleep, wake, fullscreen, Spaces, and display changes.
- [ ] Profile idle and animated operation on the M2 Air; address measured issues and Reduce Motion behavior.
- [ ] Verify the first-use workflow and document local packaging, supported versions, setup, removal, and known limits.

## Coverage check

Task 1 evidence: [compatibility matrix](../notes/agent-event-compatibility.md) and
[fictional payload examples](../notes/agent-event-examples.json).
Installed-agent runtime checks used a local mock provider. Full interactive Otty verification remains part of adapter and final workflow checks.

| Acceptance area | Tasks |
|---|---|
| Source feasibility and architecture | 1–3 |
| Local launch and event delivery | 4–6 |
| Honest session state and both agents | 7–9 |
| Reversible setup and terminal behavior | 10–11 |
| Session alerts and notch presentation | 12 |
| Pet interaction, imports, and preferences | 13–15 |
| Both providers' usage limits | 2, 16–18 |
| Desktop recovery and resource use | 19–20 |
| End-to-end acceptance and handoff | 21 |

