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

两套配色都采用高饱和度、高对比度颜色：Claude 使用橙色，Codex 使用青色。
剩余11–30%时，警告色会混入橙色；剩余10%或更少时，紧张色会混入鲜红色。Codex在两种混色中都保留较强的蓝色：

| 阶段 | 使用量 | Claude | Codex |
|---|---:|---|---|
| 正常 | 0–69% 已用 | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| 警告 | 70–89% 已用 | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| 紧张 | 90–100% 已用 | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## 设置

点击进度条并选择 **⚙ Display settings**。设置面板会保持打开，可连续修改多个选项，无需每次点击后重新打开；更改会立即生效。

插件界面仅使用英语显示。本GitHub文档仍提供14种语言版本。

| 设置项 | 作用 |
|---|---|
| 显示 Claude | 显示或隐藏 Claude |
| 显示 Claude 5h | 显示或隐藏 5 小时额度 |
| Claude 5h 百分比 | 显示或隐藏其百分比 |
| 显示 Claude 7d | 显示或隐藏 7 天额度 |
| Claude 7d 百分比 | 显示或隐藏其百分比 |
| 显示 Codex | 显示或隐藏 Codex |
| 显示 Codex 5h | 在可用时显示或隐藏 5 小时额度 |
| Codex 5h 百分比 | 显示或隐藏 5 小时百分比 |
| 显示 Codex 7d | 显示或隐藏 7 天额度 |
| Codex 7d 百分比 | 显示或隐藏 7 天百分比 |
| 刷新间隔 | 1、3 或 5 分钟 |

即使隐藏全部进度条，也会保留中性的 `AI …` 项以便打开设置。颜色只由实际显示的进度条决定。设置保存在 `~/.cache/claude-codex-bar/`，升级后仍保留。

取消 Claude 或 Codex 的勾选后，该服务将停止更新数据。5 小时、7 天和百分比设置仍会以灰暗且不可操作的状态显示；重新启用服务时会恢复之前的设置值。

如果某项服务的 5 小时和 7 天窗口均未勾选，该服务及其错误将完全隐藏，并且不会查询其数据源。

插件每天最多检查一次 GitHub Releases。运营方有更新时，菜单和显示设置会显示通知、更新说明及 **立即更新** 按钮。

## 数据来源

**Claude** 读取 OAuth 用量端点 `api.anthropic.com/api/oauth/usage`，使用 Claude Code 已保存在 macOS 钥匙串 `Claude Code-credentials`（或 `~/.claude/.credentials.json`）中的令牌。不会写入这两处，令牌除发往 Anthropic 的请求外不会离开本机。首次运行请选择 **始终允许**。

结果会在刷新间隔内缓存，因此每个间隔最多请求一次。若刷新失败，将继续显示上一次的正常数值。

**Codex** 读取安装程序放在 `~/SwiftBar/.ai-usage-barometer/` 的本地助手 `codex-usage.sh` 的输出。其额度窗口是动态的。

## 疑难排解

**出现 Claude 警告** — 未找到钥匙串条目。请在本机登录 Claude Code，然后点击 **立即刷新**。

**出现 Codex 警告** — 助手缺失或 Codex 尚未产生数据。重新运行安装程序，并使用一次 Codex CLI。

**菜单栏与下拉菜单颜色不一致** — macOS 可能把半透明菜单栏视为浅色而菜单为深色。Python 可用时始终使用双色矢量绘制；只有在缺少 Python 时才回退到单色文本。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## 许可证

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
