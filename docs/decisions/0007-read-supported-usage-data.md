# 0007: Read usage limits through supported interfaces

- Status: proposed
- Date: 2026-10-22

## Context

The user requested Claude Code and Codex limits in the companion.
Claude Code documents optional status-line rate-limit fields for eligible accounts.
Codex App Server documents account rate-limit reads and update notifications.
The installed-account behavior has not been verified.

## Options

- **Supported provider interfaces**: structured percentages and reset times; availability depends on account mode and interface version.
- **Private usage endpoints**: may expose additional information; add authentication handling and compatibility risk.
- **Token-based quota estimates**: easy to derive from some logs; do not establish actual remaining subscription allowance.

## Decision

Open. Recommend Claude Code status-line forwarding and a read-only Codex App Server usage connection.
Validate both approaches before promising particular windows or account modes.

## Reasoning

The user wants actual allowance information, which token totals alone cannot establish. ^[inferred]

## Consequences

Keep usage providers separate from session adapters. Never add an account allowance once per session.
Preserve existing status-line output. Label missing or old data explicitly.
Do not extract tokens, use private endpoints, or start agent turns to refresh usage.

## Sources

- [Claude Code status-line rate limits](https://code.claude.com/docs/en/statusline#rate-limit-usage)
- [Codex App Server account rate limits](https://learn.chatgpt.com/docs/app-server)

