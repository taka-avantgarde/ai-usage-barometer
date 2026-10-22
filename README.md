🇬🇧 English · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Track Claude, Codex, and Gemini side-by-side in real time across 3 Mac surfaces: Menu bar, Dock icon, and Floating bar.**

| AI Service | Color | Supported Sources |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (OAuth usage API & Keychain) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI & web tokens (`5h` & `1w`) |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop & IDE (`5h` & `1w`) |

<img src="assets/hero.svg" alt="AI Usage Barometer in the menu bar, the Dock icon and a floating bar" width="725">

## ⚡ Install — paste this one line into Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

That is the app. No Homebrew, no Xcode, no SwiftBar. macOS 13 or later. The first time it runs it asks where it should live — menu bar, Dock icon or floating bar — and you can change your mind from its menu at any time.

Already on SwiftBar, or want it there? This line installs the plugin instead, adding Homebrew and SwiftBar only if they are missing. Re-running is safe, so use the same line to update.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

## One menu-bar item

Claude, Codex, and Gemini share a single item, separated by a thin rule. Bars are battery-style: **the filled part is capacity left**, and the dotted tail is what has been spent. Percentages are remaining capacity too.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

The menu bar is drawn as a vector image so each service keeps its own colour inside one item. It uses a dark charcoal `#20252B` backdrop with light labels for readability on the translucent macOS menu bar. A plain-text fallback is used automatically when that is unavailable.

All three palettes use saturated, high-contrast colours: Claude uses orange,
Codex uses cyan, and Gemini uses emerald green. At 11–30% remaining, warning shades mix in orange; at 10% or
less, critical shades mix in vivid red. Codex keeps blue in both blends:

| Stage | Usage | Claude | Codex | Gemini |
|---|---:|---|---|---|
| healthy | 0–69% used | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| warning | 70–89% used | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| critical | 90–100% used | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Settings

Right-click the gauge (or open the dropdown and choose **⚙ Display settings**). It opens a persistent settings panel with macOS/iOS-style ON/OFF toggle switches and a **Save** button, so you can toggle multiple options without the panel closing after each click.

The plugin interface is English-only. This GitHub documentation remains available in 14 languages.

| Setting | Effect |
|---|---|
| **Claude** (`ON` / `OFF`) | Show or hide Claude entirely (cascades to both `5h` and `1w`) |
| **Claude `5h`** + **`%`** | Show or hide the 5-hour window and its percentage |
| **Claude `1w`** + **`%`** | Show or hide the 1-week (7d) window and its percentage |
| **Codex** (`ON` / `OFF`) | Show or hide Codex entirely (cascades to both `5h` and `1w`) |
| **Codex `5h`** + **`%`** | Show or hide the 5-hour window (e.g. Codex 5h) and its percentage |
| **Codex `1w`** + **`%`** | Show or hide the 1-week window (e.g. Codex 7d) and its percentage |
| **Gemini** (`ON` / `OFF`) | Show or hide Gemini entirely (cascades to both `5h` and `1w`) |
| **Gemini `5h`** + **`%`** | Show or hide the 5-hour window (`5h`) and its percentage |
| **Gemini `1w`** + **`%`** | Show or hide the 1-week window (`1w` / 7d) and its percentage |
| **Placement** (`Menu bar` / `Dock icon` / `Floating bar`) | Choose any combination of the 3 macOS surfaces |
| **Refresh interval** (`1m` / `3m` / `5m`) | Poll interval in minutes |

Windows are always displayed in **`5h` → `1w`** order. Turning a parent service (`Claude`, `Codex`, or `Gemini`) OFF automatically turns off both its `5h` and `1w` switches and skips its data refresh; turning both `5h` and `1w` OFF automatically turns the parent service OFF. When every gauge is hidden, a neutral `AI …` item remains so settings stay clickable. Settings live in `~/.cache/claude-codex-bar/` and survive upgrades.

The app and plugin check GitHub Releases automatically every 15 minutes and update in the background when a new release is published.

## The app — pick where it lives

The menu bar is not always available. On some Macs a status item is placed
off-screen and never drawn, and beside a notch there may simply be no room.
The app puts the same gauges somewhere you choose instead.

| Place | What it is |
|---|---|
| **Menu bar** | The app's own status item, one line |
| **Dock icon** | The Dock icon itself becomes the gauge. Costs no screen space |
| **Floating bar** | A small always-on-top bar. Drag it anywhere; it stays put |

All three are independent — turn on any combination. Right-click the bar, the
Dock icon or the menu-bar item for the settings: each service on or off,
percentages, where it lives, and **Details…** for the panel with reset times.

Switching a gauge off gives the width back — the item shrinks to fit whatever is left, so the menu bar keeps the difference.

An orange arrow means an update is waiting. **Update to vX.Y.Z** in the same menu installs it in place.

One line, no Xcode. macOS 13 or later.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

The app is signed and notarised by Apple, so it opens straight from the download — no warning, no right-click.

Or run it from source, which does need Xcode:

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

Settings are shared with the SwiftBar plugin, so the two never disagree.

## Data sources

**Claude** is read from the OAuth usage endpoint `api.anthropic.com/api/oauth/usage`, using the access token Claude Code already stores in the macOS Keychain item `Claude Code-credentials` (falling back to `~/.claude/.credentials.json`). Nothing is written to either location, and the token never leaves your Mac except in the request to Anthropic. macOS may ask you to allow Keychain access on first run — choose **Always Allow**.

Results are cached for the refresh interval, so the endpoint is polled at most once per interval. If a temporary network error or 429 occurs, the last good reading stays on screen; if credentials are removed or logged out, stale cached data is cleared immediately.

**Codex** is read from the local helper `codex-usage.sh` that the installer places in `~/SwiftBar/.ai-usage-barometer/`. It tracks both `5h` and `1w` (`7d`) windows in `5h → 1w` order (even when the 5-hour burst window has not been consumed yet).

**Gemini** is read from the local helper `gemini-usage.sh` in `~/SwiftBar/.ai-usage-barometer/`. It tracks both `5h` (Five Hour Limit) and `1w` (Weekly Limit) quotas across Antigravity Desktop App 2.0 and Antigravity IDE without credentials or external API calls via local language server Connect RPC (`RetrieveUserQuotaSummary` / `GetUserStatus`), read-only SQLite state fallback, and caching.

## Troubleshooting

**The bar shows `Claude ⚠`.** Open the dropdown for the reason. *Sign in to Claude Code again* means the OAuth token expired — re-authenticate with the Claude Code CLI or IDE extension. This is **not** the Claude desktop app: signing into Claude.app does not refresh this token. *Rate limited* clears on its own; the plugin backs off 15 minutes and shows the remaining wait. The Keychain item was not found. Sign in with Claude Code on this Mac, then click **Refresh now**.

**Codex shows a warning.** The helper is missing or Codex has not produced data yet. Re-run the installer, then use Codex CLI once.

**Gemini shows a warning.** Antigravity has not been launched yet or the local helper is waiting for data. Launch Antigravity Desktop or Antigravity IDE.

**Colours differ between the menu bar and the dropdown.** macOS can treat a translucent menu bar as light while menus render dark. The menu bar uses the two-colour vector renderer whenever Python is available; it falls back to one-colour text only when Python is unavailable.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
