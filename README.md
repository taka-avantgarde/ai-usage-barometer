🇬🇧 English · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Install — paste one line into Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

The same command works whether Homebrew is already installed or not. It installs Homebrew when necessary, then installs `jq`, SwiftBar, the unified plugin, and its Claude/Codex helpers.

A single SwiftBar item shows both services on one line. **No Claude or Codex name appears in the macOS menu bar.** Claude uses a dark, saturated orange and Codex a muted steel blue.

```text
5h ███░░  7d ████░  │  7d ███░░
└─ Claude, dark orange ┘  └ Codex, muted steel blue ┘
```

## 🎨 Three independent colour stages

Each `5h` and `7d` window is evaluated **independently**, so a healthy 5h window and a nearly exhausted 7d window can have different colours at the same time.

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| 1 — high remaining capacity | 0–69% used | `#b54f02` | current blue `#4F7FA8` |
| 2 — warning | 70–89% used | `#B85A00` | `#0e8ba1` |
| 3 — critical | 90–100% used | `#ff7045` | `#ed5d40` |

## Settings

Open the dropdown and use **Settings** to show or hide Claude or Codex independently. At least one service remains visible. The same menu also controls the 1, 3, or 5 minute refresh interval.

## Usage details

The dropdown shows each service in its own coloured section, including used/remaining percentage and reset time. Service names are kept inside the dropdown so the source of each gauge remains clear.

> **Codex 5-hour window:** Codex does not always return a 5-hour limit. When the account has no 5-hour limit, or Codex omits it from usage data, the plugin hides the 5h Codex bar and displays only the available window such as 7d. It never invents a missing limit.

## Existing Claude/Codex plugins

The installer moves existing `claude-usage.60s.sh` and `codex-usage.60s.sh` files into a hidden support folder, preventing duplicate menu-bar items while preserving the files.

## Requirements and privacy

- macOS with SwiftBar; the installer handles Homebrew and `jq`.
- Claude Code signed in for Claude usage.
- Codex CLI/app used on the Mac for Codex live or local snapshot data.
- Authentication tokens are never shown or copied into the unified plugin cache.
- The project depends partly on unofficial usage endpoints and may need updates when providers change them.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
