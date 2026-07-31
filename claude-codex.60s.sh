#!/bin/bash
#
# AI Usage Barometer — one menu-bar item for Claude and Codex.
# Claude comes from the OAuth usage endpoint; Codex is read from the local
# helper installed alongside this plugin. Bars are battery-style: the filled
# part is capacity left, the dotted tail is what has been spent.
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.3.0</xbar.version>
# <xbar.author>Takayuki Miyano</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>One menu-bar item for Claude and Codex usage, with per-window toggles.</xbar.desc>
# <xbar.dependencies>bash,jq,curl,python3</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/ai-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>
#
# License: MIT
#
VERSION="v0.3.0"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"
BETA="oauth-2025-04-20"
MBAR_W=5; DROP_W=10; WARN=70; DANGER=90
FILL="█"; EMPTY="░"; FONT="font=Menlo size=12"; SCALE="auto"

SELF_DIR="$(cd "$(dirname "${SWIFTBAR_PLUGIN_PATH:-$0}")" 2>/dev/null && pwd)"
CODEX_HELPER="${CODEX_HELPER:-$SELF_DIR/.ai-usage-barometer/codex-usage.sh}"

# ── 表示設定 ──
CFG="$HOME/.cache/claude-codex-bar"; mkdir -p "$CFG" 2>/dev/null
rd() { local v=1; [ -f "$CFG/$1" ] && read -r v < "$CFG/$1" 2>/dev/null; case "$v" in 0|1) ;; *) v=1 ;; esac; printf '%s' "$v"; }
CL_ON=$(rd claude_on); C5=$(rd c5); C5P=$(rd c5p); C7=$(rd c7); C7P=$(rd c7p)
CX_ON=$(rd codex_on); CXP=$(rd cxp); MB2=$(rd mb2)
IV=3; [ -f "$CFG/iv" ] && read -r IV < "$CFG/iv" 2>/dev/null
case "$IV" in 1|3|5) ;; *) IV=3 ;; esac
# 全部消えるとクリックできなくなるので Claude 5h を最低限残す
[ "$CL_ON" = 0 ] && [ "$CX_ON" = 0 ] && CL_ON=1
[ "$CL_ON" = 1 ] && [ "$C5" = 0 ] && [ "$C7" = 0 ] && C5=1

tg() { # tg <file> <current> <label>
  local nx=$([ "$2" = 1 ] && echo 0 || echo 1)
  echo "--$3$([ "$2" = 1 ] && echo '  ✓') | shell=/bin/bash param1=-c param2=\"echo $nx > '$CFG/$1'\" terminal=false refresh=true"
}
settings_menu() {
  echo "⚙ 表示設定 | size=12"
  tg claude_on "$CL_ON" "Claude を表示"
  tg c5  "$C5"  "Claude 5h を表示"
  tg c5p "$C5P" "Claude 5h の％"
  tg c7  "$C7"  "Claude 7d を表示"
  tg c7p "$C7P" "Claude 7d の％"
  tg codex_on "$CX_ON" "Codex を表示"
  tg cxp "$CXP" "Codex の％"
  tg mb2 "$MB2" "メニューバー2色描画"
  echo "⏱ 更新間隔: ${IV}分 | size=12"
  local m
  for m in 1 3 5; do
    echo "--${m}分$([ "$IV" = "$m" ] && echo '  ✓') | shell=/bin/bash param1=-c param2=\"echo $m > '$CFG/iv'; mkdir -p '$HOME/.cache/codex-usage-barometer'; echo $((m*60)) > '$HOME/.cache/codex-usage-barometer/interval'\" terminal=false refresh=true"
  done
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
# サービス固有色。状態（通常/警告/逼迫）は同系色内で濃くなる。
CL_OK="#B87966"; CL_WARN="#A86048"; CL_DANGER="#9C4931"   # Claude: マット・ピンクベージュ
CX_OK="#4F7FA8"; CX_WARN="#0E8BA1"; CX_DANGER="#ED5D40"   # Codex: 既存の青系
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
  n=$(date +%s); d=$((e-n)); (( d<0 )) && { echo "間もなく"; return; }
  if (( d>=86400 )); then printf '残り%dd%dh' $((d/86400)) $(((d%86400)/3600))
  else printf '残り%dh%02dm' $((d/3600)) $(((d%3600)/60)); fi; }

# ── Claude（OAuth API・IV分ごとに取得、間はキャッシュ表示）──
P5=-1; P7=-1; R5=""; R7=""; CL_ERR=""
CACHEF="$CFG/claude.tsv"
aT=0; cU5=""; cU7=""; cR5=""; cR7=""
[ -f "$CACHEF" ] && IFS=$'\t' read -r aT cU5 cU7 cR5 cR7 < "$CACHEF" 2>/dev/null
case "$aT" in ''|*[!0-9]*) aT=0 ;; esac
NOW=$(date +%s)
if [ "$CL_ON" = 1 ] && [ $(( NOW - aT )) -lt $(( IV * 60 )) ] && [ -n "$cU5$cU7" ]; then
  U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
  P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
elif [ "$CL_ON" = 1 ]; then
  TOKEN=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
          | jq -r '.claudeAiOauth.accessToken // .accessToken // empty' 2>/dev/null)
  [ -z "$TOKEN" ] && TOKEN=$(jq -r '.claudeAiOauth.accessToken // .accessToken // empty' \
          "$HOME/.claude/.credentials.json" 2>/dev/null)
  if [ -z "$TOKEN" ]; then
    CL_ERR="資格情報が見つかりません"
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
      [ -z "$U5" ] && [ -z "$U7" ] && CL_ERR="APIの形式が想定と違います"
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
if [ "$CX_ON" = 1 ]; then
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
    [ $n = 0 ] && CX_ERR="Codex のデータ待ち（Codex CLI を一度実行）"
  else
    CX_ERR="Codex ヘルパーが見つかりません"
  fi
fi

CX_R1=$(( CX_U1<0 ? -1 : 100-CX_U1 )); CX_R2=$(( CX_U2<0 ? -1 : 100-CX_U2 ))

# ── メニューバー ──
# 1項目=1色の制約があるため、Claude 表示中は Claude の色、
# Claude 非表示のときだけ Codex の色を使う（各サービスの最悪値で段階が決まる）。
CL_WORST=-1; CX_WORST=-1
if [ "$CL_ON" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && (( P5 > CL_WORST )) && CL_WORST=$P5
  [ "$C7" = 1 ] && (( P7 > CL_WORST )) && CL_WORST=$P7
fi
if [ "$CX_ON" = 1 ] && [ -z "$CX_ERR" ]; then
  (( CX_U1 > CX_WORST )) && CX_WORST=$CX_U1
  (( CX_U2 > CX_WORST )) && CX_WORST=$CX_U2
fi
if [ "$CL_ON" = 1 ]; then
  (( CL_WORST<0 )) && CL_WORST=0
  MB_COLOR=$(clcol $CL_WORST)
else
  (( CX_WORST<0 )) && CX_WORST=0
  MB_COLOR=$(cxcol $CX_WORST)
fi

MB=""
if [ "$CL_ON" = 1 ]; then
  if [ -n "$CL_ERR" ]; then MB="Claude ⚠"
  else
    [ "$C5" = 1 ] && MB="5h $(bar $REM5 $MBAR_W)$([ "$C5P" = 1 ] && printf ' %s' "$(fmt $REM5)")"
    [ "$C7" = 1 ] && MB="${MB:+$MB  }7d $(bar $REM7 $MBAR_W)$([ "$C7P" = 1 ] && printf ' %s' "$(fmt $REM7)")"
  fi
fi
if [ "$CX_ON" = 1 ] && [ -z "$CX_ERR" ] && [ -n "$CX_L1" ]; then
  CXMB="$CX_L1 $(bar $CX_R1 $MBAR_W)$([ "$CXP" = 1 ] && printf ' %s' "$(fmt $CX_R1)")"
  [ -n "$CX_L2" ] && CXMB="$CXMB  $CX_L2 $(bar $CX_R2 $MBAR_W)$([ "$CXP" = 1 ] && printf ' %s' "$(fmt $CX_R2)")"
  MB="${MB:+$MB │ }$CXMB"
fi
[ -z "$MB" ] && MB="AI …"

# メニューバー: PDF なら Claude/Codex を別色で描ける（テキストは1項目1色まで）
PDF_SPEC=""
if [ "$CL_ON" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && [ "$REM5" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}5h,$REM5,$(clcol $P5),$C5P"
  [ "$C7" = 1 ] && [ "$REM7" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}7d,$REM7,$(clcol $P7),$C7P"
fi
if [ "$CX_ON" = 1 ] && [ -z "$CX_ERR" ] && [ "$CX_R1" -ge 0 ]; then
  [ -n "$PDF_SPEC" ] && PDF_SPEC="$PDF_SPEC;|"
  PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}$CX_L1,$CX_R1,$(cxcol $CX_U1),$CXP"
  [ -n "$CX_L2" ] && [ "$CX_R2" -ge 0 ] && PDF_SPEC="$PDF_SPEC;$CX_L2,$CX_R2,$(cxcol $CX_U2),$CXP"
fi
B64=""
if [ "$MB2" = 1 ] && [ -n "$PDF_SPEC" ] && command -v python3 >/dev/null 2>&1; then
  B64=$(python3 - "$PDF_SPEC" <<'PYEOF' 2>/dev/null
import sys, base64
spec=[x for x in sys.argv[1].split(";") if x]
def rgb(h):
    h=h.lstrip("#"); return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
X=2.0; ops=[]; CW=6.2; BARW=30.0; BY=4.0; BH=10.0
for item in spec:
    if item=="|":
        ops.append("0.55 0.55 0.55 RG 0.8 w %.1f 3 m %.1f 15 l S"%(X+3,X+3)); X+=10.0; continue
    label,rem,hexc,showp=item.split(",")
    rem=max(0,min(100,int(rem))); r,g,b=rgb(hexc)
    col="%.4f %.4f %.4f"%(r,g,b)
    ops.append("%s rg"%col)
    ops.append("BT /F1 11 Tf %.1f 5 Td (%s) Tj ET"%(X,label)); X+=len(label)*CW+3
    fw=BARW*rem/100.0
    if fw>=0.5: ops.append("%.1f %.1f %.1f %.1f re f"%(X,BY,fw,BH))
    dx=X+fw+2.0
    while dx<X+BARW-0.5:
        for i,dy in enumerate((6.0,10.0)):
            xx=dx+(1.5 if i%2 else 0.0)
            if xx<X+BARW-0.5: ops.append("%.1f %.1f 1 1 re f"%(xx,dy))
        dx+=3.5
    X+=BARW+4
    if showp=="1":
        t="%d%%"%rem
        ops.append("BT /F1 11 Tf %.1f 5 Td (%s) Tj ET"%(X,t)); X+=len(t)*CW+2
    X+=5.0
W=X+2
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
if [ "$CL_ON" = 1 ]; then
  echo "Claude | size=11 color=$CL_OK"
  if [ -n "$CL_ERR" ]; then
    echo "⚠ $CL_ERR | $FONT color=#FF9F0A"
  else
    if [ "$C5" = 1 ]; then
      echo "5h  $(bar $REM5 $DROP_W)$([ "$C5P" = 1 ] && printf '  残り%s' "$(fmt $REM5)") | $FONT color=$(clcol $P5)"
      [ -n "$R5" ] && echo "       $(remain "$R5") に回復 | size=11 color=#888888"
    fi
    if [ "$C7" = 1 ]; then
      echo "7d  $(bar $REM7 $DROP_W)$([ "$C7P" = 1 ] && printf '  残り%s' "$(fmt $REM7)") | $FONT color=$(clcol $P7)"
      [ -n "$R7" ] && echo "       $(remain "$R7") に回復 | size=11 color=#888888"
    fi
  fi
fi
if [ "$CX_ON" = 1 ]; then
  echo "Codex | size=11 color=$CX_OK"
  if [ -n "$CX_ERR" ]; then
    echo "⚠ $CX_ERR | $FONT color=#FF9F0A"
  else
    if [ -n "$CX_L1" ]; then
      echo "$CX_L1  $(bar $CX_R1 $DROP_W)$([ "$CXP" = 1 ] && printf '  残り%s' "$(fmt $CX_R1)") | $FONT color=$(cxcol $CX_U1)"
      [ -n "$CX_T1" ] && echo "       残り$CX_T1 に回復 | size=11 color=#888888"
    fi
    if [ -n "$CX_L2" ]; then
      echo "$CX_L2  $(bar $CX_R2 $DROP_W)$([ "$CXP" = 1 ] && printf '  残り%s' "$(fmt $CX_R2)") | $FONT color=$(cxcol $CX_U2)"
      [ -n "$CX_T2" ] && echo "       残り$CX_T2 に回復 | size=11 color=#888888"
    fi
    [ -n "$CX_CREDITS" ] && echo "$CX_CREDITS | size=11 color=#888888"
  fi
fi
echo "---"
settings_menu
echo "---"
echo "更新: $(date '+%H:%M:%S') | size=11 color=#888888"
echo "今すぐ再読み込み | refresh=true"
