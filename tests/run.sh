#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || TMP_ROOT="/tmp"
TMP="$(mktemp -d "${TMP_ROOT%/}/ai-usage-tests.XXXXXX" 2>/dev/null || mktemp -d "/tmp/ai-usage-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/support" "$TMP/cache" "$TMP/home/.claude"

assert_spec_line() {
  local spec="$1" colour="$2" text="$3"
  grep -Fqx "$(printf '%s\t%s' "$colour" "$text")" "$spec"
}

run_plugin() {
  local cache="$1" claude_cache="$2"
  mkdir -p "$cache"
  AI_USAGE_SUPPORT_DIR="$TMP/support" \
  AI_USAGE_CACHE_DIR="$cache" \
  AI_USAGE_CLAUDE_STATUS_CACHE="$claude_cache" \
  AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" \
  AI_USAGE_HEADER_SPEC_DUMP="$cache/header-spec.tsv" \
  SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" \
  "$ROOT/ai-usage.60s.sh"
}

for script in \
  ai-usage.60s.sh claude-codex.60s.sh install.sh uninstall.sh claude-usage.sh codex-usage.sh \
  claude-statusline-capture.sh configure-claude-statusline.sh tests/colours.sh tests/run.sh; do
  bash -n "$ROOT/$script"
done

"$ROOT/tests/colours.sh"

# Official Claude Code statusLine capture, including transparent chaining of an
# existing user status line.
cat > "$TMP/original-statusline.sh" <<'ORIGINAL'
#!/usr/bin/env bash
input="$(cat)"
printf 'ORIGINAL:%s\n' "$(printf '%s' "$input" | jq -r '.model.display_name')"
ORIGINAL
chmod +x "$TMP/original-statusline.sh"
cat > "$TMP/home/.claude/ai-usage-barometer-statusline-backup.json" <<JSON
{"type":"command","command":"$TMP/original-statusline.sh","padding":2}
JSON
NOW="$(date +%s)"
RESET_5=$((NOW + 7200))
RESET_7=$((NOW + 259200))
cat > "$TMP/statusline-input.json" <<JSON
{
  "session_id":"session-test",
  "version":"2.1.90",
  "model":{"display_name":"Opus"},
  "rate_limits":{
    "five_hour":{"used_percentage":1,"resets_at":$RESET_5},
    "seven_day":{"used_percentage":97,"resets_at":$RESET_7}
  }
}
JSON
CAPTURE_CACHE="$TMP/cache/claude-statusline.json"
CAPTURE_OUT="$(HOME="$TMP/home" AI_USAGE_CACHE_DIR="$TMP/cache" AI_USAGE_CLAUDE_STATUS_CACHE="$CAPTURE_CACHE" AI_USAGE_CLAUDE_STATUSLINE_PATH="$TMP/home/.claude/ai-usage-barometer-statusline.sh" "$ROOT/claude-statusline-capture.sh" < "$TMP/statusline-input.json")"
[[ "$CAPTURE_OUT" == "ORIGINAL:Opus" ]]
jq -e '.source == "claude-code-statusline" and .five_hour.used_percentage == 1 and .seven_day.used_percentage == 97 and .five_hour_present == true and .seven_day_present == true' "$CAPTURE_CACHE" >/dev/null

# Inputs before the first API response have no rate_limits and must not erase the
# last valid official snapshot.
BEFORE_HASH="$(shasum -a 256 "$CAPTURE_CACHE" | awk '{print $1}')"
printf '{"model":{"display_name":"Opus"}}' | HOME="$TMP/home" AI_USAGE_CACHE_DIR="$TMP/cache" AI_USAGE_CLAUDE_STATUS_CACHE="$CAPTURE_CACHE" "$ROOT/claude-statusline-capture.sh" >/dev/null
AFTER_HASH="$(shasum -a 256 "$CAPTURE_CACHE" | awk '{print $1}')"
[[ "$BEFORE_HASH" == "$AFTER_HASH" ]]

# Settings integration preserves all existing settings and restores the exact
# previous statusLine object on uninstall.
CONFIG_HOME="$TMP/config-home"
mkdir -p "$CONFIG_HOME/.claude"
cp "$ROOT/claude-statusline-capture.sh" "$CONFIG_HOME/.claude/ai-usage-barometer-statusline.sh"
chmod +x "$CONFIG_HOME/.claude/ai-usage-barometer-statusline.sh"
cat > "$CONFIG_HOME/.claude/settings.json" <<JSON
{"theme":"dark","statusLine":{"type":"command","command":"$TMP/original-statusline.sh","padding":4,"refreshInterval":5}}
JSON
HOME="$CONFIG_HOME" "$ROOT/configure-claude-statusline.sh" install >/dev/null
jq -e --arg wrapper "$CONFIG_HOME/.claude/ai-usage-barometer-statusline.sh" '.theme == "dark" and .statusLine.command == $wrapper and .statusLine.padding == 4 and .statusLine.refreshInterval == 5' "$CONFIG_HOME/.claude/settings.json" >/dev/null
jq -e --arg original "$TMP/original-statusline.sh" '.command == $original and .padding == 4 and .refreshInterval == 5' "$CONFIG_HOME/.claude/ai-usage-barometer-statusline-backup.json" >/dev/null
HOME="$CONFIG_HOME" "$ROOT/configure-claude-statusline.sh" install >/dev/null
jq -e --arg original "$TMP/original-statusline.sh" '.command == $original' "$CONFIG_HOME/.claude/ai-usage-barometer-statusline-backup.json" >/dev/null
HOME="$CONFIG_HOME" "$ROOT/configure-claude-statusline.sh" uninstall >/dev/null
jq -e --arg original "$TMP/original-statusline.sh" '.theme == "dark" and .statusLine.command == $original and .statusLine.padding == 4 and .statusLine.refreshInterval == 5' "$CONFIG_HOME/.claude/settings.json" >/dev/null

# The Claude helper renders each official window independently and rolls a past
# reset locally to 0% used without inventing data before the reset.
CLAUDE_OUT="$(AI_USAGE_CLAUDE_STATUS_CACHE="$CAPTURE_CACHE" "$ROOT/claude-usage.sh")"
grep -q '^Claude 5h █████  7d ░░░░░$' <<< "$CLAUDE_OUT"
grep -q '^5h  ██████████  1% used$' <<< "$CLAUDE_OUT"
grep -q '^    99% left · resets in ' <<< "$CLAUDE_OUT"
grep -q '^7d  ░░░░░░░░░░  97% used$' <<< "$CLAUDE_OUT"
grep -q '^    3% left · resets in ' <<< "$CLAUDE_OUT"
grep -q 'official Claude Code rate_limits' <<< "$CLAUDE_OUT"

cat > "$TMP/cache/claude-seven-only.json" <<JSON
{"schema_version":2,"source":"claude-code-statusline","captured_at":$NOW,"five_hour_present":false,"seven_day_present":true,"five_hour":null,"seven_day":{"used_percentage":40,"resets_at":$RESET_7}}
JSON
SEVEN_ONLY="$(AI_USAGE_CLAUDE_STATUS_CACHE="$TMP/cache/claude-seven-only.json" "$ROOT/claude-usage.sh")"
[[ "$(head -n 1 <<< "$SEVEN_ONLY")" == 'Claude 7d ███░░' ]]
! grep -q '^5h ' <<< "$SEVEN_ONLY"

cat > "$TMP/cache/claude-past.json" <<JSON
{"schema_version":2,"source":"claude-code-statusline","captured_at":$NOW,"five_hour_present":true,"seven_day_present":false,"five_hour":{"used_percentage":100,"resets_at":1},"seven_day":null}
JSON
PAST_OUT="$(AI_USAGE_CLAUDE_STATUS_CACHE="$TMP/cache/claude-past.json" "$ROOT/claude-usage.sh")"
grep -q '^Claude 5h █████$' <<< "$PAST_OUT"
grep -q '^5h  ██████████  0% used$' <<< "$PAST_OUT"
grep -q '100% left · reset complete' <<< "$PAST_OUT"

WAIT_OUT="$(AI_USAGE_CLAUDE_STATUS_CACHE="$TMP/cache/missing.json" "$ROOT/claude-usage.sh")"
grep -q 'Waiting for official Claude Code usage data' <<< "$WAIT_OUT"
grep -q 'Open Claude Code and send one message' <<< "$WAIT_OUT"

# Unified menu bar: exact colours, independent Claude windows, no service names.
cp "$ROOT/claude-usage.sh" "$TMP/support/claude-usage.sh"
cp "$ROOT/tests/fixtures/codex-helper.sh" "$TMP/support/codex-usage.sh"
chmod +x "$TMP/support/"*.sh
OUT="$(run_plugin "$TMP/cache-plugin" "$CAPTURE_CACHE")"
FIRST="$(printf '%s\n' "$OUT" | head -n 1)"
SPEC="$TMP/cache-plugin/header-spec.tsv"
[[ "$FIRST" != *"Claude"* ]]
[[ "$FIRST" != *"Codex"* ]]
[[ "$FIRST" == *"image=VEVTVA=="* ]]
assert_spec_line "$SPEC" "#B54F02" "5h █████"
assert_spec_line "$SPEC" "#FF7045" "7d ░░░░░"
assert_spec_line "$SPEC" "#666666" "  │  "
assert_spec_line "$SPEC" "#4F7FA8" "7d ███░░"
grep -q '^5h  .*1% used.*color=#B54F02' <<< "$OUT"
grep -q '^7d  .*97% used.*color=#FF7045' <<< "$OUT"
grep -q '^Version v0.2.7' <<< "$OUT"

# No official Claude data: omit Claude from the macOS header while keeping its
# setup guidance inside the dropdown. Do not show a misleading warning gauge.
NO_CLAUDE="$(run_plugin "$TMP/cache-no-claude" "$TMP/cache/missing.json")"
NO_CLAUDE_SPEC="$TMP/cache-no-claude/header-spec.tsv"
! grep -q $'#B54F02\t' "$NO_CLAUDE_SPEC"
! grep -q $'#666666\t  │  ' "$NO_CLAUDE_SPEC"
assert_spec_line "$NO_CLAUDE_SPEC" "#4F7FA8" "7d ███░░"
grep -q 'Waiting for official Claude Code usage data' <<< "$NO_CLAUDE"

# Codex windows remain dynamic: the 5h bar appears as soon as the helper returns
# a 300-minute window and disappears when only the weekly window exists.
cat > "$TMP/support/codex-usage.sh" <<'CODEX'
#!/usr/bin/env bash
echo "Codex 5h ████░  7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "5h  ████████░░  20% used"
echo "7d  ██████░░░░  40% used"
echo "---"
CODEX
chmod +x "$TMP/support/codex-usage.sh"
BOTH="$(run_plugin "$TMP/cache-both" "$CAPTURE_CACHE")"
assert_spec_line "$TMP/cache-both/header-spec.tsv" "#4F7FA8" "5h ████░"
assert_spec_line "$TMP/cache-both/header-spec.tsv" "#4F7FA8" "7d ███░░"
grep -q '^5h  .*20% used.*color=#4F7FA8' <<< "$BOTH"

# Visibility settings still work.
env AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" "$ROOT/ai-usage.60s.sh" --toggle codex
TOGGLE="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" AI_USAGE_CLAUDE_STATUS_CACHE="$CAPTURE_CACHE" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$TMP/cache-toggle/header-spec.tsv" "$ROOT/ai-usage.60s.sh")"
! grep -Fqx "$(printf '%s\t%s' '#666666' '  │  ')" "$TMP/cache-toggle/header-spec.tsv"
! grep -q '^Codex |' <<< "$TOGGLE"

# The built-in exact-colour PDF renderer still works without Xcode tools.
cp "$ROOT/tests/fixtures/codex-helper.sh" "$TMP/support/codex-usage.sh"
PDF_CACHE="$TMP/cache-pdf"
mkdir -p "$PDF_CACHE"
PDF_OUT="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$PDF_CACHE" AI_USAGE_CLAUDE_STATUS_CACHE="$CAPTURE_CACHE" AI_USAGE_HEADER_PDF_DUMP="$PDF_CACHE/header.pdf" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
[[ "$(printf '%s\n' "$PDF_OUT" | head -n 1)" == *'image=JVBER'* ]]
[[ "$(head -c 4 "$PDF_CACHE/header.pdf")" == '%PDF' ]]
grep -a -q '/BaseFont /Helvetica' "$PDF_CACHE/header.pdf"
grep -a -q '0.7098 0.3098 0.0078 rg' "$PDF_CACHE/header.pdf"
grep -a -q '1.0000 0.4392 0.2706 rg' "$PDF_CACHE/header.pdf"
grep -a -q '0.3098 0.4980 0.6588 rg' "$PDF_CACHE/header.pdf"

# Privacy regression: the Claude implementation must not return to the old
# undocumented OAuth endpoint or read credentials/Keychain data.
! grep -R -E 'api/oauth/usage|Claude Code-credentials|\.credentials\.json|security find-generic-password' \
  "$ROOT/ai-usage.60s.sh" "$ROOT/claude-usage.sh" "$ROOT/claude-statusline-capture.sh" "$ROOT/install.sh"
grep -q 'rate_limits' "$ROOT/claude-statusline-capture.sh"
grep -q 'rate_limits' "$ROOT/claude-usage.sh"

# Installer migration test, including preservation/restoration of an existing
# Claude Code status line. Test mode skips Homebrew, SwiftBar and app launching.
INSTALL_HOME="$TMP/install-home"
mkdir -p "$INSTALL_HOME/.claude"
cat > "$INSTALL_HOME/.claude/settings.json" <<JSON
{"statusLine":{"type":"command","command":"$TMP/original-statusline.sh","padding":3},"theme":"dark"}
JSON
HOME="$INSTALL_HOME" \
AI_USAGE_TEST_MODE=1 AI_USAGE_LOCAL_SOURCE="$ROOT" \
SWIFTBAR_PLUGIN_DIR="$INSTALL_HOME/SwiftBar" \
  "$ROOT/install.sh" >/dev/null
[[ -x "$INSTALL_HOME/SwiftBar/ai-usage.60s.sh" ]]
[[ -x "$INSTALL_HOME/SwiftBar/.ai-usage-barometer/claude-usage.sh" ]]
[[ -x "$INSTALL_HOME/SwiftBar/.ai-usage-barometer/codex-usage.sh" ]]
[[ -x "$INSTALL_HOME/.claude/ai-usage-barometer-statusline.sh" ]]
! grep -q ';;&' "$INSTALL_HOME/SwiftBar/.ai-usage-barometer/codex-usage.sh"
jq -e --arg wrapper "$INSTALL_HOME/.claude/ai-usage-barometer-statusline.sh" '.theme == "dark" and .statusLine.command == $wrapper and .statusLine.padding == 3' "$INSTALL_HOME/.claude/settings.json" >/dev/null
HOME="$INSTALL_HOME" AI_USAGE_TEST_MODE=1 SWIFTBAR_PLUGIN_DIR="$INSTALL_HOME/SwiftBar" "$ROOT/uninstall.sh" >/dev/null
jq -e --arg original "$TMP/original-statusline.sh" '.theme == "dark" and .statusLine.command == $original and .statusLine.padding == 3' "$INSTALL_HOME/.claude/settings.json" >/dev/null

# Bundled Codex helper must remain compatible with macOS system Bash 3.2.
! grep -q ';;&' "$ROOT/codex-usage.sh"
! grep -q ';&' "$ROOT/codex-usage.sh"
grep -q 'https://chatgpt.com/backend-api/wham/usage' "$ROOT/codex-usage.sh"

# Documentation: one-line installer first, official source/migration explained in
# every supported language, and no claim that Warming up is fabricated as 100%.
READMES=(
  README.md README.ja.md README.es.md README.ar.md README.fr.md README.de.md
  README.zh.md README.ko.md README.pt.md README.nl.md README.it.md README.vi.md
  README.id.md README.th.md
)
for readme in "${READMES[@]}"; do
  [[ -f "$ROOT/$readme" ]]
  grep -q 'raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh' "$ROOT/$readme"
  grep -q 'rate_limits' "$ROOT/$readme"
  grep -q 'v0.2.7' "$ROOT/$readme"
  grep -q '300' "$ROOT/$readme"
  ! grep -q 'Warming up.*100% left' "$ROOT/$readme"
done

echo "All tests passed."
