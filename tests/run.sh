#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/support" "$TMP/cache"
cp "$ROOT/tests/fixtures/claude-helper.sh" "$TMP/support/claude-usage.sh"
cp "$ROOT/tests/fixtures/codex-helper.sh" "$TMP/support/codex-usage.sh"
chmod +x "$TMP/support/"*.sh

OUT="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache" SWIFTBAR_PLUGIN_PATH="$ROOT/ai-usage.60s.sh" "$ROOT/ai-usage.60s.sh")"
FIRST="$(printf '%s\n' "$OUT" | head -n 1)"
[[ "$FIRST" != *"Claude"* ]]
[[ "$FIRST" != *"Codex"* ]]
[[ "$FIRST" == *"ansi=true"* ]]
[[ "$FIRST" == *"5h"* ]]
[[ "$FIRST" == *"7d"* ]]
grep -q '^Claude | color=#D97706' <<< "$OUT"
grep -q '^Codex | color=#2563EB' <<< "$OUT"
grep -q '^    13% used · 87% left$' <<< "$OUT"
grep -q '^    Resets in 2d 8h' <<< "$OUT"
grep -q '^Settings$\|^設定$' <<< "$OUT" || true

env AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache" "$ROOT/ai-usage.60s.sh" --toggle codex
OUT2="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache" "$ROOT/ai-usage.60s.sh")"
FIRST2="$(printf '%s\n' "$OUT2" | head -n 1)"
[[ "$FIRST2" == *"5h"* ]]
[[ "$FIRST2" != *"│"* ]]
! grep -q '^Codex |' <<< "$OUT2"

env AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache" "$ROOT/ai-usage.60s.sh" --toggle claude
OUT3="$(AI_USAGE_SUPPORT_DIR="$TMP/support" AI_USAGE_CACHE_DIR="$TMP/cache" "$ROOT/ai-usage.60s.sh")"
grep -q '^Claude |' <<< "$OUT3"

echo "All tests passed."
