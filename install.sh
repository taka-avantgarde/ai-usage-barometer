#!/usr/bin/env bash
# AI Usage Barometer — one-line installer
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
set -euo pipefail

REPO="${AI_USAGE_REPO:-taka-avantgarde/ai-usage-barometer}"
BRANCH="${AI_USAGE_BRANCH:-main}"
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}"
SUPPORT_DIR="$PLUGIN_DIR/.ai-usage-barometer"
PLUGIN="ai-usage.60s.sh"
TARGET="$PLUGIN_DIR/$PLUGIN"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
CLAUDE_URL="https://raw.githubusercontent.com/taka-avantgarde/claude-usage-barometer/main/claude-usage.60s.sh"
CODEX_URL="https://raw.githubusercontent.com/taka-avantgarde/codex-usage-barometer/main/codex-usage.60s.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer supports macOS with SwiftBar." >&2
  exit 1
fi

echo "▶ AI Usage Barometer installer"

if ! command -v brew >/dev/null 2>&1; then
  echo "→ Homebrew is not installed; installing it now…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

command -v brew >/dev/null 2>&1 || { echo "Homebrew installation could not be detected." >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "→ Installing jq…"; brew install jq; }
if [[ ! -d /Applications/SwiftBar.app && ! -d "$HOME/Applications/SwiftBar.app" ]]; then
  echo "→ Installing SwiftBar…"
  brew install --cask swiftbar
fi

mkdir -p "$PLUGIN_DIR" "$SUPPORT_DIR"
chmod 700 "$SUPPORT_DIR" 2>/dev/null || true

download_install() {
  local url="$1" target="$2" tmp
  tmp="$(mktemp)"
  curl -fsSL "$url" -o "$tmp"
  install -m 755 "$tmp" "$target"
  rm -f "$tmp"
}

echo "→ Installing unified plugin…"
download_install "$RAW_BASE/$PLUGIN" "$TARGET"
download_install "$CLAUDE_URL" "$SUPPORT_DIR/claude-usage.sh"
download_install "$CODEX_URL" "$SUPPORT_DIR/codex-usage.sh"

# Prevent duplicate menu-bar items while preserving previous files.
for old in "$PLUGIN_DIR/claude-usage.60s.sh" "$PLUGIN_DIR/codex-usage.60s.sh"; do
  if [[ -f "$old" ]]; then
    mv "$old" "$SUPPORT_DIR/legacy-$(basename "$old")" 2>/dev/null || rm -f "$old"
  fi
done

defaults write com.ameba.SwiftBar PluginDirectory "$PLUGIN_DIR" >/dev/null 2>&1 || true
open -a SwiftBar >/dev/null 2>&1 || open /Applications/SwiftBar.app >/dev/null 2>&1 || true
open -g "swiftbar://refreshallplugins" >/dev/null 2>&1 || true

cat <<DONE

✅ Installed.

The menu bar shows one combined item:
• Claude segment: orange
• Codex segment: blue
• Service names are shown only inside the dropdown
• Settings lets you hide either service

If SwiftBar asks for its plugin folder, choose: $PLUGIN_DIR
DONE
