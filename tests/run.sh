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
  local cache="$1"
  mkdir -p "$cache"
  AI_USAGE_SUPPORT_DIR="$TMP/support" \
  AI_USAGE_CACHE_DIR="$cache" \
  AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" \
  AI_USAGE_HEADER_SPEC_DUMP="$cache/header-spec.tsv" \
  SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" \
  "$ROOT/ai-usage.60s.sh"
}

assert_spec_line() {
  local spec="$1" colour="$2" text="$3"
  grep -Fqx "$(printf '%s\t%s' "$colour" "$text")" "$spec"
}

bash -n "$ROOT/ai-usage.60s.sh"
bash -n "$ROOT/install.sh"
bash -n "$ROOT/uninstall.sh"

OUT="$(run_plugin "$TMP/cache")"
FIRST="$(printf '%s\n' "$OUT" | head -n 1)"
SPEC="$TMP/cache/header-spec.tsv"
[[ "$FIRST" != *"Claude"* ]]
[[ "$FIRST" != *"Codex"* ]]
[[ "$FIRST" == *"image=VEVTVA=="* ]]
[[ "$FIRST" == *"dropdown=false"* ]]
[[ "$FIRST" != *"ansi=true"* ]]
[[ "$FIRST" != *$'\033['* ]]

# Exact macOS menu-bar colours, independently selected for every window.
assert_spec_line "$SPEC" "#B54F02" "5h █████"
assert_spec_line "$SPEC" "#FF7045" "7d ░░░░░"
assert_spec_line "$SPEC" "#666666" "  │  "
assert_spec_line "$SPEC" "#4F7FA8" "7d ███░░"

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
SPEC_STAGE="$TMP/cache-stage/header-spec.tsv"
assert_spec_line "$SPEC_STAGE" "#B85A00" "5h ██░░░"
assert_spec_line "$SPEC_STAGE" "#B54F02" "7d ████░"
assert_spec_line "$SPEC_STAGE" "#0E8BA1" "5h ██░░░"
assert_spec_line "$SPEC_STAGE" "#ED5D40" "7d ░░░░░"
grep -q '^5h  .*25% left.*color=#B85A00' <<< "$OUT_STAGE"
grep -q '^7d  .*80% left.*color=#B54F02' <<< "$OUT_STAGE"
grep -q '^5h  .*75% used.*color=#0E8BA1' <<< "$OUT_STAGE"
grep -q '^7d  .*95% used.*color=#ED5D40' <<< "$OUT_STAGE"

# Visibility settings still work.
env AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" "$ROOT/ai-usage.60s.sh" --toggle codex
OUT2="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache-toggle" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$TMP/cache-toggle/header-spec.tsv" "$ROOT/ai-usage.60s.sh")"
FIRST2="$(printf '%s\n' "$OUT2" | head -n 1)"
[[ "$FIRST2" == *"image=VEVTVA=="* ]]
! grep -Fqx "$(printf '%s\t%s' '#666666' '  │  ')" "$TMP/cache-toggle/header-spec.tsv"
! grep -q '^Codex |' <<< "$OUT2"

# Regression: the screenshot scenario must never give Claude 5h and 7d the same colour.
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
SPEC_REGRESSION="$TMP/cache-regression/header-spec.tsv"
assert_spec_line "$SPEC_REGRESSION" "#B54F02" "5h █████"
assert_spec_line "$SPEC_REGRESSION" "#FF7045" "7d ░░░░░"
! assert_spec_line "$SPEC_REGRESSION" "#FF7045" "5h █████"
grep -q '^5h  .*99% left.*color=#B54F02' <<< "$OUT_REGRESSION"
grep -q '^7d  .*3% left.*color=#FF7045' <<< "$OUT_REGRESSION"
grep -q '^Version v0.2.0' <<< "$OUT_REGRESSION"

# True-colour ANSI caused the black/green regression; it must never return.
! grep -q '38;2;' "$ROOT/ai-usage.60s.sh"
! grep -q 'ansi=true' "$ROOT/ai-usage.60s.sh"
! grep -q 'swiftc' "$ROOT/ai-usage.60s.sh"
! grep -q 'xcrun' "$ROOT/ai-usage.60s.sh"
grep -q '%%PDF-1.4' "$ROOT/ai-usage.60s.sh"
grep -q 'image=%s dropdown=false' "$ROOT/ai-usage.60s.sh"

# The real renderer must work without Xcode Command Line Tools and emit a valid PDF image.
cp "$ROOT/tests/fixtures/claude-helper.sh" "$TMP/support/claude-usage.sh"
cp "$ROOT/tests/fixtures/codex-helper.sh" "$TMP/support/codex-usage.sh"
chmod +x "$TMP/support/"*.sh
PDF_CACHE="$TMP/cache-pdf"
mkdir -p "$PDF_CACHE"
PDF_OUT="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$PDF_CACHE" AI_USAGE_HEADER_PDF_DUMP="$PDF_CACHE/header.pdf" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
PDF_FIRST="$(printf '%s\n' "$PDF_OUT" | head -n 1)"
[[ "$PDF_FIRST" == *'image=JVBER'* ]]
[[ "$(head -c 4 "$PDF_CACHE/header.pdf")" == '%PDF' ]]
grep -a -q '/BaseFont /Helvetica' "$PDF_CACHE/header.pdf"
grep -a -q '0.7098 0.3098 0.0078 rg' "$PDF_CACHE/header.pdf"
grep -a -q '1.0000 0.4392 0.2706 rg' "$PDF_CACHE/header.pdf"
grep -a -q '0.3098 0.4980 0.6588 rg' "$PDF_CACHE/header.pdf"

# Claude reset recovery: when the helper says "Warming up" after a quota reset,
# a successful API response with null windows means the windows are idle/reset,
# not a permanent error. Both gauges must return at 100% left.
cat > "$TMP/support/claude-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "! | color=#ff7045"
echo "---"
echo "Warming up"
echo "..."
echo "Refresh now"
HELPER
cat > "$TMP/claude-idle.json" <<'JSON'
{"five_hour":null,"seven_day":null,"extra_usage":{"is_enabled":false}}
JSON
cat > "$TMP/support/codex-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Codex 7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "7d  ██████░░░░  40% used"
echo "    40% used · 60% left"
echo "    Resets in 6d 1h"
echo "---"
HELPER
chmod +x "$TMP/support/"*.sh
RECOVERY_CACHE="$TMP/cache-recovery"
mkdir -p "$RECOVERY_CACHE"
OUT_RECOVERY="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$RECOVERY_CACHE" AI_USAGE_CLAUDE_USAGE_FIXTURE="$TMP/claude-idle.json" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$RECOVERY_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
SPEC_RECOVERY="$RECOVERY_CACHE/header-spec.tsv"
assert_spec_line "$SPEC_RECOVERY" "#B54F02" "5h █████"
assert_spec_line "$SPEC_RECOVERY" "#B54F02" "7d █████"
! grep -q 'Warming up' <<< "$OUT_RECOVERY"
! grep -q '^! ' <<< "$OUT_RECOVERY"
grep -q '^5h  .*100% left.*color=#B54F02' <<< "$OUT_RECOVERY"
grep -q '^7d  .*100% left.*color=#B54F02' <<< "$OUT_RECOVERY"
grep -q 'reset complete · starts on next use' <<< "$OUT_RECOVERY"

# Even when the live endpoint is temporarily unavailable, the helper's explicit
# Warming up state must recover locally instead of remaining as an exclamation mark.
LOCAL_IDLE_CACHE="$TMP/cache-local-idle"
mkdir -p "$LOCAL_IDLE_CACHE"
OUT_LOCAL_IDLE="$(HOME="$TMP/no-credentials-home" AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$LOCAL_IDLE_CACHE" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$LOCAL_IDLE_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
assert_spec_line "$LOCAL_IDLE_CACHE/header-spec.tsv" "#B54F02" "5h █████"
assert_spec_line "$LOCAL_IDLE_CACHE/header-spec.tsv" "#B54F02" "7d █████"
! grep -q 'Warming up' <<< "$OUT_LOCAL_IDLE"
! grep -q '^! ' <<< "$OUT_LOCAL_IDLE"

# Numeric zero must be treated as valid data, not as missing data.
cat > "$TMP/claude-zero.json" <<'JSON'
{
  "five_hour":{"utilization":0,"resets_at":"2099-01-01T01:00:00+00:00"},
  "seven_day":{"utilization":0,"resets_at":"2099-01-07T01:00:00+00:00"}
}
JSON
ZERO_CACHE="$TMP/cache-zero"
mkdir -p "$ZERO_CACHE"
OUT_ZERO="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$ZERO_CACHE" AI_USAGE_CLAUDE_USAGE_FIXTURE="$TMP/claude-zero.json" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$ZERO_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
grep -q '^5h  .*100% left.*color=#B54F02' <<< "$OUT_ZERO"
grep -q '^7d  .*100% left.*color=#B54F02' <<< "$OUT_ZERO"
! grep -q 'Warming up' <<< "$OUT_ZERO"

# A stale pre-reset snapshot must roll locally to 0% used once its reset time is past.
cat > "$TMP/claude-past-reset.json" <<'JSON'
{
  "five_hour":{"utilization":100,"resets_at":"2020-01-01T00:00:00+00:00"},
  "seven_day":{"utilization":100,"resets_at":"2020-01-01T00:00:00+00:00"}
}
JSON
PAST_CACHE="$TMP/cache-past"
mkdir -p "$PAST_CACHE"
OUT_PAST="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$PAST_CACHE" AI_USAGE_CLAUDE_USAGE_FIXTURE="$TMP/claude-past-reset.json" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$PAST_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
grep -q '^5h  .*100% left.*color=#B54F02' <<< "$OUT_PAST"
grep -q '^7d  .*100% left.*color=#B54F02' <<< "$OUT_PAST"

# Codex windows are dynamic. Weekly-only output must show one bar; when a
# 300-minute window returns later, the 5h bar must appear automatically.
cat > "$TMP/support/claude-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Claude 5h █████  7d █████"
echo "---"
echo "5h  ██████████  100% left"
echo "7d  ██████████  100% left"
echo "---"
HELPER
cat > "$TMP/support/codex-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Codex 7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "7d  ██████░░░░  40% used"
echo "---"
HELPER
chmod +x "$TMP/support/"*.sh
WEEKLY_CACHE="$TMP/cache-codex-weekly"
mkdir -p "$WEEKLY_CACHE"
OUT_WEEKLY="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$WEEKLY_CACHE" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$WEEKLY_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
assert_spec_line "$WEEKLY_CACHE/header-spec.tsv" "#4F7FA8" "7d ███░░"
! grep -Fqx "$(printf '%s\t%s' '#4F7FA8' '5h ████░')" "$WEEKLY_CACHE/header-spec.tsv"

cat > "$TMP/support/codex-usage.sh" <<'HELPER'
#!/usr/bin/env bash
echo "Codex 5h ████░  7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "5h  ████████░░  20% used"
echo "7d  ██████░░░░  40% used"
echo "---"
HELPER
chmod +x "$TMP/support/codex-usage.sh"
BOTH_CACHE="$TMP/cache-codex-both"
mkdir -p "$BOTH_CACHE"
OUT_BOTH="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$BOTH_CACHE" AI_USAGE_HEADER_IMAGE_B64="VEVTVA==" AI_USAGE_HEADER_SPEC_DUMP="$BOTH_CACHE/header-spec.tsv" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
assert_spec_line "$BOTH_CACHE/header-spec.tsv" "#4F7FA8" "5h ████░"
assert_spec_line "$BOTH_CACHE/header-spec.tsv" "#4F7FA8" "7d ███░░"
grep -q '^5h  .*20% used.*color=#4F7FA8' <<< "$OUT_BOTH"
grep -q '^7d  .*40% used.*color=#4F7FA8' <<< "$OUT_BOTH"

# Documentation regression: every supported language must explain both v0.2.0 fixes
# and keep the one-line installer at the top.
READMES=(
  README.md README.ja.md README.es.md README.ar.md README.fr.md README.de.md
  README.zh.md README.ko.md README.pt.md README.nl.md README.it.md README.vi.md
  README.id.md README.th.md
)
for readme in "${READMES[@]}"; do
  [[ -f "$ROOT/$readme" ]]
  grep -q 'raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh' "$ROOT/$readme"
  grep -q 'Warming up' "$ROOT/$readme"
  grep -q '300' "$ROOT/$readme"
  grep -q 'v0.2.0' "$ROOT/$readme"
done

# Localised READMEs must not retain the old English placeholder paragraphs.
for readme in "${READMES[@]:1}"; do
  ! grep -q '^The dropdown keeps the service names' "$ROOT/$readme"
  ! grep -q '^Authentication tokens are never printed' "$ROOT/$readme"
done

echo "All tests passed."
