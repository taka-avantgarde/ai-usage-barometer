#!/bin/bash
# AI Usage Barometer — アプリ版を入れる。Xcode は要らない。
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
#
# 何度実行しても安全。設定 (~/.cache/claude-codex-bar/) はそのまま残る。
set -e
O=taka-avantgarde
R=ai-usage-barometer
NAME="AI Usage Barometer"
DEST="/Applications/$NAME.app"

command -v curl >/dev/null || { echo "✘ curl がありません"; exit 1; }

echo "── 最新版を探しています ──"
API="https://api.github.com/repos/$O/$R/releases/latest"
URL=$(curl -fsSL "$API" | grep -o 'https://[^"]*AIUsageBarometer-v[^"]*\.zip' | head -1)
if [ -z "$URL" ]; then
  echo "✘ 配布用の .app がまだ公開されていません。"
  echo "  ソースから動かす場合:"
  echo "    git clone https://github.com/$O/$R.git"
  echo "    cd $R/app && swift run"
  exit 1
fi
echo "  $URL"

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
curl -fsSL "$URL" -o "$T/app.zip"
ditto -x -k "$T/app.zip" "$T/x"
SRC=$(find "$T/x" -maxdepth 1 -name '*.app' -print -quit)
[ -n "$SRC" ] || { echo "✘ zip の中に .app がありません"; exit 1; }

# 動いていると差し替えられない
pkill -f AIUsageBarometer 2>/dev/null || true
sleep 1
rm -rf "$DEST"
ditto "$SRC" "$DEST"

# 公証済みなら隔離属性のままで起動できる。未署名のときだけ外す。
# 自分で取ってきた自分のアプリなので外して差し支えないが、
# 公証を入れた時点でこの迂回は自動的に使われなくなる。
if spctl --assess --type execute "$DEST" >/dev/null 2>&1; then
  echo "  （署名・公証済み）"
else
  xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
  echo "  （未署名のため隔離属性を外しました）"
fi

echo "✔ $DEST"
open "$DEST"
echo
echo "右クリックで設定（表示するサービス／％／置き場所）。"
echo "置き場所は メニューバー・Dockアイコン・フローティングバー から選べます。"
