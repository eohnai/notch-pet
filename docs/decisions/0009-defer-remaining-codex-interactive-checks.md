# 0009: Defer remaining Codex interactive checks to final workflow verification

- Status: accepted
- Date: 2026-10-24

## Context

Partial interactive Codex checks cover the main event paths through the helper, bridge, inbox, and store.
Seven checks remain open in the [compatibility record](../notes/agent-event-compatibility.md#partial-interactive-codex-verification-2026-10-23).
Hook setup and visible session alerts are not implemented yet.

## Options

- **Finish the checks now**: resolve the gaps earlier through another isolated Otty probe session.
- **Defer the checks**: proceed with the Claude adapter and test the remaining paths before final workflow acceptance.

## Decision

Move the unchecked Codex interactive task immediately before final workflow verification.
Retain all seven checks and the existing partial evidence. The user approved this plan on 2026-10-24.

## Reasoning

The approved recommendation was that hook setup and visible alerts will make these checks more useful.
Finishing them now lost because it requires another probe session before those features exist.

## Consequences

The Claude adapter can proceed next. The specification still requires complete Codex verification before final acceptance.
The remaining checks cover controlled hook trust, default-mode questions, explicit denial, graceful end,
controlled abrupt loss, prose questions, and interactive unavailable-receiver behavior.
This delays discovery of remaining Codex integration defects. It does not change event-contract decisions or claim full compatibility.
