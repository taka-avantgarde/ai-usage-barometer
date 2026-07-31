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
| healthy | 0–69% | `#B86B54` | `#4F7FA8` |
| warning | 70–89% | `#A85337` | `#0E8BA1` |
| critical | 90–100% | `#9C3D21` | `#ED5D40` |

Claude is a matte deep pink-beige: low enough in value to stay matte, saturated
enough not to wash out. Pushing saturation further turns it rust-coloured and
stops reading as pink-beige.

**Do not use `light,dark` colour pairs.** macOS can treat a translucent menu bar
as light while menus render dark, so a pair makes the same gauge show two
different colours on the same screen. One value per stage avoids this entirely.

## Menu bar

A SwiftBar text item can carry only one colour, so the menu bar is drawn as a
**PDF vector image**. That is what allows Claude and Codex to keep distinct
colours inside a single item. A plain-text fallback (one colour) is used when
`python3` is missing or when the user turns off two-colour drawing.

Colour of the fallback: Claude's colour while Claude is shown, otherwise Codex's.

Hiding every gauge would leave an empty, unclickable item, so Claude's 5-hour
bar is always kept. Menu-bar colour is decided only by gauges actually shown, so
a hidden gauge never tints the bar.

## Settings

All toggles live under **⚙ Display settings** and flip on a single click. State
is in `~/.cache/claude-codex-bar/` and survives upgrades.

`claude_on`, `c5`, `c5p`, `c7`, `c7p`, `codex_on`, `cxp`, `mb2`, `iv`, `lang`

The settings menu is also emitted on the error paths, so a broken state can
still be recovered from the dropdown.

## Language

14 languages: en, ja, es, ar, fr, de, zh, ko, pt, nl, it, vi, id, th. The
default follows `AppleLocale`; **Language** in the dropdown overrides it. No
user-facing string is hard-coded — everything goes through `T_*` and `sub()`.

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
