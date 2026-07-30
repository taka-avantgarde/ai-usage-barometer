🇬🇧 [English](README.md) · 🇯🇵 日本語 · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ インストール — ターミナルへこの1行を貼るだけ

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrewが入っているMacでも、入っていないMacでも同じコマンドで動きます。必要に応じてHomebrew、`jq`、SwiftBar、統合プラグイン、ローカルヘルパーを自動セットアップします。

## ✅ v0.2.7：メニューバー表示を安定化

v0.2.7では、実機で確認したCodexヘルパーをこのリポジトリ内に固定し、macOS標準Bash 3.2で動かない` ;;& `構文を削除しました。アップデート時にカラー画像キャッシュを再生成するため、壊れた色や古い表示が残りません。

ClaudeとCodexは完全に独立して判定され、一方のデータが取得できなくても他方は消えません。5hと7dも利用枠ごとに個別の色段階を使い、既存の**Settings**設定は保持します。

## Claudeのデータ取得


Claudeの利用量は、Claude Codeが公式に`statusLine`へ渡すJSONの`rate_limits.five_hour`と`rate_limits.seven_day`から取得します。インストーラーは小さなローカルラッパーを追加しますが、すでに設定しているステータスラインの表示はそのまま引き継ぎます。

インストール後にClaude Codeを開き、1回メッセージを送って応答を完了してください。`rate_limits`はセッションの最初のAPI応答後に渡され、5hと7dはそれぞれ独立して存在しない場合があります。そのため、実際にClaude Codeから返された枠だけを表示し、`Warming up`や欠損値を架空の「100%残量」へ置き換えません。

Claude連携ではOAuthトークン、macOS Keychain、`~/.claude/.credentials.json`を読み取りません。

## Macのメニューバーは1項目

メニューバーにはサービス名を表示しません。Claudeはオレンジ系、Codexはブルー系です。

```text
5h ███░░  7d ████░  │  7d ███░░
└──── Claude ────┘     └─ Codex ─┘
```

各利用枠を個別に色判定します。

| 段階 | 使用率 | Claude | Codex |
|---|---:|---|---|
| ① 通常 | 0〜69%使用 | `#b54f02` | `#4F7FA8` |
| ② 警告 | 70〜89%使用 | `#B85A00` | `#0e8ba1` |
| ③ 危険 | 90〜100%使用 | `#ff7045` | `#ed5d40` |

## 動的な利用枠と設定

Codexの利用枠は動的です。実際の300分枠が返れば`5h`バーを自動追加し、週間枠しか返らない場合は`7d`だけを表示します。

ドロップダウンにはサービス名、使用率、残量、リセット時刻、取得時刻を表示します。**Settings**からClaudeとCodexを個別に非表示にでき、更新間隔は1分・3分・5分から選べます。

## Claudeのバーが出ない場合

Claude Codeを開き、1回の応答を完了してください。カスタムステータスラインにはワークスペースの信頼許可が必要です。また、`disableAllHooks`が`true`の場合は実行されません。既存のステータスライン出力はラッパー経由で維持され、アンインストール時に元の設定へ戻します。

公式仕様：[Claude Codeステータスラインのドキュメント](https://code.claude.com/docs/ja/statusline#レート制限の使用状況)

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
