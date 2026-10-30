# First skill pilot

Needs: local-history

## Goal

Record a real debug-issue invocation without requiring the Notch Pet interface or a collector.
Verify the automatic signal first, then add only the end report and step-7 check evidence.
See the [telemetry area](area.md). Branch in both repositories: `feat/telemetry-skill-telemetry`.

## Done when

- S1 captures real payloads for the installed agents and distinguishes an attempted Skill call from a confirmed skill load.
- At least one verified agent records debug-issue start, reported end, and its step-7 verification result through the local emitter.
- The app stays closed throughout the pilot. A later local import shows the correct invocation and skill-folder version.
- End/check records join the exact invocation. Repeated or nested invocations in one session do not merge.
- If stable correlation is unavailable, the adapter reports that limitation instead of guessing a parent or current invocation.
- Telemetry failure or a declined emitter permission does not block the debugging work. The resulting coverage gap is explicit.

## Signals and permissions

S1 checks PreToolUse and PostToolUse for Skill using isolated configuration and fictional, nonsecret inputs.
It also checks UserPromptExpansion for typed slash commands, needed by the later manual-only next-task pilot.
These are [documented hook candidates](https://code.claude.com/docs/en/hooks#userpromptexpansion), not verified installed-version behavior.
A pre-event records an attempt. Use loaded only after S1 establishes the corresponding successful signal.

The telemetry adapter selects skill name and available invocation identity from that payload.
It calls the local emitter directly. It does not widen or bypass the accepted version-1 socket envelope.
A source supplying raw input to the adapter is not permission to store that raw input.

For the pilot, accept normal permission prompts for agent-issued emitter calls.
Existing approved rules may already cover a call. Do not add or broaden an allowlist silently.
Show any proposed hook installation diff before applying it and preserve unrelated agent settings.
If prompting makes the pilot unusable, stop to review a narrowly scoped emitter setup rule before expanding instrumentation.

## Out of scope

- Instrumenting next-task or checkpoint, every intermediate step, app history UI, a collector, and inferred task success.
- Transcript scanning or pretending that a file read establishes an invocation.

## Verify

- Seam: an actual debug-issue invocation, ready files, local import, and query output while the app is closed.
- Use the local-history build/Swift checks for runtime changes, plus `git diff --check` in both repositories.
- S1 identifies existing agent-skills validation commands before editing its pilot instructions.
- Exercise a loaded start, a denied attempt, a reported end, an actual failed/passing check, missing closure, and declined emitter permission.
- Retain only selected field examples and agent versions from the hook investigation. Do not save prompts or raw tool input.
- Temporary capture files stay outside repositories and use only the isolated fictional inputs.

## Decisions

- Pilot debug-issue before a history interface or live collector. See [D3](../../DECISIONS.md#d3-record-skill-history-before-extracting-live-monitoring).

## My calls

- Keep the existing S1 identity for the hook investigation. The later S2/S3 definitions replace the earlier unstarted multi-skill tasks.
- Accept normal permission prompts during this pilot rather than changing user permissions. Review this call before S2 setup.
- A second agent's unsupported signals remain a named coverage gap. Do not delay the first verified pilot solely for parity.

## Tasks

- [ ] S1: Capture real installed-agent hook payloads and validate start/load/correlation fields, including slash-command expansion, using isolated configuration and sanitized examples.
- [ ] S2: Add the verified telemetry start adapter for debug-issue, reviewing its setup diff and checking a real closed-interface record with emitter-owned version metadata.
- [ ] S3: Add debug-issue's reported end and step-7 check evidence, checking exact-run correlation, permission refusal, and a real imported run.
