# Goal log: Notch sessions and provider allowance

- Goal file: docs/goals/notch-agent-limits.md
- Created: 2026-10-29 20:56 +08
- Turn limit: 30
- Status: running

## Turns

| Turn | Time | Criteria passing | What changed / evidence |
|---|---|---|---|

| 1 | 2026-10-29T21:04+08:00 | 1 not run; 2 focused five pass, full target pending; 3–4 not run; 5 whitespace pass, acceptance pending | Activated. Added placement foundation and five tests. Missing-type baseline failed; explicit CoreGraphics import corrected compilation. Focused run exits 0, five tests. No panel or live quota yet. Task commit requested, pending exact-command approval. |

| 2 | 2026-10-29T21:06+08:00 | 1 build passes; 2 full suite 64 pass, target 79 pending; 3 visual verification pending; 4 not implemented; 5 incomplete | Placement committed as 886bb18 under explicit approval. Added three-function native panel controller, compact/expanded SwiftUI shell and app wiring in three app files. Isolated build exits 0, valid Info.plist. Session menu retained pending usable notch replacement. N3 remains open until actual-app verification. |

| 3 | 2026-10-29T21:08+08:00 | 1 launch/build pass; 2 previous full 64 pass; 3 compact/expanded shell verified, detailed acceptance pending; 4 not implemented; 5 partial | New bundle launched successfully. Computer Use now binds the new panel. AX showed Expand sessions; click showed Collapse sessions and Sessions/No sessions observed yet; second click restored compact header. Actual screenshots observed. No user screenshot requests. Panel shell task ready for commit approval; N3 full focus/hit-testing and session/usage acceptance remain open. |

| 4 | 2026-10-29T21:11+08:00 | 1 build pass; 2 previous 64 pass, not rerun; 3 refinement awaiting relaunch; 4 not implemented; 5 incomplete | User requested border removal, wider expansion and smooth animation. Disabled native shadow; expanded width 560 points; 0.24-second native frame/SwiftUI transitions with Reduce Motion respected. Isolated build exits 0. Runtime appearance/animation not yet confirmed. Refinement touches placement model and two panel files. |

| 5 | 2026-10-29T21:13+08:00 | 1 previous corrected build pass; 2 previous 64 pass; 3 compact rounded shape observed, latest expansion/animation pending; 4 not implemented; 5 whitespace pass, acceptance incomplete | Reconnected using tool-reported /tmp app path after resetting stale UI binding. Compact screenshot shows rounded bottom shape. Actions repeatedly report app changed even after AX refresh; latest expansion width/animation not verified. No additional code changes or duplicate screenshots requested. |

| 6 | 2026-10-29T21:14+08:00 | 1 previous build pass; 2 focused five pass, full target pending; 3 latest animation/width unverified; 4 not implemented; 5 whitespace pass | Revalidated current files and branch. Placement tests pass unchanged against 560-point expanded width. Preparing separate panel and width commits for approval; no staging/commit without approval. No UI retry or provider/config access. |

| 7 | 2026-10-29T21:20+08:00 | 1 build pass; 2 previous 64 pass, not rerun; 3 session details implemented, actual-app acceptance pending; 4 not implemented; 5 whitespace pass, tasks open | Panel and width committed as 6bf60c0/4ed152a. Added disclosure rows keyed by SessionKey with full project/session identity, status, refresh time and retained requests. Menu now has Show Notch and Quit only. Three app files changed; isolated build exits 0. No N4/I1 checkbox tick without actual-app verification. |

| 8 | 2026-10-29T21:23+08:00 | 1 build pass; 2 focused five selection tests pass; 3 ordering/selection wired, runtime pending; 4 provider visibility rule tested, sources pending; 5 whitespace pass | Session-details commit d59fef3. Frozen five new selection/provider tests first failed missing-type baseline, then passed. Added three pure presentation functions: active providers exclude ended/unsupported sessions, confirmed requests sort first, valid selection survives priority changes. Notch view now uses ordering and selection reconciliation. No quota connection yet. |

| 9 | 2026-10-29T21:24+08:00 | 1 previous build pass; 2 previous focused five pass; 3 runtime acceptance pending; 4 sources not implemented; 5 whitespace pass | Presentation commit approval pending; no staging. Reviewed U1 source identity/window/freshness requirements and corrected stale STATUS activation/implementation claims. STATUS is a separate checkpoint change outside the already proposed commit paths. No new source/config changes. |

| 10 | 2026-10-29T21:25+08:00 | 1 previous build pass; 2 previous focused five pass; 3 runtime pending; 4 sources pending; 5 whitespace pass | Same commit approval remains unanswered for goal turns 8–10. User requested commit after each task; no next implementation task started and no unauthorized staging occurred. Checkpoint and mark blocked until approval. |

| 11 | 2026-10-29T21:28+08:00 | 1 previous build pass; 2 focused five pass; full suite 74 tests in ten suites pass; 3 actual-app acceptance pending; 4 store implemented, live sources pending; 5 whitespace pass | Resumed after approved aa552d6 commit. Added three-function bounded usage store and five frozen tests after missing-type baseline. Active-only filtering, independent anonymous sources, replacement, malformed/old rejection, missing/nonstandard windows and stale/no-reset-zero covered. STATUS checkpoint included in this three-file task. No provider/config access. |

## Final result

Incomplete, running; presentation committed and usage-store task awaits commit approval. Placement committed; panel shell built and expanded/collapsed in actual app. Session details and quota integration remain outstanding.

Planning clarification: provider visibility depends on active observed sessions, not cached quota. Codex-only hides Claude, Claude-only hides Codex, both active shows both. The goal was subsequently activated.

Visual correction requested by user: replace the flat panel background with a black continuous shape whose upper corners extend above the screen edge and lower corners remain rounded. Collapsed shadow disabled. Corrected build exits 0. Relaunch/visual confirmation of the correction remains pending; do not claim it was observed in the running app.
