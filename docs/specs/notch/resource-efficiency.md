# Resource efficiency

## Goal

Keep the companion and any later background collector economical on the user's M2 MacBook Air with 16 GB RAM.
Low idle energy use is accepted in [D1](../../DECISIONS.md#d1-make-low-idle-energy-use-a-release-requirement).
The tasks and numerical targets below are proposals. No efficiency measurement has run in this planning session.

## Done when

- With no sessions, rendering, queued writes, or user actions, components wait for events instead of repeatedly checking for work.
- A static pet pose schedules no repeating animation tick. Hidden or sleeping surfaces stop animation and rendering work.
- Reduce Motion presents a stable visible pose. Low Power Mode reduces optional motion and defers discretionary work.
- Pet-only startup launches no agent receiver, provider reader, configuration probe, or collector.
- Session limits, event queues, image resources, history queries, and any persistence buffers have explicit bounds.
- Quota reads are shared by provider/account rather than repeated for every session or surface.
- Idle accounts have no periodic refresh. Active refreshes do not overlap and use cancellation, backoff, and supported update signals.
- A failed refresh leaves honest stale or unavailable status. Reset times alone do not establish fresh usage.
- Sleep triggers no keep-awake assertion. Wake does not replay history as current work or launch a catch-up request storm.
- Actual-app profiles cover idle, visible animation, hidden surfaces, active agents, failures, and event bursts.
- Metrics include every app-owned process. Provider subprocess costs are reported separately and included in totals.

## Runtime requirements

- Wait on socket readiness or native notifications. Do not add a polling loop to detect event arrivals or UI changes.
- Keep parsing and persistence off the main actor. Publish bounded, coalesced state changes without dropping request identity.
- Schedule freshness checks only while evidence needs expiry, with timer tolerance where semantics allow.
- Keep the existing helper deadline. Hooks perform no network upload, database scan, or wait for an approval decision.
- Decode bounded artwork once and reuse it. Static frames do not need a display-link loop.
- Optional animation has a proposed 30 fps ceiling and stops when not visible; asset timing can be slower.
- Refresh only while monitoring is enabled and the provider is relevant. Visibility changes must not create duplicate readers.
- Preserve existing provider support, output, cancellation, and account boundaries. Do not read credentials or transcripts.
- Coalesce simultaneous refresh requests. Honor provider retry guidance where supplied and cap exponential failure backoff.
- Do not refresh an account on every hook, frame, or view recomputation. Monitoring pause cancels scheduled work and pending reads.
- Collection while the interface is closed is the requested direction. Service registration, ownership, stop controls, and recovery need review first.
- For confirmed local history, use indexed paginated reads, bounded batches, retention, and a size limit outside the repository.
- Keep history independent of live-state evidence. Never replay approvals, replies, or stale working events as current actions or state.
- Maintenance and optional upload must be cancellable and discretionary. Do not wake a sleeping Mac for telemetry.
- D3 starts with short-lived emitter calls and explicit import. A background collector is later live-monitoring work.
- Hash a skill folder once per invocation. Do not poll it or recompute its hash for each check/end record.
- Measure emitter latency and import batches. With the app closed, telemetry schedules no ongoing background work.

## Initial targets

These are proposed engineering budgets, not measured results or guarantees. Review them against the first baseline before implementation.

- Five-minute quiescent mean CPU: below 1% of one logical CPU, combined across the app and its owned processes.
- Warm idle physical memory footprint: at most 200 MiB combined, with a proposed 50 MiB share for a later collector.
- After warm-up, no monotonic memory, queue, thread, or descriptor growth during a 30-minute fixed-workload run.
- Quiescent idle has no repeating animation or quota-refresh callbacks. Record idle wakeups and explain recurring sources.
- Animation and event-burst profiles report mean and peak CPU, memory, write volume, delivery latency, and dropped observations.
- A resource improvement cannot weaken freshness, unresolved notices, ordering, bounded helper delivery, or explicit action requirements.

## Verify

- Build: `bash scripts/run.sh --build-only`.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
- Existing bridge checks, when their integration changes: `python3 scripts/check-event-bridge.py` and `python3 scripts/check-event-contract.py`.
- Documentation and whitespace: `git diff --check`.
- Profile a release build on the M2 Air. Record macOS/build versions, power mode, display conditions, session count, artwork, and sampling method.
- After two minutes of warm-up, record five-minute samples for pet-only static, visible animation, hidden surfaces, and enabled monitoring without sessions.
- Repeat with active supported agents, provider failures, and a bounded synthetic event burst. Record workload size and delivery loss.
- Use Instruments or Activity Monitor for CPU, physical memory footprint, energy impact, idle wakeups, and disk writes.
- Report the measurement tool's CPU convention; normalize 100% to one logical CPU. Avoid summing shared RSS as physical footprint.
- Compare the same workload with monitoring disabled and enabled. Relative energy scores do not establish battery-life hours.
- Exercise sleep/wake, Reduce Motion, Low Power Mode, pause, and interface closure after their owning features exist.
- Keep captures outside the repository. Save only sanitized results and environment details in the spec.
- Existing source R4/R5 and pet BP6 acceptance remain in their owning specs. Preserve their checkbox states and historical evidence.

## Tasks

Implementation requires task-list approval under the repository instructions. No task is complete from planning alone.

- [ ] E1: Capture a reproducible release-build baseline on the M2 Air and review the proposed budgets before changing runtime behavior.
- [ ] E2: Remove unnecessary idle timers and rendering; implement hidden/asleep, Reduce Motion, and Low Power Mode behavior without changing session semantics.
- [ ] E3: Coalesce provider reads and implement relevance gating, cancellation, and bounded retry backoff; verify no periodic reads when inactive.
- [ ] E4: Verify bounded queues, decoded assets, and query/write work; review telemetry/local-history retention and storage caps within the combined resource budget.
- [ ] E5: Repeat profiles and the 30-minute resource-growth check; record measured results and remaining failures before release.

## Ownership and open design

This spec adds cross-cutting resource acceptance. It does not migrate R4/R5, BP6, or usage U4, and does not count their work twice.
Their owning features implement behavior; E1/E5 own the combined measurements and E2-E4 check gaps at those boundaries.
The [telemetry area](../telemetry/area.md) now starts with record files/import and the first skill pilot. Collector profiling applies only when that later feature is planned.
Do not resume existing goals or modify installed hooks as part of this plan.

## Sources

- [Apple: Energy Efficiency Guide for Mac Apps](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/BestPractices.html).
- [Apple: Minimize Timer Usage](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html).
- Current code: `AgentUsageController` starts bounded Codex reads on a 120-second loop while its provider is relevant.
- Current code: the event inbox and session store have capacity limits; these do not establish measured energy performance.
