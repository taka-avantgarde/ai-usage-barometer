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

The menu bar is drawn as a vector image so each service keeps its own colour inside one item. A plain-text fallback is used automatically when that is unavailable.

Colour is driven by usage, so a nearly empty bar reads as a deep tone:

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| healthy | 0–69% used | `#F2C6A0` | `#7299B9` |
| warning | 70–89% used | `#EDA66F` | `#3EA2B4` |
| critical | 90–100% used | `#E88952` | `#F17D66` |

## Settings

Open the dropdown and use **⚙ Display settings**. Every entry toggles on click and takes effect immediately in both the menu bar and the dropdown.

| Setting | Effect |
|---|---|
| Show Claude | Show or hide Claude entirely |
| Show Claude 5h | Show or hide the 5-hour window |
| Claude 5h percentage | Show or hide the 5-hour percentage |
| Show Claude 7d | Show or hide the 7-day window |
| Claude 7d percentage | Show or hide the 7-day percentage |
| Show Codex | Show or hide Codex entirely |
| Codex percentage | Show or hide Codex percentages |
| Two-colour menu bar | Vector drawing (two colours) or plain text (one colour) |
| Refresh interval | 1, 3, or 5 minutes |
| Language | 14 languages; follows macOS by default |

Hiding everything would leave an unclickable empty item, so the plugin always keeps Claude's 5-hour bar. Menu-bar colour is decided only by the gauges actually shown. Settings live in `~/.cache/claude-codex-bar/` and survive upgrades.

## Data sources

**Claude** is read from the OAuth usage endpoint `api.anthropic.com/api/oauth/usage`, using the access token Claude Code already stores in the macOS Keychain item `Claude Code-credentials` (falling back to `~/.claude/.credentials.json`). Nothing is written to either location, and the token never leaves your Mac except in the request to Anthropic. macOS may ask you to allow Keychain access on first run — choose **Always Allow**.

Results are cached for the refresh interval, so the endpoint is polled at most once per interval. If a refresh fails, the last good reading stays on screen instead of blanking the bar.

**Codex** is read from the local helper `codex-usage.sh` that the installer places in `~/SwiftBar/.ai-usage-barometer/`. Its windows are dynamic: a 5-hour bar appears only when Codex returns one.

## Troubleshooting

**The bar shows a Claude warning.** The Keychain item was not found. Sign in with Claude Code on this Mac, then click **Refresh now**.

**Codex shows a warning.** The helper is missing or Codex has not produced data yet. Re-run the installer, then use Codex CLI once.

**Colours differ between the menu bar and the dropdown.** macOS can treat a translucent menu bar as light while menus render dark. The plugin uses one colour per stage for exactly this reason; if it still looks off, turn off two-colour drawing to compare.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
