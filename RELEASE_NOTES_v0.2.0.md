# AI Usage Barometer v0.2.0

## Reset recovery and dynamic Codex windows

This release fixes the two recovery problems reported after provider quota changes.

- Claude no longer remains stuck on `Warming up` after a quota reset.
- Zero values, null windows, and stale snapshots whose reset time has passed are treated as a reset/idle state.
- Claude 5h and 7d return at 100% left, then switch to live values on the next successful refresh.
- Codex windows remain dynamic: when a real 300-minute window returns, the 5h gauge is added automatically at the next refresh.
- Weekly-only Codex accounts continue to show only the available 7d gauge.
- All 14 README translations now document the two fixes, one-line installation, independent colour stages, settings, and privacy behaviour.
- Documentation regression tests ensure the recovery explanation stays present in every supported language.

No reinstall is required after a normal automatic update. Use **Refresh now** to request an immediate refresh.
