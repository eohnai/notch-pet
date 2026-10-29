# Usage

Owns supported provider allowance reads, forwarding, freshness, account boundaries, and usage presentation in the notch.
Code: usage services in `Sources/SessionState/`, `Sources/NotchPet/NotchUsageView.swift`, and future forwarding helper code.

## Specs

- [`codex-allowance`](codex-allowance.md): Read real Codex allowance and show it for active Codex sessions, including the shared usage store. Needs: notch/session-island.
- [`claude-allowance`](claude-allowance.md): Forward real Claude allowance while preserving terminal output and cancellation. Needs: codex-allowance.
- `refresh-recovery`: Handle stale data, sparse updates, account changes, disconnects, and bounded retries. Needs: codex-allowance, claude-allowance.

## Shared context

- [Record layout decision](../../decisions/0011-organize-records-by-feature.md).
- [Source specification](../notch-companion.md): preserve the completed usage-source investigation and U1–U6 tasks and evidence.
- [Accepted provider sources](../../decisions/0007-read-supported-usage-data.md).
- [Terminal independence](../../decisions/0012-support-terminal-independent-operation.md) requires supported allowance reads and forwarding without Otty or navigation metadata.
- Preserve provider-source limits and terminal output. Terminal independence does not establish support for every shell, IDE, or remote environment.
- Implemented: shared usage store, Claude and Codex parsers, bounded read-only Codex protocol/process connection, private usage sender/receiver, and active-provider notch sections.
- Completed parser/transport tasks: U2a, U2c1, U2c2, U3a, U3b1. Preserve their checked states.
- U1, U3b2, and U5 have implementation or earlier evidence but remain unchecked in the source spec. Review evidence before changing their states.
- App receiver startup/shutdown wiring is unfinished and unverified in two existing uncommitted source files. Preserve it during planning.
- Claude forwarding and live verification remain incomplete. Installed configuration changes need a reversible plan and explicit approval.
- Migrate U1, U3a–U3b2, and Codex U5/U6 coverage into codex-allowance. Migrate U2 and Claude U5/U6 coverage into claude-allowance.
- U3c, U4, and failure/reconnect/account-switch U6 coverage belong to refresh-recovery.
- Claude depends on the shared usage foundation delivered by codex-allowance, not on a Codex account or active Codex session.
- No credentials, private endpoints, token-based estimates, or agent turns for quota refresh.

## Open questions

- Review U3b2 evidence before ticking it. Existing sockets have no crash-stale endpoint recovery.
