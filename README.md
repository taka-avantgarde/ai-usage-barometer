🇬🇧 English · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Install — paste this one line into Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

The same command works on Macs with or without Homebrew. It installs Homebrew when needed, plus `jq`, SwiftBar, the unified plugin, and its local helpers.

## ✅ v0.2.7: stable menu-bar recovery

v0.2.7 bundles the tested Codex helper in this repository, removes the Bash 4-only `;;&` syntax that fails on macOS system Bash 3.2, and rebuilds the exact-colour vector header after every upgrade.

Claude and Codex are evaluated independently: missing data from one provider no longer hides the other. Every 5h/7d window keeps its own colour stage, and existing **Settings** choices are preserved.

## Claude data source


Claude usage is captured from Claude Code's documented `statusLine` JSON, specifically `rate_limits.five_hour` and `rate_limits.seven_day`. The installer adds a small local wrapper and preserves any status line you already use.

After installing, open Claude Code and send one message. Claude Code provides `rate_limits` only after the first API response in a session, and either window may be independently absent. The menu bar therefore shows only real windows returned by Claude Code; it never converts `Warming up` or missing data into a made-up 100% value.

The Claude integration does **not** read an OAuth token, macOS Keychain item, or `~/.claude/.credentials.json`.

## One menu-bar item

The macOS menu bar does not show the service names. Claude uses orange tones and Codex uses blue tones.

```text
5h ███░░  7d ████░  │  7d ███░░
└──── Claude ────┘     └─ Codex ─┘
```

Every window is coloured independently:

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| 1 — healthy | 0–69% used | `#b54f02` | `#4F7FA8` |
| 2 — warning | 70–89% used | `#B85A00` | `#0e8ba1` |
| 3 — critical | 90–100% used | `#ff7045` | `#ed5d40` |

## Dynamic windows and settings

Codex windows remain dynamic. If Codex returns a real 300-minute window, the `5h` bar appears automatically; when it returns only the weekly window, only `7d` is shown.

The dropdown shows service names, used percentage, remaining capacity, reset time, and the source timestamp. Under **Settings**, Claude and Codex can be hidden independently, and the refresh interval can be set to 1, 3, or 5 minutes.

## Claude troubleshooting

If the Claude bars have not appeared, open Claude Code and complete one response. Custom status lines require workspace trust, and Claude Code does not run them while `disableAllHooks` is `true`. Existing status-line output is chained through the wrapper and restored by the uninstaller.

Official field reference: [Claude Code status line documentation](https://code.claude.com/docs/en/statusline#rate-limit-usage).

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
