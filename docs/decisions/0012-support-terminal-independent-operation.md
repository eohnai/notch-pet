# 0012: Support terminal-independent operation

- Status: accepted
- Date: 2026-10-30

## Context

The original release plan targets Codex CLI and Claude Code in Otty.
The user explicitly requested terminal-independent operation and asked to update the specs.
The event contract already permits observations without terminal metadata.
Its optional navigation metadata currently supports only Otty.

## Options

- **Require Otty:** retain the original navigation scope, but exclude users of other terminals.
- **Separate monitoring from terminal navigation:** accept supported agent events without terminal identity and add optional navigation adapters.
- **Promise exact-pane navigation in every terminal:** offers uniform behavior, but has no verified compatibility evidence.

## Decision

Require terminal-independent agent monitoring and pet reactions.
Treat Otty as one optional navigation integration, not an installation or runtime prerequisite.
Report exact-pane navigation, application activation, and unavailable navigation separately.

This updates the terminal-specific release scope associated with decisions 0004 and 0010.
Their hook-observation, provider-action, trust, and targeting requirements remain in force.

## Reasoning

The user does not want the app to require Otty.
Universal exact-pane navigation was not selected because terminal capabilities remain unverified.

## Consequences

Missing terminal metadata or navigation support must not block receipt, session state, alerts, pet reactions, or supported allowance reads.
Never require an Otty executable or pane selector for those capabilities.
Only expose navigation after an adapter verifies the target or application.
Otherwise explain that navigation is unavailable and let the user return manually.
Action availability depends on verified provider channels, not on terminal navigation availability.

Preserve the version-1 wire contract and all historical Otty evidence and deferred checks.
Plan any additional terminal metadata separately before changing the contract.
Verify both supported agents in at least one local terminal other than Otty before claiming terminal-independent release acceptance.
This decision establishes a requirement, not verified compatibility with every terminal, IDE, or remote environment.
