#!/usr/bin/env bash
set -euo pipefail
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}"
rm -f "$PLUGIN_DIR/ai-usage.60s.sh"
rm -rf "$PLUGIN_DIR/.ai-usage-barometer"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer"
open -g "swiftbar://refreshallplugins" >/dev/null 2>&1 || true
echo "AI Usage Barometer removed."
