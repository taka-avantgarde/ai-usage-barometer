#!/usr/bin/env bash
# <xbar.title>Codex Usage Barometer</xbar.title>
# <xbar.version>v0.1.1</xbar.version>
# <xbar.author>Takayuki Miyano / Atlas Associates Inc.</xbar.author>
# <xbar.author.github>taka-avantgarde</xbar.author.github>
# <xbar.desc>Shows Codex primary and secondary usage limits in the macOS menu bar.</xbar.desc>
# <xbar.dependencies>bash,jq,curl</xbar.dependencies>
# <xbar.abouturl>https://github.com/taka-avantgarde/codex-usage-barometer</xbar.abouturl>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -u

VERSION="0.1.1"
REPO="${REPO:-taka-avantgarde/codex-usage-barometer}"
UPDATE_CHECK="${UPDATE_CHECK:-1}"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-86400}"
WARN="${WARN:-70}"
DANGER="${DANGER:-90}"
OK_COLOR="${OK_COLOR:-#6B8E6E}"
WARN_COLOR="${WARN_COLOR:-#B8860B}"
DANGER_COLOR="${DANGER_COLOR:-#B04A3A}"
MUTED_COLOR="${MUTED_COLOR:-#808080}"
FILL="${FILL:-█}"
EMPTY="${EMPTY:-░}"
MBAR_W="${MBAR_W:-5}"
DROP_W="${DROP_W:-10}"
DEFAULT_INTERVAL="${DEFAULT_INTERVAL:-180}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-5}"
MAX_TIME="${MAX_TIME:-12}"
ALLOW_NON_OPENAI_ENDPOINT="${CODEX_USAGE_ALLOW_NON_OPENAI_ENDPOINT:-0}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/codex-usage-barometer"
CACHE_FILE="$CACHE_DIR/usage.json"
INTERVAL_FILE="$CACHE_DIR/interval"
ERROR_FILE="$CACHE_DIR/last-error.txt"
UPDATE_FILE="$CACHE_DIR/latest-version"
AUTH_FILE="$CODEX_HOME/auth.json"

# Codex has used both path styles. Try the current ChatGPT route first and keep
# the alternate route as a compatibility fallback.
DEFAULT_ENDPOINTS=(
  "https://chatgpt.com/backend-api/wham/usage"
  "https://chatgpt.com/backend-api/codex/usage"
)

mkdir -p "$CACHE_DIR" 2>/dev/null || true
chmod 700 "$CACHE_DIR" 2>/dev/null || true

write_error() {
  printf '%s\n' "$1" > "$ERROR_FILE" 2>/dev/null || true
  chmod 600 "$ERROR_FILE" 2>/dev/null || true
}

clear_error() {
  : > "$ERROR_FILE" 2>/dev/null || true
}

file_mtime() {
  local path="$1" value=""
  value="$(stat -f %m "$path" 2>/dev/null || true)"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
    return 0
  fi
  value="$(stat -c %Y "$path" 2>/dev/null || true)"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
  else
    printf '0\n'
  fi
}

now_epoch() {
  date +%s
}

clamp_percent() {
  awk -v n="${1:-0}" 'BEGIN { if (n < 0) n=0; if (n > 100) n=100; printf "%d", n+0.5 }'
}

color_for() {
  local used
  used="$(clamp_percent "$1")"
  if (( used >= DANGER )); then
    printf '%s' "$DANGER_COLOR"
  elif (( used >= WARN )); then
    printf '%s' "$WARN_COLOR"
  else
    printf '%s' "$OK_COLOR"
  fi
}

repeat_char() {
  local char="$1" count="$2" out="" i
  for ((i=0; i<count; i++)); do out+="$char"; done
  printf '%s' "$out"
}

usage_bar() {
  local used width remaining spent
  used="$(clamp_percent "$1")"
  width="$2"
  remaining=$(( ((100 - used) * width + 50) / 100 ))
  spent=$(( width - remaining ))
  printf '%s%s' "$(repeat_char "$FILL" "$remaining")" "$(repeat_char "$EMPTY" "$spent")"
}

window_label() {
  local minutes="${1:-}"
  if [[ -z "$minutes" || "$minutes" == "null" ]]; then
    printf 'Limit'
  elif (( minutes == 10080 )); then
    printf '7d'
  elif (( minutes % 10080 == 0 )); then
    printf '%dw' $((minutes / 10080))
  elif (( minutes % 1440 == 0 )); then
    printf '%dd' $((minutes / 1440))
  elif (( minutes % 60 == 0 )); then
    printf '%dh' $((minutes / 60))
  else
    printf '%dm' "$minutes"
  fi
}

format_reset() {
  local ts="${1:-}" now delta d h m
  if [[ -z "$ts" || "$ts" == "null" || "$ts" == "0" ]]; then
    printf 'unknown'
    return
  fi
  now="$(now_epoch)"
  delta=$(( ts - now ))
  (( delta < 0 )) && delta=0
  d=$((delta / 86400))
  h=$(((delta % 86400) / 3600))
  m=$(((delta % 3600) / 60))
  if (( d > 0 )); then
    printf '%dd %dh' "$d" "$h"
  elif (( h > 0 )); then
    printf '%dh %dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

format_local_time() {
  local ts="${1:-}"
  if [[ -z "$ts" || "$ts" == "null" || "$ts" == "0" ]]; then
    printf '—'
    return
  fi
  date -r "$ts" '+%Y-%m-%d %H:%M' 2>/dev/null || date -d "@$ts" '+%Y-%m-%d %H:%M' 2>/dev/null || printf '—'
}

semver_is_newer() {
  local candidate="${1#v}" current="${2#v}"
  awk -v a="$candidate" -v b="$current" '
    function n(v, p, i, x) {
      split(v, p, ".")
      for (i=1; i<=3; i++) x[i]=(p[i] == "" ? 0 : p[i]+0)
    }
    BEGIN {
      n(a, A); n(b, B)
      for (i=1; i<=3; i++) {
        if (A[i] > B[i]) exit 0
        if (A[i] < B[i]) exit 1
      }
      exit 1
    }
  '
}

latest_release_version() {
  local now mtime age latest
  [[ "$UPDATE_CHECK" == "1" ]] || return 1

  now="$(now_epoch)"
  mtime="$(file_mtime "$UPDATE_FILE")"
  age=$((now - mtime))
  if [[ -s "$UPDATE_FILE" && $age -lt $UPDATE_INTERVAL ]]; then
    cat "$UPDATE_FILE"
    return 0
  fi

  latest="$(curl -fsSL --connect-timeout 3 --max-time 6 \
    -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null |
    jq -r '.tag_name // empty' 2>/dev/null)"
  [[ -n "$latest" ]] || return 1
  printf '%s\n' "$latest" > "$UPDATE_FILE" 2>/dev/null || true
  chmod 600 "$UPDATE_FILE" 2>/dev/null || true
  printf '%s\n' "$latest"
}

# Convert API and rollout-log variants to one stable internal schema.
normalise_json() {
  local source="$1"
  jq -c --arg source "$source" --argjson fetched_at "$(now_epoch)" '
    def as_number_or_null:
      if . == null then null
      elif type == "number" then .
      elif type == "string" then (tonumber? // null)
      else null end;
    def win($w):
      if $w == null then null else {
        used_percent: (($w.used_percent // $w.utilization // 0) | as_number_or_null),
        window_minutes: (
          ($w.window_minutes //
           (if $w.limit_window_seconds != null then (($w.limit_window_seconds | as_number_or_null) / 60) else null end) //
           (if $w.window_seconds != null then (($w.window_seconds | as_number_or_null) / 60) else null end))
          | as_number_or_null
        ),
        resets_at: (
          ($w.resets_at // $w.reset_at //
           (if $w.resets_in_seconds != null then ($fetched_at + ($w.resets_in_seconds | as_number_or_null)) else null end))
          | as_number_or_null
        )
      } end;
    def choose_snapshot:
      if (.rate_limits? | type) == "array" then
        ((.rate_limits | map(select((.limit_id // "") == "codex")) | first) // .rate_limits[0] // {})
      elif (.rate_limits? | type) == "object" then .rate_limits
      elif (.rate_limit? | type) == "object" then .rate_limit
      else . end;
    . as $root |
    (choose_snapshot) as $s |
    {
      schema_version: 1,
      source: $source,
      fetched_at: $fetched_at,
      limit_id: ($s.limit_id // $root.limit_id // "codex"),
      limit_name: ($s.limit_name // $root.limit_name // "Codex"),
      plan_type: ($s.plan_type // $root.plan_type // $root.planType // null),
      primary: win($s.primary // $s.primary_window // $root.primary // $root.primary_window // $root.rate_limit.primary_window),
      secondary: win($s.secondary // $s.secondary_window // $root.secondary // $root.secondary_window // $root.rate_limit.secondary_window),
      credits: ($s.credits // $root.credits // null),
      individual_limit: ($s.individual_limit // $root.individual_limit // null),
      spend_control_reached: ($s.spend_control_reached // $root.spend_control_reached // null)
    }
    | select(.primary != null or .secondary != null)
  ' 2>/dev/null
}

extract_token() {
  jq -r '.tokens.access_token // .access_token // empty' "$AUTH_FILE" 2>/dev/null
}

extract_account_id() {
  jq -r '.tokens.account_id // .account_id // empty' "$AUTH_FILE" 2>/dev/null
}

endpoint_is_allowed() {
  local endpoint="$1"
  case "$endpoint" in
    https://chatgpt.com/*) return 0 ;;
    *) [[ "$ALLOW_NON_OPENAI_ENDPOINT" == "1" ]] ;;
  esac
}

fetch_live() {
  local token account endpoint body status tmp parsed

  if [[ -n "${CODEX_USAGE_FIXTURE:-}" ]]; then
    [[ -r "$CODEX_USAGE_FIXTURE" ]] || return 1
    parsed="$(normalise_json fixture < "$CODEX_USAGE_FIXTURE")"
    [[ -n "$parsed" ]] || return 1
    printf '%s\n' "$parsed"
    return 0
  fi

  [[ -r "$AUTH_FILE" ]] || return 2
  token="$(extract_token)"
  account="$(extract_account_id)"
  [[ -n "$token" ]] || return 2

  tmp="$(mktemp "$CACHE_DIR/live.XXXXXX")" || return 1
  chmod 600 "$tmp" 2>/dev/null || true

  local endpoints=("${DEFAULT_ENDPOINTS[@]}")
  if [[ -n "${CODEX_USAGE_ENDPOINT:-}" ]]; then
    endpoints=("$CODEX_USAGE_ENDPOINT")
  fi

  for endpoint in "${endpoints[@]}"; do
    if ! endpoint_is_allowed "$endpoint"; then
      write_error "Refusing non-OpenAI usage endpoint. Set CODEX_USAGE_ALLOW_NON_OPENAI_ENDPOINT=1 only for controlled testing."
      continue
    fi
    local headers=(-H "Authorization: Bearer $token" -H "Accept: application/json" -H "User-Agent: codex-cli")
    [[ -n "$account" ]] && headers+=(-H "ChatGPT-Account-Id: $account")

    status="$(curl -sS -o "$tmp" -w '%{http_code}' \
      --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" \
      "${headers[@]}" "$endpoint" 2>/dev/null || printf '000')"

    if [[ "$status" == "200" ]]; then
      body="$(cat "$tmp")"
      parsed="$(printf '%s' "$body" | normalise_json live)"
      if [[ -n "$parsed" ]]; then
        rm -f "$tmp"
        printf '%s\n' "$parsed"
        return 0
      fi
      write_error "Live response could not be parsed."
    else
      write_error "Live endpoint returned HTTP $status."
    fi
  done

  rm -f "$tmp"
  return 1
}

latest_rollout_snapshots() {
  local sessions="$CODEX_HOME/sessions" file snapshot count=0
  [[ -d "$sessions" ]] || return 1

  while IFS=$'\t' read -r _mtime file; do
    [[ -r "$file" ]] || continue
    snapshot="$(tail -n 2500 "$file" 2>/dev/null | jq -c '
      select(
        (.type == "event_msg" and .payload.type == "token_count" and .payload.rate_limits != null) or
        (.type == "token_count" and .rate_limits != null)
      )
      | (.payload.rate_limits // .rate_limits)
    ' 2>/dev/null | tail -n 1)"
    if [[ -n "$snapshot" ]]; then
      printf '%s\n' "$snapshot"
      return 0
    fi
    count=$((count + 1))
    (( count >= 20 )) && break
  done < <(
    find "$sessions" -type f -name 'rollout-*.jsonl' -print 2>/dev/null |
      while IFS= read -r file; do
        printf '%s\t%s\n' "$(file_mtime "$file")" "$file"
      done | sort -rn
  )
  return 1
}

fetch_rollout() {
  local raw parsed
  if [[ -n "${CODEX_ROLLOUT_FIXTURE:-}" ]]; then
    raw="$(tail -n 2500 "$CODEX_ROLLOUT_FIXTURE" 2>/dev/null | jq -c '
      select(
        (.type == "event_msg" and .payload.type == "token_count" and .payload.rate_limits != null) or
        (.type == "token_count" and .rate_limits != null)
      )
      | (.payload.rate_limits // .rate_limits)
    ' 2>/dev/null | tail -n 1)"
  else
    raw="$(latest_rollout_snapshots)"
  fi
  [[ -n "$raw" ]] || return 1
  parsed="$(printf '%s' "$raw" | normalise_json rollout)"
  [[ -n "$parsed" ]] || return 1
  printf '%s\n' "$parsed"
}

cache_is_fresh() {
  local interval now mtime age
  [[ -s "$CACHE_FILE" ]] || return 1
  interval="$(cat "$INTERVAL_FILE" 2>/dev/null || printf '%s' "$DEFAULT_INTERVAL")"
  [[ "$interval" =~ ^[0-9]+$ ]] || interval="$DEFAULT_INTERVAL"
  now="$(now_epoch)"
  mtime="$(file_mtime "$CACHE_FILE")"
  age=$((now - mtime))
  (( age < interval ))
}

save_cache() {
  local json="$1" tmp
  tmp="$(mktemp "$CACHE_DIR/cache.XXXXXX")" || return 1
  printf '%s\n' "$json" > "$tmp"
  chmod 600 "$tmp" 2>/dev/null || true
  mv "$tmp" "$CACHE_FILE"
}

load_usage() {
  local data rc
  if cache_is_fresh; then
    cat "$CACHE_FILE"
    return 0
  fi

  data="$(fetch_live)"; rc=$?
  if [[ $rc -eq 0 && -n "$data" ]]; then
    save_cache "$data"
    clear_error
    printf '%s\n' "$data"
    return 0
  fi

  data="$(fetch_rollout)" || data=""
  if [[ -n "$data" ]]; then
    save_cache "$data"
    if [[ $rc -eq 2 ]]; then
      write_error "Using the latest local Codex session snapshot; auth.json is unavailable (credentials may be in Keychain)."
    else
      write_error "Live usage unavailable; using the latest local Codex session snapshot."
    fi
    printf '%s\n' "$data"
    return 0
  fi

  if [[ -s "$CACHE_FILE" ]]; then
    jq -c '.source = "cache"' "$CACHE_FILE" 2>/dev/null || cat "$CACHE_FILE"
    return 0
  fi

  [[ $rc -eq 2 ]] && write_error "No readable auth.json and no rate-limit snapshot found in Codex session logs."
  return 1
}

set_interval() {
  local seconds="${1:-}"
  case "$seconds" in
    60|180|300) printf '%s\n' "$seconds" > "$INTERVAL_FILE" ;;
    *) exit 2 ;;
  esac
  chmod 600 "$INTERVAL_FILE" 2>/dev/null || true
  rm -f "$CACHE_FILE"
}

case "${1:-}" in
  --set-interval)
    set_interval "${2:-}"
    exit 0
    ;;
  --clear-cache)
    rm -f "$CACHE_FILE" "$ERROR_FILE"
    exit 0
    ;;
esac

if ! command -v jq >/dev/null 2>&1; then
  echo "⚠ | color=$DANGER_COLOR"
  echo "---"
  echo "jq is required | color=$DANGER_COLOR"
  echo "Install jq | bash=/bin/zsh param1=-lc param2='brew install jq' terminal=true refresh=true"
  exit 0
fi

DATA="$(load_usage)" || DATA=""
if [[ -z "$DATA" ]]; then
  ERR="$(cat "$ERROR_FILE" 2>/dev/null || printf 'Usage data is not available yet.')"
  echo "⚠ | color=$DANGER_COLOR"
  echo "---"
  echo "$ERR | color=$DANGER_COLOR"
  echo "Run Codex once, then refresh | color=$MUTED_COLOR"
  echo "Codex login status | bash=/bin/zsh param1=-lc param2='codex login status' terminal=true"
  echo "Refresh now | refresh=true"
  exit 0
fi

P_USED="$(jq -r '.primary.used_percent // 0' <<< "$DATA")"
S_USED="$(jq -r '.secondary.used_percent // 0' <<< "$DATA")"
P_MIN="$(jq -r '.primary.window_minutes // empty | floor' <<< "$DATA")"
S_MIN="$(jq -r '.secondary.window_minutes // empty | floor' <<< "$DATA")"
P_RESET="$(jq -r '.primary.resets_at // empty | floor' <<< "$DATA")"
S_RESET="$(jq -r '.secondary.resets_at // empty | floor' <<< "$DATA")"
SOURCE="$(jq -r '.source // "unknown"' <<< "$DATA")"
PLAN="$(jq -r '.plan_type // empty' <<< "$DATA")"
FETCHED="$(jq -r '.fetched_at // 0 | floor' <<< "$DATA")"
P_USED_I="$(clamp_percent "$P_USED")"
S_USED_I="$(clamp_percent "$S_USED")"
WORST="$P_USED_I"; (( S_USED_I > WORST )) && WORST="$S_USED_I"
COLOR="$(color_for "$WORST")"
P_LABEL="$(window_label "$P_MIN")"
S_LABEL="$(window_label "$S_MIN")"
P_BAR="$(usage_bar "$P_USED_I" "$MBAR_W")"
S_BAR="$(usage_bar "$S_USED_I" "$MBAR_W")"

TITLE="${P_LABEL} ${P_BAR}"
if [[ "$(jq -r '.secondary != null' <<< "$DATA")" == "true" ]]; then
  TITLE+=" ${S_LABEL} ${S_BAR}"
fi
[[ "$SOURCE" == "rollout" || "$SOURCE" == "cache" ]] && TITLE+=" ·"

echo "$TITLE | color=$COLOR font=Menlo"
echo "---"
echo "Codex usage | color=$COLOR"
[[ -n "$PLAN" ]] && echo "Plan: $PLAN | color=$MUTED_COLOR"
echo "---"

echo "$P_LABEL   $(usage_bar "$P_USED_I" "$DROP_W")   ${P_USED_I}% used | color=$(color_for "$P_USED_I") font=Menlo"
echo "     $((100-P_USED_I))% left · resets in $(format_reset "$P_RESET") | color=$MUTED_COLOR font=Menlo size=11"

if [[ "$(jq -r '.secondary != null' <<< "$DATA")" == "true" ]]; then
  echo "$S_LABEL   $(usage_bar "$S_USED_I" "$DROP_W")   ${S_USED_I}% used | color=$(color_for "$S_USED_I") font=Menlo"
  echo "     $((100-S_USED_I))% left · resets in $(format_reset "$S_RESET") | color=$MUTED_COLOR font=Menlo size=11"
fi

CREDITS_BALANCE="$(jq -r '.credits.balance // empty' <<< "$DATA")"
CREDITS_UNLIMITED="$(jq -r '.credits.unlimited // false' <<< "$DATA")"
if [[ "$CREDITS_UNLIMITED" == "true" ]]; then
  echo "Credits: unlimited"
elif [[ -n "$CREDITS_BALANCE" ]]; then
  echo "Credits: $CREDITS_BALANCE"
fi

INDIVIDUAL_REMAINING="$(jq -r '.individual_limit.remaining_percent // empty' <<< "$DATA")"
if [[ -n "$INDIVIDUAL_REMAINING" ]]; then
  echo "Spend control: ${INDIVIDUAL_REMAINING}% remaining"
fi

echo "---"
if [[ "$SOURCE" == "live" ]]; then
  echo "Source: live account usage | color=$MUTED_COLOR"
elif [[ "$SOURCE" == "fixture" ]]; then
  echo "Source: test fixture | color=$MUTED_COLOR"
elif [[ "$SOURCE" == "rollout" ]]; then
  echo "Source: latest local Codex snapshot · may be stale | color=$WARN_COLOR"
else
  echo "Source: cached reading | color=$WARN_COLOR"
fi
(( FETCHED > 0 )) && echo "Updated: $(format_local_time "$FETCHED") | color=$MUTED_COLOR"

ERR="$(cat "$ERROR_FILE" 2>/dev/null || true)"
[[ -n "$ERR" ]] && echo "$ERR | color=$MUTED_COLOR"

echo "---"
CURRENT_INTERVAL="$(cat "$INTERVAL_FILE" 2>/dev/null || printf '%s' "$DEFAULT_INTERVAL")"
echo "⏱ Update every $((CURRENT_INTERVAL/60)) min"
echo "--1 min | bash='$0' param1=--set-interval param2=60 terminal=false refresh=true"
echo "--3 min | bash='$0' param1=--set-interval param2=180 terminal=false refresh=true"
echo "--5 min | bash='$0' param1=--set-interval param2=300 terminal=false refresh=true"
echo "Refresh now | bash='$0' param1=--clear-cache terminal=false refresh=true"
echo "Open Codex | href=https://chatgpt.com/codex"
LATEST_VERSION="$(latest_release_version 2>/dev/null || true)"
if [[ -n "$LATEST_VERSION" ]] && semver_is_newer "$LATEST_VERSION" "$VERSION"; then
  echo "Update available: $LATEST_VERSION | href=https://github.com/$REPO/releases/latest color=$WARN_COLOR"
fi
echo "Version v$VERSION | href=https://github.com/$REPO/releases color=$MUTED_COLOR"
