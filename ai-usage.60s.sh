#!/usr/bin/env bash
#
# AI Usage Barometer — unified Claude + Codex SwiftBar plugin
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.1.1</xbar.version>
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

VERSION="0.1.1"
REPO="${AI_USAGE_REPO:-taka-avantgarde/ai-usage-barometer}"
PLUGIN_DIR="${SWIFTBAR_PLUGINS_PATH:-${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}}"
SUPPORT_DIR="${AI_USAGE_SUPPORT_DIR:-$PLUGIN_DIR/.ai-usage-barometer}"
CLAUDE_HELPER="${AI_USAGE_CLAUDE_HELPER:-$SUPPORT_DIR/claude-usage.sh}"
CODEX_HELPER="${AI_USAGE_CODEX_HELPER:-$SUPPORT_DIR/codex-usage.sh}"
CACHE_DIR="${AI_USAGE_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer}"
CONFIG_FILE="$CACHE_DIR/config"
NOTICE_FILE="$CACHE_DIR/notice"
CLAUDE_COLOR="${CLAUDE_COLOR:-#D97706}"
CODEX_COLOR="${CODEX_COLOR:-#2563EB}"
MUTED_COLOR="${MUTED_COLOR:-#808080}"
SEPARATOR_COLOR="${SEPARATOR_COLOR:-#8E8E93}"
CLAUDE_ANSI="${CLAUDE_ANSI:-208}"
CODEX_ANSI="${CODEX_ANSI:-39}"
SEPARATOR_ANSI="${SEPARATOR_ANSI:-244}"
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

ansi_segment() {
  # SwiftBar supports ANSI styling in the macOS menu-bar header.
  # Use the widely supported 256-colour SGR form for reliable rendering
  # across SwiftBar 1.x and 2.x.
  local colour_index="$1" text="$2"
  printf '\033[38;5;%sm%s\033[0m' "$colour_index" "$text"
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
  MENU_TITLE="$(ansi_segment "$CLAUDE_ANSI" "$CLAUDE_HEADER")"
fi
if [[ "$CODEX_ENABLED" == "1" ]]; then
  if [[ -n "$MENU_TITLE" ]]; then
    MENU_TITLE+="  $(ansi_segment "$SEPARATOR_ANSI" "│")  "
  fi
  MENU_TITLE+="$(ansi_segment "$CODEX_ANSI" "$CODEX_HEADER")"
fi

printf '%b | ansi=true symbolize=false font=Menlo size=12\n' "$MENU_TITLE"
echo "---"

if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  echo "Claude | color=$CLAUDE_COLOR"
  CLAUDE_DETAILS="$(section_between_separators "$CLAUDE_OUTPUT" 1)"
  if [[ -n "$CLAUDE_DETAILS" ]]; then
    printf '%s\n' "$CLAUDE_DETAILS"
  else
    echo "Usage data is unavailable | color=$MUTED_COLOR"
  fi
  echo "---"
fi

if [[ "$CODEX_ENABLED" == "1" ]]; then
  echo "Codex | color=$CODEX_COLOR"
  CODEX_DETAILS="$(section_between_separators "$CODEX_OUTPUT" 2)"
  if [[ -z "$CODEX_DETAILS" ]]; then
    CODEX_DETAILS="$(section_between_separators "$CODEX_OUTPUT" 1)"
  fi
  if [[ -n "$CODEX_DETAILS" ]]; then
    while IFS= read -r line; do
      normalise_detail_line "$line"
      printf '\n'
    done <<< "$CODEX_DETAILS"
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
