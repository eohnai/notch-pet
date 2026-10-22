# 0007: Read usage limits through supported interfaces

- Status: accepted
- Date: 2026-10-22

## Context

The user requested Claude Code and Codex limits in the companion.
Claude Code documents optional status-line rate-limit fields for eligible accounts.
Codex App Server documents account rate-limit reads and update notifications.
Installed Codex returned real account quota windows without starting a thread or turn.
Claude Pro account eligibility and installed fields were checked. Live quota forwarding remains unverified.
Claude quota fields provide no stable account identity. Neither quota shape establishes a general provider measurement timestamp.

## Options

- **Supported provider interfaces**: structured percentages and reset times; availability depends on account mode and interface version.
- **Private usage endpoints**: may expose additional information; add authentication handling and compatibility risk.
- **Token-based quota estimates**: easy to derive from some logs; do not establish actual remaining subscription allowance.

## Decision

Use Claude Code status-line forwarding and a read-only Codex App Server usage connection.
Keep Claude observations separate and label them account unverified when supported identity is absent.
The user approved these recommendations on 2026-10-22.

## Reasoning

These interfaces report allowance fields in the investigated versions. Private endpoints would add credential handling and compatibility work.
Token totals do not establish subscription allowance. The user approved these reasons during architecture review.

## Consequences

Keep usage providers separate from session adapters. Never add an account allowance once per session.
Group only with supported account identity. Do not infer identity from a session, folder, model, or plan name.
Record local receipt time separately from source measurement time. A repeated payload or passed reset does not prove fresh quota.
Prefer the full Codex bucket map when present; its compatibility view is not another allowance.
Sparse Codex updates require merging available values or reading a full snapshot again.
Preserve existing status-line output. Label missing or old data explicitly.
Do not extract tokens, use private endpoints, or start agent turns to refresh usage.
Verify Claude output preservation and cancellation, Codex long-running coexistence, and account changes in their implementation tasks.

## Sources

- [Usage-source compatibility findings](../notes/usage-source-compatibility.md)
- [Claude Code status-line rate limits](https://code.claude.com/docs/en/statusline#rate-limit-usage)
- [Codex App Server account rate limits](https://learn.chatgpt.com/docs/app-server)

