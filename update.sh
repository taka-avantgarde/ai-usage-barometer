#!/usr/bin/env bash
# Install the latest reviewed version from the official project repository.
set -euo pipefail

INSTALLER="https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh"
exec /bin/bash -c "$(curl -fsSL --connect-timeout 5 --max-time 20 "$INSTALLER")"
