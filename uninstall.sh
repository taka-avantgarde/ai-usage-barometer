#!/usr/bin/env bash
set -euo pipefail
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}"
SUPPORT_DIR="$PLUGIN_DIR/.ai-usage-barometer"
CLAUDE_DIR="${AI_USAGE_CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_CAPTURE_TARGET="$CLAUDE_DIR/ai-usage-barometer-statusline.sh"

if [[ -x "$SUPPORT_DIR/configure-claude-statusline.sh" ]]; then
  AI_USAGE_CLAUDE_DIR="$CLAUDE_DIR" \
  AI_USAGE_CLAUDE_STATUSLINE_PATH="$CLAUDE_CAPTURE_TARGET" \
    "$SUPPORT_DIR/configure-claude-statusline.sh" uninstall || true
fi

rm -f "$CLAUDE_CAPTURE_TARGET"
rm -f "$CLAUDE_DIR/ai-usage-barometer-statusline-backup.json"
rm -f "$PLUGIN_DIR/ai-usage.60s.sh"
rm -rf "$SUPPORT_DIR"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer"
open -g "swiftbar://refreshallplugins" >/dev/null 2>&1 || true
echo "AI Usage Barometer removed. Previous Claude Code status line restored when applicable."
