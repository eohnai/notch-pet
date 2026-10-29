# Pets

Owns pet rendering, detachment and return, safe artwork imports, preferences, and pet desktop behavior.
Code: future pet services and AppKit panels, sharing existing session/presentation state.

## Specs

- `built-in-pet`: Show independently supplied artwork using shared session state. Needs: notch/session-island.
- `detachable-pet`: Drag the pet out, return it, and recover placement across desktop changes. Needs: built-in-pet.
- `custom-packs`: Validate, import, select, and restore manifest-based pet packs. Needs: built-in-pet.
- `sprite-sheet-import`: Settle and implement the optional sheet conversion proposal. Needs: custom-packs.

## Shared context

- [Record layout decision](../../decisions/0011-organize-records-by-feature.md).
- [Terminal independence](../../decisions/0012-support-terminal-independent-operation.md) is accepted. Pet reactions must not require Otty or terminal navigation.
- [Standalone pet scope and packaging](../../decisions/0013-separate-standalone-pet-scope.md) remains proposed. The user raised pet-only users but has not chosen a module, service, or separate project.
- P0 in the source spec must settle standalone behavior and packaging before pet implementation. Keep the existing built-in-pet dependency until that choice is accepted.
- [Source specification](../notch-companion.md): P1–P8 remain open. Shared presentation code exists, but does not establish implemented pet rendering.
- [Accepted asset-only pack format](../../decisions/0006-import-asset-only-pet-packs.md).
- P1 belongs to built-in-pet. P2 and pet-specific R1–R3 checks belong to detachable-pet.
- P3–P4 and pack-selection preferences from P7 belong to custom-packs. Placement preferences from P7 belong to detachable-pet.
- P5–P6 belong to sprite-sheet-import. Preserve P6's blocked state until P5 is accepted.
- Divide P8 actual-app checks among the features they verify. Preserve pet Reduce Motion and hidden/asleep animation checks from R4.
- R5 includes the animated-pet resource profile on the target Mac. Do not replace measured acceptance with a native-stack assumption.
- Keep runtime files, imported packs, and fixture assets outside the repository. Invalid imports must preserve the selected pet.

## Open questions

- Should pet-only users need any agent setup? What behavior should the pet provide without agent events?
- Should one app contain a separate pet module, should two apps share it, or should the pet use a separate project or service? Resolve P0 before changing dependencies.
- Sprite-sheet conversion versus a second runtime loader remains proposed. The optional importer is not a first-release dependency.
