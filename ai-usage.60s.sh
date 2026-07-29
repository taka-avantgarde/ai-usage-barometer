#!/usr/bin/env bash
#
# AI Usage Barometer — unified Claude + Codex SwiftBar plugin
#
# <xbar.title>AI Usage Barometer</xbar.title>
# <xbar.version>v0.1.9</xbar.version>
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

VERSION="0.1.9"
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

pdf_rgb_from_hex() {
  local hex="${1#\#}" r g b
  [[ "$hex" =~ ^[0-9A-Fa-f]{6}$ ]] || hex="808080"
  r=$((16#${hex:0:2}))
  g=$((16#${hex:2:2}))
  b=$((16#${hex:4:2}))
  awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN { printf "%.4f %.4f %.4f", r/255, g/255, b/255 }'
}

pdf_write_object() {
  local pdf="$1" offsets="$2" object_number="$3" body_file="$4" offset
  offset="$(wc -c < "$pdf" | tr -d '[:space:]')"
  printf '%s\n' "$offset" >> "$offsets"
  printf '%s 0 obj\n' "$object_number" >> "$pdf"
  cat "$body_file" >> "$pdf"
  printf '\nendobj\n' >> "$pdf"
}

render_header_pdf() {
  # Render a tiny vector PDF using only tools included with macOS. This avoids
  # Swift/Xcode Command Line Tools while preserving exact per-window HEX colours.
  local spec="$1" pdf="$2"
  local content="$CACHE_DIR/pdf-content.$$" offsets="$CACHE_DIR/pdf-offsets.$$"
  local body="$CACHE_DIR/pdf-body.$$"
  local colour segment label gauge rgb x=2 width=4
  local full empty total i cell_x row col dot_x dot_y
  local bar_y=4 bar_h=10 cell_w=8 cell_gap=1 text_y=5
  local content_length xref_offset offset

  : > "$content"
  while IFS=$'\t' read -r colour segment || [[ -n "${colour:-}${segment:-}" ]]; do
    [[ -n "${segment:-}" ]] || continue
    if [[ "$segment" =~ ^[[:space:]]+$ ]]; then
      x=$((x + 8))
      continue
    fi
    rgb="$(pdf_rgb_from_hex "$colour")"

    if [[ "$segment" == *"│"* ]]; then
      # Neutral separator between Claude and Codex.
      printf '%s RG\n1 w\n%s 2 m\n%s 16 l\nS\n' "$rgb" "$x" "$x" >> "$content"
      x=$((x + 13))
      continue
    fi

    label="${segment%% *}"
    gauge="${segment#* }"
    while [[ "$gauge" == ' '* ]]; do gauge="${gauge# }"; done

    case "$label" in
      [0-9]*h|[0-9]*d|[0-9]*w|[0-9]*m)
        # Labels are ASCII and use a built-in PDF font; no local font is needed.
        printf '%s rg\nBT\n/F1 11 Tf\n%s %s Td\n(%s) Tj\nET\n' \
          "$rgb" "$x" "$text_y" "$label" >> "$content"
        x=$((x + 23))

        full="$(printf '%s' "$gauge" | awk '{s=$0; print gsub(/█/,"",s)}')"
        empty="$(printf '%s' "$gauge" | awk '{s=$0; print gsub(/░/,"",s)}')"
        full="${full:-0}"
        empty="${empty:-0}"
        total=$((full + empty))
        if (( total <= 0 )); then total=5; empty=5; fi

        printf '%s rg\n' "$rgb" >> "$content"
        i=0
        while (( i < total )); do
          cell_x=$((x + i * (cell_w + cell_gap)))
          if (( i < full )); then
            printf '%s %s %s %s re f\n' "$cell_x" "$bar_y" "$cell_w" "$bar_h" >> "$content"
          else
            # Checkerboard dots make the unused part readable without changing hue.
            row=0
            while (( row < 3 )); do
              col=0
              while (( col < 2 )); do
                dot_x=$((cell_x + 1 + col * 4 + (row % 2) * 2))
                dot_y=$((bar_y + 1 + row * 3))
                printf '%s %s 2 2 re f\n' "$dot_x" "$dot_y" >> "$content"
                col=$((col + 1))
              done
              row=$((row + 1))
            done
          fi
          i=$((i + 1))
        done
        x=$((x + total * (cell_w + cell_gap) - cell_gap + 13))
        ;;
      *)
        # Unexpected helper output: render a compact ASCII warning marker.
        printf '%s rg\nBT\n/F1 11 Tf\n%s %s Td\n(!) Tj\nET\n' \
          "$rgb" "$x" "$text_y" >> "$content"
        x=$((x + 16))
        ;;
    esac
  done < "$spec"

  width=$((x > 4 ? x - 10 : 24))
  content_length="$(wc -c < "$content" | tr -d '[:space:]')"

  : > "$pdf"
  : > "$offsets"
  printf '%%PDF-1.4\n%%AIUsageBarometer\n' >> "$pdf"

  printf '<< /Type /Catalog /Pages 2 0 R >>' > "$body"
  pdf_write_object "$pdf" "$offsets" 1 "$body"

  printf '<< /Type /Pages /Kids [3 0 R] /Count 1 >>' > "$body"
  pdf_write_object "$pdf" "$offsets" 2 "$body"

  printf '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 %s 18] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>' "$width" > "$body"
  pdf_write_object "$pdf" "$offsets" 3 "$body"

  printf '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>' > "$body"
  pdf_write_object "$pdf" "$offsets" 4 "$body"

  {
    printf '<< /Length %s >>\nstream\n' "$content_length"
    cat "$content"
    printf 'endstream'
  } > "$body"
  pdf_write_object "$pdf" "$offsets" 5 "$body"

  xref_offset="$(wc -c < "$pdf" | tr -d '[:space:]')"
  {
    printf 'xref\n0 6\n'
    printf '0000000000 65535 f \n'
    while IFS= read -r offset; do
      printf '%010d 00000 n \n' "$offset"
    done < "$offsets"
    printf 'trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n%s\n%%%%EOF\n' "$xref_offset"
  } >> "$pdf"

  rm -f "$content" "$offsets" "$body" 2>/dev/null || true
  [[ -s "$pdf" ]] && [[ "$(head -c 4 "$pdf" 2>/dev/null)" == "%PDF" ]]
}

append_header_windows() {
  # Write exact per-window colours to a TSV vector-render specification.
  local service="$1" header="$2" output="$3" spec="$4"
  local rest="$header" segment label used rgb colour first=1

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
    colour="$(rgb_to_hex "$rgb")"

    if [[ "$first" == "0" ]]; then
      printf '%s\t  \n' "$MUTED_COLOR" >> "$spec"
    fi
    printf '%s\t%s\n' "$colour" "$segment" >> "$spec"
    first=0
  done
}

render_header_image() {
  local spec="$1" key image="" pdf="$CACHE_DIR/header-image.pdf.tmp.$$"
  if [[ -n "${AI_USAGE_HEADER_SPEC_DUMP:-}" ]]; then
    cp "$spec" "$AI_USAGE_HEADER_SPEC_DUMP" 2>/dev/null || true
  fi
  if [[ -n "${AI_USAGE_HEADER_IMAGE_B64:-}" ]]; then
    printf '%s' "$AI_USAGE_HEADER_IMAGE_B64"
    return 0
  fi

  key="$( { cat "$spec"; printf '%s\n' 'pdf-vector-renderer-v2'; } | shasum -a 256 2>/dev/null | awk '{print $1}')"
  if [[ -n "$key" && -s "$CACHE_DIR/header-image.b64" && -r "$CACHE_DIR/header-image.key" && "$(cat "$CACHE_DIR/header-image.key" 2>/dev/null)" == "$key" ]]; then
    cat "$CACHE_DIR/header-image.b64"
    return 0
  fi

  render_header_pdf "$spec" "$pdf" || {
    rm -f "$pdf" 2>/dev/null || true
    return 1
  }
  if [[ -n "${AI_USAGE_HEADER_PDF_DUMP:-}" ]]; then
    cp "$pdf" "$AI_USAGE_HEADER_PDF_DUMP" 2>/dev/null || true
  fi
  image="$(base64 < "$pdf" 2>/dev/null | tr -d '\r\n' || true)"
  rm -f "$pdf" 2>/dev/null || true
  case "$image" in
    ''|*[!A-Za-z0-9+/=]*) return 1 ;;
  esac
  [[ ${#image} -gt 100 ]] || return 1
  printf '%s' "$image" > "$CACHE_DIR/header-image.b64"
  printf '%s\n' "$key" > "$CACHE_DIR/header-image.key"
  chmod 600 "$CACHE_DIR/header-image.b64" "$CACHE_DIR/header-image.key" 2>/dev/null || true
  printf '%s' "$image"
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

HEADER_SPEC="$CACHE_DIR/header-segments.tsv.tmp.$$"
: > "$HEADER_SPEC"
PLAIN_TITLE=""
if [[ "$CLAUDE_ENABLED" == "1" ]]; then
  append_header_windows claude "$CLAUDE_HEADER" "$CLAUDE_OUTPUT" "$HEADER_SPEC"
  PLAIN_TITLE="$CLAUDE_HEADER"
fi
if [[ "$CODEX_ENABLED" == "1" ]]; then
  if [[ -s "$HEADER_SPEC" ]]; then
    printf '%s\t  │  \n' "$SEPARATOR_COLOR" >> "$HEADER_SPEC"
  fi
  append_header_windows codex "$CODEX_HEADER" "$CODEX_OUTPUT" "$HEADER_SPEC"
  if [[ -n "$PLAIN_TITLE" ]]; then PLAIN_TITLE+="  │  "; fi
  PLAIN_TITLE+="$CODEX_HEADER"
fi

HEADER_IMAGE="$(render_header_image "$HEADER_SPEC" 2>/dev/null || true)"
rm -f "$HEADER_SPEC" 2>/dev/null || true
if [[ -n "$HEADER_IMAGE" ]]; then
  printf ' | image=%s dropdown=false\n' "$HEADER_IMAGE"
else
  # Safe fallback: never emit unsupported true-colour ANSI sequences.
  printf '%s | font=Menlo size=12\n' "$PLAIN_TITLE"
fi
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
