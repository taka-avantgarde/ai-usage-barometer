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
for doc in "$ROOT"/README*.md; do
  grep -Eqi 'persistent settings panel|開いたまま|permanece abierto|تبقى .*مفتوحة|reste ouvert|bleibt geöffnet|保持打开|열린 상태|permanece aberto|blijft open|resta aperto|vẫn mở|tetap terbuka|เปิดค้างไว้' "$doc"
  grep -q '\*\*⚙ Display settings\*\*' "$doc"
  grep -q 'Codex 5h' "$doc"
  grep -q 'Codex 7d' "$doc"
  grep -q 'GitHub Releases' "$doc"
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

# Turning a service off skips its helper/API work. Display settings are supplied
# by a persistent web view whose child controls are muted and disabled in place.
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"
cat > "$TMP/should-not-run.sh" <<'STOP'
#!/usr/bin/env bash
printf 'ran\n' > "$HOME/codex-helper-ran"
echo "Codex helper must not run when Codex is disabled" >&2
exit 99
STOP
chmod +x "$TMP/should-not-run.sh"
rm -f "$TMP/home/codex-helper-ran"
DISABLED_OUT="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" "$ROOT/claude-codex.60s.sh")"
grep -q 'webview=true' <<< "$DISABLED_OUT"
grep -q 'codex_on=0' <<< "$DISABLED_OUT"
! grep -q 'must not run' <<< "$DISABLED_OUT"
[[ ! -e "$TMP/home/codex-helper-ran" ]]
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"

# The web page provides visible gray locked rows for disabled services.
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"
DISABLED_CLAUDE="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q 'claude_on=0' <<< "$DISABLED_CLAUDE"
grep -q 'label.muted' "$ROOT/settings.html"
grep -q "label.classList.toggle('muted', !on)" "$ROOT/settings.html"
grep -q "label.querySelector('input').disabled = !on" "$ROOT/settings.html"
grep -q 'swiftbar.persistentWebView' "$ROOT/claude-codex.60s.sh"
for key in cx5 cx5p cx7 cx7p; do
  grep -q "id=\"$key\"" "$ROOT/settings.html"
done

# The plugin UI is English-only. A legacy saved language must be ignored, the
# settings page has no selector, and the settings URL carries no locale state.
printf 'ja\n' > "$TMP/home/.cache/claude-codex-bar/lang"
ENGLISH_ONLY="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q 'Display settings' <<< "$ENGLISH_ONLY"
! grep -q '表示設定' <<< "$ENGLISH_ONLY"
! grep -Eq '[?&]lang=' <<< "$ENGLISH_ONLY"
! grep -q 'id="lang"' "$ROOT/settings.html"
! grep -q 'data-i18n' "$ROOT/settings.html"
! grep -q 'AppleLocale' "$ROOT/claude-codex.60s.sh"
! grep -q 'CFG/lang' "$ROOT/claude-codex.60s.sh"

# A provider with every usage window unchecked is fully hidden: do not query
# it and do not leave a provider heading or a stale/API error in the dropdown.
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/c5"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/c7"
NO_CLAUDE_WINDOWS="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
! grep -q '^Claude |' <<< "$NO_CLAUDE_WINDOWS"
! grep -q 'HTTP 429' <<< "$NO_CLAUDE_WINDOWS"
! grep -q 'Credentials not found' <<< "$NO_CLAUDE_WINDOWS"

printf '1\n' > "$TMP/home/.cache/claude-codex-bar/c5"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/cx5"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/cx7"
rm -f "$TMP/home/codex-helper-ran"
NO_CODEX_WINDOWS="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" "$ROOT/claude-codex.60s.sh")"
! grep -q '^Codex |' <<< "$NO_CODEX_WINDOWS"
! grep -q 'must not run' <<< "$NO_CODEX_WINDOWS"
[[ ! -e "$TMP/home/codex-helper-ran" ]]
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/c7"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/cx5"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/cx7"

# Codex 5h/7d windows and their percentages are independently selectable.
cat > "$TMP/codex-two-windows.sh" <<'CODEX'
#!/usr/bin/env bash
echo "Codex 5h ████░  7d ███░░"
echo "---"
echo "Codex usage"
echo "---"
echo "5h  ████████░░  20% used"
echo "7d  ██████░░░░  40% used"
echo "---"
CODEX
chmod +x "$TMP/codex-two-windows.sh"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/cx5"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/cx7"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/cx7p"
CODEX_WINDOWS="$(HOME="$TMP/home" CODEX_HELPER="$TMP/codex-two-windows.sh" "$ROOT/claude-codex.60s.sh")"
! grep -q '^5h  .*color=#1A8BA6' <<< "$CODEX_WINDOWS"
grep -q '^7d  .*color=#1A8BA6' <<< "$CODEX_WINDOWS"
! grep -q '^7d  .*left' <<< "$CODEX_WINDOWS"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/cx5"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/cx7p"

# A fresh cached release avoids network access while exercising both update
# notices and the settings-page version parameter.
printf 'v9.9.9\n' > "$TMP/home/.cache/claude-codex-bar/latest_release"
UPDATE_OUT="$(HOME="$TMP/home" AI_USAGE_UPDATE_CHECK=1 AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^⬆ Update v9.9.9 available' <<< "$UPDATE_OUT"
grep -q 'update=v9.9.9' <<< "$UPDATE_OUT"
grep -q "id=\"install-update\"" "$ROOT/settings.html"
grep -q 'AUB_ACTION=update' "$ROOT/settings.html"

# Disabling both services must not silently re-enable Claude. The header remains
# clickable through the neutral fallback while every child row stays muted.
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"
printf '0\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"
BOTH_DISABLED="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^AI … |' <<< "$BOTH_DISABLED"
grep -q 'claude_on=0' <<< "$BOTH_DISABLED"
grep -q 'codex_on=0' <<< "$BOTH_DISABLED"
! grep -q '^Claude |' <<< "$BOTH_DISABLED"
! grep -q '^Codex |' <<< "$BOTH_DISABLED"

# URL-scheme parameters are validated before writing and are reflected in the
# same plugin invocation. Invalid keys and values must not create files.
WEB_ACTION="$(HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" AUB_KEY=codex_on AUB_VALUE=1 "$ROOT/claude-codex.60s.sh")"
grep -q 'codex_on=1' <<< "$WEB_ACTION"
[[ "$(cat "$TMP/home/.cache/claude-codex-bar/codex_on")" == 1 ]]
HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" AUB_KEY=codex_on AUB_VALUE=bad "$ROOT/claude-codex.60s.sh" >/dev/null
[[ "$(cat "$TMP/home/.cache/claude-codex-bar/codex_on")" == 1 ]]
HOME="$TMP/home" AI_USAGE_SETTINGS_PAGE="$ROOT/settings.html" CODEX_HELPER="$TMP/should-not-run.sh" AUB_KEY=unexpected AUB_VALUE=1 "$ROOT/claude-codex.60s.sh" >/dev/null
[[ ! -e "$TMP/home/.cache/claude-codex-bar/unexpected" ]]
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/claude_on"
printf '1\n' > "$TMP/home/.cache/claude-codex-bar/codex_on"

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
