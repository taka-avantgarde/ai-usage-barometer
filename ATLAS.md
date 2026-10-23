# ATLAS.md — AI Usage Barometer 正本規約 (Single Source of Truth)

このファイルは `ai-usage-barometer` リポジトリおよび関連する公式サイト紹介ページ（`/Users/takayukimiyano/StudioProjects/Arc/marketing` の `claude-usage-barometer`）における不変条件（Invariants）とリリースゲートを定義する正本である。

---

## 1. アーキテクチャ & 配布形態の正本

- **唯一の配布形態**: ネイティブ macOS アプリ **`AI Usage Barometer.app`**（Bundle ID: `io.atlasassociates.aiusagebarometer`、最小OS: `macOS 13.0`）。
- **SwiftBar 廃止**: `install.sh`, `install-app.sh`, `update.sh`, `README*.md`（全14言語）, 公式サイト（全21言語）において SwiftBar のインストールや案内を行わない。`install.sh` は `install-app.sh` への互換フォワードとし、レガシーな `~/SwiftBar` プラグイン残骸があれば自動清掃する。
- **3大AIサービスと固有カラーパレット**:
  - **Claude**: Healthy `#C66D28` / Warning `#B65A1E` / Critical `#C52E22`
  - **Codex**: Healthy `#1A8BA6` / Warning `#52768A` / Critical `#783F78`
  - **Gemini**: Healthy `#158F6A` / Warning `#5E7B3A` / Critical `#8C3B5A`
- **ウィンドウ表記と順序の不変条件**:
  - 全サービス（Claude / Codex / Gemini）とも、UI上のウィンドウ表記は **`5h`**（5時間枠）と **`1w`**（1週間枠）に統一し、並び順は必ず **`5h` → `1w`** とする。
  - `5h` が未使用（`100% left`）のときも省略せず常に **`5h` と `1w` の2本** を返す。
- **3つの表示サーフェス（Placement）**:
  - **Menu bar** (`p_menu`) / **Dock icon** (`p_dock`) / **Floating bar** (`p_float`) の3つを独立トグル可能とし、すべてOFFにされた場合は `p_float` を自動でONに戻すフェイルセーフを維持する。

---

## 2. ビルド隔離・署名・Apple 公証の不変条件

- **ワークスペース外隔離ビルド**:
  - `app/bundle.sh` がワークスペース直下に `.app` バンドルを放置すると、macOS の Spotlight / LaunchServices / ControlCenter (`group.com.apple.controlcenter.plist`) が開発用バンドルを自動登録し、「システム設定 > メニューバー」に重複ゴミエントリを作る。
  - したがって `.app` の組み立ては必ず `/tmp/ai-usage-barometer-build.XXXXXX` で行い、ワークスペースの `app/dist/` には最終配布物である `.zip`（`AIUsageBarometer-v<VERSION>.zip`）のみを出力し、ビルド一時ディレクトリは `trap` で即座に削除する。
- **Apple Developer ID 署名と公証のデフォルト強制**:
  - `AIB_SIGN_ID` のデフォルトは `"Developer ID Application: Atlas Associates Inc (NCPKFUCRCS)"`。
  - `AIB_NOTARY_PROFILE` のデフォルトは `"aib"`。
  - リリースビルド時は `codesign --verify --strict` および `spctl --assess --type execute -vv` が exit 0 で通ることを必須条件とし、未公証の `.app` は絶対に GitHub Releases にアップロードしない。

---

## 3. 5軸品質基準（安全性・安定性・確実性・軽量性・高速性）

1. **安全性 (Safety)**:
   - `~/.cache/claude-codex-bar` は `chmod 700`、キャッシュファイル（`claude.tsv`, `claude.attempt`, `latest_release` 等）は一時ファイル（`.tmp.$$`）へ書き出し＋`chmod 600`＋`mv -f` でアトミックに更新する。
   - 認証エラー（401 / トークン不在 / 解約済み）時は即座に `claude.tsv` を破棄し、古いキャッシュを表示しない。
2. **安定性 (Stability)**:
   - 自動アップデートの二重起動防止: ネイティブアプリ（`Model.swift`）からの呼び出し時は環境変数 `AIBAR_NATIVE_APP=1` を渡し、`claude-codex.60s.sh` 側のバックグラウンド自己更新を抑止して `AppDelegate` 側の一箇所（`isUpdating` ロック付き＋`semverIsNewer` 比較）で一元管理する。
   - `AppDelegate.refresh()` に `isRefreshing` ガードを設け、タイマーと手動リフレッシュの多重実行を防ぐ。
   - `Plugin.run()` にタイムアウト（15秒）を設け、万が一子プロセスが応答しなくてもスレッドが永久ブロックしないようにする。
3. **確実性 (Reliability)**:
   - `MenuBarSurface.update()` は `NSImage(size: size, flipped: false) { ... }` の drawing handler を用い、Retina (2x) 解像度で鮮明に描画する。
   - `FloatPanel` は外部ディスプレイ抜去時にも画面外に取り残されないよう、現在のスクリーン群の `visibleFrame` 内に座標をクランプする。
4. **軽量性 (Lightweight)**:
   - `gemini-usage.sh` の JSON パースは1回の `python3` 呼び出しに統合し、プロセス生成回数を最小化する。
5. **高速性 (Speed)**:
   - `claude-codex.60s.sh --json` 実行時は、不要なテキストメニューバー文字列組み立てや PDF 生成の前段で即座に JSON を出力して終了する。
   - `AppDelegate` は直近の `lastUsage: Usage?` をメモリ保持し、設定パネルで `Save` を押した瞬間にメインスレッドで 0ms 即時反映した上でバックグラウンド同期を行う。

---

## 4. リリース・ドキュメント同期ゲート (`scripts/verify-release.sh`)

コミット・プッシュ・リリース前に必ず `bash scripts/verify-release.sh` を実行し、exit 0 であることを確認する。

- バージョン番号の完全一致（`claude-codex.60s.sh`, `gemini-usage.sh`, `codex-usage.sh`, `claude-usage.sh`, `ai-usage.60s.sh`）。
- 全14言語 `README*.md` の構造的パリティ（SwiftBar 言及ゼロ、11行の設定表、`Placement` 行、`## Data sources` の **Claude / Codex / Gemini** 3段落、`assets/hero.svg` 6本バー）。
- 公式サイト（`/Users/takayukimiyano/StudioProjects/Arc/marketing`）全21言語 `src/messages/*.json` の `cub.*` キーにおける SwiftBar 言及ゼロ・`7d` 残存ゼロ・ハードコードされた旧バージョン番号ゼロ。
- 既存テストスイート（`tests/colours.sh` および `tests/run.sh`）および Swift リリースビルド（`swift build -c release`）の完全通過。
