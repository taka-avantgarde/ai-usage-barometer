#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || TMP_ROOT="/tmp"
TMP="$(mktemp -d "${TMP_ROOT%/}/ai-usage-tests.XXXXXX" 2>/dev/null || mktemp -d "/tmp/ai-usage-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/support" "$TMP/cache"
cp "$ROOT/tests/fixtures/claude-helper.sh" "$TMP/support/claude-usage.sh"
cp "$ROOT/tests/fixtures/codex-helper.sh" "$TMP/support/codex-usage.sh"
chmod +x "$TMP/support/"*.sh

run_plugin() {
  AI_USAGE_SUPPORT_DIR="$TMP/support" \
  AI_USAGE_CACHE_DIR="$1" \
  SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" \
  "$ROOT/ai-usage.60s.sh"
}

OUT="$(run_plugin "$TMP/cache")"
FIRST="$(printf '%s\n' "$OUT" | head -n 1)"
[[ "$FIRST" != *"Claude"* ]]
[[ "$FIRST" != *"Codex"* ]]
[[ "$FIRST" == *"ansi=true"* ]]
[[ "$FIRST" == *"symbolize=false"* ]]

# Claude 5h is healthy (1% used): stage 1 #b54f02.
[[ "$FIRST" == *$'\033[38;2;181;79;2m5h █████\033[0m'* ]]
# Claude 7d is critical (97% used): stage 3 #ff7045.
[[ "$FIRST" == *$'\033[38;2;255;112;69m7d ░░░░░\033[0m'* ]]
# Codex 7d is healthy (40% used): current stage 1 blue #4F7FA8.
[[ "$FIRST" == *$'\033[38;2;79;127;168m7d ███░░\033[0m'* ]]

grep -q '^Claude | color=#B54F02' <<< "$OUT"
grep -q '^5h  .*99% left.*color=#B54F02' <<< "$OUT"
grep -q '^7d  .*3% left.*color=#FF7045' <<< "$OUT"
grep -q '^Codex | color=#4F7FA8' <<< "$OUT"
grep -q '^7d  .*40% used.*color=#4F7FA8' <<< "$OUT"
grep -q '^    40% used · 60% left$' <<< "$OUT"
grep -q '^    Resets in 6d 1h' <<< "$OUT"

# Stage 2 must also be applied per window, not per provider.
cat > "$TMP/support/claude-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "5h ██░░░  7d ████░"
echo "---"
echo "5h  ███░░░░░░░  25% left"
echo "7d  ████████░░  80% left"
echo "---"
HELPER
cat > "$TMP/support/codex-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Codex 5h ██░░░  7d ░░░░░"
echo "---"
echo "Codex usage"
echo "---"
echo "5h  ███░░░░░░░  75% used"
echo "7d  ░░░░░░░░░░  95% used"
echo "---"
HELPER
chmod +x "$TMP/support/"*.sh
OUT_STAGE="$(run_plugin "$TMP/cache-stage")"
FIRST_STAGE="$(printf '%s\n' "$OUT_STAGE" | head -n 1)"
[[ "$FIRST_STAGE" == *$'\033[38;2;184;90;0m5h ██░░░\033[0m'* ]]
[[ "$FIRST_STAGE" == *$'\033[38;2;181;79;2m7d ████░\033[0m'* ]]
[[ "$FIRST_STAGE" == *$'\033[38;2;14;139;161m5h ██░░░\033[0m'* ]]
[[ "$FIRST_STAGE" == *$'\033[38;2;237;93;64m7d ░░░░░\033[0m'* ]]
grep -q '^5h  .*25% left.*color=#B85A00' <<< "$OUT_STAGE"
grep -q '^7d  .*80% left.*color=#B54F02' <<< "$OUT_STAGE"
grep -q '^5h  .*75% used.*color=#0E8BA1' <<< "$OUT_STAGE"
grep -q '^7d  .*95% used.*color=#ED5D40' <<< "$OUT_STAGE"

# Visibility settings still work.
env AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" "$ROOT/ai-usage.60s.sh" --toggle codex
OUT2="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" "$ROOT/ai-usage.60s.sh")"
FIRST2="$(printf '%s\n' "$OUT2" | head -n 1)"
[[ "$FIRST2" == *"5h"* ]]
[[ "$FIRST2" != *"│"* ]]
! grep -q '^Codex |' <<< "$OUT2"

# Regression: screenshot scenario must never give Claude 5h and 7d the same colour.
cat > "$TMP/support/claude-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Claude 5h █████  7d ░░░░░"
echo "---"
echo "5h  ██████████  99% left"
echo "resets in soon"
echo "7d  ░░░░░░░░░░  3% left"
echo "resets in 7h 43m"
echo "---"
HELPER
chmod +x "$TMP/support/claude-usage.sh"
OUT_REGRESSION="$(run_plugin "$TMP/cache-regression")"
FIRST_REGRESSION="$(printf '%s\n' "$OUT_REGRESSION" | head -n 1)"
[[ "$FIRST_REGRESSION" == *$'\033[38;2;181;79;2m5h █████\033[0m'* ]]
[[ "$FIRST_REGRESSION" == *$'\033[38;2;255;112;69m7d ░░░░░\033[0m'* ]]
[[ "$FIRST_REGRESSION" != *$'\033[38;2;255;112;69m5h █████\033[0m'* ]]
grep -q '^5h  .*99% left.*color=#B54F02' <<< "$OUT_REGRESSION"
grep -q '^7d  .*3% left.*color=#FF7045' <<< "$OUT_REGRESSION"
grep -q '^Version v0.1.6' <<< "$OUT_REGRESSION"

echo "All tests passed."
