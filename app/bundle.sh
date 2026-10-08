#!/bin/bash
# AI Usage Barometer — .app を組み立てて、任意で Release に添付する。
#
#   bash app/bundle.sh            → AI Usage Barometer.app と zip を作る
#   bash app/bundle.sh v0.7.0     → さらに その Release に zip を添付する
#
# 署名はしていない。公証（Developer ID）は別の話で、それまでは
# install-app.sh 側で隔離属性を外す。
set -e
cd "$(dirname "$0")"

VERSION="${1:-}"
NAME="AI Usage Barometer"
BIN="AIUsageBarometer"
ID="io.atlasassociates.aiusagebarometer"
SHORT="$(grep -m1 '^VERSION=' ../claude-codex.60s.sh | sed 's/.*"v\(.*\)"/\1/')"
OUT="$PWD/dist"
APP="$OUT/$NAME.app"

echo "── ビルド (release) ──"
swift build -c release
BINPATH="$(swift build -c release --show-bin-path)/$BIN"
[ -x "$BINPATH" ] || { echo "✘ 実行ファイルが見つかりません: $BINPATH"; exit 1; }

echo "── アイコン ──"
rm -rf "$OUT"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$OUT/icon.iconset"
python3 - "$OUT/icon.iconset" <<'PY'
# 外部ライブラリ無しで PNG を書く。ダークな角丸に、バッテリー式のバーを3本。
# Claude のオレンジ2本と Codex のシアン1本で、中身が何かひと目で分かるようにする。
import struct, sys, zlib, pathlib

BG    = (0x20, 0x25, 0x2B)
BARBG = (0x33, 0x3A, 0x42)
BARS  = [((0xC6, 0x6D, 0x28), 0.88), ((0xC6, 0x6D, 0x28), 0.43), ((0x1A, 0x8B, 0xA6), 0.99)]

def png(path, n):
    r = n * 0.22                      # 角丸半径
    pad = n * 0.14
    bar_h = n * 0.11
    gap = (n - pad * 2 - bar_h * 3) / 2
    rows = []
    for y in range(n):
        row = bytearray()
        for x in range(n):
            # 角丸の外側は透明
            cx = min(max(x + 0.5, r), n - r)
            cy = min(max(y + 0.5, r), n - r)
            if (x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2 > r * r:
                row += bytes((0, 0, 0, 0))
                continue
            px = BG
            for i, (colour, left) in enumerate(BARS):
                top = pad + i * (bar_h + gap)
                if top <= y < top + bar_h and pad <= x < n - pad:
                    span = n - pad * 2
                    px = colour if x < pad + span * left else BARBG
                    break
            row += bytes(px + (255,))
        rows.append(bytes(row))
    raw = b"".join(b"\x00" + r for r in rows)
    def chunk(tag, data):
        c = tag + data
        return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
    out = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", n, n, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 9))
           + chunk(b"IEND", b""))
    pathlib.Path(path).write_bytes(out)

d = pathlib.Path(sys.argv[1])
for size in (16, 32, 64, 128, 256, 512):
    png(d / f"icon_{size}x{size}.png", size)
    png(d / f"icon_{size}x{size}@2x.png", size * 2)
print("  アイコン生成: 16〜512 (@2x 含む)")
PY
iconutil -c icns "$OUT/icon.iconset" -o "$APP/Contents/Resources/AppIcon.icns"

echo "── バンドル ──"
cp "$BINPATH" "$APP/Contents/MacOS/$BIN"
# データ層を同梱する。~/SwiftBar に無い環境でも単体で動くように。
cp ../claude-codex.60s.sh "$APP/Contents/Resources/claude-codex.60s.sh"
chmod +x "$APP/Contents/Resources/claude-codex.60s.sh"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$NAME</string>
  <key>CFBundleDisplayName</key><string>$NAME</string>
  <key>CFBundleIdentifier</key><string>$ID</string>
  <key>CFBundleExecutable</key><string>$BIN</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$SHORT</string>
  <key>CFBundleVersion</key><string>$SHORT</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

ZIP="$OUT/AIUsageBarometer-v$SHORT.zip"
ditto -c -k --keepParent "$APP" "$ZIP"
echo "✔ $APP"
echo "✔ $ZIP  ($(du -h "$ZIP" | cut -f1))"

if [ -n "$VERSION" ]; then
  echo "── Release に添付 ──"
  gh release upload "$VERSION" "$ZIP" --clobber && echo "✔ $VERSION に添付しました"
fi

echo
echo "▶ 手元で試す:  open \"$APP\""
