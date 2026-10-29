# 0013: Settle standalone pet scope and packaging

- Status: proposed
- Date: 2026-10-30

## Context

The user identified people who want a pet without agentic coding.
They asked whether the pet should be a separate service or project.
The current pet plan depends on notch session presentation. Pet rendering is not implemented.
The user has not selected a packaging approach or standalone behavior requirements.

## Options

- **One app with a separate pet module and optional agent features:** share installation and releases, but keep coding setup optional.
- **Two apps sharing a pet module:** give each audience a focused app, but maintain two release paths.
- **Separate pet project or repository:** permit independent maintenance, but add coordination for shared integration changes.
- **Separate background service:** let several apps control one pet, but add process communication and lifecycle handling.

## Decision

Open.

## Reasoning

The user's stated concern is serving people who do not use coding agents.
The assistant recommends one app with a separate pet module as a starting point. ^[inferred]
That would permit standalone use without adding a second process or release path. ^[inferred]
The recommendation is not an accepted architecture change.

## Consequences

Settle standalone behavior and packaging in P0 before revising the pet dependency graph.
If accepted, define normal pet behavior without agent events and optional mappings from agent state into pet presentation.
A proposed pet module would own animation, assets, interaction, placement, and preferences without importing agent session types.
Keep unknown agent state distinct from integrations being disabled.
Do not remove existing pet/session acceptance, create a service, or split repositories under this proposal.
