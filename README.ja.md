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

どちらも彩度とコントラストを高めた配色で、Claudeはオレンジ、Codexはシアンです。
残り11〜30%ではオレンジを混ぜた警告色、残り10%以下では鮮やかな赤を混ぜた逼迫色になります。Codexはどちらも青を強く残します。

| 段階 | 使用量 | Claude | Codex |
|---|---:|---|---|
| 通常 | 0–69% 使用 | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| 警告 | 70–89% 使用 | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| 逼迫 | 90–100% 使用 | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## 設定

バーをクリックして **⚙ Display settings** を開きます。設定画面は開いたまま維持されるため、項目を変更するたびに閉じることなく続けて操作でき、変更は即座に反映されます。

プラグイン本体の画面表示は英語のみです。このGitHubドキュメントは引き続き14言語で提供します。

| 項目 | 効果 |
|---|---|
| Claude を表示 | Claude 全体の表示/非表示 |
| Claude 5h を表示 | 5時間枠の表示/非表示 |
| Claude 5h の％ | 5時間枠の％表示/非表示 |
| Claude 7d を表示 | 7日枠の表示/非表示 |
| Claude 7d の％ | 7日枠の％表示/非表示 |
| Codex を表示 | Codex 全体の表示/非表示 |
| Codex 5h を表示 | Codex が5時間枠を返した場合の表示/非表示 |
| Codex 5h の％ | 5時間枠の％表示/非表示 |
| Codex 7d を表示 | 7日枠の表示/非表示 |
| Codex 7d の％ | 7日枠の％表示/非表示 |
| 更新間隔 | 1分・3分・5分 |

すべてのゲージを非表示にしても、設定を開けるように `AI …` の項目が残ります。メニューバーの色は実際に表示中のゲージだけで決まります。設定は `~/.cache/claude-codex-bar/` に保存され、アップデートしても引き継がれます。

Claude または Codex のチェックを外すと、そのAIのデータ更新を停止します。5h・7d・％の設定項目は薄暗く表示されたまま操作不可になり、AIを再度オンにすると以前の設定値が復元されます。

1つのAIで5hと7dの両方を未選択にした場合も、そのAIのデータ取得を停止し、AI名とHTTP 429などのエラーを完全に非表示にします。

GitHub Releasesを1日1回まで確認します。運営からのアップデートがある場合は、ドロップダウンと表示設定に通知し、更新内容の確認と **今すぐ更新** ができます。

## データの取得元

**Claude** は OAuth の使用量エンドポイント `api.anthropic.com/api/oauth/usage` から取得します。認証には、Claude Code が macOS キーチェーンの `Claude Code-credentials` に保存済みのアクセストークンを使います（見つからない場合は `~/.claude/.credentials.json`）。どちらにも書き込みは行わず、トークンが Mac の外に出るのは Anthropic へのリクエストのときだけです。初回にキーチェーンへのアクセス許可を求められたら **常に許可** を選んでください。

取得結果は更新間隔のあいだキャッシュされるため、エンドポイントへの問い合わせは1間隔につき最大1回です。取得に失敗しても、直前の正常な値を表示し続けます。

**Codex** は、インストーラが `~/SwiftBar/.ai-usage-barometer/` に配置するローカルヘルパー `codex-usage.sh` の出力から読み取ります。枠は動的で、Codex が5時間枠を返したときだけ表示されます。

## うまく動かないとき

**Claude の警告が出る** — キーチェーンに認証情報が見つかっていません。この Mac で Claude Code にサインインしてから **今すぐ再読み込み** を押してください。

**Codex に警告が出る** — ヘルパーが無いか、Codex のデータがまだ生成されていません。インストーラを再実行し、Codex CLI を一度使ってください。

**メニューバーとドロップダウンで色が違って見える** — macOS は半透明のメニューバーを、システムがダークでもライト扱いにすることがあります。Python が使える場合は常に2色のベクター描画を使い、Python がない場合だけ1色のテキスト表示にフォールバックします。

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
