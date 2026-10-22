# 0004: Receive lifecycle events through agent hooks

- Status: accepted
- Date: 2026-10-22

## Context

The first supported agents are Codex CLI and Claude Code in Otty.
Controlled checks verified approval, response-stop, structured-question, and graceful-end hooks in both installed agents.
Normal interactive Otty sessions, interruption, and abrupt process loss remain unverified.
Otty can also install agent hooks, so configuration must coexist.

## Options

- **Agent hooks**: structured events with session context; availability varies by event and agent version.
- **Transcript reading**: exposes additional recorded details; file formats and timing can change.
- **Terminal output parsing**: works without hook configuration; visual output is a fragile state interface.
- **Launching all sessions through a wrapper**: controls session metadata; changes the user's normal launch workflow.

## Decision

Use official agent hooks, with explicit source-coverage limitations.
Use separate adapters for agent events and terminal navigation.
The user approved this recommendation on 2026-10-22.

## Reasoning

Controlled checks verified relevant structured events. Transcript and terminal parsing would add format dependencies.
The user approved this reason during architecture review.

## Consequences

Do not promise detection of arbitrary natural-language questions.
Classify structured-question tools separately from command approvals. A response stop does not prove task success.
Use agent plus source session ID for sessions. Keep pane identity separate and validate it against live Otty state.
Ambiguous or stale pane identity makes navigation unavailable. Missing lifecycle evidence can leave a session unknown.
Preserve existing configuration during setup and removal. Respect Codex hook trust review; do not install a trust bypass.

## Evidence

See the [event compatibility record](../notes/agent-event-compatibility.md) for checked versions, payload shapes, and remaining checks.

