# Notch

Owns the native session interface, attention presentation, desktop recovery, and accessible notch controls.
Code: `Sources/NotchPet/` and shared presentation services in `Sources/SessionState/`.

## Specs

- [`session-island`](session-island.md): Inspect sessions and requests in the expandable notch, replacing the menu session list. Needs: sessions/session-state.
- `desktop-recovery`: Keep the notch accessible through display changes, Spaces, fullscreen, and sleep/wake. Needs: session-island.
- `accessible-controls`: Support keyboard controls, Reduce Motion, and perceivable alerts without unsolicited focus. Needs: session-island.

## Shared context

- [Record layout decision](../../decisions/0011-organize-records-by-feature.md).
- [Terminal independence](../../decisions/0012-support-terminal-independent-operation.md) is accepted. Display sessions and notices without requiring navigation metadata.
- Expose only verified terminal navigation capabilities. Unavailable navigation must not hide alerts or disable provider actions that have a verified channel.
- [Source specification](../notch-companion.md): retain I1 and N3–N6 requirements and historical evidence during migration.
- Implemented: native expandable panel, placement calculation, session rows, selection, shared attention rules, and menu session-list removal.
- Existing implementation does not establish all N3–N6 acceptance checks. Preserve their unchecked states pending evidence review.
- R1–R3 supply notch placement, fullscreen/Spaces, hit-testing, and sleep/wake checks. Pet-specific checks belong to pets/detachable-pet.
- R4 supplies accessible notch controls. R5 includes the idle resource profile. Preserve these requirements when writing feature specs.
- Session state remains shared with the pet. New alerts must not acquire keyboard focus.

## Open questions

- Physical-notch focus, click-through, and desktop acceptance remain incomplete.
