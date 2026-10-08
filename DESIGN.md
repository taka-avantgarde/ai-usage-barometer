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

The plugin has always checked GitHub's `releases/latest`, but every version
before this was published as a git tag only. A tag is not a release: the
endpoint answers 404, the check yields nothing, and the notice never fires.
No installed copy had ever been told an update existed. Publishing therefore
means creating a GitHub Release, not pushing a tag.

A notice that cannot be acted on is only half a notice. The dropdown carries
**Install now**, which re-runs the installer in place via `--update`, and the
menu bar shows an arrow so a pending update is visible without opening
anything.

That arrow is a vector path drawn into the image, not a character. v0.5.1
drew it as text and fell back to the text renderer for as long as an update
was pending, so the two-colour bar vanished and stayed gone until the user
updated. A notice may not degrade the thing it is attached to. The embedded
PDF has no glyph for an arrow, so the arrow is built from `m`, `l` and `re`,
and the bars beside it render exactly as before (v0.6.0).

## The menu bar is not as wide as it looks (v0.6.0)

On a notched Mac the usable strip left of the notch is short, and anything
that does not fit is not clipped - it is simply never drawn. A plugin that
renders 325pt of bars is therefore invisible, with no error and nothing to
click. Width is a correctness constraint here, not a matter of taste.

Compact is the default: window names are dropped, bars are 20pt instead of
30, percentages lose their `%` sign and drop to 9pt, and the gaps tighten.
Claude and Codex together come to about 168pt, half of what they were, and
120pt with percentages off. Nothing is lost that the dropdown does not still
spell out in full, and the windows keep their order, so the first bar is the
first window whatever it is called. **Compact** in the settings menu turns
the names back on.

## Where the gauge lives is the user's choice (v0.7.0)

The menu bar was treated as the only possible home, and it turned out not to be
a home at all on some machines: on macOS 26 the status items were created,
reported a real size, and were parked off-screen at `x=-1`, where nothing draws
them. Resetting the host app's preferences did not bring them back. Beside a
notch there may also simply be no room, and an item that does not fit is not
clipped — it is never drawn, with no error and nothing to click.

So the app owns its own surfaces and offers three, as independent switches
rather than a three-way choice, because wanting the menu bar and a floating bar
at once is an ordinary wish: its own status item, the Dock tile (which costs no
screen space at all), and a floating bar that can be dragged anywhere and stays
where it is put. Turning all three off would leave nothing to turn one back on
from, so the floating bar survives that.

One renderer draws all of them. The Dock tile, the floating bar, the detail
panel and the menu-bar image choose metrics and nothing else, so the surfaces
cannot drift apart. Each has one constraint of its own: the Dock tile is a fixed
128pt and lays its rows out in columns so percentages sit flush right instead of
being clipped; the menu bar has 22pt of height and so stays on one line; the
floating bar groups by service, Claude above Codex, with bars at 40pt because
what is read is the colour and the proportion left, not the length.

`claude-codex.60s.sh --json` is the only data layer. The app re-implements no
authentication, no backoff, no settings and no Codex parsing, and writes its
settings back through `--set` into the same `~/.cache/claude-codex-bar/`. The
plugin and the app therefore cannot disagree about what is on.

## An unsigned app still has to be installable (v0.7.0)

Asking people to install Xcode before they can see a usage bar is not an
install step, it is a refusal. `app/bundle.sh` therefore produces a real
`.app` — binary, `Info.plist`, a generated icon, and the plugin carried inside
`Resources` so the app works on a machine that never had SwiftBar — and
`install-app.sh` fetches that from the latest Release in one line.

The app is not signed or notarised, so macOS quarantines the download and
Gatekeeper refuses it. The installer clears the quarantine attribute on the
copy it just placed, and both the script and every README say so plainly:
it is the publisher's own build, fetched over HTTPS from the publisher's own
release, and the alternative is a right-click-Open dance that most people read
as the app being broken. A Developer ID signature removes the need for that
line entirely, and when one exists the line should go.

The icon is drawn by the build script rather than committed as a binary, for
the same reason the menu bar is drawn rather than described: three bars, two
Claude-orange and one Codex-cyan, battery-style like everything else. It says
what the app is before it is opened, and it cannot drift out of step with the
palette, because it is generated from it.

## jq is a convenience, not a requirement (v0.7.1)

Shipping a `.app` and then needing Homebrew to read a number is not shipping an
app. Every JSON read — the Keychain credentials, the usage response, the
release check, and `--json` itself — went through `jq`, so anyone who installed
only the app got `Cannot read …` and no way to tell why.

`jq` is still used when it is there, because it is the robust reader. When it
is not, three fixed shapes are picked apart with `sed` instead, and `--json` is
assembled with `printf`. The fallback is deliberately not a JSON parser: it
knows only the fields this plugin reads, which is why a hundred lines of
parsing are not needed to remove the dependency.

Both paths were compared field by field against the `jq` build on the same
input and differ in nothing but the version string.

## A first run that asks one question (v0.7.2)

The settings are behind a right-click, and a right-click is not discoverable on
a bar nobody told you was clickable. The first launch therefore shows the three
places side by side, drawn with the user's own real numbers by the same
renderer, and clicking one is the answer — no explanation, no OK button. It
waits for real data before appearing, because three empty frames are not a
choice. It never appears again, and the menu can change the answer forever
after.

The floating bar stays out of the way on its own. It is no longer
`fullScreenAuxiliary`, and it hides while a full-screen app is frontmost,
detected by the menu bar's absence from `visibleFrame`. It also snaps to a
screen edge when dropped near one, a quarter-second after the hand stops, since
snapping during the drag fights the hand that is dragging.

Low-usage alerts fire once at 10% and rearm at 20%. A notification that repeats
every poll is a notification that gets switched off, and one that fires again
the moment a bar wobbles across the line is the same thing more slowly.

## The quarantine workaround should delete itself (v0.7.2)

`bundle.sh` signs and notarises when `AIB_SIGN_ID` and `AIB_NOTARY_PROFILE` are
set, and does neither when they are not, so an unsigned build stays possible for
anyone without a Developer ID. `install-app.sh` asks `spctl` whether the copy it
just placed is already accepted, and only clears the quarantine attribute when
it is not.

That day arrived with v0.7.2, which ships signed by Developer ID and notarised,
stapled, and checked with the same `spctl` assessment a downloaded copy faces.
The workaround is still in the installer and is now never reached — which is the
point of having written it that way.

## The app is the product; the script is the engine (v0.7.2)

The README opened with "install SwiftBar", which described what this was a year
ago rather than what it is. The app needs no Homebrew, no Xcode and no SwiftBar,
it works where the menu bar does not, and it is what a new person should get.
So the first line of every README installs the app, and the plugin follows as
the alternative for people already on SwiftBar — who keep working, keep
updating through the same line, and lose nothing.

`claude-codex.60s.sh` is not demoted by this. It remains the only implementation
of authentication, backoff, settings and Codex parsing, and the app carries a
copy inside its bundle. SwiftBar compatibility is then free: the file is already
in the format SwiftBar reads, and keeping it costs nothing because the app needs
the file anyway. New behaviour goes to the app; the script changes when the data
layer changes.

The App Store is not a destination for this. A sandboxed app cannot read Claude
Code's Keychain item or run the Codex helper, so there is no version of this
that ships there — which also settles the question of rewriting the engine in
Swift. One implementation, two front ends.
