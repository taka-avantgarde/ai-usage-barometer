#!/usr/bin/env bash
# AI Usage Barometer — one-line installer
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
set -euo pipefail

VERSION="0.2.7"
REPO="${AI_USAGE_REPO:-taka-avantgarde/ai-usage-barometer}"
BRANCH="${AI_USAGE_BRANCH:-main}"
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/SwiftBar}"
SUPPORT_DIR="$PLUGIN_DIR/.ai-usage-barometer"
PLUGIN="claude-codex.60s.sh"
TARGET="$PLUGIN_DIR/$PLUGIN"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
CLAUDE_DIR="${AI_USAGE_CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_CAPTURE_TARGET="$CLAUDE_DIR/ai-usage-barometer-statusline.sh"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/ai-usage-barometer"
CONFIG_FILE="$CACHE_DIR/config"
TEST_MODE="${AI_USAGE_TEST_MODE:-0}"

if [[ "$TEST_MODE" != "1" && "$(uname -s)" != "Darwin" ]]; then
  echo "This installer supports macOS with SwiftBar." >&2
  exit 1
fi

echo "▶ AI Usage Barometer installer v$VERSION"

if [[ "$TEST_MODE" != "1" ]]; then
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
else
  command -v jq >/dev/null 2>&1 || { echo "jq is required for tests." >&2; exit 1; }
fi

mkdir -p "$PLUGIN_DIR" "$SUPPORT_DIR" "$CLAUDE_DIR" "$CACHE_DIR"
chmod 700 "$SUPPORT_DIR" "$CLAUDE_DIR" "$CACHE_DIR" 2>/dev/null || true

download_install() {
  local url="$1" target="$2" tmp
  tmp="$(mktemp)"
  curl -fsSL "$url" -o "$tmp"
  install -m 755 "$tmp" "$target"
  rm -f "$tmp"
}

install_repo_file() {
  local name="$1" target="$2"
  if [[ -n "${AI_USAGE_LOCAL_SOURCE:-}" && -f "${AI_USAGE_LOCAL_SOURCE}/$name" ]]; then
    install -m 755 "${AI_USAGE_LOCAL_SOURCE}/$name" "$target"
  else
    download_install "$RAW_BASE/$name" "$target"
  fi
}

echo "→ Installing unified plugin and local helpers…"
install_repo_file "$PLUGIN" "$TARGET"
install_repo_file "claude-usage.sh" "$SUPPORT_DIR/claude-usage.sh"
install_repo_file "claude-statusline-capture.sh" "$CLAUDE_CAPTURE_TARGET"
install_repo_file "configure-claude-statusline.sh" "$SUPPORT_DIR/configure-claude-statusline.sh"

if [[ -n "${AI_USAGE_CODEX_SOURCE:-}" && -f "$AI_USAGE_CODEX_SOURCE" ]]; then
  install -m 755 "$AI_USAGE_CODEX_SOURCE" "$SUPPORT_DIR/codex-usage.sh"
else
  install_repo_file "codex-usage.sh" "$SUPPORT_DIR/codex-usage.sh"
fi

AI_USAGE_CLAUDE_DIR="$CLAUDE_DIR" \
AI_USAGE_CLAUDE_STATUSLINE_PATH="$CLAUDE_CAPTURE_TARGET" \
  "$SUPPORT_DIR/configure-claude-statusline.sh" install

# Fresh installs start with both services visible. Existing preferences are kept.
if [[ ! -s "$CONFIG_FILE" ]]; then
  cat > "$CONFIG_FILE" <<'CONFIG'
CLAUDE_ENABLED=1
CODEX_ENABLED=1
INTERVAL_MIN=3
CONFIG
  chmod 600 "$CONFIG_FILE" 2>/dev/null || true
fi

# Prevent duplicate menu-bar items while preserving previous standalone files.
STAMP="$(date '+%Y%m%d-%H%M%S')"
LEGACY_DIR="$SUPPORT_DIR/legacy-$STAMP"
for old in "$PLUGIN_DIR/ai-usage.60s.sh" "$PLUGIN_DIR/claude-usage.60s.sh" \
           "$PLUGIN_DIR/claude-usage.60s.sh.nobg" "$PLUGIN_DIR/codex-usage.60s.sh"; do
  if [[ -f "$old" ]]; then
    mkdir -p "$LEGACY_DIR"
    mv "$old" "$LEGACY_DIR/$(basename "$old")" 2>/dev/null || rm -f "$old"
  fi
done

# Force a clean rebuild of the exact-colour header after every upgrade.
rm -f "$CACHE_DIR/header-image.b64" "$CACHE_DIR/header-image.key" \
      "$CACHE_DIR/header-image.pdf" "$CACHE_DIR/header-spec.tsv" \
      "$CACHE_DIR"/header-image.pdf.tmp.* "$CACHE_DIR"/header-segments.tsv.tmp.* 2>/dev/null || true

# Remove caches from the former undocumented Claude OAuth implementation.
rm -f "$CACHE_DIR/claude-recovery.json" \
      "$HOME/.cache/claude-usage-barometer.tsv" 2>/dev/null || true

FIRST_HEADER="$(AI_USAGE_CACHE_DIR="$CACHE_DIR" "$TARGET" 2>/dev/null | head -n 1 || true)"
if [[ "$FIRST_HEADER" != *" image="* ]]; then
  echo "⚠ Exact-colour header is not available yet; SwiftBar will use a text fallback until usage data is available." >&2
fi

if [[ -r "$CLAUDE_DIR/settings.json" ]] && jq -e '.disableAllHooks == true' "$CLAUDE_DIR/settings.json" >/dev/null 2>&1; then
  echo "⚠ Claude Code disableAllHooks is true, so its status line cannot run." >&2
fi

if [[ "$TEST_MODE" != "1" && "${AI_USAGE_SKIP_APP_LAUNCH:-0}" != "1" ]]; then
  defaults write com.ameba.SwiftBar PluginDirectory "$PLUGIN_DIR" >/dev/null 2>&1 || true
  killall SwiftBar >/dev/null 2>&1 || true
  sleep 1
  open -a SwiftBar >/dev/null 2>&1 || open /Applications/SwiftBar.app >/dev/null 2>&1 || true
  sleep 1
  open -g "swiftbar://refreshallplugins" >/dev/null 2>&1 || true
fi

cat <<DONE

✅ Installed v$VERSION.

Menu-bar behaviour:
• Claude and Codex share one menu-bar item; service names appear only in the dropdown
• Every 5h/7d window is coloured independently
• Claude: #F2C6A0 → #EDA66F → #E88952
• Codex:  #BEEAF3 → #96DCE9 → #6BC9DC
• If Codex returns a real 300-minute window, its 5h bar appears automatically
• If one provider has no usable window, the other provider remains visible

If SwiftBar asks for its plugin folder, choose: $PLUGIN_DIR
DONE
