#!/usr/bin/env bash
# Install the latest reviewed version from the official project repository.
set -euo pipefail

if [[ -d "/Applications/AI Usage Barometer.app" ]]; then
  /bin/bash -c "$(curl -fsSL --connect-timeout 5 --max-time 20 "https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh")" || true
fi
if [[ -d "/Applications/SwiftBar.app" || -d "$HOME/Applications/SwiftBar.app" || -d "$HOME/SwiftBar" || ! -d "/Applications/AI Usage Barometer.app" ]]; then
  INSTALLER="https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh"
  exec /bin/bash -c "$(curl -fsSL --connect-timeout 5 --max-time 20 "$INSTALLER")"
fi
