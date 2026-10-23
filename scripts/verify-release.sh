#!/usr/bin/env bash
# verify-release.sh — 機械的リリースゲート
# すべての不変条件（Invariants）を検査し、違反があれば非ゼロ終了する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== 1. シェルスクリプト構文検査 (bash -n) ==="
for sh in "$ROOT"/*.sh "$ROOT"/scripts/*.sh "$ROOT"/app/*.sh "$ROOT"/tests/*.sh; do
  [ -f "$sh" ] || continue
  bash -n "$sh"
done
echo "✔ 全シェルスクリプト構文正常"

echo "=== 2. スクリプト間バージョン一致検査 ==="
V_MAIN=$(grep -m1 '^VERSION=' "$ROOT/claude-codex.60s.sh" | sed 's/.*"v*\(.*\)"/\1/')
for sh in gemini-usage.sh codex-usage.sh claude-usage.sh ai-usage.60s.sh; do
  V_CUR=$(grep -m1 '^VERSION=' "$ROOT/$sh" | sed 's/.*"v*\(.*\)"/\1/')
  if [ "$V_MAIN" != "$V_CUR" ]; then
    echo "✘ バージョン不一致: claude-codex.60s.sh ($V_MAIN) != $sh ($V_CUR)" >&2
    exit 1
  fi
done
echo "✔ バージョン一致: v$V_MAIN"

echo "=== 3. SwiftBar 言及ゼロ検査 ==="
# README*.md から大文字小文字問わず SwiftBar を完全排除
for r in "$ROOT"/README*.md; do
  if grep -qi 'SwiftBar' "$r"; then
    echo "✘ $r に SwiftBar の言及が残っています" >&2
    exit 1
  fi
done
# install.sh, install-app.sh, update.sh はレガシー掃除パス ($HOME/SwiftBar) を除く言及がゼロであること
for sh in install.sh install-app.sh update.sh; do
  [ -f "$ROOT/$sh" ] || continue
  # $HOME/SwiftBar や $PLUGIN_DIR 以外の文脈で SwiftBar に言及していないか確認
  if grep -i 'SwiftBar' "$ROOT/$sh" | grep -v 'HOME/SwiftBar' | grep -v 'rm -' | grep -v 'SWIFTBAR_' | grep -q .; then
    echo "✘ $sh に SwiftBar の不要な言及が残っています" >&2
    exit 1
  fi
done
echo "✔ SwiftBar 言及ゼロ"

echo "=== 4. 全14言語 README パリティ検査 ==="
python3 - <<'PY'
import glob, sys

readmes = sorted(glob.glob("README*.md"))
if len(readmes) != 14:
    print(f"✘ README の言語数が 14 ではありません: {len(readmes)}", file=sys.stderr)
    sys.exit(1)

for r in readmes:
    with open(r) as f:
        text = f.read()
    if "install-app.sh" not in text:
        print(f"✘ {r}: install-app.sh が見つかりません", file=sys.stderr)
        sys.exit(1)
    if "gemini-usage.sh" not in text:
        print(f"✘ {r}: gemini-usage.sh の説明が見つかりません", file=sys.stderr)
        sys.exit(1)
    if "30d" in text:
        print(f"✘ {r}: 30d の旧記述が残っています", file=sys.stderr)
        sys.exit(1)
    if "Menu bar" not in text and "Menüleiste" not in text and "Barra de menús" not in text and "Barre des menus" not in text and "메뉴" not in text and "菜单栏" not in text and "メニューバー" not in text:
        print(f"✘ {r}: Menu bar の記述が見つかりません", file=sys.stderr)
        sys.exit(1)
    # Settings table rows
    sep_indices = [i for i, l in enumerate(text.splitlines()) if "|---|" in l]
    if len(sep_indices) < 2:
        print(f"✘ {r}: 設定テーブルが見つかりません", file=sys.stderr)
        sys.exit(1)
    lines = text.splitlines()
    end = sep_indices[1] + 1
    while end < len(lines) and lines[end].startswith("|"):
        end += 1
    row_count = end - (sep_indices[1] + 1)
    if row_count != 11:
        print(f"✘ {r}: 設定テーブルが 11 行ではありません ({row_count} 行)", file=sys.stderr)
        sys.exit(1)

print("✔ 全14言語 README パリティ正常 (11行設定表・30dゼロ・gemini-usage.sh・install-app.sh 完備)")
PY

echo "=== 5. assets/hero.svg 検査 ==="
grep -q 'Menu bar' "$ROOT/assets/hero.svg"
grep -q 'Dock icon' "$ROOT/assets/hero.svg"
grep -q 'Floating bar' "$ROOT/assets/hero.svg"
grep -q '#C66D28' "$ROOT/assets/hero.svg"
grep -q '#1A8BA6' "$ROOT/assets/hero.svg"
grep -q '#158F6A' "$ROOT/assets/hero.svg"
echo "✔ assets/hero.svg 正常"

echo "=== 6. テストスイート実行 (colours.sh & run.sh) ==="
bash "$ROOT/tests/colours.sh"
bash "$ROOT/tests/run.sh"
echo "✔ テストスイート通過"

echo "=== 7. Swift リリースビルド & 隔離検査 ==="
(cd "$ROOT/app" && swift build -c release)
if [ -d "$ROOT/app/dist/AI Usage Barometer.app" ]; then
  echo "✘ app/dist に .app ディレクトリが残っています" >&2
  exit 1
fi
echo "✔ Swift リリースビルド正常 & 隔離確認"

echo "=== 8. 公式サイト (Arc/marketing) cub.* 同期検査 ==="
MARKETING_DIR="/Users/takayukimiyano/StudioProjects/Arc/marketing"
if [ -d "$MARKETING_DIR" ]; then
  python3 - <<'PY'
import glob, json, sys

files = sorted(glob.glob("/Users/takayukimiyano/StudioProjects/Arc/marketing/src/messages/*.json"))
violations = []
for fpath in files:
    fname = fpath.split('/')[-1]
    with open(fpath, "r", encoding="utf-8") as f:
        data = json.load(f)
    for k, v in data.items():
        if not k.startswith("cub."):
            continue
        s = str(v)
        for bad in ["SwiftBar", "swiftbar", "v0.10.0", "v0.9.0", "v0.8.0", "5h/7d", "5-hour/7-day"]:
            if bad in s:
                violations.append(f"{fname} [{k}]: contains '{bad}'")
if violations:
    for v in violations:
        print(f"✘ {v}", file=sys.stderr)
    sys.exit(1)
print(f"✔ 公式サイト全 {len(files)} 言語 cub.* キー同期正常")
PY
fi

echo "🎉 verify-release.sh: 全リリースゲート通過！"
