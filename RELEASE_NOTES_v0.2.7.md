# AI Usage Barometer v0.2.7

This release restores the stable unified macOS menu-bar UI and pins the tested provider helpers used by the working local recovery build.

## Fixed

- Restored Codex when Claude data is unavailable or still waiting.
- Bundled the Codex helper in this repository instead of downloading an unpinned external copy.
- Removed the Bash 4-only `;;&` syntax that fails on macOS system Bash 3.2.
- Forced a fresh exact-colour vector-header render after upgrades, preventing stale or corrupted colours.
- Kept Claude and Codex windows independent, including independent colour stages for 5h and 7d.
- Kept service names out of the macOS menu bar while retaining them inside the dropdown.

## Colours

| Stage | Usage | Claude | Codex |
|---|---:|---|---|
| Healthy | 0–69% used | `#b54f02` | `#4F7FA8` |
| Warning | 70–89% used | `#B85A00` | `#0e8ba1` |
| Critical | 90–100% used | `#ff7045` | `#ed5d40` |

Codex remains dynamic: when a real 300-minute window is returned, the 5h bar appears automatically; otherwise only the available weekly window is shown.
