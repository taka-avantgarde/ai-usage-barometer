🇬🇧 English · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Install — paste this one line into Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

The same command works on Macs with or without Homebrew. It installs Homebrew when needed, plus `jq`, SwiftBar, the plugin, and its local helpers. Re-running is safe, so use the same line to update.

## One menu-bar item

Claude and Codex share a single item, separated by a thin rule. Bars are battery-style: **the filled part is capacity left**, and the dotted tail is what has been spent. Percentages are remaining capacity too.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

The menu bar is drawn as a vector image so each service keeps its own colour inside one item. It uses a dark charcoal `#20252B` backdrop with light labels for readability on the translucent macOS menu bar. A plain-text fallback is used automatically when that is unavailable.

Both palettes use saturated, high-contrast colours: Claude uses orange and
Codex uses cyan. At 11–30% remaining, warning shades mix in orange; at 10% or
less, critical shades mix in vivid red. Codex keeps blue in both blends:

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| healthy | 0–69% used | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| warning | 70–89% used | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| critical | 90–100% used | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Settings

Open the dropdown and choose **⚙ Display settings**. It opens a persistent settings panel, so you can change several options without the panel closing after each click. Changes take effect immediately.

The plugin interface is English-only. This GitHub documentation remains available in 14 languages.

| Setting | Effect |
|---|---|
| Show Claude | Show or hide Claude entirely |
| Show Claude 5h | Show or hide the 5-hour window |
| Claude 5h percentage | Show or hide the 5-hour percentage |
| Show Claude 7d | Show or hide the 7-day window |
| Claude 7d percentage | Show or hide the 7-day percentage |
| Show Codex | Show or hide Codex entirely |
| Show Codex 5h | Show or hide the 5-hour window when Codex provides it |
| Codex 5h percentage | Show or hide the 5-hour percentage |
| Show Codex 7d | Show or hide the 7-day window |
| Codex 7d percentage | Show or hide the 7-day percentage |
| Refresh interval | 1, 3, or 5 minutes |

When every gauge is hidden, a neutral `AI …` item remains so settings stay clickable. Menu-bar colour is decided only by the gauges actually shown. Settings live in `~/.cache/claude-codex-bar/` and survive upgrades.

Turning Claude or Codex off skips that service's data refresh. Its 5h, 7d, and percentage settings remain visible but are dimmed and locked; their previous values are restored when the service is turned on again.

If both the 5h and 7d windows for a service are unchecked, that service and its errors are hidden completely, and its data source is not queried.

The plugin checks GitHub Releases at most once a day. When an operator update is available, the dropdown and Display settings show a notice with release notes and an **Update now** button.

## Data sources

**Claude** is read from the OAuth usage endpoint `api.anthropic.com/api/oauth/usage`, using the access token Claude Code already stores in the macOS Keychain item `Claude Code-credentials` (falling back to `~/.claude/.credentials.json`). Nothing is written to either location, and the token never leaves your Mac except in the request to Anthropic. macOS may ask you to allow Keychain access on first run — choose **Always Allow**.

Results are cached for the refresh interval, so the endpoint is polled at most once per interval. If a refresh fails, the last good reading stays on screen instead of blanking the bar.

**Codex** is read from the local helper `codex-usage.sh` that the installer places in `~/SwiftBar/.ai-usage-barometer/`. Its windows are dynamic: a 5-hour bar appears only when Codex returns one.

## Troubleshooting

**The bar shows a Claude warning.** The Keychain item was not found. Sign in with Claude Code on this Mac, then click **Refresh now**.

**Codex shows a warning.** The helper is missing or Codex has not produced data yet. Re-run the installer, then use Codex CLI once.

**Colours differ between the menu bar and the dropdown.** macOS can treat a translucent menu bar as light while menus render dark. The menu bar uses the two-colour vector renderer whenever Python is available; it falls back to one-colour text only when Python is unavailable.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
