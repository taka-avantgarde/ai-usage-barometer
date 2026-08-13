#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || TMP_ROOT="/tmp"
TMP="$(mktemp -d "${TMP_ROOT%/}/ai-usage-colours.XXXXXX" 2>/dev/null || mktemp -d "/tmp/ai-usage-colours.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# The active v0.3 palette keeps orange and cyan service identities, adds orange
# to warning, and adds vivid red to critical. Lock rendering and documentation.
grep -q 'CL_OK="#C66D28"; CL_WARN="#B65A1E"; CL_DANGER="#C52E22"' "$ROOT/claude-codex.60s.sh"
grep -q 'CX_OK="#1A8BA6"; CX_WARN="#52768A"; CX_DANGER="#783F78"' "$ROOT/claude-codex.60s.sh"

for doc in "$ROOT"/README*.md "$ROOT/DESIGN.md"; do
  for colour in C66D28 B65A1E C52E22 1A8BA6 52768A 783F78; do
    grep -q "#$colour" "$doc"
  done
done

for entry in \
  claude-healthy:C66D28 claude-warning:B65A1E claude-critical:C52E22 \
  codex-healthy:1A8BA6 codex-warning:52768A codex-critical:783F78; do
  swatch="${entry%%:*}"
  colour="${entry#*:}"
  grep -q "fill=\"#$colour\"" "$ROOT/assets/colors/$swatch.svg"
  for readme in "$ROOT"/README*.md; do
    grep -q "assets/colors/$swatch.svg" "$readme"
  done
done

for colour in C66D28 B65A1E C52E22 1A8BA6 52768A 783F78; do
  grep -q "#$colour" "$ROOT/install.sh"
done
grep -q 'Claude uses orange' "$ROOT/README.md"
grep -q 'Codex uses cyan' "$ROOT/README.md"
# Two-colour rendering is no longer a user setting. Legacy mb2 state must not
# disable the vector renderer or reappear in the settings menu.
! grep -Eq '\b(MB2|mb2|T_MB2)\b' "$ROOT/claude-codex.60s.sh"

# Exercise the active renderer with healthy, warning and critical Claude bars,
# plus a healthy Codex bar, without reading real credentials or calling APIs.
mkdir -p "$TMP/home/.cache/claude-codex-bar"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/mb2"
printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.10 0.95 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"

grep -q '^5h  .*color=#C66D28$' <<< "$OUT"
grep -q '^7d  .*color=#C52E22$' <<< "$OUT"
grep -q '^7d  .*color=#1A8BA6$' <<< "$OUT"
! grep -q 'Two-colour menu bar' <<< "$OUT"

IMAGE="$(head -n 1 <<< "$OUT" | sed -nE 's/.*image=([^ ]+).*/\1/p')"
[[ -n "$IMAGE" ]]
python3 - "$IMAGE" <<'PY'
import base64
import sys

pdf = base64.b64decode(sys.argv[1]).decode("latin-1")
for operation in (
    "0.1255 0.1451 0.1686 rg 0.5 1.0",  # dark charcoal backdrop: #20252B
    "0.92 0.94 0.96 rg",                  # light labels on the backdrop
    "0.7765 0.4275 0.1569 rg",  # Claude healthy: #C66D28
    "0.7725 0.1804 0.1333 rg",  # Claude critical: #C52E22
    "0.1020 0.5451 0.6510 rg",  # Codex healthy: #1A8BA6
):
    assert operation in pdf, operation
PY

printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.75 0.75 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
WARN_OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^5h  .*color=#B65A1E$' <<< "$WARN_OUT"

# Codex crosses to orange warning at 70% used (30% remaining), then vivid-red
# critical at 90% used (10% remaining).
cat > "$TMP/codex-stage.sh" <<'CODEX'
#!/usr/bin/env bash
echo "Codex 7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "7d  ██████░░░░  ${CODEX_USED}% used"
echo "---"
CODEX
chmod +x "$TMP/codex-stage.sh"
CODEX_WARNING="$(HOME="$TMP/home" CODEX_USED=70 CODEX_HELPER="$TMP/codex-stage.sh" "$ROOT/claude-codex.60s.sh")"
CODEX_CRITICAL="$(HOME="$TMP/home" CODEX_USED=90 CODEX_HELPER="$TMP/codex-stage.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^7d  .*color=#52768A$' <<< "$CODEX_WARNING"
grep -q '^7d  .*color=#783F78$' <<< "$CODEX_CRITICAL"

# Turning a service off skips its helper/API work while keeping child settings
# visible as non-interactive, muted rows. Existing child values are preserved.
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"
cat > "$TMP/should-not-run.sh" <<'STOP'
#!/usr/bin/env bash
echo "Codex helper must not run when Codex is disabled" >&2
exit 99
STOP
chmod +x "$TMP/should-not-run.sh"
DISABLED_OUT="$(HOME="$TMP/home" CODEX_HELPER="$TMP/should-not-run.sh" "$ROOT/claude-codex.60s.sh")"
grep -q -- '--Codex percentage | color=#666666$' <<< "$DISABLED_OUT"
! grep -A1 -- '--Codex percentage | color=#666666$' <<< "$DISABLED_OUT" | grep -q 'shell='
! grep -q 'must not run' <<< "$DISABLED_OUT"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"

# A disabled Claude service uses the same muted, locked child rows.
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"
DISABLED_CLAUDE="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q -- '--Show Claude 5h | color=#666666$' <<< "$DISABLED_CLAUDE"
grep -q -- '--Show Claude 7d | color=#666666$' <<< "$DISABLED_CLAUDE"
grep -q -- '--Claude 5h percentage | color=#666666$' <<< "$DISABLED_CLAUDE"
! grep -A1 -- '--Show Claude 5h | color=#666666$' <<< "$DISABLED_CLAUDE" | grep -q 'shell='
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"

# Small menu-bar marks need enough contrast against the common light-gray
# translucent macOS background. Keep even the healthy stages near 3:1.
python3 - <<'PY'
def luminance(value):
    channels = []
    for offset in (1, 3, 5):
        channel = int(value[offset:offset + 2], 16) / 255
        channels.append(channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4)
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]

background = luminance("#E6E6E6")
for colour in ("#C66D28", "#B65A1E", "#C52E22", "#1A8BA6", "#52768A", "#783F78"):
    foreground = luminance(colour)
    contrast = (max(background, foreground) + 0.05) / (min(background, foreground) + 0.05)
    assert contrast >= 2.95, (colour, contrast)
PY

echo "Colour tests passed."
