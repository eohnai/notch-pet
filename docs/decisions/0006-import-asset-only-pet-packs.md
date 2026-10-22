# 0006: Import asset-only pet packs

- Status: accepted
- Date: 2026-10-22

## Context

The user wants to customize the pet through imported artwork.
An animation needs artwork for its distinct poses; one image can only support basic transforms.

## Options

- **JSON manifest and PNG frame sequences**: easy to inspect and author; creates multiple files.
- **JSON manifest and sprite atlas**: packs frames into fewer files; requires authoring tools and frame coordinates.
- **Static image import**: simplest customization; limits animation to movement, tilt, and scale.

## Decision

Use a versioned JSON manifest with transparent PNG frame sequences.
Allow a single-frame idle pose and define fallbacks for missing optional states.
The user approved this recommendation on 2026-10-22.

## Reasoning

Frame sequences support simple authoring. Sprite atlases reduce file counts but require frame coordinates.
The user approved this reason during architecture review.

## Consequences

Specify dimensions, frame counts, timing, and resource limits before accepting packs.
Import data and images only. Do not execute scripts from pet packs.
Store imported packs in Application Support outside the repository.
Recoloring arbitrary imported artwork is not guaranteed by simple preference controls.

