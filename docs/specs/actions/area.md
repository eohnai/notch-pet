# Actions

Owns explicit local permission decisions, structured answers, and follow-up replies to verified agent targets.
Code: future shared action services, provider adapters, and notch/pet action controls.

## Specs

- `verified-channels`: Establish supported action mechanisms and their targeting, acknowledgement, and cancellation contracts.
- `permission-decisions`: Approve once or deny an exact pending request from the notch. Needs: verified-channels, notch/session-island.
- `structured-answers`: Answer a verified structured question from the notch. Needs: permission-decisions.
- `follow-up-replies`: Explicitly send text to the selected existing conversation. Needs: permission-decisions.

## Shared context

- [Record layout decision](../../decisions/0011-organize-records-by-feature.md).
- [Source specification](../notch-companion.md): A1–A8 remain planned, not implemented capabilities.
- [Accepted local-action scope](../../decisions/0010-add-local-agent-actions.md).
- A1–A2 establish shared compatibility and contract prerequisites. They do not prove an end-to-end action works.
- Migrate A3–A4 and permission-specific A7–A8 coverage into permission-decisions.
- Migrate A5 and question-specific A7–A8 coverage into structured-answers.
- Migrate A6 and reply-specific A7–A8 coverage into follow-up-replies.
- Each capability needs actual-app acceptance. Keep provider/version gaps explicit.
- Keep action delivery separate from the one-way observation protocol. Never auto-approve or blindly replay uncertain delivery.
- Pet controls reuse these capabilities when pet presentation exists. Preserve pet action coverage during migration.

## Open questions

- Supported response channels and attachment to existing local sessions remain unverified. Do not choose a channel before A1–A2 evidence.
