🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 简体中文 · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 安装——只需在终端粘贴一行

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

无论是否已安装 Homebrew，都使用同一条命令。需要时会自动安装 Homebrew、jq、SwiftBar 和统一插件。

macOS 菜单栏只显示一个项目，不显示 Claude 或 Codex 名称。Claude 为深橙色，Codex 为蓝色。

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 三档独立颜色

`5h`和`7d`会分别判断。第1档：已使用0–69%；第2档：70–89%；第3档：90–100%。

| 档位 | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## 设置

可在下拉菜单中分别显示或隐藏 Claude 与 Codex，至少保留一个服务。

> **Codex 5h:** Codex 并不总是返回 5 小时限制。如果账户没有该限制，或使用量数据未包含它，Codex 的 5h 条会自动隐藏，只显示 7d 等实际可用窗口。插件不会猜测不存在的限制。

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
