# 0008: Use conservative event ordering without persistent helper state

- Status: accepted
- Date: 2026-10-22

## Context

Hook processes send separate observations without a verified total source order.
The app must distinguish sessions and avoid displaying conflicting observations as current.
The accepted transport can lose messages while the app is closed.

## Options

- **Conservative observations**: use source identities and bounded local observations; show unknown when evidence conflicts.
- **Persistent sequence numbers**: coordinate hook processes through runtime state; adds locking and recovery without proving source order.

## Decision

Use conservative observations without persistent helper sequencing or replay.
The user approved this approach after the explanation that uncertain ordering produces unknown state.
The [version-1 contract](../contracts/agent-events-v1.md) defines the fields, bounds, and state rules.

## Reasoning

The conversation selected the simpler first version and an explicit unknown state when order cannot be determined.
Persistent sequence numbers lost because they add coordination without establishing the agent's actual event order.

## Consequences

The app can omit an activity indication when observations conflict or expire.
Long-running sessions can become unknown without a verified heartbeat.
Repeated source session IDs after an observed end cannot become working without additional lifecycle evidence.
Bridge and store tests must preserve these limits rather than inventing source ordering.
Revisit this choice when a verified source sequence or lifecycle identity becomes available.
