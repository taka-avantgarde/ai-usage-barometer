# AI Usage Barometer v0.1.6

This release fixes the remaining case where Claude 5h and 7d could still inherit the same menu-bar colour.

- Every window is evaluated from its own `% used` or `% left` value.
- Gauge-derived fallback remains per-window.
- Claude stages: `#b54f02`, `#B85A00`, `#ff7045`.
- Codex stages: `#4F7FA8`, `#0e8ba1`, `#ed5d40`.
- Thresholds: stage 1 = 0–69% used, stage 2 = 70–89%, stage 3 = 90–100%.
- The updater replaces the installed plugin and fully restarts SwiftBar.
