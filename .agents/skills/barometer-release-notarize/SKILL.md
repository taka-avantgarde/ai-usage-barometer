---
name: barometer-release-notarize
description: Build, Developer-ID sign, Apple-notarize (profile 'aib'), Gatekeeper-verify (spctl), and publish AI Usage Barometer.app in an isolated /tmp directory with zero workspace or ControlCenter pollution.
---

# AI Usage Barometer — Apple-Notarized Isolated Release Runbook

Use this skill whenever releasing or packaging `AI Usage Barometer.app`.

## Hard Invariants (`ATLAS.md`)
1. **Version Sync**: All 5 scripts (`claude-codex.60s.sh`, `gemini-usage.sh`, `codex-usage.sh`, `claude-usage.sh`, `ai-usage.60s.sh`) must share the exact same `VERSION` and `<xbar.version>`.
2. **Pre-Release Verification Gate**:
   ```bash
   bash scripts/verify-release.sh
   ```
   Must exit `0` across all 8 gates before building or tagging.
3. **Isolated `/tmp` Build & Default Apple Notarization**:
   ```bash
   bash app/bundle.sh
   ```
   - Builds inside `/tmp/ai-usage-barometer-build.XXXXXX` (`trap` cleaned on exit) so macOS Spotlight / LaunchServices / ControlCenter never index temporary `.app` bundles.
   - Signs with `AIB_SIGN_ID="Developer ID Application: Atlas Associates Inc (NCPKFUCRCS)"`.
   - Submits to Apple Notary Service with `AIB_NOTARY_PROFILE="aib"` and staples the ticket.
   - Verifies `spctl --assess --type execute -vv` (`source=Notarized Developer ID`) before creating `app/dist/AIUsageBarometer-v<VERSION>.zip`.
4. **GitHub Release & Local Upgrade**:
   - Create/upload release asset with single-quoted notes (to prevent shell backtick expansion):
     ```bash
     gh release create v<VERSION> app/dist/AIUsageBarometer-v<VERSION>.zip --title "v<VERSION>" --notes '...'
     rm -rf app/dist
     bash install-app.sh
     spctl --assess --type execute -vv "/Applications/AI Usage Barometer.app"
     ```
