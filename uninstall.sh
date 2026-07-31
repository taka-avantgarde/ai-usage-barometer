#!/usr/bin/env bash
set -euo pipefail
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}"
SUPPORT_DIR="$PLUGIN_DIR/.ai-usage-barometer"
CLAUDE_DIR="${AI_USAGE_CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_CAPTURE_TARGET="$CLAUDE_DIR/ai-usage-barometer-statusline.sh"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"

if [[ -x "$SUPPORT_DIR/configure-claude-statusline.sh" ]]; then
  AI_USAGE_CLAUDE_DIR="$CLAUDE_DIR" \
  AI_USAGE_CLAUDE_STATUSLINE_PATH="$CLAUDE_CAPTURE_TARGET" \
    "$SUPPORT_DIR/configure-claude-statusline.sh" uninstall || true
fi

rm -f "$CLAUDE_CAPTURE_TARGET"
rm -f "$CLAUDE_DIR/ai-usage-barometer-statusline-backup.json"

# Current plugin, plus every name this tool has shipped under.
for p in claude-codex.60s.sh ai-usage.60s.sh codex-usage.60s.sh \
         claude-usage.60s.sh claude-usage.60s.sh.nobg; do
  rm -f "$PLUGIN_DIR/$p"
done

rm -rf "$SUPPORT_DIR"
rm -rf "$CACHE_ROOT/ai-usage-barometer"
rm -rf "$CACHE_ROOT/claude-codex-bar"      # display settings + Claude cache
rm -rf "$CACHE_ROOT/codex-usage-barometer" # refresh interval written for the helper

open -g "swiftbar://refreshallplugins" >/dev/null 2>&1 || true
echo "AI Usage Barometer removed. Previous Claude Code status line restored when applicable."

# Backups are the user's, so they are reported rather than deleted.
shopt -s nullglob
kept=("$PLUGIN_DIR"/.retired-* "$PLUGIN_DIR"/*.bak-*)
if (( ${#kept[@]} )); then
  echo "Backups left in place — delete them yourself if you no longer need them:"
  printf '  %s\n' "${kept[@]}"
fi
