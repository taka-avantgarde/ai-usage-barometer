#!/usr/bin/env bash
# Render Claude Code's official statusLine rate_limits cache in SwiftBar format.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -u

CACHE_DIR="${AI_USAGE_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer}"
CACHE_FILE="${AI_USAGE_CLAUDE_STATUS_CACHE:-$CACHE_DIR/claude-statusline.json}"
FILL="${FILL:-█}"
EMPTY="${EMPTY:-░}"
MBAR_W="${MBAR_W:-5}"
DETAIL_W="${DETAIL_W:-10}"
MUTED_COLOR="${MUTED_COLOR:-#808080}"

clamp_round() {
  awk -v n="${1:-0}" 'BEGIN { if (n < 0) n=0; if (n > 100) n=100; printf "%d", n+0.5 }'
}

repeat_char() {
  local char="$1" count="$2" out="" i=0
  while (( i < count )); do out+="$char"; i=$((i + 1)); done
  printf '%s' "$out"
}

remaining_gauge() {
  local used width remaining spent
  used="$(clamp_round "$1")"
  width="$2"
  remaining=$(( ((100 - used) * width + 50) / 100 ))
  spent=$((width - remaining))
  printf '%s%s' "$(repeat_char "$FILL" "$remaining")" "$(repeat_char "$EMPTY" "$spent")"
}

format_reset() {
  local reset="${1:-0}" now delta d h m
  now="$(date +%s)"
  if [[ ! "$reset" =~ ^[0-9]+$ ]] || (( reset <= 0 )); then
    printf 'reset time unavailable'
    return
  fi
  if (( reset <= now )); then
    printf 'reset complete · starts on next use'
    return
  fi
  delta=$((reset - now))
  d=$((delta / 86400))
  h=$(((delta % 86400) / 3600))
  m=$(((delta % 3600) / 60))
  if (( d > 0 )); then printf 'resets in %dd %dh' "$d" "$h"
  elif (( h > 0 )); then printf 'resets in %dh %dm' "$h" "$m"
  else printf 'resets in %dm' "$m"; fi
}

format_age() {
  local captured="${1:-0}" now delta d h m
  now="$(date +%s)"
  if [[ ! "$captured" =~ ^[0-9]+$ ]] || (( captured <= 0 || captured > now )); then
    printf 'capture time unavailable'
    return
  fi
  delta=$((now - captured))
  d=$((delta / 86400))
  h=$(((delta % 86400) / 3600))
  m=$(((delta % 3600) / 60))
  if (( d > 0 )); then printf 'updated %dd %dh ago' "$d" "$h"
  elif (( h > 0 )); then printf 'updated %dh %dm ago' "$h" "$m"
  elif (( m > 0 )); then printf 'updated %dm ago' "$m"
  else printf 'updated just now'; fi
}

waiting_output() {
  printf 'Claude\n---\n'
  printf 'Waiting for official Claude Code usage data | color=%s\n' "$MUTED_COLOR"
  printf 'Open Claude Code and send one message | color=%s\n' "$MUTED_COLOR"
  printf 'The bars appear after Claude returns rate_limits | color=%s\n' "$MUTED_COLOR"
  printf '%s\n' '---'
}

if ! command -v jq >/dev/null 2>&1 || [[ ! -s "$CACHE_FILE" ]] || \
   ! jq -e 'type == "object" and .source == "claude-code-statusline"' "$CACHE_FILE" >/dev/null 2>&1; then
  waiting_output
  exit 0
fi

now="$(date +%s)"
captured="$(jq -r '.captured_at // 0' "$CACHE_FILE" 2>/dev/null || printf 0)"
five_present="$(jq -r '.five_hour_present // false' "$CACHE_FILE" 2>/dev/null || printf false)"
seven_present="$(jq -r '.seven_day_present // false' "$CACHE_FILE" 2>/dev/null || printf false)"

header=""
details=""

append_window() {
  local label="$1" key="$2" present="$3" used reset remaining
  [[ "$present" == "true" ]] || return 0
  used="$(jq -r --arg key "$key" '.[$key].used_percentage // empty' "$CACHE_FILE" 2>/dev/null || true)"
  reset="$(jq -r --arg key "$key" '.[$key].resets_at // 0' "$CACHE_FILE" 2>/dev/null || printf 0)"
  [[ -n "$used" ]] || return 0
  used="$(clamp_round "$used")"
  if [[ "$reset" =~ ^[0-9]+$ ]] && (( reset > 0 && reset <= now )); then
    used=0
  fi
  remaining=$((100 - used))
  [[ -n "$header" ]] && header+="  "
  header+="$label $(remaining_gauge "$used" "$MBAR_W")"
  [[ -n "$details" ]] && details+=$'\n'
  details+="$label  $(remaining_gauge "$used" "$DETAIL_W")  ${used}% used"$'\n'
  details+="    ${remaining}% left · $(format_reset "$reset")"
}

append_window "5h" "five_hour" "$five_present"
append_window "7d" "seven_day" "$seven_present"

if [[ -z "$header" ]]; then
  waiting_output
  exit 0
fi

printf 'Claude %s\n---\n' "$header"
printf '%s\n' "$details"
printf '    official Claude Code rate_limits · %s | color=%s\n' "$(format_age "$captured")" "$MUTED_COLOR"
printf '%s\n' '---'
