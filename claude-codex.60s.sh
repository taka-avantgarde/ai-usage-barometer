#!/bin/bash
#
# AI Usage Barometer — one menu-bar item for Claude and Codex.
# Claude comes from the OAuth usage endpoint; Codex is read from the local
# helper installed alongside this plugin. Bars are battery-style: the filled
# part is capacity left, the dotted tail is what has been spent.
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.8.1</xbar.version>
# <xbar.author>Takayuki Miyano</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>One menu-bar item for Claude, Codex and Gemini usage, with per-window toggles.</xbar.desc>
# <xbar.dependencies>bash,curl</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/ai-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>
# <swiftbar.persistentWebView>true</swiftbar.persistentWebView>
#
# License: MIT
#
VERSION="v0.8.1"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
ENDPOINT="https://api.anthropic.com/api/oauth/usage"
BETA="oauth-2025-04-20"
MBAR_W=5; DROP_W=10; WARN=70; DANGER=90
FILL="█"; EMPTY="░"; FONT="font=Menlo size=12"; SCALE="auto"

SELF_DIR="$(cd "$(dirname "${SWIFTBAR_PLUGIN_PATH:-$0}")" 2>/dev/null && pwd)"
CODEX_HELPER="${CODEX_HELPER:-$SELF_DIR/.ai-usage-barometer/codex-usage.sh}"
[ ! -f "$CODEX_HELPER" ] && [ -f "$SELF_DIR/codex-usage.sh" ] && CODEX_HELPER="$SELF_DIR/codex-usage.sh"
GEMINI_HELPER="${GEMINI_HELPER:-$SELF_DIR/.ai-usage-barometer/gemini-usage.sh}"
[ ! -f "$GEMINI_HELPER" ] && [ -f "$SELF_DIR/gemini-usage.sh" ] && GEMINI_HELPER="$SELF_DIR/gemini-usage.sh"
SETTINGS_PAGE="${AI_USAGE_SETTINGS_PAGE:-$SELF_DIR/.ai-usage-barometer/settings.html}"
UPDATER="${AI_USAGE_UPDATER:-$SELF_DIR/.ai-usage-barometer/update.sh}"

# ── 表示設定 ──
CFG="$HOME/.cache/claude-codex-bar"; mkdir -p "$CFG" 2>/dev/null
rd() { local v=1; [ -f "$CFG/$1" ] && read -r v < "$CFG/$1" 2>/dev/null; case "$v" in 0|1) ;; *) v=1 ;; esac; printf '%s' "$v"; }
# jq があれば使う。無い環境でも動くよう、必要な取り出しだけ代替を用意する。
# アプリ単体で入れた人に Homebrew を強いないため。読むのは3種類の決まった形
# （鍵・使用量・リリース）だけなので、汎用パーサは要らない。
HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1
jpick() { # jpick <json> <field> [parent]
  if [ "$HAVE_JQ" = 1 ]; then
    if [ -n "${3:-}" ]; then printf '%s' "$1" | jq -r ".$3.$2 // empty" 2>/dev/null
    else printf '%s' "$1" | jq -r ".$2 // empty" 2>/dev/null; fi
    return
  fi
  local src v
  src=$(printf '%s' "$1" | tr -d '\n\r')
  if [ -n "${3:-}" ]; then
    src=$(printf '%s' "$src" | sed -n "s/.*\"$3\"[[:space:]]*:[[:space:]]*{\([^{}]*\)}.*/\1/p")
  fi
  v=$(printf '%s' "$src" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p")
  [ -z "$v" ] && v=$(printf '%s' "$src" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\([0-9][0-9.]*\).*/\1/p")
  printf '%s' "$v"
}

CL_ON=$(rd claude_on); C5=$(rd c5); C5P=$(rd c5p); C7=$(rd c7); C7P=$(rd c7p)
CX_ON=$(rd codex_on); CXP=$(rd cxp); CX5=$(rd cx5); CX7=$(rd cx7)
GM_ON=$(rd gemini_on); GM5=$(rd gm5); GM5P=$(rd gm5p); GM7=$(rd gm7); GM7P=$(rd gm7p)
CMP=$(rd cmp)
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
    claude_on|codex_on|gemini_on|c5|c5p|c7|c7p|cx5|cx5p|cx7|cx7p|gm5|gm5p|gm7|gm7p|cmp)
      case "$value" in 0|1) printf '%s\n' "$value" > "$CFG/$key" ;; esac
      # 親子連動:
      # 1) 親を OFF にしたら傘下の 5h / 1w もすべて OFF にする
      # 2) 親を ON にしたら傘下の 5h / 1w もすべて ON にする
      # 3) 子を ON にしたら親も自動で ON にする
      # 4) 傘下の子がすべて OFF になったら親も自動で OFF にする
      case "$key:$value" in
        claude_on:0) printf '0\n' > "$CFG/c5"; printf '0\n' > "$CFG/c7" ;;
        claude_on:1) printf '1\n' > "$CFG/c5"; printf '1\n' > "$CFG/c7" ;;
        codex_on:0)  printf '0\n' > "$CFG/cx5"; printf '0\n' > "$CFG/cx7" ;;
        codex_on:1)  printf '1\n' > "$CFG/cx5"; printf '1\n' > "$CFG/cx7" ;;
        gemini_on:0) printf '0\n' > "$CFG/gm5"; printf '0\n' > "$CFG/gm7" ;;
        gemini_on:1) printf '1\n' > "$CFG/gm5"; printf '1\n' > "$CFG/gm7" ;;
        c5:1|c7:1)   printf '1\n' > "$CFG/claude_on" ;;
        c5:0|c7:0)   [ "$(rd c5)" = 0 ] && [ "$(rd c7)" = 0 ] && printf '0\n' > "$CFG/claude_on" ;;
        cx5:1|cx7:1) printf '1\n' > "$CFG/codex_on" ;;
        cx5:0|cx7:0) [ "$(rd cx5)" = 0 ] && [ "$(rd cx7)" = 0 ] && printf '0\n' > "$CFG/codex_on" ;;
        gm5:1|gm7:1) printf '1\n' > "$CFG/gemini_on" ;;
        gm5:0)       printf '0\n' > "$CFG/gemini_on" ;;
      esac
      ;;
    iv)
      case "$value" in
        1|3|5)
          printf '%s\n' "$value" > "$CFG/iv"
          mkdir -p "$HOME/.cache/codex-usage-barometer"
          printf '%s\n' "$((value*60))" > "$HOME/.cache/codex-usage-barometer/interval"
          mkdir -p "$HOME/.cache/gemini-usage-barometer"
          printf '%s\n' "$((value*60))" > "$HOME/.cache/gemini-usage-barometer/interval"
          ;;
      esac
      ;;
  esac
}
[ -n "${AUB_KEY:-}" ] && apply_web_setting
if [ -n "${AUB_BULK:-}" ]; then
  OLD_IFS="$IFS"; IFS=','
  for pair in $AUB_BULK; do
    IFS="$OLD_IFS"
    AUB_KEY="${pair%%:*}" AUB_VALUE="${pair#*:}" apply_web_setting
  done
  IFS="$OLD_IFS"
fi
# SwiftBar の URL スキーム経由が効かない環境があるため、メニュー項目から
# 直接呼べる引数も用意する（Codex ヘルパーと同じ bash= 方式）。
if [ "${1:-}" = "--set" ] && [ -n "${2:-}" ]; then
  AUB_KEY="$2" AUB_VALUE="${3:-}" apply_web_setting
  open -g "swiftbar://refreshplugin?name=claude-codex.60s.sh" >/dev/null 2>&1 &
  exit 0
fi
# 更新はメニューから1クリックで完了させる。通知だけ出して手順を読ませない。
if [ "${1:-}" = "--update" ]; then
  if [ -x "$UPDATER" ]; then "$UPDATER" >/tmp/ai-usage-barometer-update.log 2>&1
  else /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)" \
       >/tmp/ai-usage-barometer-update.log 2>&1; fi
  exit 0
fi
if [ "${AUB_ACTION:-}" = update ] && [ -x "$UPDATER" ]; then
  "$UPDATER" >/tmp/ai-usage-barometer-update.log 2>&1 &
fi
# Refresh values after a web-view action so the same invocation renders the
# updated menu-bar state rather than the values read before applying it.
if [ -n "${AUB_KEY:-}${AUB_BULK:-}" ]; then
  CL_ON=$(rd claude_on); C5=$(rd c5); C5P=$(rd c5p); C7=$(rd c7); C7P=$(rd c7p)
  CX_ON=$(rd codex_on); CX5=$(rd cx5); CX5P=$(rd cx5p); CX7=$(rd cx7); CX7P=$(rd cx7p)
  GM_ON=$(rd gemini_on); GM5=$(rd gm5); GM5P=$(rd gm5p); GM7=$(rd gm7); GM7P=$(rd gm7p)
  CMP=$(rd cmp)
  IV=3; [ -f "$CFG/iv" ] && read -r IV < "$CFG/iv" 2>/dev/null
  case "$IV" in 1|3|5) ;; *) IV=3 ;; esac
fi

# A provider with no selected usage window is effectively hidden. Skipping its
# data source also prevents stale/API errors from appearing for an unchecked AI.
CL_ACTIVE=0
[ "$CL_ON" = 1 ] && { [ "$C5" = 1 ] || [ "$C7" = 1 ]; } && CL_ACTIVE=1
CX_ACTIVE=0
[ "$CX_ON" = 1 ] && { [ "$CX5" = 1 ] || [ "$CX7" = 1 ]; } && CX_ACTIVE=1
GM_ACTIVE=0
[ "$GM_ON" = 1 ] && { [ "$GM5" = 1 ] || [ "$GM7" = 1 ]; } && GM_ACTIVE=1

# The plugin interface is intentionally English-only. Documentation remains
# available in multiple languages on GitHub.
sub() { local s="$1"; printf '%s' "${s/\{v\}/$2}"; }
T_SET="Display settings"; T_REFRESH="Refresh now"; T_UPDATED="Updated {v}"
T_LEFT="{v} left"; T_RESET="recovers in {v}"; T_SOON="soon"
T_NOCRED="Credentials not found"; T_BADFMT="Unexpected API format"
T_CXWAIT="Waiting for Codex data (run Codex CLI once)"; T_CXMISS="Codex helper not found"
T_REAUTH="Sign in to Claude Code again"; T_RATELIMIT="Rate limited — retrying soon"
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
    latest=$(jpick "$(curl -fsSL --connect-timeout 3 --max-time 6 \
      -H 'Accept: application/vnd.github+json' \
      https://api.github.com/repos/taka-avantgarde/ai-usage-barometer/releases/latest 2>/dev/null)" tag_name)
    [ -n "$latest" ] && printf '%s\n' "$latest" > "$file"
  fi
  [ -n "$latest" ] && printf '%s\n' "$latest"
}
LATEST_VERSION=$(latest_release_version || true)
UPDATE_AVAILABLE=0
[ -n "$LATEST_VERSION" ] && semver_is_newer "$LATEST_VERSION" "$VERSION" && UPDATE_AVAILABLE=1

SELF_PATH="${SWIFTBAR_PLUGIN_PATH:-$0}"
if [ "$UPDATE_AVAILABLE" = 1 ]; then
  if [ "${AI_USAGE_AUTO_UPDATE:-1}" = 1 ] && [ -z "${AI_USAGE_UPDATE_CHECK:-}" ] && [ -n "${SWIFTBAR_PLUGIN_PATH:-}" ]; then
    LAST_AUTO_UPDATED=""
    [ -f "$CFG/auto_updated_version" ] && read -r LAST_AUTO_UPDATED < "$CFG/auto_updated_version" 2>/dev/null || true
    if [ "$LAST_AUTO_UPDATED" != "$LATEST_VERSION" ]; then
      printf '%s\n' "$LATEST_VERSION" > "$CFG/auto_updated_version" 2>/dev/null || true
      osascript -e "display notification \"Updating automatically to $LATEST_VERSION (Claude, Codex & Gemini)…\" with title \"AI Usage Barometer\"" 2>/dev/null || true
      "$SELF_PATH" --update >/tmp/ai-usage-barometer-update.log 2>&1 &
    fi
  fi
fi

uri() {
  python3 - "$1" <<'PY'
import pathlib
import sys
import urllib.parse

print(pathlib.Path(sys.argv[1]).resolve().as_uri().replace("#", "%23"))
PY
}
# 設定画面は persistentWebView で常駐するため、クエリ文字列だけに頼ると
# 画面と実ファイルが食い違ったまま自己修復しない。毎回これを書き出して
# 画面側から読み直させる。
write_settings_state() {
  local dir; dir="$(dirname "$SETTINGS_PAGE")"
  [ -d "$dir" ] || return 0
  local cxl1="${CX_L1:-5h}" cxl2="${CX_L2:-7d}"
  [ "$CX_L1" = "7d" ] && [ -z "$CX_L2" ] && { cxl1="5h"; cxl2="7d"; }
  printf '{"claude_on":"%s","c5":"%s","c5p":"%s","c7":"%s","c7p":"%s","codex_on":"%s","cx5":"%s","cx5p":"%s","cx7":"%s","cx7p":"%s","gemini_on":"%s","gm5":"%s","gm5p":"%s","gm7":"%s","gm7p":"%s","iv":"%s","update":"%s","cx_l1":"%s","cx_l2":"%s","gm_l1":"%s","gm_l2":"%s"}\n' \
    "$CL_ON" "$C5" "$C5P" "$C7" "$C7P" "$CX_ON" "$CX5" "$CX5P" "$CX7" "$CX7P" "$GM_ON" "$GM5" "$GM5P" "$GM7" "$GM7P" "$IV" \
    "$([ "$UPDATE_AVAILABLE" = 1 ] && printf '%s' "$LATEST_VERSION")" "$cxl1" "$cxl2" "$GM_L1" "$GM_L2" > "$dir/state.json.tmp" &&
    mv -f "$dir/state.json.tmp" "$dir/state.json"
}

SELF_PATH="${SWIFTBAR_PLUGIN_PATH:-$0}"
tg() { # tg <key> <現在値> <ラベル>
  local nx; nx=$([ "$2" = 1 ] && echo 0 || echo 1)
  echo "--$3$([ "$2" = 1 ] && echo '  ✓') | bash='$SELF_PATH' param1=--set param2=$1 param3=$nx terminal=false refresh=true"
}
toggle_menu() {
  local cl_c5=0 cl_c7=0 cx_5=0 cx_7=0 gm_5=0
  [ "$CL_ON" = 1 ] && [ "$C5" = 1 ] && cl_c5=1
  [ "$CL_ON" = 1 ] && [ "$C7" = 1 ] && cl_c7=1
  [ "$CX_ON" = 1 ] && [ "$CX5" = 1 ] && cx_5=1
  [ "$CX_ON" = 1 ] && [ "$CX7" = 1 ] && cx_7=1
  [ "$GM_ON" = 1 ] && [ "$GM5" = 1 ] && gm_5=1
  echo "⚙ Display settings | size=12"
  tg claude_on "$CL_ACTIVE" "Claude"
  tg c5 "$cl_c5" "  5h"
  tg c5p "$C5P" "  5h %"
  tg c7 "$cl_c7" "  1w (7d)"
  tg c7p "$C7P" "  1w (7d) %"
  tg codex_on "$CX_ACTIVE" "Codex"
  local cx_l1="${CX_L1:-5h}" cx_l2="${CX_L2:-7d}"
  [ "$CX_L1" = "7d" ] && [ -z "$CX_L2" ] && { cx_l1="5h"; cx_l2="7d"; }
  tg cx5 "$cx_5" "  $cx_l1"
  tg cx5p "$CX5P" "  $cx_l1 %"
  tg cx7 "$cx_7" "  1w ($cx_l2)"
  tg cx7p "$CX7P" "  1w ($cx_l2) %"
  tg gemini_on "$GM_ACTIVE" "Gemini"
  local gm_l1="${GM_L1:-5h}"
  tg gm5 "$gm_5" "  $gm_l1"
  tg gm5p "$GM5P" "  $gm_l1 %"
  tg cmp "$CMP" "Compact (fits beside the notch)"
  echo "⏱ Refresh: ${IV} min | size=12"
  local m
  for m in 1 3 5; do
    echo "--${m} min$([ "$IV" = "$m" ] && echo '  ✓') | bash='$SELF_PATH' param1=--set param2=iv param3=$m terminal=false refresh=true"
  done
}

settings_menu() {
  local page="$SETTINGS_PAGE"
  if [ -f "$page" ]; then
    write_settings_state
    echo "⚙ $T_SET | size=12 href=$(uri "$page")?claude_on=$CL_ON&c5=$C5&c5p=$C5P&c7=$C7&c7p=$C7P&codex_on=$CX_ON&cx5=$CX5&cx5p=$CX5P&cx7=$CX7&cx7p=$CX7P&gemini_on=$GM_ON&gm5=$GM5&gm5p=$GM5P&gm7=$GM7&gm7p=$GM7P&iv=$IV&update=$([ "$UPDATE_AVAILABLE" = 1 ] && printf '%s' "$LATEST_VERSION") webview=true webvieww=430 webviewh=720"
  else
    echo "⚠ $T_SET | size=12 color=#FF9F0A tooltip=Settings helper missing; re-run the installer"
  fi
}

to_pct() { local v="$1"; [ -z "$v" ] && { echo "-1"; return; }
  case "$SCALE" in
    yes) awk -v x="$v" 'BEGIN{printf "%.0f", x*100}' ;;
    no)  awk -v x="$v" 'BEGIN{printf "%.0f", x}' ;;
    *)   awk -v x="$v" 'BEGIN{ if (x>0 && x<1) printf "%.0f",x*100; else printf "%.0f",x }' ;;
  esac; }
bar() { local p=$1 w=$2 i f s=""; (( p<0 )) && p=0; (( p>100 )) && p=100
  f=$(( (p*w+50)/100 )); (( f>w )) && f=w
  for ((i=0;i<f;i++)); do s+="$FILL"; done
  for ((i=f;i<w;i++)); do s+="$EMPTY"; done; printf '%s' "$s"; }
# サービス固有色。白を混ぜた明るい色調を保ち、同系色内で段階を分ける。
CL_OK="#C66D28"; CL_WARN="#B65A1E"; CL_DANGER="#C52E22"   # Claude: オレンジ警告・赤橙の逼迫
CX_OK="#1A8BA6"; CX_WARN="#52768A"; CX_DANGER="#783F78"   # Codex: 青橙警告・青赤の逼迫
GM_OK="#158F6A"; GM_WARN="#5E7B3A"; GM_DANGER="#8C3B5A"   # Gemini: エメラルドグリーン
clcol() { local p=$1; if (( p>=DANGER )); then echo "$CL_DANGER"
  elif (( p>=WARN )); then echo "$CL_WARN"; else echo "$CL_OK"; fi; }
cxcol() { local p=$1; if (( p>=DANGER )); then echo "$CX_DANGER"
  elif (( p>=WARN )); then echo "$CX_WARN"; else echo "$CX_OK"; fi; }
gmcol() { local p=$1; if (( p>=DANGER )); then echo "$GM_DANGER"
  elif (( p>=WARN )); then echo "$GM_WARN"; else echo "$GM_OK"; fi; }
fmt() { local p=$1; (( p<0 )) && { echo "--"; return; }; printf '%d%%' "$p"; }
iso_epoch() { local iso="$1" ts; [ -z "$iso" ] && return 1
  ts="${iso/Z/+00:00}"
  ts=$(printf '%s' "$ts" | sed -E 's/\.[0-9]+//; s/([+-][0-9][0-9]):([0-9][0-9])$/\1\2/')
  date -j -f "%Y-%m-%dT%H:%M:%S%z" "$ts" +%s 2>/dev/null; }
remain() { local iso="$1" e n d; [ -z "$iso" ] && { echo ""; return; }
  e=$(iso_epoch "$iso")
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
# 失敗しても次に試してよい時刻を記録する。成功時しかキャッシュを書かないと
# 429 のあいだ毎分叩き続けてしまい、制限が永久に解けなくなるため。
ATT="$CFG/claude.attempt"; RETRY_AT=0; LAST_ERR=""
[ -f "$ATT" ] && IFS=$'\t' read -r RETRY_AT LAST_ERR < "$ATT" 2>/dev/null
case "$RETRY_AT" in ''|*[!0-9]*) RETRY_AT=0 ;; esac
if [ "$CL_ACTIVE" = 1 ] && [ $(( NOW - aT )) -lt $(( IV * 60 )) ] && [ -n "$cU5$cU7" ]; then
  U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
  P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
elif [ "$CL_ACTIVE" = 1 ] && [ "$NOW" -lt "$RETRY_AT" ]; then
  if [ -n "$cU5$cU7" ]; then
    U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
    P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
  else
    CL_ERR="${LAST_ERR:-Retrying soon} ($(( (RETRY_AT - NOW + 59) / 60 ))m)"
  fi
elif [ "$CL_ACTIVE" = 1 ]; then
  CREDS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  [ -z "$CREDS" ] && CREDS=$(cat "$HOME/.claude/.credentials.json" 2>/dev/null)
  TOKEN=$(jpick "$CREDS" accessToken claudeAiOauth)
  [ -z "$TOKEN" ] && TOKEN=$(jpick "$CREDS" accessToken)
  if [ -z "$TOKEN" ]; then
    CL_ERR="$T_NOCRED"
  else
    RESP=$(curl -s -m 8 -w $'\n%{http_code}' "$ENDPOINT" \
            -H "Authorization: Bearer $TOKEN" -H "anthropic-beta: $BETA")
    CODE="${RESP##*$'\n'}"; BODY="${RESP%$'\n'*}"
    if [ "$CODE" = "401" ]; then
      CL_ERR="$T_REAUTH"
    elif [ "$CODE" = "429" ]; then
      CL_ERR="$T_RATELIMIT"
    elif [ "$CODE" != "200" ]; then
      CL_ERR="HTTP $CODE"
    else
      U5=$(jpick "$BODY" utilization five_hour)
      U7=$(jpick "$BODY" utilization seven_day)
      R5=$(jpick "$BODY" resets_at five_hour)
      R7=$(jpick "$BODY" resets_at seven_day)
      [ -z "$U5" ] && [ -z "$U7" ] && CL_ERR="$T_BADFMT"
      P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
      [ -z "$CL_ERR" ] && printf '%s\t%s\t%s\t%s\t%s\n' "$NOW" "$U5" "$U7" "$R5" "$R7" > "$CACHEF"
    fi
  fi
  if [ -n "$CL_ERR" ]; then
    BO=$(( IV * 60 ))
    case "$CL_ERR" in *"$T_RATELIMIT"*) BO=900 ;; esac
    printf '%s\t%s\n' "$(( NOW + BO ))" "$CL_ERR" > "$ATT"
  else
    rm -f "$ATT"
  fi
  # 取得に失敗してもキャッシュがあればそれを表示（エラーはキャッシュ無し時のみ）
  if [ -n "$CL_ERR" ] && [ -n "$cU5$cU7" ]; then
    CL_ERR=""; U5="$cU5"; U7="$cU7"; R5="$cR5"; R7="$cR7"
    P5=$(to_pct "$U5"); P7=$(to_pct "$U7")
  fi
fi

# リセット時刻を過ぎている枠は 0% used (100% left) にロールオーバーする
if [ "$P5" -ge 0 ] && [ -n "$R5" ]; then
  e5=$(iso_epoch "$R5" || true)
  if [ -n "$e5" ] && [ "$e5" -le "$NOW" ]; then P5=0; R5=""; fi
fi
if [ "$P7" -ge 0 ] && [ -n "$R7" ]; then
  e7=$(iso_epoch "$R7" || true)
  if [ -n "$e7" ] && [ "$e7" -le "$NOW" ]; then P7=0; R7=""; fi
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

# Codex 側の枠の名前は固定ではない（例: プラン変更で 7d → 30d）。
# ラベル文字列ではなく「1個目/2個目の枠」という順序で紐づけることで、
# ラベルが何であっても cx5/cx7 のトグルが効くようにする。
cx_window_enabled() {
  case "$1" in
    1) if [ "$CX_L1" = "7d" ] && [ -z "$CX_L2" ]; then [ "$CX7" = 1 ]; else [ "$CX5" = 1 ]; fi ;;
    2) [ "$CX7" = 1 ] ;;
    *) return 0 ;;
  esac
}
cx_window_percentage() {
  case "$1" in
    1) if [ "$CX_L1" = "7d" ] && [ -z "$CX_L2" ]; then printf '%s' "$CX7P"; else printf '%s' "$CX5P"; fi ;;
    2) printf '%s' "$CX7P" ;;
    *) printf '1' ;;
  esac
}

# ── Gemini（ヘルパーの出力を解析）──
GM_L1=""; GM_U1=-1; GM_T1=""; GM_L2=""; GM_U2=-1; GM_T2=""; GM_PLAN=""; GM_ERR=""
if [ "$GM_ACTIVE" = 1 ]; then
  if [ -x "$GEMINI_HELPER" ]; then
    GM_OUT=$("$GEMINI_HELPER" 2>/dev/null || true)
    n=0; expect=""
    while IFS= read -r line; do
      p="${line%%|*}"
      lbl=$(printf '%s' "$p" | sed -nE 's/^[[:space:]]*([0-9a-zA-Z]+)[[:space:]].*[^0-9]([0-9]+)% used.*/\1/p')
      if [ -n "$lbl" ]; then
        usd=$(printf '%s' "$p" | sed -nE 's/.*[^0-9]([0-9]+)% used.*/\1/p')
        n=$((n+1))
        if [ $n = 1 ]; then GM_L1="$lbl"; GM_U1="$usd"; expect=1
        elif [ $n = 2 ]; then GM_L2="$lbl"; GM_U2="$usd"; expect=2; fi
        continue
      fi
      rst=$(printf '%s' "$p" | sed -nE 's/.*resets in ([^|]*).*/\1/p' | sed 's/[[:space:]]*$//')
      if [ -n "$rst" ] && [ -n "$expect" ]; then
        [ "$expect" = 1 ] && GM_T1="$rst"; [ "$expect" = 2 ] && GM_T2="$rst"
        expect=""; continue
      fi
      case "$p" in Plan:*) GM_PLAN=$(printf '%s' "$p" | sed 's/^[[:space:]]*Plan:[[:space:]]*//; s/[[:space:]]*$//') ;; esac
    done <<EOF_GM
$(printf '%s\n' "$GM_OUT" | sed -n '/^---$/,$p')
EOF_GM
    [ $n = 0 ] && GM_ERR="$T_GMWAIT"
  else
    GM_ERR="$T_GMMISS"
  fi
fi

GM_R1=$(( GM_U1<0 ? -1 : 100-GM_U1 )); GM_R2=$(( GM_U2<0 ? -1 : 100-GM_U2 ))

gm_window_enabled() {
  case "$1" in
    1) [ "$GM5" = 1 ] ;;
    2) [ "$GM7" = 1 ] ;;
    *) return 0 ;;
  esac
}
gm_window_percentage() {
  case "$1" in
    1) printf '%s' "$GM5P" ;;
    2) printf '%s' "$GM7P" ;;
    *) printf '1' ;;
  esac
}

# ── メニューバー ──
# 1項目=1色の制約があるため、Claude 表示中は Claude の色、
# Claude 非表示のときだけ Codex / Gemini の色を使う（各サービスの最悪値で段階が決まる）。
CL_WORST=-1; CX_WORST=-1; GM_WORST=-1
if [ "$CL_ACTIVE" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && (( P5 > CL_WORST )) && CL_WORST=$P5
  [ "$C7" = 1 ] && (( P7 > CL_WORST )) && CL_WORST=$P7
fi
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ]; then
  cx_window_enabled 1 && (( CX_U1 > CX_WORST )) && CX_WORST=$CX_U1
  cx_window_enabled 2 && (( CX_U2 > CX_WORST )) && CX_WORST=$CX_U2
fi
if [ "$GM_ACTIVE" = 1 ] && [ -z "$GM_ERR" ]; then
  gm_window_enabled 1 && (( GM_U1 > GM_WORST )) && GM_WORST=$GM_U1
  gm_window_enabled 2 && (( GM_U2 > GM_WORST )) && GM_WORST=$GM_U2
fi
if [ "$CL_ACTIVE" = 1 ]; then
  (( CL_WORST<0 )) && CL_WORST=0
  MB_COLOR=$(clcol $CL_WORST)
elif [ "$CX_ACTIVE" = 1 ]; then
  (( CX_WORST<0 )) && CX_WORST=0
  MB_COLOR=$(cxcol $CX_WORST)
else
  (( GM_WORST<0 )) && GM_WORST=0
  MB_COLOR=$(gmcol $GM_WORST)
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
  if cx_window_enabled 1; then
    CXMB="$CX_L1 $(bar $CX_R1 $MBAR_W)$([ "$(cx_window_percentage 1)" = 1 ] && printf ' %s' "$(fmt $CX_R1)")"
  fi
  if [ -n "$CX_L2" ] && cx_window_enabled 2; then
    CXMB="${CXMB:+$CXMB  }$CX_L2 $(bar $CX_R2 $MBAR_W)$([ "$(cx_window_percentage 2)" = 1 ] && printf ' %s' "$(fmt $CX_R2)")"
  fi
  [ -n "$CXMB" ] && MB="${MB:+$MB │ }$CXMB"
fi
[ "$CX_ACTIVE" = 1 ] && [ -n "$CX_ERR" ] && MB="${MB:+$MB │ }Codex ⚠"

if [ "$GM_ACTIVE" = 1 ] && [ -z "$GM_ERR" ] && [ -n "$GM_L1" ]; then
  GMMB=""
  if gm_window_enabled 1; then
    GMMB="$GM_L1 $(bar $GM_R1 $MBAR_W)$([ "$(gm_window_percentage 1)" = 1 ] && printf ' %s' "$(fmt $GM_R1)")"
  fi
  if [ -n "$GM_L2" ] && gm_window_enabled 2; then
    GMMB="${GMMB:+$GMMB  }$GM_L2 $(bar $GM_R2 $MBAR_W)$([ "$(gm_window_percentage 2)" = 1 ] && printf ' %s' "$(fmt $GM_R2)")"
  fi
  [ -n "$GMMB" ] && MB="${MB:+$MB │ }$GMMB"
fi
[ "$GM_ACTIVE" = 1 ] && [ -n "$GM_ERR" ] && MB="${MB:+$MB │ }Gemini ⚠"
[ -z "$MB" ] && MB="AI …"

# メニューバー: PDF なら Claude/Codex/Gemini を別色で描ける（テキストは1項目1色まで）
# ── --json：他のフロントエンド（フローティング版アプリ等）向けの機械可読出力 ──
# 認証・バックオフ・設定・Codex解析はこのスクリプトが唯一の実装。
# 描画側はここから先を読むだけで、判断を二重に持たない。
#
# jq は使わない。アプリ単体で入れた人の環境に Homebrew がある保証はなく、
# 「Mac アプリです」と言って配る以上、別のパッケージマネージャを前提にできない。
if [ "${1:-}" = "--json" ]; then
  jesc() { local v=${1//\\/\\\\}; v=${v//\"/\\\"}; v=${v//$'\n'/ }; v=${v//$'\t'/ }; printf '%s' "$v"; }
  jbool() { if [ "$1" = 1 ]; then printf 'true'; else printf 'false'; fi; }
  jnum() { case "$1" in ''|*[!0-9-]*) printf '%s' "${2:-0}" ;; *) printf '%s' "$1" ;; esac; }
  jwin() { # jwin <label> <left> <color> <resets> <show> <pct>
    printf '{"label":"%s","left":%s,"color":"%s","resets":"%s","show":%s,"pct":%s}' \
      "$(jesc "$1")" "$(jnum "$2" -1)" "$(jesc "$3")" "$(jesc "$4")" "$(jbool "$5")" "$(jbool "$6")"
  }

  S5=0; [ "$C5" = 1 ] && [ "$REM5" -ge 0 ] && S5=1
  S7=0; [ "$C7" = 1 ] && [ "$REM7" -ge 0 ] && S7=1
  X1=0; cx_window_enabled 1 && [ "$CX_R1" -ge 0 ] && X1=1
  X2=0; cx_window_enabled 2 && [ "$CX_R2" -ge 0 ] && X2=1
  G1=0; [ "$GM5" = 1 ] && [ "$GM_R1" -ge 0 ] && G1=1
  G2=0; [ "$GM7" = 1 ] && [ "$GM_R2" -ge 0 ] && G2=1

  CL_WINS="$(jwin "5h" "$REM5" "$(clcol "$P5")" "$(remain "$R5")" "$S5" "$C5P"),"
  CL_WINS="$CL_WINS$(jwin "7d" "$REM7" "$(clcol "$P7")" "$(remain "$R7")" "$S7" "$C7P")"

  # Codex の枠は 1 個のこともある（契約状態で変わる）。空の枠は出さない。
  CX_WINS=""
  [ -n "$CX_L1" ] && CX_WINS="$(jwin "$CX_L1" "$CX_R1" "$(cxcol "$CX_U1")" "$CX_T1" "$X1" "$(cx_window_percentage 1)")"
  [ -n "$CX_L2" ] && CX_WINS="${CX_WINS:+$CX_WINS,}$(jwin "$CX_L2" "$CX_R2" "$(cxcol "$CX_U2")" "$CX_T2" "$X2" "$(cx_window_percentage 2)")"

  # Gemini の枠
  GM_WINS=""
  [ -n "$GM_L1" ] && GM_WINS="$(jwin "$GM_L1" "$GM_R1" "$(gmcol "$GM_U1")" "$GM_T1" "$G1" "$GM5P")"
  [ -n "$GM_L2" ] && GM_WINS="${GM_WINS:+$GM_WINS,}$(jwin "$GM_L2" "$GM_R2" "$(gmcol "$GM_U2")" "$GM_T2" "$G2" "$GM7P")"

  printf '{"version":"%s","update":{"available":%s,"latest":"%s"},"updated":"%s",' \
    "$(jesc "$VERSION")" "$(jbool "$UPDATE_AVAILABLE")" "$(jesc "$LATEST_VERSION")" "$(date '+%H:%M:%S')"
  printf '"settings":{"claude_on":%s,"c5":%s,"c5p":%s,"c7":%s,"c7p":%s,' \
    "$(jnum "$CL_ON")" "$(jnum "$C5")" "$(jnum "$C5P")" "$(jnum "$C7")" "$(jnum "$C7P")"
  printf '"codex_on":%s,"cx5":%s,"cx5p":%s,"cx7":%s,"cx7p":%s,' \
    "$(jnum "$CX_ON")" "$(jnum "$CX5")" "$(jnum "$CX5P")" "$(jnum "$CX7")" "$(jnum "$CX7P")"
  printf '"gemini_on":%s,"gm5":%s,"gm5p":%s,"gm7":%s,"gm7p":%s,"iv":%s,"cmp":%s},' \
    "$(jnum "$GM_ON")" "$(jnum "$GM5")" "$(jnum "$GM5P")" "$(jnum "$GM7")" "$(jnum "$GM7P")" \
    "$(jnum "$IV" 3)" "$(jnum "$CMP")"
  printf '"services":[{"name":"Claude","on":%s,"error":"%s","color":"%s","credits":"","windows":[%s]},' \
    "$(jbool "$CL_ACTIVE")" "$(jesc "$CL_ERR")" "$(jesc "$CL_OK")" "$CL_WINS"
  printf '{"name":"Codex","on":%s,"error":"%s","color":"%s","credits":"%s","windows":[%s]},' \
    "$(jbool "$CX_ACTIVE")" "$(jesc "$CX_ERR")" "$(jesc "$CX_OK")" "$(jesc "$CX_CREDITS")" "$CX_WINS"
  printf '{"name":"Gemini","on":%s,"error":"%s","color":"%s","credits":"","windows":[%s]}]}\n' \
    "$(jbool "$GM_ACTIVE")" "$(jesc "$GM_ERR")" "$(jesc "$GM_OK")" "$GM_WINS"
  exit 0
fi

PDF_SPEC=""
if [ "$CL_ACTIVE" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && [ "$REM5" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}5h,$REM5,$(clcol $P5),$C5P"
  [ "$C7" = 1 ] && [ "$REM7" -ge 0 ] && PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}7d,$REM7,$(clcol $P7),$C7P"
fi
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ]; then
  CX_PDF=""
  if [ "$CX_R1" -ge 0 ] && cx_window_enabled 1; then
    CX_PDF="$CX_L1,$CX_R1,$(cxcol $CX_U1),$(cx_window_percentage 1)"
  fi
  if [ -n "$CX_L2" ] && [ "$CX_R2" -ge 0 ] && cx_window_enabled 2; then
    CX_PDF="${CX_PDF:+$CX_PDF;}$CX_L2,$CX_R2,$(cxcol $CX_U2),$(cx_window_percentage 2)"
  fi
  if [ -n "$CX_PDF" ]; then
    [ -n "$PDF_SPEC" ] && PDF_SPEC="$PDF_SPEC;|"
    PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}$CX_PDF"
  fi
fi
if [ "$GM_ACTIVE" = 1 ] && [ -z "$GM_ERR" ]; then
  GM_PDF=""
  if [ "$GM_R1" -ge 0 ] && gm_window_enabled 1; then
    GM_PDF="$GM_L1,$GM_R1,$(gmcol $GM_U1),$(gm_window_percentage 1)"
  fi
  if [ -n "$GM_L2" ] && [ "$GM_R2" -ge 0 ] && gm_window_enabled 2; then
    GM_PDF="${GM_PDF:+$GM_PDF;}$GM_L2,$GM_R2,$(gmcol $GM_U2),$(gm_window_percentage 2)"
  fi
  if [ -n "$GM_PDF" ]; then
    [ -n "$PDF_SPEC" ] && PDF_SPEC="$PDF_SPEC;|"
    PDF_SPEC="${PDF_SPEC:+$PDF_SPEC;}$GM_PDF"
  fi
fi
B64=""
# 更新の印は画像の中にベクタで描く。テキストに落とすと、更新するまで
# 二色バーが失われる。
if [ -n "$PDF_SPEC" ] && [ -z "$CL_ERR$CX_ERR$GM_ERR" ] && command -v python3 >/dev/null 2>&1; then
  B64=$(python3 - "$PDF_SPEC" "$UPDATE_AVAILABLE" "$CMP" <<'PYEOF' 2>/dev/null
import sys, base64
spec=[x for x in sys.argv[1].split(";") if x]
def rgb(h):
    h=h.lstrip("#"); return tuple(int(h[i:i+2],16)/255 for i in (0,2,4))
X=2.0; ops=[]; CW=6.2; BARW=30.0; BY=4.0; BH=10.0
# ノッチ脇は幅が足りない。コンパクトでは枠名を落とし、バーと余白を詰める。
# 枠の並び順は変わらないので、どちらがどの枠かは見失わない。
CMP = len(sys.argv) > 3 and sys.argv[3] == "1"
if CMP: CW=5.0; BARW=20.0
GAP1 = 2.0 if CMP else 4.0
GAP2 = 3.0 if CMP else 5.0
TEXT_COL="0.92 0.94 0.96 rg"
if len(sys.argv) > 2 and sys.argv[2] == "1":
    ops.append("1 0.624 0.039 rg")
    ops.append("%.1f 8.0 m %.1f 13.4 l %.1f 8.0 l f"%(X+0.2,X+4.0,X+7.8))
    ops.append("%.1f 3.6 2.8 4.6 re f"%(X+2.6))
    X += 11.0 if not CMP else 9.5
for item in spec:
    if item=="|":
        ops.append("0.55 0.55 0.55 RG 0.8 w %.1f 3 m %.1f 15 l S"%(X+3,X+3)); X+=(7.0 if CMP else 10.0); continue
    label,rem,hexc,showp=item.split(",")
    rem=max(0,min(100,int(rem))); r,g,b=rgb(hexc)
    col="%.4f %.4f %.4f"%(r,g,b)
    if not CMP:
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
    X+=BARW+GAP1
    if showp=="1":
        t=("%d"%rem) if CMP else ("%d%%"%rem)
        ops.append(TEXT_COL)
        ops.append("BT /F1 %d Tf %.1f %.1f Td (%s) Tj ET"%(9 if CMP else 11,X,5.5 if CMP else 5,t)); X+=len(t)*CW+2
    X+=GAP2
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
  UPDATE_BADGE=""
  [ "$UPDATE_AVAILABLE" = 1 ] && UPDATE_BADGE="⬆ "
  UPDATE_BADGE=""
  [ "$UPDATE_AVAILABLE" = 1 ] && UPDATE_BADGE="⬆ "
  echo "${UPDATE_BADGE}$MB | $FONT color=$MB_COLOR"
fi
echo "---"

# ── ドロップダウン ──
# API が片方の枠しか返さないことがある（未使用・プラン差など）。データが無い枠に
# 「-- left」の空行を出さないよう、残量が取れたものだけ描く。
CL_ROWS=0
if [ "$CL_ACTIVE" = 1 ] && [ -z "$CL_ERR" ]; then
  [ "$C5" = 1 ] && [ "$REM5" -ge 0 ] && CL_ROWS=1
  [ "$C7" = 1 ] && [ "$REM7" -ge 0 ] && CL_ROWS=1
fi
if [ "$CL_ACTIVE" = 1 ] && { [ -n "$CL_ERR" ] || [ "$CL_ROWS" = 1 ]; }; then
  echo "Claude | size=11 color=$CL_OK"
  if [ -n "$CL_ERR" ]; then
    echo "⚠ $CL_ERR | $FONT color=#FF9F0A"
  else
    if [ "$C5" = 1 ] && [ "$REM5" -ge 0 ]; then
      echo "5h  $(bar $REM5 $DROP_W)$([ "$C5P" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $REM5)")") | $FONT color=$(clcol $P5)"
      [ -n "$R5" ] && echo "       $(sub "$T_RESET" "$(remain "$R5")") | size=11 color=#888888"
    fi
    if [ "$C7" = 1 ] && [ "$REM7" -ge 0 ]; then
      echo "7d  $(bar $REM7 $DROP_W)$([ "$C7P" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $REM7)")") | $FONT color=$(clcol $P7)"
      [ -n "$R7" ] && echo "       $(sub "$T_RESET" "$(remain "$R7")") | size=11 color=#888888"
    fi
  fi
fi
# 表示する枠が1つも無いなら見出しごと出さない（見出しだけ浮くのを防ぐ）
CX_ROWS=0
if [ "$CX_ACTIVE" = 1 ] && [ -z "$CX_ERR" ]; then
  [ -n "$CX_L1" ] && cx_window_enabled 1 && CX_ROWS=1
  [ -n "$CX_L2" ] && cx_window_enabled 2 && CX_ROWS=1
fi
if [ "$CX_ACTIVE" = 1 ] && { [ -n "$CX_ERR" ] || [ "$CX_ROWS" = 1 ]; }; then
  echo "Codex | size=11 color=$CX_OK"
  if [ -n "$CX_ERR" ]; then
    echo "⚠ $CX_ERR | $FONT color=#FF9F0A"
  else
    if [ -n "$CX_L1" ] && cx_window_enabled 1; then
      echo "$CX_L1  $(bar $CX_R1 $DROP_W)$([ "$(cx_window_percentage 1)" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $CX_R1)")") | $FONT color=$(cxcol $CX_U1)"
      [ -n "$CX_T1" ] && echo "       $(sub "$T_RESET" "$CX_T1") | size=11 color=#888888"
    fi
    if [ -n "$CX_L2" ] && cx_window_enabled 2; then
      echo "$CX_L2  $(bar $CX_R2 $DROP_W)$([ "$(cx_window_percentage 2)" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $CX_R2)")") | $FONT color=$(cxcol $CX_U2)"
      [ -n "$CX_T2" ] && echo "       $(sub "$T_RESET" "$CX_T2") | size=11 color=#888888"
    fi
    [ -n "$CX_CREDITS" ] && echo "$CX_CREDITS | size=11 color=#888888"
  fi
fi
# 表示する枠が1つも無いなら見出しごと出さない（見出しだけ浮くのを防ぐ）
GM_ROWS=0
if [ "$GM_ACTIVE" = 1 ] && [ -z "$GM_ERR" ]; then
  [ -n "$GM_L1" ] && gm_window_enabled 1 && GM_ROWS=1
  [ -n "$GM_L2" ] && gm_window_enabled 2 && GM_ROWS=1
fi
if [ "$GM_ACTIVE" = 1 ] && { [ -n "$GM_ERR" ] || [ "$GM_ROWS" = 1 ]; }; then
  echo "Gemini | size=11 color=$GM_OK"
  if [ -n "$GM_ERR" ]; then
    echo "⚠ $GM_ERR | $FONT color=#FF9F0A"
  else
    if [ -n "$GM_L1" ] && gm_window_enabled 1; then
      echo "$GM_L1  $(bar $GM_R1 $DROP_W)$([ "$(gm_window_percentage 1)" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $GM_R1)")") | $FONT color=$(gmcol $GM_U1)"
      [ -n "$GM_T1" ] && echo "       $(sub "$T_RESET" "$GM_T1") | size=11 color=#888888"
    fi
    if [ -n "$GM_L2" ] && gm_window_enabled 2; then
      echo "$GM_L2  $(bar $GM_R2 $DROP_W)$([ "$(gm_window_percentage 2)" = 1 ] && printf '  %s' "$(sub "$T_LEFT" "$(fmt $GM_R2)")") | $FONT color=$(gmcol $GM_U2)"
      [ -n "$GM_T2" ] && echo "       $(sub "$T_RESET" "$GM_T2") | size=11 color=#888888"
    fi
  fi
fi
echo "---"
if [ "$UPDATE_AVAILABLE" = 1 ]; then
  echo "⬆ Update $LATEST_VERSION available | color=#FF9F0A size=13"
  echo "--Install now | color=#FF9F0A bash='$SELF_PATH' param1=--update terminal=false refresh=true"
  echo "--Release notes | href=https://github.com/taka-avantgarde/ai-usage-barometer/releases/latest"
  echo "---"
fi
settings_menu
echo "---"
echo "$(sub "$T_UPDATED" "$(date '+%H:%M:%S')") | size=11 color=#888888"
echo "$T_REFRESH | refresh=true"
