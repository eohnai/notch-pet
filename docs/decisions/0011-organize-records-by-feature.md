# 0011: Organize project records by area and feature

- Status: accepted
- Date: 2026-10-29

## Context

The single companion specification contains several independently reviewable features.
The user asked whether features had separate specs, then approved five areas and their feature lists.
The user explicitly required implemented features to appear alongside planned work.

## Options

- **Keep one specification:** preserves the existing layout, but combines independent features and acceptance checks.
- **Use areas and feature specs:** supports one reviewable feature per spec, but requires careful migration of tasks and evidence.

## Decision

Use `sessions`, `notch`, `usage`, `actions`, and `pets` areas under `docs/specs/`.
Include implemented and planned features. This replaces the earlier single-spec preference.

## Reasoning

The user requested the one-spec-per-feature structure and preservation of implemented features.

## Consequences

Area files list features in build order. `plan-feature` creates their specifications and migrates existing tasks and evidence.
Preserve task IDs, checkbox states, blocked reasons, and historical verification evidence.
Implementation without completed verification must remain unchecked.
Keep the original specification as the task source until migration is complete.
Do not rename or delete it without confirming the final move with the user.
No code changes, goal resumption, commits, or pushes follow from this decision.
