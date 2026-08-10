🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 简体中文 · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 安装 — 把这一行粘贴到终端

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

无论是否已有 Homebrew，同一行都能用。只会安装缺少的部分：Homebrew、`jq`、SwiftBar、插件及本地助手。重复执行是安全的，更新也用同一行。

## 菜单栏只占一项

Claude 与 Codex 共用一项，中间以细线分隔。进度条为电量式：**填充部分是剩余额度**，点状部分是已消耗。百分比同样表示剩余。

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

菜单栏以矢量图绘制，因此同一项内每个服务都能保留各自的颜色。无法绘制时会自动改用纯文本。

颜色由使用量决定，越接近用尽颜色越深：

| 阶段 | 使用量 | Claude | Codex |
|---|---:|---|---|
| 正常 | 0–69% 已用 | `#F2C6A0` | `#7299B9` |
| 警告 | 70–89% 已用 | `#EDA66F` | `#3EA2B4` |
| 紧张 | 90–100% 已用 | `#E88952` | `#F17D66` |

## 设置

点击进度条，使用 **⚙ 显示设置**。每一项点击即切换，菜单栏与下拉菜单立即生效。

| 设置项 | 作用 |
|---|---|
| 显示 Claude | 显示或隐藏 Claude |
| 显示 Claude 5h | 显示或隐藏 5 小时额度 |
| Claude 5h 百分比 | 显示或隐藏其百分比 |
| 显示 Claude 7d | 显示或隐藏 7 天额度 |
| Claude 7d 百分比 | 显示或隐藏其百分比 |
| 显示 Codex | 显示或隐藏 Codex |
| Codex 百分比 | 显示或隐藏 Codex 百分比 |
| 菜单栏双色绘制 | 矢量绘制（双色）或纯文本（单色） |
| 刷新间隔 | 1、3 或 5 分钟 |
| 语言 | 14 种语言，默认跟随 macOS |

若全部隐藏会留下无法点击的空项，因此始终保留 Claude 的 5 小时进度条。颜色只由实际显示的进度条决定。设置保存在 `~/.cache/claude-codex-bar/`，升级后仍保留。

## 数据来源

**Claude** 读取 OAuth 用量端点 `api.anthropic.com/api/oauth/usage`，使用 Claude Code 已保存在 macOS 钥匙串 `Claude Code-credentials`（或 `~/.claude/.credentials.json`）中的令牌。不会写入这两处，令牌除发往 Anthropic 的请求外不会离开本机。首次运行请选择 **始终允许**。

结果会在刷新间隔内缓存，因此每个间隔最多请求一次。若刷新失败，将继续显示上一次的正常数值。

**Codex** 读取安装程序放在 `~/SwiftBar/.ai-usage-barometer/` 的本地助手 `codex-usage.sh` 的输出。其额度窗口是动态的。

## 疑难排解

**出现 Claude 警告** — 未找到钥匙串条目。请在本机登录 Claude Code，然后点击 **立即刷新**。

**出现 Codex 警告** — 助手缺失或 Codex 尚未产生数据。重新运行安装程序，并使用一次 Codex CLI。

**菜单栏与下拉菜单颜色不一致** — macOS 可能把半透明菜单栏视为浅色而菜单为深色。正因如此每个阶段只用一种颜色；若仍有问题，可关闭双色绘制对比。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## 许可证

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
