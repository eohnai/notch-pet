# Show allowance in the notch's top row

Needs: session-cards

## Goal

Replace the expanded notch's large "limits" sections with a compact allowance strip in the top row, to the left of the physical notch.
Each active provider shows its logo, its 5-hour percent left, and the time until reset. A tooltip keeps the details the usage specs require.
This takes over the display part of usage/codex-allowance U5. See the [notch area](area.md) and [usage area](../usage/area.md) for shared context.

## Done when

- Collapsed, the top row still shows the paw and the session count, unchanged.
- Expanded, the top row shows the strip left of the notch: `[logo] 5h 96% 3h45m | [logo] 5h 80% 1h10m`. The right side stays empty for a later toolbar.
  Clicking the top row still expands and collapses the panel.
- Only providers with a non-ended session appear, as before. Claude Code uses the Claude logo and Codex uses the Codex logo.
- Each provider shows its 5-hour window. If the provider reports no 5-hour window, it shows its weekly window as `7d`.
- Percent left is `100 − used`, rounded down. It is green above 50% left, yellow from 20% to 50%, and red below 20%.
- The countdown reads `3h45m` or `4d22h`. A stale reading shows in gray. A provider with no window shows `5h —`. An unverified account shows a marker.
- Hovering an entry shows a tooltip with every reported window (used and left), reset times, freshness, account confidence, and any source status,
  such as "Codex executable unavailable" or "Awaiting Claude status-line data".
- The old "Codex limits" and "Claude Code limits" sections are gone from the panel.
- `swift test` passes, including new presentation tests.
- Real app: a real Codex reading appears in the strip, its tooltip appears on hover in the nonactivating panel, and Claude shows `5h —` with its status tooltip.
  The user reviews it in the same batched visual pass as session-cards C5.

## Out of scope

- Toolbar icons on the right of the top row.
- Live Claude allowance in the app: usage/claude-allowance U2c3. The app has no receiver startup path yet.
- Refresh, retry, reconnect, and account switching: usage/refresh-recovery.
- Changes to the usage store, providers, or the Codex read loop.
- Session cards and panel size: [session-cards](session-cards.md).

## Constraints

- The usage store keeps the reported used value. Percent left is derived only in presentation, under [D6](../../DECISIONS.md#d6-show-allowance-as-percent-left-not-percent-used).
- Read-only views use pure presentation functions, under [D3](../../DECISIONS.md#d3-add-view-models-only-where-a-view-owns-state).
- Several sessions never duplicate allowance. Providers are never combined into a total.
- The countdown updates no more than every 30 seconds, and only while the panel is expanded.
- Keep the nonactivating panel. Hovering must not take keyboard focus.
- Builds, tests, and app checks need the user's authorization for each task. App launches were allowed on 2026-10-31.

## Verify

- Seam: `UsageStore` snapshots into the expanded top row of the running app.
- Swift checks: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --scratch-path /private/tmp/notch-pet-dev/build`.
  Passing means exit 0 with no failing tests.
- Build: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh --build-only`. The packaged app contains both logo files.
- Real app: `env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer bash scripts/run.sh` with an active Codex session.
  Keep no raw quota or account IDs in the repository. Do not request screen-capture permission. The user supplies the one visual review.

## Decisions

- [D6: Show allowance as percent left, not percent used](../../DECISIONS.md#d6-show-allowance-as-percent-left-not-percent-used), 2026-10-31.
- **Put the strip in the top row only when expanded, 2026-10-31.** The user chose the top row beside the notch over a separate row below it.
  Collapsed, the paw and session count stay. The right side is kept for a later toolbar.
- **Show the 5-hour window, or the weekly window when there is no 5-hour window, 2026-10-31.** The user chose this over both windows per provider and over the window with the least left.
  Some plans have no 5-hour window.
- **Put details in a hover tooltip, 2026-10-31.** The user chose this over a details row that opens on click, and over dropping the details.
- **Use the real Claude and Codex logos, 2026-10-31.** The user chose them over simple colored marks we draw ourselves.
  This means bundling the two companies' brand artwork in the app.

## My calls

- The strip waits for session-cards, because it fits in the 620-point panel width that session-cards C3 sets.
- The user supplies the two logo files (SVG or PDF) from each company's official brand page. The task records where each file came from.
- Logos go in the app's resources, with the pet resources as the pattern. A missing logo falls back to the provider name in text.
- The strip shows one entry per provider. If one provider has several sources, the entry uses the newest fresh reading, and the tooltip lists every source.
- A passed reset counts as stale, as the usage store already decides.

## Open questions

- Tooltips may not appear in a panel that never becomes active. A5 checks this. If they don't appear, choose another place for the details before A5 is ticked.

## Tasks

- [ ] A1: Add pure strip presentation: pick the 5-hour window or the weekly fallback per provider, percent left rounded down, its color level, and the stale, missing, and unverified states; presentation tests cover each case.
- [ ] A2: Add countdown text (`3h45m`, `4d22h`) and tooltip text listing every window, reset time, freshness, account confidence, and source status; presentation tests cover each case.
- [ ] A3: Add the Claude and Codex logo files to the app's resources with their sources recorded; the build passes and the packaged app contains both files.
- [ ] A4: Show the strip left of the notch in the expanded top row with logos and tooltips, keep the collapsed paw and count, and remove the old limits sections; the build passes.
- [ ] A5: Verify the strip in the real app with a real Codex reading and Claude's empty state, including a tooltip on hover; the user reviews it with session-cards C5.
