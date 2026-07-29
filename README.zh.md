🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 简体中文 · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 安装——只需在终端粘贴这一行

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

无论 Mac 是否已安装 Homebrew，都使用同一条命令。需要时会自动安装 Homebrew、`jq`、SwiftBar、统一插件以及 Claude/Codex 辅助脚本。

一个 SwiftBar 项目同时显示两个服务。**macOS 菜单栏不会显示 Claude 或 Codex 名称。** Claude 使用橙色系，Codex 使用蓝色系。

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0：两个恢复问题均已修复

- **Claude 重置后：** 当 Claude 返回 `Warming up`、零值、空窗口，或重置时间已经过去的旧快照时，插件不会再一直停留在错误状态。Claude 的 5h 和 7d 会恢复为“已重置/待机、剩余 100%”，并在下一次成功刷新时自动换成实时数据。无需重新安装。
- **Codex 的 5h 之后恢复：** Codex 窗口会动态检测。如果 Codex 再次返回 300 分钟窗口，下一次刷新时会自动加入 `5h` 进度条。未返回时只显示实际存在的窗口，例如 `7d`。

需要立即更新时，可在下拉菜单中选择 **Refresh now**。

## 🎨 三档独立颜色

每个 5h 或 7d 窗口都单独判断。

| 档位 | 已使用 | Claude | Codex |
|---|---:|---|---|
| 1 — 正常 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — 警告 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — 危险 | 90–100% | `#ff7045` | `#ed5d40` |

菜单栏标题使用 macOS 内置工具生成小型矢量 PDF，无需 Xcode Command Line Tools。

## 设置与详细信息

下拉菜单会显示服务名称、使用率、剩余量和重置时间。在 **Settings** 中可以分别显示或隐藏 Claude 与 Codex，但至少保留一个服务。刷新间隔可设为 1、3 或 5 分钟。

> **Codex 5h：** 插件不会猜测不存在的限制。在 Codex 真正返回 300 分钟窗口之前会隐藏 5h，返回后自动加入。

现有的独立插件会被移动到隐藏的支持文件夹中，既保留文件又避免菜单栏重复显示。

## 要求与隐私

- macOS；安装程序会处理 Homebrew、`jq` 和 SwiftBar。
- Claude Code 已登录。
- 已在该 Mac 上使用 Codex CLI 或 Codex 应用。
- 身份验证令牌不会被输出或复制到缓存中。
- 部分使用量接口并非官方接口，未来可能需要兼容性更新。

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## 许可证

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
