🇬🇧 English · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Install — paste this one line into Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

The same command works on Macs with or without Homebrew. When needed, it installs Homebrew, `jq`, SwiftBar, the unified plugin, and the Claude/Codex helper scripts.

One SwiftBar item shows both services on a single line. **The macOS menu bar does not show the names Claude or Codex.** Claude uses orange tones and Codex uses blue tones.

```text
5h ███░░  7d ████░  │  7d ███░░
└──── Claude ────┘     └─ Codex ─┘
```

## ✅ v0.2.0: the two recovery issues are fixed

- **Claude after a reset:** when Claude returns `Warming up`, zero values, null windows, or a stale pre-reset snapshot whose reset time has passed, the plugin no longer remains stuck on an error. It restores the Claude 5h and 7d gauges as reset/idle at 100% left, then replaces them with live values on the next successful refresh. No reinstall is required.
- **Codex 5h returning later:** Codex windows are detected dynamically. If Codex starts returning a 300-minute window again, the `5h` gauge is added automatically on the next refresh. If the 300-minute window is absent, only the available window such as `7d` is shown.

Use **Refresh now** in the dropdown whenever you want to request an immediate update.

## 🎨 Three independent colour stages

Every 5h or 7d window is evaluated independently. A healthy Claude 5h window and a nearly exhausted Claude 7d window can therefore use different colours at the same time.

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| 1 — healthy | 0–69% used | `#b54f02` | `#4F7FA8` |
| 2 — warning | 70–89% used | `#B85A00` | `#0e8ba1` |
| 3 — critical | 90–100% used | `#ff7045` | `#ed5d40` |

The header is rendered as a tiny vector PDF using built-in macOS tools, so SwiftBar can preserve the exact HEX colour for each window without Xcode Command Line Tools.

## Settings and details

The dropdown keeps the service names, usage, remaining capacity, and reset times. Under **Settings**, Claude and Codex can be shown or hidden independently; at least one service always remains visible. The refresh interval can be set to 1, 3, or 5 minutes.

> **Codex 5h:** Codex does not always provide a 5-hour window. The plugin never invents a missing limit. It hides the Codex 5h gauge until a real 300-minute window is returned, then adds it automatically.

Existing standalone `claude-usage.60s.sh` and `codex-usage.60s.sh` plugins are moved to a hidden support folder to prevent duplicate menu-bar items while preserving the files.

## Requirements and privacy

- macOS; the installer handles Homebrew, `jq`, and SwiftBar.
- Claude Code signed in for Claude usage.
- Codex CLI or the Codex app used on the Mac for Codex usage data.
- Authentication tokens are never printed or copied into the unified plugin cache.
- Some usage interfaces are unofficial and may require future compatibility updates.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
