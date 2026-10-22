🇬🇧 [English](README.md) · 🇯🇵 日本語 · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Claude・Codex・Gemini の残量を一目で把握。Macの「メニューバー」「Dockアイコン」「フローティングバー」の3箇所でリアルタイム表示。**

| AIサービス | カラー | 対応ソース |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code（OAuth Usage API・キーチェーン自動読取） |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI・Webトークン（`5h` & `1w`） |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop & IDE（`5h` & `1w`） |

<img src="assets/hero.svg" alt="メニューバー・Dockアイコン・フローティングバーに表示した AI Usage Barometer" width="725">

## ⚡ インストール — この1行をターミナルに貼るだけ

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

これらはアプリ版です。Homebrew も Xcode も SwiftBar も要りません。macOS 13 以降。初回起動時に置き場所（メニューバー・Dockアイコン・フローティングバー）を聞かれ、あとからメニューでいつでも変えられます。

すでに SwiftBar を使っている、あるいは SwiftBar に出したい場合は、こちらの1行でプラグイン版が入ります（Homebrew と SwiftBar は無いときだけ導入）。何度実行しても安全なので、更新にも同じ1行を使えます。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

## メニューバーは1項目

Claude・Codex・Gemini を細い区切り線で分けて1項目にまとめています。バーはバッテリー式で、**塗りが残量**、点々が消費済みです。％も残量を示します。

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

メニューバーはベクター画像として描画するため、1項目の中でサービスごとに別の色を保てます。描画できない環境では自動的にテキスト表示に切り替わります。

3サービスとも彩度とコントラストを高めた配色で、Claudeはオレンジ、Codexはシアン、Geminiはエメラルドグリーンです。
残り11〜30%では警告色、残り10%以下では鮮やかな逼迫色になります。

| 段階 | 使用量 | Claude | Codex | Gemini |
|---|---:|---|---|---|
| 通常 | 0–69% 使用 | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| 警告 | 70–89% 使用 | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| 逼迫 | 90–100% 使用 | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## 設定

ゲージを右クリック（または **⚙ Display settings** を選択）して設定パネルを開きます。設定画面は開いたまま維持され、macOS / iOS 標準風の青ピルトグルスイッチと **Save** ボタンで複数項目をまとめて直感的に切り替えられます。

プラグイン本体の画面表示は英語のみです。このGitHubドキュメントは引き続き14言語で提供します。

| 項目 | 効果 |
|---|---|
| **Claude** (`ON` / `OFF`) | Claude 全体の表示/非表示（傘下の `5h`・`1w` と双方向連動） |
| **Claude `5h`** + **`%`** | 5時間枠および％の表示/非表示 |
| **Claude `1w`** + **`%`** | 1週間枠（7d）および％の表示/非表示 |
| **Codex** (`ON` / `OFF`) | Codex 全体の表示/非表示（傘下の `5h`・`1w` と双方向連動） |
| **Codex `5h`** + **`%`** | 5時間枠（例: Codex 5h）および％の表示/非表示 |
| **Codex `1w`** + **`%`** | 1週間枠（例: Codex 7d）および％の表示/非表示 |
| **Gemini** (`ON` / `OFF`) | Gemini 全体の表示/非表示（傘下の `5h`・`1w` と双方向連動） |
| **Gemini `5h`** + **`%`** | 5時間枠（`5h`）および％の表示/非表示 |
| **Gemini `1w`** + **`%`** | 1週間枠（`1w` / 7d）および％の表示/非表示 |
| **置き場所** (`Menu bar` / `Dock icon` / `Floating bar`) | 3つの表示場所の任意の組み合わせを選択 |
| **更新間隔** (`1m` / `3m` / `5m`) | 1分・3分・5分 |

枠の並び順は常に **`5h` → `1w`** で統一されています。親（`Claude` / `Codex` / `Gemini`）をオフにすると傘下の `5h`・`1w` もすべてオフになりデータ取得を停止します。逆に `5h` と `1w` の両方をオフにすると親も自動でオフになります。設定は `~/.cache/claude-codex-bar/` に保存され、アップデートしても引き継がれます。

GitHub Releases を15分ごとに自動確認し、新しいリリースが公開されるとバックグラウンドで自動アップデートされます。

## アプリ版 — 置き場所を選べます

メニューバーがいつも使えるとは限りません。ステータス項目が画面外に配置されて
一切描かれないMacがありますし、ノッチの横には単に空きが無いこともあります。
アプリ版は同じゲージを、好きな場所に置きます。

| 置き場所 | 内容 |
|---|---|
| **メニューバー** | アプリ自身のステータス項目。1行表示 |
| **Dockアイコン** | Dockアイコン自体がゲージになります。画面を1pxも使いません |
| **フローティングバー** | 常に最前面の小さなバー。好きな場所にドラッグできます |

3つは独立しているので、どの組み合わせでも選べます。バー・Dockアイコン・
メニューバー項目のいずれかを右クリックすると設定が出ます。サービスごとの
表示切替、％の有無、置き場所、そして **Details…** で回復時間つきのパネル。

枠を消すと、その分だけ幅が縮みます。残った中身ちょうどの幅になるので、空いた分はメニューバーに返ります。

オレンジの上向き矢印は「更新があります」の印です。同じメニューの **Update to vX.Y.Z** から、その場で入れ替わります。

1行で入ります。Xcodeは不要です。macOS 13以降。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

アプリは Apple の署名と公証を通しているので、ダウンロードしてそのまま開けます。警告も右クリックも要りません。

ソースから動かす場合はXcodeが必要です。

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

設定は SwiftBar プラグインと共有なので、両者の表示が食い違いません。

## データの取得元

**Claude** は OAuth の使用量エンドポイント `api.anthropic.com/api/oauth/usage` から取得します。認証には、Claude Code が macOS キーチェーンの `Claude Code-credentials` に保存済みのアクセストークンを使います（見つからない場合は `~/.claude/.credentials.json`）。どちらにも書き込みは行わず、トークンが Mac の外に出るのは Anthropic へのリクエストのときだけです。初回にキーチェーンへのアクセス許可を求められたら **常に許可** を選んでください。

取得結果は更新間隔のあいだキャッシュされるため、エンドポイントへの問い合わせは1間隔につき最大1回です。一時的な通信エラーや429のときは直前の正常値を維持し、解約・ログアウト等で認証情報が消えた場合は古いキャッシュを即座に破棄します。

**Codex** は、インストーラが `~/SwiftBar/.ai-usage-barometer/` に配置するローカルヘルパー `codex-usage.sh` の出力から読み取ります。`5h`（5時間枠）が未使用（残り100%）のときも省略せず、常に **`5h` → `1w` (`7d`)** の順で2本とも取得・表示します。

**Gemini** は、インストーラが配置するローカルヘルパー `gemini-usage.sh` の出力から読み取ります。Antigravity Desktop App 2.0 および Antigravity IDE の両方に対応し、外部API呼び出しや認証情報の書き換えなしに、ローカル Language Server の Connect RPC（`RetrieveUserQuotaSummary` / `GetUserStatus`）・SQLite (`state.vscdb`)・キャッシュの3段階フォールバックで **`5h`（5時間枠）と `1w`（週間枠）の両方**を安全に取得します。

## うまく動かないとき

**`Claude ⚠` と出る** — ドロップダウンに理由が表示されます。*Sign in to Claude Code again* は OAuth トークンの期限切れで、Claude Code の CLI か IDE 拡張から再認証してください。**Claude デスクトップアプリとは別物**なので、Claude.app にサインインしてもこのトークンは更新されません。*Rate limited* は時間で解消します（15分バックオフし、残り時間を表示します）。

**Codex に警告が出る** — ヘルパーが無いか、Codex のデータがまだ生成されていません。インストーラを再実行し、Codex CLI を一度使ってください。

**Gemini に警告が出る** — Antigravity が一度も起動されていないか、データ待機中です。Antigravity Desktop または Antigravity IDE を起動してください。

**メニューバーとドロップダウンで色が違って見える** — macOS は半透明のメニューバーを、システムがダークでもライト扱いにすることがあります。Python が使える場合は常に2色のベクター描画を使い、Python がない場合だけ1色のテキスト表示にフォールバックします。

## アンインストール

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## ライセンス

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
