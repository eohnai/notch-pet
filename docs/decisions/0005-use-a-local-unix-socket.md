# 0005: Deliver local events through a Unix-domain socket

- Status: proposed
- Date: 2026-10-22

## Context

Short-lived hook commands need to deliver events to a running macOS app.
A Unix-domain socket connects local processes through a filesystem endpoint.
The hook must not wait indefinitely when the app is unavailable.

## Options

- **Unix-domain socket and helper**: local delivery without allocating a TCP port; needs message framing and socket lifecycle handling.
- **Loopback HTTP**: easy to inspect with common tools; requires port allocation and local request authorization.
- **File spool**: can retain events while the app is down; requires cleanup, deduplication, and stale-event rules.

## Decision

Open. Recommend a small helper and a user-scoped Unix-domain socket.
Define message limits, access permissions, timeouts, and disconnected behavior before implementation.

## Reasoning

A local macOS-only app does not need a network listener for hook events. ^[inferred]

## Consequences

Delivery failure must not grant permission, alter agent decisions, or delay normal agent operation indefinitely.
The initial design may lose events while the app is closed; represent unknown state honestly after restart.

