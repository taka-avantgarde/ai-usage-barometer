#!/usr/bin/env bash
# Install or restore the Claude Code statusLine wrapper without discarding the
# user's existing status line configuration.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
set -euo pipefail

ACTION="${1:-install}"
CLAUDE_DIR="${AI_USAGE_CLAUDE_DIR:-$HOME/.claude}"
SETTINGS_FILE="${AI_USAGE_CLAUDE_SETTINGS_FILE:-$CLAUDE_DIR/settings.json}"
WRAPPER="${AI_USAGE_CLAUDE_STATUSLINE_PATH:-$CLAUDE_DIR/ai-usage-barometer-statusline.sh}"
BACKUP_FILE="${AI_USAGE_CLAUDE_STATUSLINE_BACKUP:-$CLAUDE_DIR/ai-usage-barometer-statusline-backup.json}"
SETTINGS_BACKUP="${AI_USAGE_CLAUDE_SETTINGS_BACKUP:-$CLAUDE_DIR/settings.before-ai-usage-barometer.json}"

command -v jq >/dev/null 2>&1 || { echo "jq is required." >&2; exit 1; }
mkdir -p "$CLAUDE_DIR"
chmod 700 "$CLAUDE_DIR" 2>/dev/null || true

ensure_settings() {
  if [[ ! -e "$SETTINGS_FILE" ]]; then
    printf '{}\n' > "$SETTINGS_FILE"
    chmod 600 "$SETTINGS_FILE" 2>/dev/null || true
  fi
  jq -e 'type == "object"' "$SETTINGS_FILE" >/dev/null 2>&1 || {
    echo "Claude settings is not valid JSON: $SETTINGS_FILE" >&2
    exit 1
  }
}

atomic_replace() {
  local source="$1" target="$2" tmp
  tmp="$(mktemp "$CLAUDE_DIR/settings.XXXXXX")"
  cat "$source" > "$tmp"
  chmod 600 "$tmp" 2>/dev/null || true
  mv "$tmp" "$target"
}

install_wrapper() {
  local current_command current_status tmp
  [[ -x "$WRAPPER" ]] || { echo "Claude statusLine wrapper is missing: $WRAPPER" >&2; exit 1; }
  ensure_settings
  [[ -e "$SETTINGS_BACKUP" ]] || cp "$SETTINGS_FILE" "$SETTINGS_BACKUP"
  chmod 600 "$SETTINGS_BACKUP" 2>/dev/null || true

  current_command="$(jq -r 'if (.statusLine | type) == "object" then (.statusLine.command // "") else "" end' "$SETTINGS_FILE")"
  if [[ "$current_command" != "$WRAPPER" ]]; then
    current_status="$(jq -c '.statusLine // null' "$SETTINGS_FILE")"
    printf '%s\n' "$current_status" > "$BACKUP_FILE"
    chmod 600 "$BACKUP_FILE" 2>/dev/null || true
  elif [[ ! -e "$BACKUP_FILE" ]]; then
    printf 'null\n' > "$BACKUP_FILE"
    chmod 600 "$BACKUP_FILE" 2>/dev/null || true
  fi

  tmp="$(mktemp "$CLAUDE_DIR/settings-new.XXXXXX")"
  jq --arg command "$WRAPPER" '
    .statusLine = (
      (if (.statusLine | type) == "object" then .statusLine else {} end)
      + {type: "command", command: $command}
    )
  ' "$SETTINGS_FILE" > "$tmp"
  atomic_replace "$tmp" "$SETTINGS_FILE"
  rm -f "$tmp"
  echo "Claude Code official rate-limit capture enabled."
}

uninstall_wrapper() {
  local current_command backup tmp
  [[ -e "$SETTINGS_FILE" ]] || return 0
  jq -e 'type == "object"' "$SETTINGS_FILE" >/dev/null 2>&1 || return 0
  current_command="$(jq -r 'if (.statusLine | type) == "object" then (.statusLine.command // "") else "" end' "$SETTINGS_FILE")"
  [[ "$current_command" == "$WRAPPER" ]] || return 0

  backup='null'
  if [[ -r "$BACKUP_FILE" ]] && jq -e '. == null or type == "object"' "$BACKUP_FILE" >/dev/null 2>&1; then
    backup="$(cat "$BACKUP_FILE")"
  fi
  tmp="$(mktemp "$CLAUDE_DIR/settings-restore.XXXXXX")"
  jq --argjson backup "$backup" '
    if $backup == null then del(.statusLine) else .statusLine = $backup end
  ' "$SETTINGS_FILE" > "$tmp"
  atomic_replace "$tmp" "$SETTINGS_FILE"
  rm -f "$tmp"
  echo "Previous Claude Code status line restored."
}

case "$ACTION" in
  install) install_wrapper ;;
  uninstall) uninstall_wrapper ;;
  *) echo "Usage: $0 [install|uninstall]" >&2; exit 2 ;;
esac
