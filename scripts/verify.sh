#!/usr/bin/env bash
# verify.sh — Canonical deterministic verification entrypoint
set -euo pipefail
exec "$(cd "$(dirname "$0")" && pwd)/verify-release.sh" --fast "$@"
