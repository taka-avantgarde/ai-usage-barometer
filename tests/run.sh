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
grep -q '^Version v0.1.9' <<< "$OUT_REGRESSION"

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

echo "All tests passed."
