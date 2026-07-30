# AI Usage Barometer v0.2.0

This release fixes the reset-state bug that could leave Claude stuck on **Warming up** after the 5h or 7d quota reset.

## Fixed

- Claude null/idle windows now render as reset gauges with 100% remaining instead of a permanent warning.
- Expired cached Claude windows roll over locally while the live endpoint catches up.
- A successful refresh replaces the recovery state with the actual live percentages automatically.
- Codex remains dynamic: when a 300-minute window is returned again, the 5h bar appears automatically without reinstalling.

## Privacy

The fallback reads the same local Claude Code OAuth credential used by the standalone helper. The token is not printed, placed in the process command line, or stored in the AI Usage Barometer cache.
