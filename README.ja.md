🇬🇧 [English](README.md) · 🇯🇵 日本語 · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ インストール — ターミナルへこの1行を貼るだけ

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrewが入っているMacでも、入っていないMacでも同じコマンドで動きます。必要な場合はHomebrew、`jq`、SwiftBar、統合プラグイン、Claude/Codex取得用ヘルパーを自動セットアップします。

Macのメニューバーには1つの項目だけを表示します。**ClaudeやCodexという名前はメニューバーには出しません。** Claudeはオレンジ系、Codexはブルー系で表示します。

```text
5h ███░░  7d ████░  │  7d ███░░
└──── Claude ────┘     └─ Codex ─┘
```

## ✅ v0.2.0：2つの復旧問題を修正

- **Claudeのリセット後：** Claudeが`Warming up`、0%、nullの利用枠、またはリセット時刻を過ぎた古いスナップショットを返しても、エラー表示のまま固着しません。Claudeの5hと7dを「リセット済み・待機中」の100%残量として復元し、次に正常なライブ値を取得した時点で自動的に置き換えます。再インストールは不要です。
- **Codexの5hが後から復活した場合：** Codexの利用枠は動的に検出します。Codexが300分枠を再び返したら、次回更新時に`5h`バーを自動追加します。300分枠がない間は、`7d`など実際に返された枠だけを表示します。

すぐに再取得したい場合は、ドロップダウン内の**Refresh now**を押してください。

## 🎨 3段階カラー（各枠を個別判定）

5hと7dはそれぞれ独立して判定します。そのため、Claudeの5hに十分な残量があり、7dがほぼ使い切られている場合は、同時に異なる色になります。

| 段階 | 使用率 | Claude | Codex |
|---|---:|---|---|
| ① 通常 | 0〜69%使用 | `#b54f02` | `#4F7FA8` |
| ② 警告 | 70〜89%使用 | `#B85A00` | `#0e8ba1` |
| ③ 危険 | 90〜100%使用 | `#ff7045` | `#ed5d40` |

メニューバー部分はmacOS標準機能だけで小さなベクターPDFとして生成するため、Xcode Command Line Toolsなしで各枠のHEXカラーを正確に表示できます。

## 設定と詳細表示

ドロップダウン内にはサービス名、使用率、残量、リセット時刻を表示します。**Settings**からClaudeとCodexを個別に表示・非表示にでき、少なくともどちらか一方は必ず表示されます。更新間隔は1分・3分・5分から選べます。

> **Codexの5hについて：** Codexが常に5時間枠を返すとは限りません。存在しない枠は推測しません。実際の300分枠が返るまではCodexの5hを非表示にし、返された時点で自動追加します。

既存の`claude-usage.60s.sh`と`codex-usage.60s.sh`は隠しサポートフォルダへ移動し、ファイルを保持したままメニューバーへの重複表示を防ぎます。

## 動作条件とプライバシー

- macOS。Homebrew、`jq`、SwiftBarはインストーラーが処理します。
- Claude側はClaude Codeへログイン済みであること。
- Codex側はこのMacでCodex CLIまたはCodexアプリを使用済みであること。
- 認証トークンを画面へ表示したり、統合プラグインのキャッシュへコピーしたりしません。
- 非公式の利用量取得経路を一部利用するため、提供元の変更後に互換性更新が必要になる場合があります。

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
