🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 简体中文 · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 安装 — 在终端粘贴这一行

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

无论是否已安装 Homebrew，都可使用同一命令，并自动安装所需组件。

## ✅ v0.2.7：稳定恢复菜单栏显示

v0.2.7 将经过测试的 Codex 辅助脚本固定在本仓库中，移除了 macOS 自带 Bash 3.2 不支持的 `;;&` 语法，并在每次升级后重新生成精确颜色的矢量菜单栏标题。

Claude 与 Codex 会独立判断：一个服务没有可用数据时，不会再导致另一个服务消失。每个 5h/7d 窗口都有独立的颜色阶段，并保留现有的 **Settings** 选择。

## Claude 数据来源


Claude 使用量来自 Claude Code 文档化的 `statusLine` JSON：`rate_limits.five_hour` 与 `rate_limits.seven_day`。安装器会保留已有状态栏输出。

安装后请打开 Claude Code 并完成一次回复。`rate_limits` 只会在会话首次 API 回复后出现，5h 和 7d 也可能分别缺失。工具只显示真实返回的窗口，不会把 `Warming up` 或缺失数据伪造成 100%。

不会读取 OAuth 令牌、macOS 钥匙串或 `~/.claude/.credentials.json`。

## 菜单栏只显示一个项目

Claude 使用橙色，Codex 使用蓝色，macOS 菜单栏不显示服务名称。每个窗口独立着色。

| 阶段 | 使用率 | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex 返回真实的 300 分钟窗口时会自动添加 `5h`；只有周窗口时只显示 `7d`。可在 **Settings** 中隐藏服务并选择 1、3 或 5 分钟刷新。

如果 Claude 条形未出现，请打开 Claude Code 并完成一次回复。`statusLine` 需要工作区信任，且在 `disableAllHooks: true` 时不会运行。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
