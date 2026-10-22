# 0004: Receive lifecycle events through agent hooks

- Status: proposed
- Date: 2026-10-22

## Context

The first supported agents are Codex CLI and Claude Code in Otty.
Both document lifecycle hooks. Exact payload coverage still needs local verification.
Otty can also install agent hooks, so configuration must coexist.

## Options

- **Agent hooks**: structured events with session context; availability varies by event and agent version.
- **Transcript reading**: exposes additional recorded details; file formats and timing can change.
- **Terminal output parsing**: works without hook configuration; visual output is a fragile state interface.
- **Launching all sessions through a wrapper**: controls session metadata; changes the user's normal launch workflow.

## Decision

Open. Recommend hooks first, with explicit source-coverage limitations.
Use separate adapters for agent events and terminal navigation.

## Reasoning

The user's existing terminal workflow favors integration without replacing their session host. ^[inferred]

## Consequences

Do not promise detection of arbitrary natural-language questions.
Document gaps before implementing adapters. Preserve existing configuration during setup and removal.

