# Notch Pet

A macOS companion for Codex CLI and Claude Code in Otty, under development.
The current app provides a menu-bar control and Quit action.
Agent notifications, the notch interface, the detachable pet, and usage limits are planned next.

The working name is `notch-pet`; the user has not chosen a product name.

## Run locally

Use macOS 13 or later with Swift 6 tools. Install Apple's Command Line Tools if `swift --version` is unavailable.
The first build was verified on macOS 26.3.1 with Swift 6.2.3 on the M2 MacBook Air.
Older supported macOS versions have not been tested yet.

From the repository root, run:

```bash
bash scripts/run.sh
```

Click the paw icon in the menu bar. The menu says that agent connections are not set up.
Select **Quit Notch Pet** to close the app. Command-Q also quits while its menu is open.
The app has no Dock icon and opens no window.

The script builds a Swift package and creates `Notch Pet.app` under `${TMPDIR:-/private/tmp}/notch-pet-dev`.
Build products stay there too. The app uses no external package dependencies and changes no agent settings.
Quit the running app before rebuilding. Repeating the launch command reuses the same app bundle.
Temporary files can be removed by macOS; rerun the command to rebuild them.

Build the bundle without launching it:

```bash
bash scripts/run.sh --build-only
```

On success, the command prints the app bundle's absolute path. Build messages go to stderr.
This is a development bundle; distribution packaging and signing are a later task.

## Start here

- [Project status](docs/STATUS.md)
- [First-version specification and tasks](docs/specs/notch-companion.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Decision records](docs/decisions/)

## Confirmed requirements

- Use SwiftUI and AppKit on the user's M2 MacBook Air.
- Support Codex CLI and Claude Code in Otty first.
- Show input requests and response completion through the notch interface.
- Let the user detach, customize, and return a desktop pet.
- Include reported usage limits where supported.
- Allow later integrations with other apps and terminals.
- Do not depend on Flux Island. The user withdrew that reference.

The user approved the task list and architecture decisions 0001–0007.
See the specification for remaining implementation tasks and the compatibility records for verified integration limits.

