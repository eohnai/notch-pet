# Notch Pet

A macOS companion for Codex CLI and Claude Code in Otty, under development.
The current app provides a menu-bar control and Quit action.
It also runs a local event receiver and bundles a silent hook helper.
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

## Local event bridge

The app listens at `/private/tmp/notch-pet-<uid>/events-v1.sock` while it runs.
The directory has mode `0700`. The socket has mode `0600`.
Both endpoints check the connected user's numeric ID.
The receiver validates [version-1 envelopes](docs/contracts/agent-events-v1.md) before calling its consumer.
The current shell discards validated observations. Session state and agent setup are later tasks.

The bundle includes `Contents/MacOS/NotchPetHook`.
Run it with `--agent codex` or `--agent claude`, with one raw hook JSON object on stdin.
It forwards only the contract's allowed fields, including an optional unverified `OTTY_PANE_ID` hint.
It never opens transcripts or forwards prompt text, commands, or raw tool input.
Handled errors return exit `0` with empty stdout and stderr.
There is no acknowledgement, retry, queue, or saved activity.

The helper limits stdin, connection, and writing to 50 ms each.
It also enforces a shared 250 ms deadline after executable entry.
Process launch time is additional. Future hook setup must also set the agent's execution timeout.
The receiver allows 100 ms to finish one frame, including fragmented reads.
A successful write does not prove that an observation reached session state.

The app holds `listener.lock` while it owns the endpoint.
It recovers an owned stale socket only after a refused connection and an unchanged file identity.
It leaves active listeners, symlinks, and unrelated files intact.
Normal shutdown removes only its own socket. The lock file and directory remain for later launches.
These checks separate users and coordinate app instances. They do not authenticate an agent running as the same user.

## Verify the bridge

Quit Notch Pet before running the process checks. They refuse to replace an existing socket.
The Swift tests use isolated temporary directories. The process checks use the standard endpoint and fictional input.
Neither command installs hooks or changes agent settings.

Build the bundle and helper first:

```bash
bash scripts/run.sh --build-only
```

Run the Swift tests with full Xcode selected for this command only:

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift test --scratch-path /private/tmp/notch-pet-dev/build
```

The tested Command Line Tools installation cannot import the test frameworks.
The app and helper still build with Command Line Tools.
The Swift tests also use `/usr/bin/python3` to serialize the existing fictional contract cases.
They check the production Swift decoder, rather than the Python reference validator.

Run the helper process checks and contract reference checks:

```bash
python3 scripts/check-event-bridge.py
python3 scripts/check-event-contract.py
git diff --check
```

Success means all Swift tests pass and the process checker prints `Bridge process checks passed`.
The contract checker prints four `PASS` lines. The diff check prints nothing.
Process timings include launch time. They are observations on this Mac, not a real-time scheduling guarantee.

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

