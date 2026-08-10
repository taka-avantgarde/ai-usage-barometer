🇬🇧 [English](README.md) · 🇯🇵 日本語 · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ インストール — この1行をターミナルに貼るだけ

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew の有無にかかわらず同じ1行で動きます。足りないもの（Homebrew・`jq`・SwiftBar・プラグイン本体・ローカルヘルパー）だけを導入します。何度実行しても安全なので、更新にも同じ1行を使えます。

## メニューバーは1項目

Claude と Codex を細い区切り線で分けて1項目にまとめています。バーはバッテリー式で、**塗りが残量**、点々が消費済みです。％も残量を示します。

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

メニューバーはベクター画像として描画するため、1項目の中でサービスごとに別の色を保てます。描画できない環境では自動的にテキスト表示に切り替わります。

色は使用量で決まるので、バーが空に近いほど濃い色になります。

| 段階 | 使用量 | Claude | Codex |
|---|---:|---|---|
| 通常 | 0–69% 使用 | `#C68976` | `#7299B9` |
| 警告 | 70–89% 使用 | `#B9755F` | `#3EA2B4` |
| 逼迫 | 90–100% 使用 | `#B0644D` | `#F17D66` |

## 設定

バーをクリックして **⚙ 表示設定** から切り替えます。クリックするたびに反転し、メニューバーとドロップダウンの両方に即座に反映されます。

| 項目 | 効果 |
|---|---|
| Claude を表示 | Claude 全体の表示/非表示 |
| Claude 5h を表示 | 5時間枠の表示/非表示 |
| Claude 5h の％ | 5時間枠の％表示/非表示 |
| Claude 7d を表示 | 7日枠の表示/非表示 |
| Claude 7d の％ | 7日枠の％表示/非表示 |
| Codex を表示 | Codex 全体の表示/非表示 |
| Codex の％ | Codex の％表示/非表示 |
| メニューバー2色描画 | ベクター描画（2色）／テキスト（1色） |
| 更新間隔 | 1分・3分・5分 |
| 言語 | 14言語。既定は macOS の言語 |

すべて非表示にするとクリックできない空項目になるため、最低限 Claude の5時間バーは残ります。メニューバーの色は実際に表示中のゲージだけで決まります。設定は `~/.cache/claude-codex-bar/` に保存され、アップデートしても引き継がれます。

## データの取得元

**Claude** は OAuth の使用量エンドポイント `api.anthropic.com/api/oauth/usage` から取得します。認証には、Claude Code が macOS キーチェーンの `Claude Code-credentials` に保存済みのアクセストークンを使います（見つからない場合は `~/.claude/.credentials.json`）。どちらにも書き込みは行わず、トークンが Mac の外に出るのは Anthropic へのリクエストのときだけです。初回にキーチェーンへのアクセス許可を求められたら **常に許可** を選んでください。

取得結果は更新間隔のあいだキャッシュされるため、エンドポイントへの問い合わせは1間隔につき最大1回です。取得に失敗しても、直前の正常な値を表示し続けます。

**Codex** は、インストーラが `~/SwiftBar/.ai-usage-barometer/` に配置するローカルヘルパー `codex-usage.sh` の出力から読み取ります。枠は動的で、Codex が5時間枠を返したときだけ表示されます。

## うまく動かないとき

**Claude の警告が出る** — キーチェーンに認証情報が見つかっていません。この Mac で Claude Code にサインインしてから **今すぐ再読み込み** を押してください。

**Codex に警告が出る** — ヘルパーが無いか、Codex のデータがまだ生成されていません。インストーラを再実行し、Codex CLI を一度使ってください。

**メニューバーとドロップダウンで色が違って見える** — macOS は半透明のメニューバーを、システムがダークでもライト扱いにすることがあります。この対策として段階ごとに1色だけを使う設計ですが、それでも気になる場合は2色描画をオフにして比較してください。

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
