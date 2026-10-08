# AI Usage Barometer — フローティング／Dock 版アプリ 開発計画

> ローカルの Claude Code はまずこのファイルを読み、M1 から着手する。
> 質問より先に `swift build` を回すこと。ここに書いていない判断は `../DESIGN.md` に従う。

## 0. なぜ作るか

メニューバーは macOS の都合で消える（ノッチ、macOS 26 でステータス項目が画面外に退避されるのを実機で確認済み。
`x=-1` に配置され、SwiftBar の設定を初期化しても戻らない）。表示の「居場所」をアプリ自身が持つ必要がある。

## 1. コンセプト — AIのバッテリー

**残量を一目で。考えさせない。** 説明が要る時点で負け。

### 居場所（Presence）

| モード | 挙動 | 画面コスト |
|---|---|---|
| `dock`  | **Dock アイコンそのものがゲージ**（`NSApp.dockTile.contentView` にライブ描画）。クリックでパネル | 0 px |
| `float` | 最前面の小さなバー。ドラッグ自由・画面端にスナップ・ディスプレイごとに位置記憶・全画面アプリ中は自動で隠れる | 約 300×28 pt |
| `both`  | 上の2つ | |

**初回起動**：説明文なし。実物のプレビュー2つを並べて「Where should it live?」。クリックした瞬間に反映、OK ボタン無し。
以後はパネルの ⚙ からいつでも変更。

### 削る（増やさない）

- settings.html（webview）は使わない。SwiftBar 依存も無し（プラグインは SwiftBar ユーザー向けに維持）
- データ層を二重実装しない。`claude-codex.60s.sh --json` が唯一の口
- 言語切替なし。UI は英語、README は 14 言語
- 設定は **6 個まで**：Presence / Claude / Codex / % / 更新間隔 / 逼迫通知

### 譲らない

- **レンダラーは 1 つ、表面は 3 つ**（Dock・Float・パネル）。同じ `Gauge` を描く。見た目が絶対にズレない
- バッテリー式（塗り＝残量）、使用量で 3 段階の色、点々の消費分 — `DESIGN.md` を継承
- エラーは 1 行で「次にやること」を言う（例：`Sign in to Claude Code again`）。JSON の `error` をそのまま出す
- 更新は 1 クリック。通知は「残り 10% 以下」になった時に**一度だけ**
- 起動 0.3 秒、CPU ほぼゼロ（60 秒に 1 回スクリプトを実行して読むだけ。API 呼び出し頻度はスクリプト側が制御）

## 2. アーキテクチャ

```
claude-codex.60s.sh --json   ← 認証・バックオフ・設定・Codex 解析・更新チェック（唯一の実装）
        │ JSON
        ▼
   Model.swift   (Process で実行 → Decodable)
        ▼
   Gauge.swift   (共通レンダラー：NSView 1 つ、サイズに応じてレイアウト)
    ├─ Dock タイル      NSApp.dockTile.contentView
    ├─ Float パネル     NSPanel(.borderless, .nonactivatingPanel) level=.floating
    └─ パネル（詳細）   通常ウィンドウ。ゲージ＋回復時間＋⚙＋Refresh＋更新
```

- **AppKit のみ。SwiftUI は使わない**（API 安定性、Swift 5 言語モード）
- **SwiftPM のみ。Xcode プロジェクトは作らない**（`app/Package.swift`、tools-version 5.9、`platforms: [.macOS(.v13)]`）
- ファイルは 5 つ：`Main.swift` `Model.swift` `Gauge.swift` `Presence.swift` `Panel.swift`
- 設定は **`~/.cache/claude-codex-bar/` を SwiftBar 版と共有**（1 キー 1 ファイル、値は `0`/`1`）。追加キーは `presence`（`dock`|`float`|`both`）と `notify`（`0`/`1`）のみ
- 設定変更は `claude-codex.60s.sh --set <key> <0|1>` を呼ぶ（`iv` は `1|3|5`）。自分でファイルを書かない
- プラグインの場所：`$AIBAR_PLUGIN` → `~/SwiftBar/claude-codex.60s.sh` → アプリ同梱の `Resources/claude-codex.60s.sh` の順。実行時の環境変数 `SWIFTBAR_PLUGIN_PATH` にそのパスを入れる（ヘルパー解決と更新チェック有効化のため）

## 3. JSON 契約（v0.7.0）

`bash claude-codex.60s.sh --json` の実例：

```json
{"version":"v0.7.0",
 "update":{"available":false,"latest":"v0.7.0"},
 "updated":"11:30:05",
 "settings":{"claude_on":1,"c5":1,"c5p":1,"c7":1,"c7p":1,"codex_on":1,"cx5":1,"cx5p":1,"cx7":1,"cx7p":1,"iv":3,"cmp":1},
 "services":[
  {"name":"Claude","on":true,"error":"","color":"#C66D28","credits":"",
   "windows":[
    {"label":"5h","left":35,"color":"#C66D28","resets":"soon","show":true,"pct":true},
    {"label":"7d","left":86,"color":"#C66D28","resets":"6d 8h","show":true,"pct":true}]},
  {"name":"Codex","on":true,"error":"","color":"#1A8BA6","credits":"",
   "windows":[
    {"label":"5h","left":58,"color":"#1A8BA6","resets":"3h 10m","show":true,"pct":true},
    {"label":"7d","left":82,"color":"#1A8BA6","resets":"4d 2h","show":true,"pct":true}]}]}
```

- `left` は残量 %（`-1` = データなし）。`show` が false の行は描かない。`pct` が false なら数字を出さない
- `windows` の順序は固定（1 個目/2 個目）。Codex のラベルは動的（`30d` もあり得る）。ラベル文字列で分岐しない
- `error` が非空なら、その service はゲージの代わりにエラー 1 行
- `color` は使用量に応じた段階色が既に入っている。アプリ側で色を決めない

## 4. 描画仕様（Gauge）

| 項目 | 値 |
|---|---|
| 背景 | `#20252B`、角丸 10（Dock は 22）、不透明度 0.92 |
| 文字 | `#EBF0F5`、ラベル 12pt medium、% は等幅数字 12pt、回復時間 9pt `#888888` |
| バー | 高さ 10pt、角丸 3、幅は表面で決める（Float 110 / パネル 160 / Dock 88） |
| 塗り | `color` そのまま。左から `left`% |
| 消費分 | 0.9pt の正方形を 2.2pt ピッチ、行ごとに半ピッチずらす。塗りと同色、面積比約 17% |
| 色の段階 | Claude `#C66D28` / `#B65A1E` / `#C52E22`、Codex `#1A8BA6` / `#52768A` / `#783F78`（JSON が持ってくる） |
| 更新あり | 左端にオレンジ `#FF9F0A` の上向き矢印（ベクタ）。文字に落とさない |

## 5. 画面

1. **Dock タイル**：角丸ダーク、横バー 2〜4 本、2 文字ラベル。64px でも読める太さ。60 秒ごとに `dockTile.display()`
2. **Float**：1 行 `Claude 5h ▮▮▮▯▯ 35%  Codex 7d ▮▮▮▮▯ 82%`。ホバーで回復時間が下にスッと出る（高さ 28→44）
3. **パネル**：Dock/Float のクリックで出る。ゲージ＋回復時間、⚙（Presence / Claude / Codex / % / 間隔 / 通知）、Refresh now、更新通知（Install now = `--update` 実行）、version

## 6. マイルストーン

| | 内容 | 完了条件 |
|---|---|---|
| M0 ✅ | 環境確認・`--json` | macOS 26.6.2 / Swift 6.3.3 / keychain OK / `--json` 動作 |
| **M1** | コア：Dock タイル＋Float＋パネル、共通レンダラー | `swift run` で 3 表面に同じゲージ。`screencapture` で確認して PLAN に貼る |
| **M2** | 居場所：初回画面・スナップ・位置記憶・全画面時非表示 | 再起動しても同じ場所に居る。Presence の切替が即時 |
| **M3** | 設定 6 個・エラー 1 行・更新 1 クリック・逼迫通知 | プラグインと機能同等 |
| **M4** | 配布：`.app` バンドル・GitHub Release 添付・1 行インストーラー・README（14 言語）・DESIGN.md | 他人が 1 行で入れられる |
| M5 | 公証（Developer ID） | 右クリック→開く が不要 |

## 7. 作業ルール（ローカル Claude Code 向け）

- 変更のたびに `cd app && swift build` を通す。見た目は `swift run` ＋ `screencapture -x` で自分で確認する
- ブランチ `app` で作業。`main` への push とタグ・Release はユーザーが指示した時だけ
- 設計判断は `DESIGN.md` に追記する（既存の書式：見出しに (vX.Y.Z)）
- プラグイン側の変更は `--json` の契約を壊さない。壊す場合は `version` を上げて両側を同時に更新
- 「動かない」報告には推測で答えず、`swift build` の出力と `screencapture` で確かめてから直す

## 8. 最初の一言（ローカルで貼る）

```
app/PLAN.md を読んで M1 から着手して。ビルドは cd app && swift build、起動は swift run。
動いたら screencapture で3表面のスクショを撮って見せて。質問より先にビルドを回して。
```
