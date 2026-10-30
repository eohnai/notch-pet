# Validated development artifacts

Needs: pull-request-checks

## Goal

Let a contributor download an unsigned release-mode app bundle that CI has structurally checked and whose bundled helper has actually executed.
Extend the [CI area](area.md) and current development packaging script without changing pet/session behavior or claiming distribution readiness.
Proposed branch: `feat/ci-development-artifacts`.

## Done when

- The existing `bash scripts/run.sh` and `--build-only` debug behaviors remain usable; a documented explicit release-mode build-only invocation
  creates a separate temporary bundle without launching it or accidentally packaging debug binaries.
- A validator checks the packaged plist, expected executable paths and executable bits, native Mach-O architecture,
  and minimum-OS metadata for both NotchPet and NotchPetHook against the declared build inputs and package platform contract.
- The copied SwiftPM pet resource bundle contains the expected manifest and PNG artwork; validation checks their parseability,
  declared geometry, and expected resource placement rather than just the existence of an empty Resources directory.
  Existing Pet artwork tests still establish decoder behavior separately from this packaging check.
- Packaged executable hashes match the explicitly selected release build products. Configuration evidence comes from the recorded build invocation
  and product paths, not a claim that arbitrary Mach-O bytes alone prove how they were compiled.
- The helper checker can explicitly target a packaged helper path while preserving its current no-argument debug workflow.
  It runs fictional input and bounded disconnected/busy/invalid cases against the actual release helper inside the produced app bundle.
- Validation rejects a missing helper, an executable that differs from the selected release product, an invalid plist, missing/invalid pet resources,
  and wrong architecture/deployment metadata with actionable errors. Preserve the existing supported deployment target rather than rewriting it to match a runner.
- A successful job archives the validated bundle with permissions and resource structure preserved, records the revision/configuration/architecture/toolchain,
  and uploads a uniquely named artifact. Failed validation prevents artifact delivery and makes Required fail.
- A downstream job downloads that exact run/attempt artifact, extracts it in a temporary location, reruns structural validation and the packaged-helper check,
  and supplies its result to Required. No rebuilding can substitute for checking the delivered bytes.
- The documented artifact download/run limitations explicitly identify it as unsigned development output with short retention;
  it is neither a signed release nor proof of visual or minimum-OS runtime acceptance. An authorized hosted run supplies end-to-end artifact evidence.

## Out of scope

- Code signing, certificates, secrets, notarization, Gatekeeper bypass instructions, installers, auto-update, GitHub Releases, or public hosting.
- Universal binaries, downloading/copying third-party pet art, modifying artwork or product behavior, or a second app/project.
- Launching the GUI, window/screen capture, physical notch acceptance, or completing deferred standalone-pet acceptance.

## Constraints

- Follow the [shared CI boundaries](area.md) and the existing [one-app pet decision](../../decisions/0013-separate-standalone-pet-scope.md).
- Preserve the default development-script interface, stdout bundle-path contract, stderr build logs, and build-only no-launch behavior.
  Isolate debug/release output so a previous build cannot supply stale products or resources to the next artifact.
- Each task changes at most three files including its spec update, adds at most three production functions and at most five test cases.
  Split artifact checks before implementation if this budget cannot hold; do not hide a new fixture/test module outside the file count.
- Keep source checkout, generated bundle, and downloaded bundle distinct. Use fictional bridge data and refuse an already active local endpoint.
- Artifacts contain only the app bundle and allowlisted build metadata, never an entire workspace, home directory, runtime socket, preferences, or session data.

## Verify

- Seam: release-mode build through packaged app/helper, archive upload/download, and execution of the downloaded helper with fictional socket input.
- Existing debug regression command: `bash scripts/run.sh --build-only`.
  Record the exact new release invocation and generated path when the packaging change exists; the release option is proposed, not a current command.
- Use `plutil`, `file`/`lipo`, and the selected Xcode's Mach-O metadata tools to verify plist, binary formats, architecture, and deployment commands.
  Check resource manifest/PNG metadata with a bounded validator; generate intentionally invalid bundle copies only under temporary directories.
- Extend `python3 scripts/check-event-bridge.py` with an explicit helper input, then run the same checker against both debug and packaged release helpers.
- Verify archive round-trip executable permissions, resource paths, build identity, validation, and fictional helper delivery after download.
- Use Required result fixtures and an authorized hosted run to demonstrate that build, validation, missing artifact, or downstream verification failure cannot pass the gate.
- `git diff --check`; no package build, helper invocation, app launch, or hosted action occurred during planning.

## Decisions

- Unsigned development output and excluded visual/distribution acceptance follow the [area decisions](area.md#decisions).

## My calls

- Add an explicit build configuration option to `run.sh` rather than copying packaging into a second independent script.
  Keep debug as the default; finalize the option spelling before implementation.
- Use a macOS-capable archive format and a documented archive checksum/build-metadata record so the delivery job checks the produced bundle without rebuilding.
- Initially deliver the primary native architecture. The compatibility spec validates Intel/Apple Silicon source execution;
  it does not promise that one downloaded bundle contains both architectures.
- Retain downloadable bundles for three days initially and include commit SHA, run attempt, configuration, and architecture in their identity.

## Tasks

The user approved this task list and its scoped local verification on 2026-10-30; its prerequisite and execution remain pending.

- [ ] DA1: Extend build-only packaging to select release mode with isolated output while preserving existing debug calls; verify both bundle layouts and that no application launch occurs.
- [ ] DA2: Add bounded structural validation for plist, both executable products, architecture/deployment metadata, and bundled pet manifest/artwork; verify rejection using disposable corrupted bundle copies.
- [ ] DA3: Let the existing bridge checker target an explicit packaged helper, retaining no-argument debug discovery; verify the fictional process cases against debug and release helpers without changing production deadlines.
- [ ] DA4: Add the release packaging/validation job and archive upload with build identity, bounded logs, and Required enrollment; verify that a packaging or validation failure prevents app-artifact delivery.
- [ ] DA5: Add exact-artifact download and extracted-bundle/helper verification to Required, then verify an authorized hosted round trip and document download identity, retention, and unsigned development limitations.
