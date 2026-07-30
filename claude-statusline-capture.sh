#!/usr/bin/env bash
# Capture Claude Code's official statusLine rate_limits payload for SwiftBar.
# This script stays silent unless the user already had a status line, in which
# case it transparently passes the same JSON to that original command.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -u

CACHE_DIR="${AI_USAGE_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer}"
CACHE_FILE="${AI_USAGE_CLAUDE_STATUS_CACHE:-$CACHE_DIR/claude-statusline.json}"
BACKUP_FILE="${AI_USAGE_CLAUDE_STATUSLINE_BACKUP:-$HOME/.claude/ai-usage-barometer-statusline-backup.json}"
SELF_PATH="${AI_USAGE_CLAUDE_STATUSLINE_PATH:-$HOME/.claude/ai-usage-barometer-statusline.sh}"

input="$(cat)"
mkdir -p "$CACHE_DIR" 2>/dev/null || true
chmod 700 "$CACHE_DIR" 2>/dev/null || true

# rate_limits is deliberately read only from Claude Code's documented statusLine
# JSON. No OAuth token, Keychain item, or credentials file is accessed here.
if command -v jq >/dev/null 2>&1 && \
   printf '%s' "$input" | jq -e '.rate_limits | type == "object"' >/dev/null 2>&1; then
  now="$(date +%s)"
  tmp="$(mktemp "$CACHE_DIR/claude-statusline.XXXXXX" 2>/dev/null || true)"
  if [[ -n "$tmp" ]]; then
    if printf '%s' "$input" | jq -c --argjson captured_at "$now" '
      def n:
        if type == "number" then .
        elif type == "string" then (tonumber? // null)
        else null end;
      def window($name):
        if (.rate_limits | has($name)) and (.rate_limits[$name] | type == "object") then
          {
            used_percentage: ((.rate_limits[$name].used_percentage // null) | n),
            resets_at: ((.rate_limits[$name].resets_at // null) | n)
          }
        else null end;
      {
        schema_version: 2,
        source: "claude-code-statusline",
        captured_at: $captured_at,
        session_id: (.session_id // null),
        claude_code_version: (.version // null),
        five_hour_present: (.rate_limits | has("five_hour")),
        seven_day_present: (.rate_limits | has("seven_day")),
        five_hour: window("five_hour"),
        seven_day: window("seven_day")
      }
    ' > "$tmp" 2>/dev/null; then
      chmod 600 "$tmp" 2>/dev/null || true
      mv "$tmp" "$CACHE_FILE" 2>/dev/null || rm -f "$tmp"
    else
      rm -f "$tmp"
    fi
  fi
fi

# Preserve an existing user status line. The installer stores the previous
# statusLine object as JSON before replacing its command with this wrapper.
if [[ -r "$BACKUP_FILE" ]] && command -v jq >/dev/null 2>&1; then
  original_type="$(jq -r 'if type == "object" then (.type // "") else "" end' "$BACKUP_FILE" 2>/dev/null || true)"
  original_command="$(jq -r 'if type == "object" then (.command // "") else "" end' "$BACKUP_FILE" 2>/dev/null || true)"
  if [[ "$original_type" == "command" && -n "$original_command" && "$original_command" != "$SELF_PATH" ]]; then
    user_shell="${SHELL:-/bin/bash}"
    [[ -x "$user_shell" ]] || user_shell="/bin/bash"
    printf '%s' "$input" | "$user_shell" -lc "$original_command" 2>/dev/null || true
  fi
fi

exit 0
