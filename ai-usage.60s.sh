#!/usr/bin/env bash
#
# AI Usage Barometer — unified Claude + Codex SwiftBar plugin
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.1.6</xbar.version>
# <xbar.author>Takayuki Miyano / Atlas Associates Inc.</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>One menu-bar item for Claude and Codex usage, with per-service toggles.</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/ai-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -u

VERSION="0.1.6"
REPO="${AI_USAGE_REPO:-taka-avantgarde/ai-usage-barometer}"
PLUGIN_DIR="${SWIFTBAR_PLUGINS_PATH:-${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}}"
SUPPORT_DIR="${AI_USAGE_SUPPORT_DIR:-$PLUGIN_DIR/.ai-usage-barometer}"
CLAUDE_HELPER="${AI_USAGE_CLAUDE_HELPER:-$SUPPORT_DIR/claude-usage.sh}"
CODEX_HELPER="${AI_USAGE_CODEX_HELPER:-$SUPPORT_DIR/codex-usage.sh}"
CACHE_DIR="${AI_USAGE_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer}"
CONFIG_FILE="$CACHE_DIR/config"
NOTICE_FILE="$CACHE_DIR/notice"
MUTED_COLOR="${MUTED_COLOR:-#808080}"
SEPARATOR_COLOR="${SEPARATOR_COLOR:-#666666}"
WARN="${WARN:-70}"
DANGER="${DANGER:-90}"

# Each usage window is coloured independently. Stage 1 is the healthy state
# (high remaining capacity), stage 2 is warning, and stage 3 is critical.
CLAUDE_STAGE1_RGB="${CLAUDE_STAGE1_RGB:-181;79;2}"    # #b54f02
CLAUDE_STAGE2_RGB="${CLAUDE_STAGE2_RGB:-184;90;0}"    # #B85A00
CLAUDE_STAGE3_RGB="${CLAUDE_STAGE3_RGB:-255;112;69}"  # #ff7045
CODEX_STAGE1_RGB="${CODEX_STAGE1_RGB:-79;127;168}"    # current #4F7FA8
CODEX_STAGE2_RGB="${CODEX_STAGE2_RGB:-14;139;161}"    # #0e8ba1
CODEX_STAGE3_RGB="${CODEX_STAGE3_RGB:-237;93;64}"     # #ed5d40
SEPARATOR_RGB="${SEPARATOR_RGB:-102;102;102}"
SELF="${SWIFTBAR_PLUGIN_PATH:-$0}"

mkdir -p "$CACHE_DIR" 2>/dev/null || true
chmod 700 "$CACHE_DIR" 2>/dev/null || true

CLAUDE_ENABLED=1
CODEX_ENABLED=1
INTERVAL_MIN=3

read_config_value() {
  local key="$1" fallback="$2" value=""
  if [[ -r "$CONFIG_FILE" ]]; then
    value="$(awk -F= -v key="$key" '$1 == key { print $2; exit }' "$CONFIG_FILE" 2>/dev/null)"
  fi
  case "$key" in
    CLAUDE_ENABLED|CODEX_ENABLED)
      case "$value" in 0|1) printf '%s' "$value" ;; *) printf '%s' "$fallback" ;; esac
      ;;
    INTERVAL_MIN)
      case "$value" in 1|3|5) printf '%s' "$value" ;; *) printf '%s' "$fallback" ;; esac
      ;;
  esac
}

load_config() {
  CLAUDE_ENABLED="$(read_config_value CLAUDE_ENABLED 1)"
  CODEX_ENABLED="$(read_config_value CODEX_ENABLED 1)"
  INTERVAL_MIN="$(read_config_value INTERVAL_MIN 3)"
}

write_config() {
  local tmp
  tmp="$(mktemp "$CACHE_DIR/config.XXXXXX")" || return 1
  {
    printf 'CLAUDE_ENABLED=%s\n' "$CLAUDE_ENABLED"
    printf 'CODEX_ENABLED=%s\n' "$CODEX_ENABLED"
    printf 'INTERVAL_MIN=%s\n' "$INTERVAL_MIN"
  } > "$tmp"
  chmod 600 "$tmp" 2>/dev/null || true
  mv "$tmp" "$CONFIG_FILE"
}

write_notice() {
  printf '%s\n' "$1" > "$NOTICE_FILE" 2>/dev/null || true
  chmod 600 "$NOTICE_FILE" 2>/dev/null || true
}

load_config

case "${1:-}" in
  --toggle)
    service="${2:-}"
    case "$service" in
      claude)
        if [[ "$CLAUDE_ENABLED" == "1" && "$CODEX_ENABLED" == "0" ]]; then
          write_notice "At least one service must remain visible."
        elif [[ "$CLAUDE_ENABLED" == "1" ]]; then
          CLAUDE_ENABLED=0
        else
          CLAUDE_ENABLED=1
        fi
        ;;
      codex)
        if [[ "$CODEX_ENABLED" == "1" && "$CLAUDE_ENABLED" == "0" ]]; then
          write_notice "At least one service must remain visible."
        elif [[ "$CODEX_ENABLED" == "1" ]]; then
          CODEX_ENABLED=0
        else
          CODEX_ENABLED=1
        fi
        ;;
      *) exit 2 ;;
    esac
    write_config
    exit 0
    ;;
  --set-interval)
    case "${2:-}" in 1|3|5) INTERVAL_MIN="${2}" ;; *) exit 2 ;; esac
    write_config
    mkdir -p "$HOME/.cache" 2>/dev/null || true
    printf '%s\n' "$INTERVAL_MIN" > "$HOME/.cache/claude-usage-barometer.interval" 2>/dev/null || true
    mkdir -p "$HOME/.cache/codex-usage-barometer" 2>/dev/null || true
    printf '%s\n' "$((INTERVAL_MIN * 60))" > "$HOME/.cache/codex-usage-barometer/interval" 2>/dev/null || true
    rm -f "$HOME/.cache/codex-usage-barometer/usage.json" 2>/dev/null || true
    exit 0
    ;;
  --refresh)
    rm -f "$HOME/.cache/codex-usage-barometer/usage.json" 2>/dev/null || true
    rm -f "$HOME/.cache/claude-usage-barometer.tsv" 2>/dev/null || true
    exit 0
    ;;
esac

locale_code="$(defaults read -g AppleLocale 2>/dev/null | cut -d_ -f1 | cut -d- -f1)"
case "$locale_code" in
  ja) T_SETTINGS="設定"; T_SHOW_CLAUDE="Claudeを表示"; T_SHOW_CODEX="Codexを表示"; T_REFRESH="今すぐ更新"; T_INTERVAL="更新間隔"; T_AT_LEAST="少なくとも1つは表示する必要があります" ;;
  es) T_SETTINGS="Ajustes"; T_SHOW_CLAUDE="Mostrar Claude"; T_SHOW_CODEX="Mostrar Codex"; T_REFRESH="Actualizar ahora"; T_INTERVAL="Intervalo de actualización"; T_AT_LEAST="Debe quedar visible al menos un servicio" ;;
  ar) T_SETTINGS="الإعدادات"; T_SHOW_CLAUDE="إظهار Claude"; T_SHOW_CODEX="إظهار Codex"; T_REFRESH="تحديث الآن"; T_INTERVAL="فاصل التحديث"; T_AT_LEAST="يجب إبقاء خدمة واحدة ظاهرة على الأقل" ;;
  fr) T_SETTINGS="Réglages"; T_SHOW_CLAUDE="Afficher Claude"; T_SHOW_CODEX="Afficher Codex"; T_REFRESH="Actualiser"; T_INTERVAL="Intervalle d’actualisation"; T_AT_LEAST="Au moins un service doit rester visible" ;;
  de) T_SETTINGS="Einstellungen"; T_SHOW_CLAUDE="Claude anzeigen"; T_SHOW_CODEX="Codex anzeigen"; T_REFRESH="Jetzt aktualisieren"; T_INTERVAL="Aktualisierungsintervall"; T_AT_LEAST="Mindestens ein Dienst muss sichtbar bleiben" ;;
  zh) T_SETTINGS="设置"; T_SHOW_CLAUDE="显示 Claude"; T_SHOW_CODEX="显示 Codex"; T_REFRESH="立即刷新"; T_INTERVAL="刷新间隔"; T_AT_LEAST="至少需要保留一个服务" ;;
  ko) T_SETTINGS="설정"; T_SHOW_CLAUDE="Claude 표시"; T_SHOW_CODEX="Codex 표시"; T_REFRESH="지금 새로고침"; T_INTERVAL="새로고침 간격"; T_AT_LEAST="최소 하나의 서비스를 표시해야 합니다" ;;
  pt) T_SETTINGS="Definições"; T_SHOW_CLAUDE="Mostrar Claude"; T_SHOW_CODEX="Mostrar Codex"; T_REFRESH="Atualizar agora"; T_INTERVAL="Intervalo de atualização"; T_AT_LEAST="Pelo menos um serviço deve permanecer visível" ;;
  nl) T_SETTINGS="Instellingen"; T_SHOW_CLAUDE="Claude tonen"; T_SHOW_CODEX="Codex tonen"; T_REFRESH="Nu vernieuwen"; T_INTERVAL="Vernieuwingsinterval"; T_AT_LEAST="Minstens één dienst moet zichtbaar blijven" ;;
  it) T_SETTINGS="Impostazioni"; T_SHOW_CLAUDE="Mostra Claude"; T_SHOW_CODEX="Mostra Codex"; T_REFRESH="Aggiorna ora"; T_INTERVAL="Intervallo di aggiornamento"; T_AT_LEAST="Almeno un servizio deve restare visibile" ;;
  vi) T_SETTINGS="Cài đặt"; T_SHOW_CLAUDE="Hiện Claude"; T_SHOW_CODEX="Hiện Codex"; T_REFRESH="Làm mới ngay"; T_INTERVAL="Khoảng thời gian làm mới"; T_AT_LEAST="Phải giữ hiển thị ít nhất một dịch vụ" ;;
  id) T_SETTINGS="Pengaturan"; T_SHOW_CLAUDE="Tampilkan Claude"; T_SHOW_CODEX="Tampilkan Codex"; T_REFRESH="Segarkan sekarang"; T_INTERVAL="Interval penyegaran"; T_AT_LEAST="Setidaknya satu layanan harus tetap terlihat" ;;
  th) T_SETTINGS="การตั้งค่า"; T_SHOW_CLAUDE="แสดง Claude"; T_SHOW_CODEX="แสดง Codex"; T_REFRESH="รีเฟรชตอนนี้"; T_INTERVAL="ช่วงเวลารีเฟรช"; T_AT_LEAST="ต้องแสดงอย่างน้อยหนึ่งบริการ" ;;
  *) T_SETTINGS="Settings"; T_SHOW_CLAUDE="Show Claude"; T_SHOW_CODEX="Show Codex"; T_REFRESH="Refresh now"; T_INTERVAL="Update interval"; T_AT_LEAST="At least one service must remain visible" ;;
esac

strip_params() {
  printf '%s' "$1" | sed -E 's/[[:space:]]*\|.*$//; s/[[:space:]]+$//'
}

run_helper() {
  local helper="$1"
  if [[ ! -x "$helper" ]]; then
    printf 'Not installed\n---\nHelper is missing: %s\n' "$helper"
    return 0
  fi
  "$helper" 2>/dev/null || true
}

header_from_output() {
  local service="$1" output="$2" title
  title="$(printf '%s\n' "$output" | head -n 1)"
  title="$(strip_params "$title")"
  case "$service" in
    claude) title="${title#Claude }" ;;
    codex) title="${title#Codex }" ;;
  esac
  [[ -n "$title" ]] || title="⚠"
  printf '%s' "$title"
}

section_between_separators() {
  local output="$1" target="$2"
  printf '%s\n' "$output" | awk -v target="$target" '
    $0 == "---" { section++; next }
    section == target { print }
  '
}

normalise_detail_line() {
  local line="$1"
  case "$line" in
    --[0-9]*%\ used*|--Resets\ in*) line="    ${line#--}" ;;
  esac
  printf '%s' "$line"
}

window_used_from_output() {
  # Resolve one window independently. Prefer the exact numeric value from that
  # window's detail row. If a helper omits the percentage, derive it from that
  # window's own gauge in the header instead of borrowing another window's state.
  local output="$1" label="$2" used=""

  used="$(printf '%s\n' "$output" | awk -v label="$label" '
    {
      line=$0
      sub(/[[:space:]]*\|.*/, "", line)
      sub(/^[[:space:]-]+/, "", line)
      if (line !~ ("^" label "([[:space:]]|$)")) next

      if (match(line, /[0-9]+%[[:space:]]+used/)) {
        token=substr(line, RSTART, RLENGTH)
        pct=token+0
        if (pct < 0) pct=0
        if (pct > 100) pct=100
        print int(pct+0.5)
        exit
      }
      if (match(line, /[0-9]+%[[:space:]]+left/)) {
        token=substr(line, RSTART, RLENGTH)
        pct=100-(token+0)
        if (pct < 0) pct=0
        if (pct > 100) pct=100
        print int(pct+0.5)
        exit
      }
    }
  ')"

  if [[ "$used" =~ ^[0-9]+$ ]]; then
    printf '%s' "$used"
    return 0
  fi

  # Gauge fallback. Helpers render the filled part as remaining capacity.
  printf '%s\n' "$output" | awk -v label="$label" '
    NR == 1 {
      line=$0
      sub(/[[:space:]]*\|.*/, "", line)
      n=split(line, parts, /[[:space:]][[:space:]]+/)
      for (i=1; i<=n; i++) {
        part=parts[i]
        sub(/^[[:space:]]+/, "", part)
        sub(/[[:space:]]+$/, "", part)
        if (part !~ ("^" label "([[:space:]]|$)")) continue
        gauge=part
        sub("^" label "[[:space:]]+", "", gauge)
        full=gsub(/█/, "", gauge)
        empty=gsub(/░/, "", gauge)
        total=full+empty
        if (total > 0) {
          remaining=(100*full)/total
          used=100-remaining
          if (used < 0) used=0
          if (used > 100) used=100
          print int(used+0.5)
          exit
        }
      }
    }
    END { if (NR == 0) print 0 }
  '
}
rgb_for_stage() {
  local service="$1" used="$2"
  case "$service" in
    claude)
      if (( used >= DANGER )); then printf '%s' "$CLAUDE_STAGE3_RGB"
      elif (( used >= WARN )); then printf '%s' "$CLAUDE_STAGE2_RGB"
      else printf '%s' "$CLAUDE_STAGE1_RGB"; fi
      ;;
    codex)
      if (( used >= DANGER )); then printf '%s' "$CODEX_STAGE3_RGB"
      elif (( used >= WARN )); then printf '%s' "$CODEX_STAGE2_RGB"
      else printf '%s' "$CODEX_STAGE1_RGB"; fi
      ;;
  esac
}

rgb_to_hex() {
  local rgb="$1" r g b
  IFS=';' read -r r g b <<< "$rgb"
  printf '#%02X%02X%02X' "$r" "$g" "$b"
}

ansi_segment() {
  # Exact 24-bit RGB ANSI colour for SwiftBar's menu-bar header.
  local rgb="$1" text="$2" r g b
  IFS=';' read -r r g b <<< "$rgb"
  printf '\033[38;2;%s;%s;%sm%s\033[0m' "$r" "$g" "$b" "$text"
}

colourise_header_windows() {
  # The helper header contains windows separated by two or more spaces, e.g.
  # "5h ███░░  7d █░░░░". Colour each window from its own percentage.
  local service="$1" header="$2" output="$3"
  local rest="$header" segment label used rgb result="" first=1

  while [[ -n "$rest" ]]; do
    if [[ "$rest" == *"  "* ]]; then
      segment="${rest%%  *}"
      rest="${rest#*  }"
      while [[ "$rest" == ' '* ]]; do rest="${rest# }"; done
    else
      segment="$rest"
      rest=""
    fi

    while [[ "$segment" == ' '* ]]; do segment="${segment# }"; done
    while [[ "$segment" == *' ' ]]; do segment="${segment% }"; done
    [[ -n "$segment" ]] || continue

    label="${segment%% *}"
    case "$label" in
      [0-9]*h|[0-9]*d|[0-9]*w|[0-9]*m)
        used="$(window_used_from_output "$output" "$label")"
        rgb="$(rgb_for_stage "$service" "$used")"
        ;;
      *)
        rgb="$(rgb_for_stage "$service" 100)"
        ;;
    esac

    if [[ "$first" == "0" ]]; then result+="  "; fi
    result+="$(ansi_segment "$rgb" "$segment")"
    first=0
  done

  printf '%s' "$result"
}

replace_line_color() {
  local line="$1" colour="$2" text params
  if [[ "$line" == *"|"* ]]; then
    text="${line%%|*}"
    params="${line#*|}"
    params="$(printf '%s' "$params" | sed -E 's/(^|[[:space:]])color=[^[:space:]]+//g; s/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]+/ /g')"
    if [[ -n "$params" ]]; then
      printf '%s| %s color=%s' "$text" "$params" "$colour"
    else
      printf '%s| color=%s' "$text" "$colour"
    fi
  else
    printf '%s | color=%s' "$line" "$colour"
  fi
}

render_coloured_details() {
  local service="$1" output="$2" details="$3"
  local line normal plain trimmed label used rgb colour

  while IFS= read -r line; do
    normal="$(normalise_detail_line "$line")"
    plain="$(strip_params "$normal")"
    trimmed="$plain"
    while [[ "$trimmed" == ' '* ]]; do trimmed="${trimmed# }"; done
    label="${trimmed%% *}"

    case "$label" in
      [0-9]*h|[0-9]*d|[0-9]*w|[0-9]*m)
        used="$(window_used_from_output "$output" "$label")"
        rgb="$(rgb_for_stage "$service" "$used")"
        colour="$(rgb_to_hex "$rgb")"
        replace_line_color "$normal" "$colour"
        ;;
      *)
        printf '%s' "$normal"
        ;;
    esac
    printf '\n'
  done <<< "$details"
}

CLAUDE_OUTPUT=""
CODEX_OUTPUT=""
CLAUDE_HEADER=""
CODEX_HEADER=""

if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  CLAUDE_OUTPUT="$(run_helper "$CLAUDE_HELPER")"
  CLAUDE_HEADER="$(header_from_output claude "$CLAUDE_OUTPUT")"
fi
if [[ "$CODEX_ENABLED" == "1" ]]; then
  CODEX_OUTPUT="$(run_helper "$CODEX_HELPER")"
  CODEX_HEADER="$(header_from_output codex "$CODEX_OUTPUT")"
fi

MENU_TITLE=""
if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  MENU_TITLE="$(colourise_header_windows claude "$CLAUDE_HEADER" "$CLAUDE_OUTPUT")"
fi
if [[ "$CODEX_ENABLED" == "1" ]]; then
  if [[ -n "$MENU_TITLE" ]]; then
    MENU_TITLE+="  $(ansi_segment "$SEPARATOR_RGB" "│")  "
  fi
  MENU_TITLE+="$(colourise_header_windows codex "$CODEX_HEADER" "$CODEX_OUTPUT")"
fi

printf '%b | ansi=true symbolize=false font=Menlo size=12\n' "$MENU_TITLE"
echo "---"

if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  echo "Claude | color=$(rgb_to_hex "$CLAUDE_STAGE1_RGB")"
  CLAUDE_DETAILS="$(section_between_separators "$CLAUDE_OUTPUT" 1)"
  if [[ -n "$CLAUDE_DETAILS" ]]; then
    render_coloured_details claude "$CLAUDE_OUTPUT" "$CLAUDE_DETAILS"
  else
    echo "Usage data is unavailable | color=$MUTED_COLOR"
  fi
  echo "---"
fi

if [[ "$CODEX_ENABLED" == "1" ]]; then
  echo "Codex | color=$(rgb_to_hex "$CODEX_STAGE1_RGB")"
  CODEX_DETAILS="$(section_between_separators "$CODEX_OUTPUT" 2)"
  if [[ -z "$CODEX_DETAILS" ]]; then
    CODEX_DETAILS="$(section_between_separators "$CODEX_OUTPUT" 1)"
  fi
  if [[ -n "$CODEX_DETAILS" ]]; then
    render_coloured_details codex "$CODEX_OUTPUT" "$CODEX_DETAILS"
  else
    echo "Usage data is unavailable | color=$MUTED_COLOR"
  fi
  echo "---"
fi

echo "$T_SETTINGS"
if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  echo "--$T_SHOW_CLAUDE | checked=true bash='$SELF' param1=--toggle param2=claude terminal=false refresh=true"
else
  echo "--$T_SHOW_CLAUDE | bash='$SELF' param1=--toggle param2=claude terminal=false refresh=true"
fi
if [[ "$CODEX_ENABLED" == "1" ]]; then
  echo "--$T_SHOW_CODEX | checked=true bash='$SELF' param1=--toggle param2=codex terminal=false refresh=true"
else
  echo "--$T_SHOW_CODEX | bash='$SELF' param1=--toggle param2=codex terminal=false refresh=true"
fi

echo "--$T_INTERVAL: ${INTERVAL_MIN} min"
for m in 1 3 5; do
  if [[ "$INTERVAL_MIN" == "$m" ]]; then
    echo "----${m} min | checked=true bash='$SELF' param1=--set-interval param2=$m terminal=false refresh=true"
  else
    echo "----${m} min | bash='$SELF' param1=--set-interval param2=$m terminal=false refresh=true"
  fi
done

echo "$T_REFRESH | bash='$SELF' param1=--refresh terminal=false refresh=true"
if [[ -s "$NOTICE_FILE" ]]; then
  NOTICE="$(cat "$NOTICE_FILE" 2>/dev/null || true)"
  rm -f "$NOTICE_FILE" 2>/dev/null || true
  [[ -n "$NOTICE" ]] && echo "$T_AT_LEAST | color=$MUTED_COLOR"
fi
echo "Version v$VERSION | href=https://github.com/$REPO/releases color=$MUTED_COLOR"
