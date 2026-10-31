# Show sessions as compact cards in the notch

## Goal

Replace the expanded notch's disclosure rows with compact session cards, based on the reference layout the user supplied on 2026-10-31.
Each card shows the provider, project folder, status, and a timer for the current prompt. A pending request gets its own card with the tool name.
The allowance strip above the cards is a separate spec, `allowance-strip`. See the [notch area](area.md) for shared context.

## Done when

- Each session card shows a provider badge, the project folder name, the status, and the prompt timer.
  Two sessions in the same folder also show a short session ID. Opening a card shows the full project path and session ID.
- The timer starts at the turn's `UserPromptSubmit` and counts each second while the panel is open. It stops at its final duration on `Stop`.
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
  The store must therefore keep the turn's start time. It does not keep that time today.
- [0002: Use services and shared stores](../../decisions/0002-use-mvvm-with-services.md).
- [0012: Support terminal-independent operation](../../decisions/0012-support-terminal-independent-operation.md).

## My calls

- Expanded panel: 620 points wide (was 560) and 240 points below the header (was 280). The user asked for "a little shorter but a little wider".
- Timer times come from the events' `observed_at_ms`, not the app's receipt times. A delayed delivery does not shorten the timer.
- A new turn resets the timer. A repeated `Stop` does not change the final duration.
- Timer format: `45s`, `2m03s`, `1h02m`.
- An unknown session hides its timer, because the app cannot confirm the turn is still running. Waiting for approval or an answer keeps the timer running.
- Short session ID: the last 6 characters. The first characters of time-ordered IDs can match for sessions started close together. ^[inferred]
- Folder name: the last part of the project path, or "Project not observed".
- The request card replaces the reference's "Go to terminal to confirm" button with plain text, because no navigation exists yet.
- The existing "Codex limits" sections stay until `allowance-strip` replaces them.

## Tasks

- [ ] C1: Keep each turn's start and response-ready times in `SessionStore` and expose them on `SessionSnapshot`; store tests cover start, stop, repeated stop, and a new turn resetting both times.
- [ ] C2: Add pure card presentation to `NotchPresentation`: folder name, short session ID only when another session shares the folder, and timer text that runs, stops, or hides by status; presentation tests cover each case.
- [ ] C3: Make the expanded panel 620 points wide and 240 points below the header in `NotchPlacement`; update the placement tests.
- [ ] C4: Replace `NotchSessionRow` with a session card (badge, folder · status, timer) and a request card (tool name, "Answer in the terminal"); tick timers once per second only while expanded with a running timer; build passes.
- [ ] C5: Verify the cards in the real app with fictional events through the bundled helper: same-folder sessions, running and stopped timers, a request card, and an unknown session; one batched visual review by the user.
