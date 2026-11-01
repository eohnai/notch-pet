# Show sessions as compact cards in the notch

## Goal

Replace the expanded notch's disclosure rows with compact session cards, based on the reference layout the user supplied on 2026-10-31.
Each card shows the provider, project folder, status, and a timer for the current prompt. A pending request gets its own card with the tool name.
The allowance strip above the cards is a separate spec, `allowance-strip`. See the [notch area](area.md) for shared context.

## Done when

- Each session card shows a provider badge, the project folder name, the status, and the prompt timer.
  Two sessions in the same folder also show a short session ID. Opening a card shows the full project path and session ID.
- The timer starts at the turn's `UserPromptSubmit` and recalculates elapsed time each second while the panel is open.
  It stops at its final duration on `Stop`.
  It is hidden for unknown and ended sessions, and for sessions with no observed turn.
- A pending request shows a request card with the tool name and the text "Answer in the terminal".
  No prompt, command, question, or tool-input text appears anywhere in the panel.
- Every observed state keeps its label: idle, working, question, approval, response ready, ended, and unknown.
- The expanded panel is wider and shorter than before, at the sizes under **My calls**.
- `swift test` passes, including new store and presentation tests.
- Real app: fictional events sent through the bundled helper show two same-folder sessions, a running timer, a stopped timer, a request card, and an unknown session.
  The user reviews them in one batched visual pass.

## Out of scope

- The allowance strip (icon, `5h`, percent left, reset countdown, `7d`): `allowance-strip`.
- Toolbar icons, per-row pet icons (pets/agent-reactions), and the terminal kind tag (`otty`).
- "Go to terminal" buttons and any terminal navigation: sessions/pane-navigation.
- The latest tool name while a session is working.
- Prompt or command text in rows. That needs its own decision and a contract v2.
- The collapsed view, and session-island's N3–N5 actual-app acceptance.
- Keyboard controls and Reduce Motion beyond the existing animation check: accessible-controls.

## Constraints

- Follow the [event contract's omission rule](../../contracts/agent-events-v1.md): rows show only the tool name from a request.
- Session meaning stays in `SessionStore`. Views render snapshots through pure `NotchPresentation` functions, under [D3](../../DECISIONS.md#d3-add-view-models-only-where-a-view-owns-state).
- Keep the nonactivating panel. Cards and timers must not take keyboard focus.
- Tick the timer only while the panel is expanded and at least one timer is running. Idle cost belongs to [resource-efficiency](resource-efficiency.md).
- Builds, tests, and helper injections need the user's authorization for each task. App launches were allowed on 2026-10-31.

## Verify

- Seam: the bundled `NotchPetHook` helper into the running app and the expanded notch panel.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
  Passing means exit 0 with no failing tests. Store tests are in `SessionStoreTests.swift`. Presentation and placement tests are in `NotchSelectionTests.swift` and `NotchPresentationTests.swift`.
- Build: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`.
- Real app: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh`, then send fictional observations through the bundled helper.
  Do not request screen-capture permission or retry the prohibited capture path. The user supplies the one visual review.

## Decisions

- **Change the layout before session-island's acceptance checks, 2026-10-31.** The user chose this over waiting for session-island (`Needs: session-island`).
  This avoids verifying the old row layout and then the new one. ^[inferred] Session-island's N3–N5 checks then run on the cards.
- **Rows keep the contract's omission rule, 2026-10-31.** The user chose tool names only, over showing prompt and command text as in the reference.
  Showing that text needs its own decision and a contract v2.
- **Time each prompt from `UserPromptSubmit` until `Stop`, 2026-10-31.** The user asked for the timer to stop at its final duration when the response is ready.
  The store must therefore keep the turn's start time. At planning time, the store did not keep it.
- **Calculate duration from numeric timestamps, 2026-11-01.** The user chose the existing `Int64` millisecond timestamps over parsing display strings or adding `Date` conversions.
  Subtract start from current or stop time, then format once for display. This avoids string parsing and counter drift after delayed updates.
- [0002: Use services and shared stores](../../decisions/0002-use-mvvm-with-services.md).
- [0012: Support terminal-independent operation](../../decisions/0012-support-terminal-independent-operation.md).

## My calls

- Expanded panel: 620 points wide (was 560) and 240 points below the header (was 280). The user asked for "a little shorter but a little wider".
- Timer times come from the events' `observed_at_ms`, not the app's receipt times. A delayed delivery does not shorten the timer.
- A new turn resets the timer. A repeated `Stop` does not change the final duration.
- C1 exposes `turnStartedAtMs` and `responseReadyAtMs` on `SessionSnapshot`, using event capture times in Unix milliseconds.
  A matching stop records its first time even when the session stays unknown. C2 owns hiding timers for unknown and ended sessions.
- Timer format: `45s`, `2m03s`, `1h02m`.
- An unknown session hides its timer, because the app cannot confirm the turn is still running. Waiting for approval or an answer keeps the timer running.
- Short session ID: the last 6 characters. The first characters of time-ordered IDs can match for sessions started close together. ^[inferred]
- Folder name: the last part of the project path, or "Project not observed".
- The request card replaces the reference's "Go to terminal to confirm" button with plain text, because no navigation exists yet.
- The existing "Codex limits" sections stay until `allowance-strip` replaces them.

## C2 plan


The user approved C2 implementation and the focused tests on 2026-11-01. The numeric timing approach is accepted.
This timer belongs to the session card. The allowance strip's reset countdown remains in `allowance-strip`.

Branch: `feat/notch-session-cards`, preserving C1 commit `1f30a3c`.
The user chose a normal branch switch. The earlier CI cleanup and plan are preserved in the stash named
`preserve ci cleanup and c2 plan before feature work`, with a patch backup at `/private/tmp/notch-pet-c2-documentation-before-switch.patch`.
No main merge ran. Restore the CI cleanup on its owning branch and integrate main separately before PR review.

Files, in order:

1. Add `Tests/SessionStateTests/NotchCardPresentationTests.swift` with failing presentation cases.
2. Update `Sources/SessionState/NotchPresentation.swift` with the value types and pure functions below.
3. Update this spec and `docs/STATUS.md` with verification evidence. Tick C2 only after verification passes.

Approved API sketch, with empty function bodies:

```swift
public enum PromptTimer: Equatable, Sendable {
    case running(startedAtMs: Int64)
    case stopped(durationMs: Int64)

    public func elapsedSeconds(at nowMs: Int64) -> Int64 {}
}

public struct NotchCardPresentation: Equatable, Sendable {
    public let folderName: String
    public let shortSessionID: String?
    public let timer: PromptTimer?
}

// New methods shown inside the existing enum. Keep its current methods too.
public enum NotchPresentation {
    public static func card(for session: SessionSnapshot,
                            among sessions: [SessionSnapshot]) -> NotchCardPresentation {}
    public static func timerText(seconds: Int64) -> String {}
}
```

C4 caller example:

```swift
let card = NotchPresentation.card(for: snapshot, among: sessions)
if let timer = card.timer {
    let seconds = timer.elapsedSeconds(at: nowMs)
    let text = NotchPresentation.timerText(seconds: seconds)
    // Render text in the session card.
}
```

The card has no stored `timerText` or `isTimerRunning` property.
C4 identifies running timers by matching `.running`, so a second boolean cannot disagree with the timer state.
Pass current time into the calculation. These functions do not read a clock, schedule updates, or perform I/O.
Keep the functions in the existing enum because it is small and already owns notch presentation.
An extension is valid Swift, but adds no useful separation for this change.

Behavior and test cases:

- Show the final path component, or "Project not observed" for a missing or empty path.
- Show the last six session-ID characters only when another session key shares the same full observed project path.
  Two different paths with the same final folder name do not count as one folder. Include both providers in these cases.
- Return `.running` for working, question-needed, or approval-needed sessions with an observed start time.
- Return `.stopped` for response-ready sessions with both start and stop times. Later current times leave its duration unchanged.
- Return no timer for idle, unknown, or ended sessions, missing starts, or response-ready sessions missing a stop time.
- Floor elapsed milliseconds to whole seconds and clamp negative durations to zero.
  Cover delayed updates, current time before start, and the second/minute/hour format boundaries: `45s`, `2m03s`, `1h02m`.
- Calculate every update from timestamps. Never parse the displayed text or increment a stored elapsed counter.

Approved focused verification:

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift test --scratch-path /private/tmp/notch-pet-c2/build \
  --filter 'NotchCardPresentationTests|NotchSelectionTests|NotchPresentationTests'
git diff --check
```

Run the focused command before implementation to establish the failing cases, then repeat after implementation.
Passing means exit 0 with no failed tests. `git diff --check` must also exit 0.
C2 adds no app launch, helper injection, layout change, timer scheduling, or capture. C3–C5 retain those separate responsibilities.

## C2 verification, 2026-11-01

Implemented on `feat/notch-session-cards`, based on C1 commit `1f30a3c`.
The functions live directly in `NotchPresentation`. `PromptTimer` supplies numeric running/stopped states and elapsed seconds.
Display formatting is separate. The existing app UI does not use the new card presentation until C4.

The approved focused command above first exited 1 because `card`, `PromptTimer`, and `timerText` did not exist.
After implementation, the same command exited 0: 20 tests in three suites passed.
The suites are `NotchCardPresentationTests`, `NotchSelectionTests`, and `NotchPresentationTests`.
`git diff --check` also exited 0.

The cases cover both providers, full-path folder sharing, missing paths and timing evidence, hidden timers,
fixed stopped durations, delayed updates, millisecond rounding, and second/minute/hour formatting boundaries.
No full-suite run, app launch, helper injection, or capture ran for C2.
Logs remain outside the repository at `/private/tmp/notch-pet-c2-red.log` and `/private/tmp/notch-pet-c2-green.log`.

## Tasks

- [x] C1: Keep each turn's start and response-ready times in `SessionStore` and expose them on `SessionSnapshot`; store tests cover start, stop, repeated stop, and a new turn resetting both times.
- [x] C2: Add pure card presentation to `NotchPresentation`: folder name, short session ID for a shared folder, numeric running/stopped timer states, elapsed-time calculation, and separate display formatting. Presentation tests cover each case.
- [ ] C3: Make the expanded panel 620 points wide and 240 points below the header in `NotchPlacement`; update the placement tests.
- [ ] C4: Replace `NotchSessionRow` with a session card (badge, folder · status, timer) and a request card (tool name, "Answer in the terminal"); recalculate elapsed time once per second only while expanded with a running timer; build passes.
- [ ] C5: Verify the cards in the real app with fictional events through the bundled helper: same-folder sessions, running and stopped timers, a request card, and an unknown session; one batched visual review by the user.
