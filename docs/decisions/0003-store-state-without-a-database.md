# 0003: Store local state without a database

- Status: proposed
- Date: 2026-10-22

## Context

The first version needs live status, saved preferences, custom images, and current usage snapshots.
The user questioned whether a database was necessary. Searchable history has not been requested.

## Options

- **Memory, UserDefaults, and files**: fits current data with little setup; does not support structured history queries.
- **SQLite**: supports indexed history and analytics; requires a schema, migrations, and retention rules.

## Decision

Open. Recommend no database for the first version.
Keep live state in memory, preferences in UserDefaults, and assets in Application Support.
An optional JSON usage cache must include its observation time.

## Reasoning

The requested data does not need historical queries or relational joins. ^[inferred]

## Consequences

Restart recovery uses fresh session evidence rather than treating saved status as live.
Revisit SQLite if the user requests persistent session history or usage analytics.

