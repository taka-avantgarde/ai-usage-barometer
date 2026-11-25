---
name: barometer-zero-pollution
description: Audit and clean up stray .app bundles, duplicate macOS ControlCenter / Menu Bar entries, LaunchServices ghosts, and legacy ~/SwiftBar remnants.
---

# AI Usage Barometer — macOS Zero-Pollution & Menu Bar Hygiene Skill

Use this skill when duplicate menu bar items appear in `System Settings > Menu Bar` or when auditing local macOS installation hygiene.

## 1. Canonical App Location
- Only **one** copy of `AI Usage Barometer.app` (`io.atlasassociates.aiusagebarometer`) may exist on disk:
  `/Applications/AI Usage Barometer.app`
- `app/dist/` in the repository must never retain `.app` directories.

## 2. Diagnostic & Cleanup Commands
1. **Verify no stray `.app` bundles exist**:
   ```bash
   mdfind 'kMDItemCFBundleIdentifier == "io.atlasassociates.aiusagebarometer"'
   ```
   Must return only `/Applications/AI Usage Barometer.app`.
2. **Clean LaunchServices & ControlCenter ghost entries** (if duplicates appear in System Settings > Menu Bar):
   - Remove any ad-hoc `cdhash` or legacy `com.ameba.SwiftBar` entries from `~/Library/Group Containers/group.com.apple.controlcenter/Library/Preferences/group.com.apple.controlcenter.plist`, keeping only the single signed `io.atlasassociates.aiusagebarometer` entry.
   - Restart `cfprefsd` and `ControlCenter`:
     ```bash
     killall cfprefsd ControlCenter 2>/dev/null || true
     ```
