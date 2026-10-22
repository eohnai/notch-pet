# 0003: Store local state without a database

- Status: accepted
- Date: 2026-10-22

## Context

The first version needs live status, saved preferences, custom images, and current usage snapshots.
The user questioned whether a database was necessary. Searchable history has not been requested.

## Options

- **Memory, UserDefaults, and files**: fits current data with little setup; does not support structured history queries.
- **SQLite**: supports indexed history and analytics; requires a schema, migrations, and retention rules.

## Decision

Use no database for the first version.
Keep live state in memory, preferences in UserDefaults, and assets in Application Support.
Any later JSON usage cache must include local receipt time and any available source measurement time.
The user approved this recommendation on 2026-10-22. This decision does not require a usage cache.

## Reasoning

Current requirements need no history queries. SQLite would add schema and migration work.
The user approved this reason during architecture review.

## Consequences

Restart recovery uses fresh session evidence rather than treating saved status as live.
Keep runtime files, imported packs, and captured session data outside the repository.
Local receipt time does not establish when a provider measured usage.
Revisit SQLite if the user requests persistent session history or usage analytics.

