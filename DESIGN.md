# Design decisions — locked

This file records the decisions behind `claude-codex.60s.sh` so they are not
re-litigated or accidentally reverted. Each entry states what the behaviour is
and, where the reason is not obvious, why the alternative was rejected.

## Bars

Bars are **battery-style**: the filled part is capacity **left**, and the tail
is what has been spent. Percentages shown next to the bars are remaining
capacity too. An earlier version showed usage instead; that was wrong.

The spent tail is a **fine dither over the full bar height**, matching the `░`
texture of the dropdown. Coverage is about 17%, deliberately lighter than `░`
(25%), because a straight copy reads as bold. In the vector menu bar this is
0.9pt squares on a 2.2pt grid, offset by half a pitch on alternate rows.

Colour is driven by **usage**, not by what is left, so a nearly empty bar shows
a deep tone.

## Colour

Each service keeps its own hue. Stages darken within that hue instead of
switching to a traffic-light green/amber/red — the point is to see at a glance
which service a bar belongs to.

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| healthy | 0–69% | `#C66D28` | `#1A8BA6` |
| warning | 70–89% | `#B65A1E` | `#52768A` |
| critical | 90–100% | `#C52E22` | `#783F78` |

Healthy bars keep their service identity: orange for Claude and cyan for Codex.
Warning bars mix in orange when 11–30% remains; Codex retains a blue majority.
Critical bars mix in vivid red when 10% or less remains; Codex combines it with
blue as violet-red. Every stage targets at least about 3:1 contrast against a
light gray (`#E6E6E6`) macOS menu-bar background.

**Do not use `light,dark` colour pairs.** macOS can treat a translucent menu bar
as light while menus render dark, so a pair makes the same gauge show two
different colours on the same screen. One value per stage avoids this entirely.

## Menu bar

A SwiftBar text item can carry only one colour, so the menu bar is drawn as a
**PDF vector image**. That is what allows Claude and Codex to keep distinct
colours inside a single item. The vector renderer is always used when
`python3` is available; a plain-text fallback (one colour) is used only when
the renderer is unavailable. The vector item has a dark charcoal backdrop
(`#20252B`) with light labels, so the service colours remain legible on
macOS's translucent light menu bar.

Colour of the fallback: Claude's colour while Claude is shown, otherwise Codex's.

Hiding every gauge would leave an empty, unclickable item, so Claude's 5-hour
bar is always kept. Menu-bar colour is decided only by gauges actually shown, so
a hidden gauge never tints the bar.

## Settings

All toggles live under **⚙ Display settings** and flip on a single click. State
is in `~/.cache/claude-codex-bar/` and survives upgrades.

`claude_on`, `c5`, `c5p`, `c7`, `c7p`, `codex_on`, `cxp`, `iv`

The settings menu is also emitted on the error paths, so a broken state can
still be recovered from the dropdown.

## Language

The plugin interface is English-only, with no language selector or locale-based
switching. GitHub documentation remains available in 14 languages: en, ja, es,
ar, fr, de, zh, ko, pt, nl, it, vi, id, and th.

## Data

**Claude** — OAuth usage endpoint, authenticated with the token Claude Code
already stores in the Keychain item `Claude Code-credentials`, falling back to
`~/.claude/.credentials.json`. Neither is written to. This was chosen over the
`statusLine` JSON route because it works without any Claude Code setup step.

Responses are cached for the refresh interval, so the endpoint is polled at most
once per interval. On a failed refresh the last good reading stays on screen
rather than blanking the bar.

**Codex** — parsed from the local helper `.ai-usage-barometer/codex-usage.sh`.
Its windows are dynamic: a 5-hour window appears only when Codex returns one.

The helper output is the interchange format, so `█` and `░` must stay in the
parser's character class if either helper's fill characters ever change.


## Failure states must stay visible and must not amplify (v0.4.0)

**A working service must never erase the other's error.** The menu bar switches
to a vector PDF image whenever any window has bars to draw, and a plain-text
menu item carries only one string. So when Claude errored while Codex rendered
fine, the image drew only Codex and the `"Claude ⚠"` text was discarded. The
image is now skipped whenever either service has an error, falling back to text
that names both. Colour per service is worth less than knowing something broke.

**A failed fetch must record that it happened.** The response cache was only
written on success, so a 429 left the attempt time at 0 and every 60-second run
hit the endpoint again — the rate limit could never expire. `claude.attempt`
now stores the earliest time worth retrying, written on every failure. Rate
limits back off 15 minutes; everything else waits one refresh interval. Success
deletes the file so recovery is immediate.

**An error message is a snapshot, not a state.** Reusing the stored message
during backoff showed `Rate limited` long after the real problem had become an
expired token, sending diagnosis down the wrong path. Backoff now appends the
remaining wait so a stale message is visibly stale, and 401 uses the short
interval so re-authentication is picked up within minutes.

401 reads `Sign in to Claude Code again`, not `HTTP 401`. The account it needs
is Claude Code's, which is **not** the Claude desktop app — signing into
Claude.app does not refresh this token.

## The settings view must not be able to lie (v0.4.0)

`<swiftbar.persistentWebView>` keeps settings.html alive across refreshes rather
than reloading it, so its checkboxes were seeded once from the query string and
never re-read. During this bug hunt the panel showed *Show Claude* ticked while
`claude_on` was `0`, which made the plugin look broken when it was faithfully
doing what it was told.

The plugin now writes `state.json` beside settings.html on every run, and the
page re-fetches it on load, on focus, on visibility change, and shortly after
each save. The query string remains only as the first paint.


## A Codex window label is not a stable identifier (v0.4.1)

Per-window toggles (`cx5`/`cx7`) matched Codex's window by its literal label
text, `"5h"` or `"7d"`. When a plan change made the Codex helper report a
single `"30d"` window instead (observed on a free-tier/expired-contract
account), the label matched neither case, fell through to the wildcard
branch, and that branch means *always show* — so the per-window toggle
silently stopped doing anything for that window, regardless of what the user
had set.

Toggle matching is now positional: whichever window the helper returns first
is controlled by `cx5`/`cx5p`, the second by `cx7`/`cx7p`, no matter what
either is labelled. `state.json` also carries the current labels (`cx_l1`,
`cx_l2`) so the settings panel's "Show Codex 5h" text becomes "Show Codex
30d" when that is what is actually being toggled, instead of naming a window
that is not the one on screen.

## An update nobody can see is not a release (v0.5.1)

The plugin has always checked GitHub's `releases/latest` endpoint, but every
version so far was published as a git tag only. A tag is not a release: the
endpoint answers 404, the check yields nothing, and the notice never fires.
No installed copy had ever been told an update existed.

Publishing therefore means creating a GitHub Release, not pushing a tag.

A notice that cannot be acted on is only half a notice. The dropdown carries
**Install now**, which re-runs the installer in place via `--update`, and the
menu bar itself shows an arrow so a pending update is visible without opening
anything.

That arrow is a vector path drawn into the menu-bar image, not a character.
v0.5.1 drew it as text and fell back to the text renderer for as long as an
update was pending — so the two-colour bar vanished and stayed gone until the
user updated. A notice may not degrade the thing it is attached to. The
embedded PDF has no glyph for an arrow, so the arrow is built from `m`, `l`
and `re`, and the bars beside it render exactly as before (v0.5.2).
