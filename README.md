# Notch Pet

A planned macOS companion for Codex CLI and Claude Code in Otty.
The notch shows when a session needs attention or has a response ready.
Drag a customizable pet onto the desktop and return it to the notch.
Show reported usage limits and reset times when the account supports them.

This repository contains planning documents only. Implementation has not started.
The working name is `notch-pet`; the user has not chosen a product name.

## Start here

- [Project status](docs/STATUS.md)
- [First-version specification and tasks](docs/specs/notch-companion.md)
- [Architecture proposal](docs/ARCHITECTURE.md)
- [Decision records](docs/decisions/)

## Confirmed requirements

- Use SwiftUI and AppKit on the user's M2 MacBook Air.
- Support Codex CLI and Claude Code in Otty first.
- Show input requests and response completion through the notch interface.
- Let the user detach, customize, and return a desktop pet.
- Include reported usage limits where supported.
- Allow later integrations with other apps and terminals.
- Do not depend on Flux Island. The user withdrew that reference.

Architecture recommendations remain proposed unless a decision record says accepted.
The user reviews the task list before implementation starts.

