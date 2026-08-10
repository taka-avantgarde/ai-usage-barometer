#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || TMP_ROOT="/tmp"
TMP="$(mktemp -d "${TMP_ROOT%/}/ai-usage-colours.XXXXXX" 2>/dev/null || mktemp -d "/tmp/ai-usage-colours.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# The active v0.3 palette uses bright white-orange for Claude and a 20% white
# blend for Codex. Lock all stages so the renderer, docs and installer agree.
grep -q 'CL_OK="#F2C6A0"; CL_WARN="#EDA66F"; CL_DANGER="#E88952"' "$ROOT/claude-codex.60s.sh"
grep -q 'CX_OK="#7299B9"; CX_WARN="#3EA2B4"; CX_DANGER="#F17D66"' "$ROOT/claude-codex.60s.sh"

for doc in "$ROOT"/README*.md "$ROOT/DESIGN.md"; do
  for colour in F2C6A0 EDA66F E88952 7299B9 3EA2B4 F17D66; do
    grep -q "#$colour" "$doc"
  done
done
for colour in F2C6A0 EDA66F E88952 7299B9 3EA2B4 F17D66; do
  grep -q "#$colour" "$ROOT/install.sh"
done

# Exercise the active renderer with healthy, warning and critical Claude bars,
# plus a healthy Codex bar, without reading real credentials or calling APIs.
mkdir -p "$TMP/home/.cache/claude-codex-bar"
printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.10 0.95 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"

grep -q '^5h  .*color=#F2C6A0$' <<< "$OUT"
grep -q '^7d  .*color=#E88952$' <<< "$OUT"
grep -q '^7d  .*color=#7299B9$' <<< "$OUT"

IMAGE="$(head -n 1 <<< "$OUT" | sed -nE 's/.*image=([^ ]+).*/\1/p')"
[[ -n "$IMAGE" ]]
python3 - "$IMAGE" <<'PY'
import base64
import sys

pdf = base64.b64decode(sys.argv[1]).decode("latin-1")
for operation in (
    "0.9490 0.7765 0.6275 rg",  # Claude healthy: #F2C6A0
    "0.9098 0.5373 0.3216 rg",  # Claude critical: #E88952
    "0.4471 0.6000 0.7255 rg",  # Codex healthy: #7299B9
):
    assert operation in pdf, operation
PY

printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.75 0.75 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
WARN_OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^5h  .*color=#EDA66F$' <<< "$WARN_OUT"

echo "Colour tests passed."
