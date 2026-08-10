#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="${TMPDIR:-/tmp}"
[[ -d "$TMP_ROOT" && -w "$TMP_ROOT" ]] || TMP_ROOT="/tmp"
TMP="$(mktemp -d "${TMP_ROOT%/}/ai-usage-colours.XXXXXX" 2>/dev/null || mktemp -d "/tmp/ai-usage-colours.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# The active v0.3 palette is a 20% white blend of the previous Claude and Codex
# colours. Lock all stages so the renderer, dropdown, docs and installer agree.
grep -q 'CL_OK="#C68976"; CL_WARN="#B9755F"; CL_DANGER="#B0644D"' "$ROOT/claude-codex.60s.sh"
grep -q 'CX_OK="#7299B9"; CX_WARN="#3EA2B4"; CX_DANGER="#F17D66"' "$ROOT/claude-codex.60s.sh"

for doc in "$ROOT"/README*.md "$ROOT/DESIGN.md"; do
  for colour in C68976 B9755F B0644D 7299B9 3EA2B4 F17D66; do
    grep -q "#$colour" "$doc"
  done
done
for colour in C68976 B9755F B0644D 7299B9 3EA2B4 F17D66; do
  grep -q "#$colour" "$ROOT/install.sh"
done

# Exercise the active renderer with healthy, warning and critical Claude bars,
# plus a healthy Codex bar, without reading real credentials or calling APIs.
mkdir -p "$TMP/home/.cache/claude-codex-bar"
printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.10 0.95 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"

grep -q '^5h  .*color=#C68976$' <<< "$OUT"
grep -q '^7d  .*color=#B0644D$' <<< "$OUT"
grep -q '^7d  .*color=#7299B9$' <<< "$OUT"

IMAGE="$(head -n 1 <<< "$OUT" | sed -nE 's/.*image=([^ ]+).*/\1/p')"
[[ -n "$IMAGE" ]]
python3 - "$IMAGE" <<'PY'
import base64
import sys

pdf = base64.b64decode(sys.argv[1]).decode("latin-1")
for operation in (
    "0.7765 0.5373 0.4627 rg",  # Claude healthy: #C68976
    "0.6902 0.3922 0.3020 rg",  # Claude critical: #B0644D
    "0.4471 0.6000 0.7255 rg",  # Codex healthy: #7299B9
):
    assert operation in pdf, operation
PY

printf '%s\t%s\t%s\t\t\n' "$(date +%s)" 0.75 0.75 > "$TMP/home/.cache/claude-codex-bar/claude.tsv"
WARN_OUT="$(HOME="$TMP/home" CODEX_HELPER="$ROOT/tests/fixtures/codex-helper.sh" "$ROOT/claude-codex.60s.sh")"
grep -q '^5h  .*color=#B9755F$' <<< "$WARN_OUT"

echo "Colour tests passed."
