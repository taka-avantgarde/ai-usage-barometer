#!/bin/bash
#
# AI Usage Barometer — one menu-bar item for Claude and Codex.
# Claude comes from the OAuth usage endpoint; Codex is read from the local
# helper installed alongside this plugin. Bars are battery-style: the filled
# part is capacity left, the dotted tail is what has been spent.
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.3.3</xbar.version>
# <xbar.author>Takayuki Miyano</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>One menu-bar item for Claude and Codex usage, with per-window toggles.</xbar.desc>
# <xbar.dependencies>bash,jq,curl,python3</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/ai-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>
# <swiftbar.persistentWebView>true</swiftbar.persistentWebView>
#
# License: MIT
#
VERSION="v0.3.3"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"
BETA="oauth-2025-04-20"
MBAR_W=5; DROP_W=10; WARN=70; DANGER=90
FILL="█"; EMPTY="░"; FONT="font=Menlo size=12"; SCALE="auto"

SELF_DIR="$(cd "$(dirname "${SWIFTBAR_PLUGIN_PATH:-$0}")" 2>/dev/null && pwd)"
CODEX_HELPER="${CODEX_HELPER:-$SELF_DIR/.ai-usage-barometer/codex-usage.sh}"
SETTINGS_PAGE="${AI_USAGE_SETTINGS_PAGE:-$SELF_DIR/.ai-usage-barometer/settings.html}"
UPDATER="${AI_USAGE_UPDATER:-$SELF_DIR/.ai-usage-barometer/update.sh}"

# ── 表示設定 ──
CFG="$HOME/.cache/claude-codex-bar"; mkdir -p "$CFG" 2>/dev/null
rd() { local v=1; [ -f "$CFG/$1" ] && read -r v < "$CFG/$1" 2>/dev/null; case "$v" in 0|1) ;; *) v=1 ;; esac; printf '%s' "$v"; }
CL_ON=$(rd claude_on); C5=$(rd c5); C5P=$(rd c5p); C7=$(rd c7); C7P=$(rd c7p)
CX_ON=$(rd codex_on); CXP=$(rd cxp); CX5=$(rd cx5); CX7=$(rd cx7)
# Preserve the legacy shared Codex percentage preference on first upgrade.
if [ -f "$CFG/cx5p" ]; then CX5P=$(rd cx5p); else CX5P=$CXP; fi
if [ -f "$CFG/cx7p" ]; then CX7P=$(rd cx7p); else CX7P=$CXP; fi
IV=3; [ -f "$CFG/iv" ] && read -r IV < "$CFG/iv" 2>/dev/null
case "$IV" in 1|3|5) ;; *) IV=3 ;; esac

# SwiftBar's refresh URL exposes extra query items as environment variables.
# The persistent settings web view uses that channel so several switches can
# be changed without dismissing the popover after every click.
apply_web_setting() {
  local key="${AUB_KEY:-}" value="${AUB_VALUE:-}"
  case "$key" in
    claude_on|codex_on|c5|c5p|c7|c7p|cx5|cx5p|cx7|cx7p)
      case "$value" in 0|1) printf '%s\n' "$value" > "$CFG/$key" ;; esac
      ;;
    iv)
      case "$value" in
        1|3|5)
          printf '%s\n' "$value" > "$CFG/iv"
          mkdir -p "$HOME/.cache/codex-usage-barometer"
          printf '%s\n' "$((value*60))" > "$HOME/.cache/codex-usage-barometer/interval"
          ;;
      esac
      ;;
  esac
}
[ -n "${AUB_KEY:-}" ] && apply_web_setting
if [ "${AUB_ACTION:-}" = update ] && [ -x "$UPDATER" ]; then
  "$UPDATER" >/tmp/ai-usage-barometer-update.log 2>&1 &
fi
# Refresh values after a web-view action so the same invocation renders the
# updated menu-bar state rather than the values read before applying it.
if [ -n "${AUB_KEY:-}" ]; then
  CL_ON=$(rd claude_on); C5=$(rd c5); C5P=$(rd c5p); C7=$(rd c7); C7P=$(rd c7p)
  CX_ON=$(rd codex_on); CX5=$(rd cx5); CX5P=$(rd cx5p); CX7=$(rd cx7); CX7P=$(rd cx7p)
  IV=3; [ -f "$CFG/iv" ] && read -r IV < "$CFG/iv" 2>/dev/null
  case "$IV" in 1|3|5) ;; *) IV=3 ;; esac
fi

# A provider with no selected usage window is effectively hidden. Skipping its
# data source also prevents stale/API errors from appearing for an unchecked AI.
CL_ACTIVE=0
[ "$CL_ON" = 1 ] && { [ "$C5" = 1 ] || [ "$C7" = 1 ]; } && CL_ACTIVE=1
CX_ACTIVE=0
[ "$CX_ON" = 1 ] && { [ "$CX5" = 1 ] || [ "$CX7" = 1 ]; } && CX_ACTIVE=1

# The plugin interface is intentionally English-only. Documentation remains
# available in multiple languages on GitHub.
sub() { local s="$1"; printf '%s' "${s/\{v\}/$2}"; }
T_SET="Display settings"; T_REFRESH="Refresh now"; T_UPDATED="Updated {v}"
T_LEFT="{v} left"; T_RESET="recovers in {v}"; T_SOON="soon"
T_NOCRED="Credentials not found"; T_BADFMT="Unexpected API format"
T_CXWAIT="Waiting for Codex data (run Codex CLI once)"; T_CXMISS="Codex helper not found"
# 両サービスがオフでも後段の「AI …」ヘッダーがクリック可能な項目を残す。

semver_is_newer() {
  local candidate="${1#v}" current="${2#v}"
  awk -v a="$candidate" -v b="$current" '
    function parts(v, p) { split(v, p, ".") }
    BEGIN {
      parts(a, A); parts(b, B)
      for (i=1; i<=3; i++) {
        av=(A[i] == "" ? 0 : A[i]+0); bv=(B[i] == "" ? 0 : B[i]+0)
        if (av > bv) exit 0
        if (av < bv) exit 1
      }
      exit 1
    }'
}
latest_release_version() {
  local file="$CFG/latest_release" now mtime=0 latest="" enabled="${AI_USAGE_UPDATE_CHECK:-}"
  [ -z "$enabled" ] && [ -n "${SWIFTBAR_PLUGIN_PATH:-}" ] && enabled=1
  [ "$enabled" = 1 ] || return 1
  now=$(date +%s)
  if [ -f "$file" ]; then
    mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo 0)
    if [ $((now-mtime)) -lt 86400 ]; then read -r latest < "$file" 2>/dev/null; fi
  fi
  if [ -z "$latest" ]; then
    latest=$(curl -fsSL --connect-timeout 3 --max-time 6 \
      -H 'Accept: application/vnd.github+json' \
      https://api.github.com/repos/taka-avantgarde/ai-usage-barometer/releases/latest 2>/dev/null |
      jq -r '.tag_name // empty' 2>/dev/null)
    [ -n "$latest" ] && printf '%s\n' "$latest" > "$file"
  fi
  [ -n "$latest" ] && printf '%s\n' "$latest"
}
LATEST_VERSION=$(latest_release_version || true)
UPDATE_AVAILABLE=0
[ -n "$LATEST_VERSION" ] && semver_is_newer "$LATEST_VERSION" "$VERSION" && UPDATE_AVAILABLE=1

uri() {
  python3 - "$1" <<'PY'
import pathlib
import sys
import urllib.parse

print(pathlib.Path(sys.argv[1]).resolve().as_uri().replace("#", "%23"))
PY
}
settings_menu() {
  local page="$SETTINGS_PAGE"
  if [ -f "$page" ]; then
    echo "⚙ $T_SET | size=12 href=$(uri "$page")?claude_on=$CL_ON&c5=$C5&c5p=$C5P&c7=$C7&c7p=$C7P&codex_on=$CX_ON&cx5=$CX5&cx5p=$CX5P&cx7=$CX7&cx7p=$CX7P&iv=$IV&update=$([ "$UPDATE_AVAILABLE" = 1 ] && printf '%s' "$LATEST_VERSION") webview=true webvieww=430 webviewh=720"
  else
    echo "⚠ $T_SET | size=12 color=#FF9F0A tooltip=Settings helper missing; re-run the installer"
  fi
}

to_pct() { local v="$1"; [ -z "$v" ] && { echo "-1"; return; }
  case "$SCALE" in
    yes) awk -v x="$v" 'BEGIN{printf "%.0f", x*100}' ;;
    no)  awk -v x="$v" 'BEGIN{printf "%.0f", x}' ;;
    *)   awk -v x="$v" 'BEGIN{ if (x<=1) printf "%.0f",x*100; else printf "%.0f",x }' ;;
  esac; }
bar() { local p=$1 w=$2 i f s=""; (( p<0 )) && p=0; (( p>100 )) && p=100
  f=$(( (p*w+50)/100 )); (( f>w )) && f=w
  for ((i=0;i<f;i++)); do s+="$FILL"; done
  for ((i=f;i<w;i++)); do s+="$EMPTY"; done; printf '%s' "$s"; }
# サービス固有色。白を混ぜた明るい色調を保ち、同系色内で段階を分ける。
CL_OK="#C66D28"; CL_WARN="#B65A1E"; CL_DANGER="#C52E22"   # Claude: オレンジ警告・赤橙の逼迫
CX_OK="#1A8BA6"; CX_WARN="#52768A"; CX_DANGER="#783F78"   # Codex: 青橙警告・青赤の逼迫
clcol() { local p=$1; if (( p>=DANGER )); then echo "$CL_DANGER"
  elif (( p>=WARN )); then echo "$CL_WARN"; else echo "$CL_OK"; fi; }
cxcol() { local p=$1; if (( p>=DANGER )); then echo "$CX_DANGER"
  elif (( p>=WARN )); then echo "$CX_WARN"; else echo "$CX_OK"; fi; }
fmt() { local p=$1; (( p<0 )) && { echo "--"; return; }; printf '%d%%' "$p"; }
remain() { local iso="$1" ts e n d; [ -z "$iso" ] && { echo ""; return; }
  ts="${iso/Z/+00:00}"
  ts=$(printf '%s' "$ts" | sed -E 's/\.[0-9]+//; s/([+-][0-9][0-9]):([0-9][0-9])$/\1\2/')
  e=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$ts" +%s 2>/dev/null)
  [ -z "$e" ] && { echo "$iso"; return; }
  n=$(date +%s); d=$((e-n)); (( d<0 )) && { echo "$T_SOON"; return; }
  if (( d>=86400 )); then printf '%dd %dh' $((d/86400)) $(((d%86400)/3600))
  else printf '%dh %02dm' $((d/3600)) $(((d%3600)/60)); fi; }

# ── Claude（OAuth API・IV分ごとに取得、間はキャッシュ表示）──
P5=-1; P7=-1; R5=""; R7=""; CL_ERR=""
CACHEF="$CFG/claude.tsv"
aT=0; cU5=""; cU7=""; cR5=""; cR7=""
[ -f "$CACHEF" ] && IFS=$'\t' read -r aT cU5 cU7 cR5 cR7 < "$CACHEF" 2>/dev/null
case "$aT" in ''|*[!0-9]*) aT=0 ;; esac
NOW=$(date +%s)
if [ "$CL_ACTIVE" = 1 ] && [ $(( NOW - aT )) -lt $(( IV * 60 )) ] && [ -n "$cU5$cU7" ]; then
  U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
  P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
elif [ "$CL_ACTIVE" = 1 ]; then
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
          | jq -r '.claudeAiOauth.accessToken // .accessToken // empty' 2>/dev/null)
  [ -z "$TOKEN" ] && TOKEN=$(jq -r '.claudeAiOauth.accessToken // .accessToken // empty' \
          "$HOME/.claude/.credentials.json" 2>/dev/null)
  if [ -z "$TOKEN" ]; then
    CL_ERR="$T_NOCRED"
  else
    RESP=$(curl -s -m 8 -w $'\n%{http_code}' "$ENDPOINT" \
            -H "Authorization: Bearer $TOKEN" -H "anthropic-beta: $BETA")
    CODE="${RESP##*$'\n'}"; BODY="${RESP%$'\n'*}"
    if [ "$CODE" != "200" ]; then
      CL_ERR="HTTP $CODE"
    else
      U5=$(printf '%s' "$BODY" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
      U7=$(printf '%s' "$BODY" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
      R5=$(printf '%s' "$BODY" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
      R7=$(printf '%s' "$BODY" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
      [ -z "$U5" ] && [ -z "$U7" ] && CL_ERR="$T_BADFMT"
      P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
      [ -z "$CL_ERR" ] && printf '%s\t%s\t%s\t%s\t%s\n' "$NOW" "$U5" "$U7" "$R5" "$R7" > "$CACHEF"
    fi
  fi
  # 取得に失敗してもキャッシュがあればそれを表示（エラーはキャッシュ無し時のみ）
  if [ -n "$CL_ERR" ] && [ -n "$cU5$cU7" ]; then
    CL_ERR=""; U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
    P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
  fi
fi

REM5=$(( P5<0 ? -1 : 100-P5 )); REM7=$(( P7<0 ? -1 : 100-P7 ))

# ── Codex（既存ヘルパーの出力を解析）──
CX_L1=""; CX_U1=-1; CX_T1=""; CX_L2=""; CX_U2=-1; CX_T2=""; CX_CREDITS=""; CX_ERR=""
if [ "$CX_ACTIVE" = 1 ]; then
  if [ -x "$CODEX_HELPER" ]; then
    CX_OUT=$("$CODEX_HELPER" 2>/dev/null || true)
    # 詳細部（最初の --- 以降）から「<label> … <n>% used」と「resets in …」を拾う
    n=0; expect=""
    while IFS= read -r line; do
      p="${line%%|*}"
      lbl=$(printf '%s' "$p" | sed -nE 's/^[[:space:]]*([0-9]+[a-z]+)[[:space:]].*[^0-9]([0-9]+)% used.*/\1/p')
      if [ -n "$lbl" ]; then
        usd=$(printf '%s' "$p" | sed -nE 's/.*[^0-9]([0-9]+)% used.*/\1/p')
        n=$((n+1))
        if [ $n = 1 ]; then CX_L1="$lbl"; CX_U1="$usd"; expect=1
        elif [ $n = 2 ]; then CX_L2="$lbl"; CX_U2="$usd"; expect=2; fi
        continue
      fi
      rst=$(printf '%s' "$p" | sed -nE 's/.*resets in ([^|]*).*/\1/p' | sed 's/[[:space:]]*$//')
      if [ -n "$rst" ] && [ -n "$expect" ]; then
        [ "$expect" = 1 ] && CX_T1="$rst"; [ "$expect" = 2 ] && CX_T2="$rst"
        expect=""; continue
      fi
      case "$p" in Credits:*) CX_CREDITS=$(printf '%s' "$p" | sed 's/[[:space:]]*$//') ;; esac
    done <<EOF_CX
$(printf '%s\n' "$CX_OUT" | sed -n '/^---$/,$p')
EOF_CX
    [ $n = 0 ] && CX_ERR="$T_CXWAIT"
  else
    CX_ERR="$T_CXMISS"
  fi
fi

CX_R1=$(( CX_U1<0 ? -1 : 100-CX_U1 )); CX_R2=$(( CX_U2<0 ? -1 : 100-CX_U2 ))

cx_window_enabled() {
  case "$1" in
    5h) [ "$CX5" = 1 ] ;;
    7d) [ "$CX7" = 1 ] ;;
    *) return 0 ;;
  esac
}
cx_window_percentage() {
  case "$1" in
    5h) printf '%s' "$CX5P" ;;
    7d) printf '%s' "$CX7P" ;;
    *) printf '1' ;;
  esac
}

# ── メニューバー ──
# 1項目=1色の制約があるため、Claude 表示中は Claude の色、
# Claude 非表示のときだけ Codex の色を使う（各サービスの最悪値で段階が決まる）。
CL_WORST=-1; CX_WORST=-1
if [ "$CL_ACTIVE" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && (( P5 > CL_WORST )) && CL_WORST=$P5
  [ "$C7" = 1 ] && (( P7 > CL_WORST )) && CL_WORST=$P7
fi
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ]; then
  cx_window_enabled "$CX_L1" && (( CX_U1 > CX_WORST )) && CX_WORST=$CX_U1
  cx_window_enabled "$CX_L2" && (( CX_U2 > CX_WORST )) && CX_WORST=$CX_U2
fi
if [ "$CL_ACTIVE" = 1 ]; then
  (( CL_WORST<0 )) && CL_WORST=0
  MB_COLOR=$(clcol $CL_WORST)
else
  (( CX_WORST<0 )) && CX_WORST=0
  MB_COLOR=$(cxcol $CX_WORST)
fi

MB=""
if [ "$CL_ACTIVE" = 1 ]; then
  if [ -n "$CL_ERR" ]; then MB="Claude ⚠"
  else
    [ "$C5" = 1 ] && MB="5h $(bar $REM5 $MBAR_W)$([ "$C5P" = 1 ] && printf ' %s' "$(fmt $REM5)")"
    [ "$C7" = 1 ] && MB="${MB:+$MB  }7d $(bar $REM7 $MBAR_W)$([ "$C7P" = 1 ] && printf ' %s' "$(fmt $REM7)")"
  fi
fi
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ] && [ -n "$CX_L1" ]; then
  CXMB=""
  if cx_window_enabled "$CX_L1"; then
    CXMB="$CX_L1 $(bar $CX_R1 $MBAR_W)$([ "$(cx_window_percentage "$CX_L1")" = 1 ] && printf ' %s' "$(fmt $CX_R1)")"
  fi
  if [ -n "$CX_L2" ] && cx_window_enabled "$CX_L2"; then
    CXMB="${CXMB:+$CXMB  }$CX_L2 $(bar $CX_R2 $MBAR_W)$([ "$(cx_window_percentage "$CX_L2")" = 1 ] && printf ' %s' "$(fmt $CX_R2)")"
  fi
  [ -n "$CXMB" ] && MB="${MB:+$MB │ }$CXMB"
fi
[ -z "$MB" ] && MB="AI …"

# メニューバー: PDF なら Claude/Codex を別色で描ける（テキストは1項目1色まで）
PDF_SPEC=""
if [ "$CL_ACTIVE" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && [ "$REM5" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}5h,$REM5,$(clcol $P5),$C5P"
  [ "$C7" = 1 ] && [ "$REM7" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}7d,$REM7,$(clcol $P7),$C7P"
fi
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ]; then
  CX_PDF=""
  if [ "$CX_R1" -ge 0 ] && cx_window_enabled "$CX_L1"; then
    CX_PDF="$CX_L1,$CX_R1,$(cxcol $CX_U1),$(cx_window_percentage "$CX_L1")"
  fi
  if [ -n "$CX_L2" ] && [ "$CX_R2" -ge 0 ] && cx_window_enabled "$CX_L2"; then
    CX_PDF="${CX_PDF:+$CX_PDF;}$CX_L2,$CX_R2,$(cxcol $CX_U2),$(cx_window_percentage "$CX_L2")"
  fi
  if [ -n "$CX_PDF" ]; then
    [ -n "$PDF_SPEC" ] && PDF_SPEC="$PDF_SPEC;|"
    PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}$CX_PDF"
  fi
fi
B64=""
if [ -n "$PDF_SPEC" ] && command -v python3 >/dev/null 2>&1; then
  B64=$(python3 - "$PDF_SPEC" <<'PYEOF' 2>/dev/null
import sys, base64
spec=[x for x in sys.argv[1].split(";") if x]
def rgb(h):
    h=h.lstrip("#"); return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
X=2.0; ops=[]; CW=6.2; BARW=30.0; BY=4.0; BH=10.0
TEXT_COL="0.92 0.94 0.96 rg"
for item in spec:
    if item=="|":
        ops.append("0.55 0.55 0.55 RG 0.8 w %.1f 3 m %.1f 15 l S"%(X+3,X+3)); X+=10.0; continue
    label,rem,hexc,showp=item.split(",")
    rem=max(0,min(100,int(rem))); r,g,b=rgb(hexc)
    col="%.4f %.4f %.4f"%(r,g,b)
    ops.append(TEXT_COL)
    ops.append("BT /F1 11 Tf %.1f 5 Td (%s) Tj ET"%(X,label)); X+=len(label)*CW+3
    ops.append("%s rg"%col)
    fw=BARW*rem/100.0
    if fw>=0.5: ops.append("%.1f %.1f %.1f %.1f re f"%(X,BY,fw,BH))
    # 消費分はドロップダウンの ░ と同じ「全高の網目」。ただし密度は控えめ
    # （面積比 約17%。░ の25%より軽く、太く見えないようにする）
    PITCH=2.2; DOT=0.9
    dx=X+fw+1.4; c=0
    while dx<X+BARW-DOT:
        yy=BY+0.6; r=0
        while yy<BY+BH-DOT:
            xx=dx+(PITCH/2 if r%2 else 0.0)
            if xx<X+BARW-DOT:
                ops.append("%.2f %.2f %.1f %.1f re f"%(xx,yy,DOT,DOT))
            yy+=PITCH; r+=1
        dx+=PITCH; c+=1
    X+=BARW+4
    if showp=="1":
        t="%d%%"%rem
        ops.append(TEXT_COL)
        ops.append("BT /F1 11 Tf %.1f 5 Td (%s) Tj ET"%(X,t)); X+=len(t)*CW+2
    X+=5.0
W=X+2
BG_LEFT=0.5; BG_BOTTOM=1.0; BG_WIDTH=W-1.0; BG_HEIGHT=16.0
ops.insert(0, "0.1255 0.1451 0.1686 rg %.1f %.1f %.1f %.1f re f"%(BG_LEFT,BG_BOTTOM,BG_WIDTH,BG_HEIGHT))
sb=("\n".join(ops)+"\n").encode()
objs=[(1,b"<< /Type /Catalog /Pages 2 0 R >>"),
      (2,b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>"),
      (3,("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %.0f 18] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>"%W).encode()),
      (4,b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"),
      (5,b"<< /Length %d >>\nstream\n"%len(sb)+sb+b"endstream")]
out=b"%PDF-1.4\n"; offs={}
for n,body in objs:
    offs[n]=len(out); out+=b"%d 0 obj\n"%n+body+b"\nendobj\n"
xref=len(out)
out+=b"xref\n0 6\n0000000000 65535 f \n"
for n in range(1,6): out+=b"%010d 00000 n \n"%offs[n]
out+=b"trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n%d\n%%%%EOF\n"%xref
sys.stdout.write(base64.b64encode(out).decode())
PYEOF
)
fi
if [ -n "$B64" ]; then
  echo "| image=$B64 dropdown=false"
else
  echo "$MB | $FONT color=$MB_COLOR"
fi
echo "---"

# ── ドロップダウン ──
if [ "$CL_ACTIVE" = 1 ]; then
  echo "Claude | size=11 color=$CL_OK"
  if [ -n "$CL_ERR" ]; then
    echo "⚠ $CL_ERR | $FONT color=#FF9F0A"
  else
    if [ "$C5" = 1 ]; then
      echo "5h  $(bar $REM5 $DROP_W)$([ "$C5P" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $REM5)")") | $FONT color=$(clcol $P5)"
      [ -n "$R5" ] && echo "       $(sub "$T_RESET" "$(remain "$R5")") | size=11 color=#888888"
    fi
    if [ "$C7" = 1 ]; then
      echo "7d  $(bar $REM7 $DROP_W)$([ "$C7P" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $REM7)")") | $FONT color=$(clcol $P7)"
      [ -n "$R7" ] && echo "       $(sub "$T_RESET" "$(remain "$R7")") | size=11 color=#888888"
    fi
  fi
fi
if [ "$CX_ACTIVE" = 1 ]; then
  echo "Codex | size=11 color=$CX_OK"
  if [ -n "$CX_ERR" ]; then
    echo "⚠ $CX_ERR | $FONT color=#FF9F0A"
  else
    if [ -n "$CX_L1" ] && cx_window_enabled "$CX_L1"; then
      echo "$CX_L1  $(bar $CX_R1 $DROP_W)$([ "$(cx_window_percentage "$CX_L1")" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $CX_R1)")") | $FONT color=$(cxcol $CX_U1)"
      [ -n "$CX_T1" ] && echo "       $(sub "$T_RESET" "$CX_T1") | size=11 color=#888888"
    fi
    if [ -n "$CX_L2" ] && cx_window_enabled "$CX_L2"; then
      echo "$CX_L2  $(bar $CX_R2 $DROP_W)$([ "$(cx_window_percentage "$CX_L2")" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $CX_R2)")") | $FONT color=$(cxcol $CX_U2)"
      [ -n "$CX_T2" ] && echo "       $(sub "$T_RESET" "$CX_T2") | size=11 color=#888888"
    fi
    [ -n "$CX_CREDITS" ] && echo "$CX_CREDITS | size=11 color=#888888"
  fi
fi
echo "---"
[ "$UPDATE_AVAILABLE" = 1 ] && echo "⬆ Update $LATEST_VERSION available | color=#FF9F0A href=https://github.com/taka-avantgarde/ai-usage-barometer/releases/latest"
settings_menu
echo "---"
echo "$(sub "$T_UPDATED" "$(date '+%H:%M:%S')") | size=11 color=#888888"
echo "$T_REFRESH | refresh=true"
