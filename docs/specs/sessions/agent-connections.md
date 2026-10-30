# Manage agent connections

Needs: agent-adapters, codex-setup, claude-setup, integration-health

## Goal

Let someone enable Codex and Claude Code observation from one native settings list and see their
sessions in the existing island. The user's Flux screenshot supplies the per-agent list/toggle
interaction reference. The island owns session browsing; usage and pet reactions remain separate.
See the [sessions area](area.md). Proposed branch: `feat/sessions-agent-connections`.

## Done when

- An Agents settings section lists implemented catalog registrations with a per-agent monitoring
  control, setup/check/disconnect actions and readable state beyond a colored indicator.
- Connect previews owned setup changes, preserves normal trust review and distinguishes configured,
  receiving, quiet, unavailable and conflicting evidence. A toggle never fabricates an Active session.
- Monitoring preference and live activity are separate. Quiet configured agents remain enabled.
  No installed agent or observed session automatically grants setup consent.
- Pausing one provider gates its observations and invalidates freshness while retaining unresolved
  requests as unconfirmed. It leaves the other provider running. Resume requires fresh evidence.
- Disconnect removes only that provider's proven owned setup, then disables its monitoring. A removal
  conflict leaves an actionable result; it never pretends cleanup succeeded or resolves notices.
- The app owns one receiver and session store while observation is enabled. Pet-only launch with
  both providers disabled starts no agent I/O. Unsupported/failed setup never enables itself.
- Both installed agents can deliver verified lifecycle events through the bundled helper to the
  real app using isolated settings and no Otty metadata. Tested versions/modes are recorded honestly.
- Working, structured question, approval, response-ready, ended and unknown meanings survive
  end-to-end presentation; no claim of arbitrary prose-question detection or in-island replies.

## Out of scope

- More agents, a runtime plugin manager, quota forwarding, approvals/replies, exact-pane navigation,
  telemetry, background collection, pet reactions or detachment, and full first-use/release acceptance.
- Copying Flux's artwork, implementation or an unverified meaning of its Active label.

## Constraints

- Retain pet-first SwiftUI/AppKit and explicit optional service ownership.
- Health stays multidimensional. Receiver success or a helper write is not end-to-end delivery proof.
- No startup/background configuration probes. Persist only preferences and owned setup metadata.
- Source I5/I6/N8 and deferred R6/R7 checks remain unchanged; this bounded goal supplies partial
  coverage, not their automatic completion. No new terminal metadata is required.
- No screen recording or window capture, and no verification until renewed explicit approval.

## Verify

- Seam: actual settings actions and bundled helper into the production receiver/store/island.
- Unit checks cover provider-specific pause/resume and conflict outcomes; native checks must invoke
  production controls and inspect actual resulting views/window state, not only model snapshots.
- Proposed checker: `python3 scripts/check-agent-workflow.py --app '/private/tmp/notch-pet-agent-workflow/notch-pet-dev/Notch Pet.app' --artifacts /private/tmp/notch-pet-agent-workflow/evidence --skip-capture`.
  This checker does not exist yet. Freeze the goal's twelve groups before adding it.
- Live dispatch needs isolated installed-agent execution and ordinary trust review. Fictional helper
  input is labeled fixture evidence; blocked live coverage keeps acceptance open.

## Decisions

- **Monitoring switch semantics, accepted 2026-10-30.** On = enable approved observation;
  Off = pause that provider; Disconnect is a separate owned-removal action. This avoids repeated hook
  edits while toggling. Alternative: every Off uninstalls hooks; simpler binary configuration state,
  but every toggle needs guarded writes/trust and cannot express pause independently. The user approved
  the recommended Off-as-pause design when activating the goal.

## My calls

- Reuse the native settings entry point; keep pet settings usable without connected agents.
- Start with two rows. The adapter conformance test may inject a third descriptor, but the shipped
  settings screen must not list unimplemented agents as active or connectable.
- Detailed visual QA stays deferred without captures. Native accessibility/window observations can
  establish specific interaction results, not pixel appearance or full physical-desktop acceptance.

## Tasks

- [ ] CN1: Settle per-agent monitoring/control semantics and add independent persisted preferences with at most five tests for defaults, provider isolation, pause and fresh resume.
- [ ] CN2: Connect app-owned optional services to provider preferences and observation gates, preserving one receiver/store and retained unknown notices with at most five tests.
- [ ] CN3: Add catalog-driven Agents settings rows and explicit Check feedback through app-owned health, covering empty, quiet, unavailable and conflicting states without startup probes.
- [ ] CN4: Connect setup preview/confirmation and owned Disconnect actions for both drivers, checking errors and preservation through disposable production control paths.
- [ ] CN5a: Add the bounded no-capture checker driver and frozen setup/control assertions for G1–G6, calling the already-tested production paths within three files, three production functions and five added test cases.
- [ ] CN5b: Add native helper/presentation assertions for G7–G10 through the existing production app seam, preserving G1–G6 and checking actual views/actions within the same slice limits.
- [ ] CN6: Run isolated real-agent dispatch for both installed providers, record version/mode/trust coverage and verify the app receives each established event without Otty metadata or production configuration changes.
