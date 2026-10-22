# 0002: Use MVVM with services and shared stores

- Status: proposed
- Date: 2026-10-22

## Context

The notch and detached pet must show consistent session state.
The user asked about MVVM and wants later support for other apps and terminals.

## Options

- **MVVM with services and shared stores**: keeps presentation and integrations separate; requires clear ownership between layers.
- **View-owned state**: quick for a small prototype; duplicates state when several windows need it.
- **A full unidirectional architecture framework**: formalizes effects and state transitions; adds a dependency and learning cost.

## Decision

Open. Recommend MVVM for presentation and services for integration, with one authoritative store for each shared data domain.

## Reasoning

Consistent state across the notch and pet favors shared ownership. ^[inferred]
Separate agent and terminal adapters support the user's stated extension goal. ^[inferred]

## Consequences

View models prepare state and accept actions. They do not parse hooks or manage account processes.
Start with explicit dependencies rather than a framework for dependency injection.

