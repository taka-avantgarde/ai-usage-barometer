🇬🇧 [English](README.md) · 🇯🇵 日本語 · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ インストール — ターミナルへこの1行を貼るだけ

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrewが入っているMacでも、入っていないMacでも同じコマンドで動きます。必要な場合はHomebrewを導入し、`jq`、SwiftBar、統合プラグイン、Claude/Codex取得用ヘルパーを自動セットアップします。

Macのメニューバーには1つの項目だけを表示します。**ClaudeやCodexという名前はメニューバーには出しません。** Claudeは暗めに抑えたアンバー、Codexは落ち着いたスチールブルーです。

```text
5h ███░░  7d ████░  │  7d ███░░
└─ Claude・暗めのアンバー ┘  └ Codex・スチールブルー ┘
```

## 設定

ドロップダウン内の**設定**から、ClaudeまたはCodexを個別に表示・非表示にできます。少なくともどちらか1つは表示された状態を保ちます。同じメニューで更新間隔を1分・3分・5分から選べます。

## 利用量の詳細

クリック後の画面では、ClaudeとCodexを色分けしたセクションとして表示し、使用率、残量、リセット時刻を直接確認できます。識別できるよう、サービス名はドロップダウン内だけに残します。

> **Codexの5時間枠について：** Codexは常に5時間制限を返すわけではありません。アカウントに5時間制限がない場合、またはCodexが利用量データに5時間枠を含めない場合、Codex側の`5h`バーは非表示になり、`7d`など実際に返された枠だけを表示します。存在しない制限値を推測して表示することはありません。

## 既存のClaude/Codexプラグイン

インストーラーは既存の`claude-usage.60s.sh`と`codex-usage.60s.sh`を隠しサポートフォルダへ移動します。ファイルを保持したまま、メニューバーへの重複表示を防ぎます。

## 動作条件とプライバシー

- macOSとSwiftBar。Homebrewと`jq`はインストーラーが処理します。
- Claude側は、このMacでClaude Codeへログイン済みであること。
- Codex側は、このMacでCodex CLIまたはCodexアプリを利用済みであること。
- 認証トークンを画面へ表示したり、統合プラグインのキャッシュへコピーしたりしません。
- 非公開・非公式の利用量取得経路を一部利用するため、提供元の変更後に更新が必要になる場合があります。

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
