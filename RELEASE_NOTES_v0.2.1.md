# AI Usage Barometer v0.2.1

Claude now uses Claude Code’s documented `statusLine` JSON instead of the former undocumented OAuth usage request.

## What changed

- Reads `rate_limits.five_hour` and `rate_limits.seven_day` from the official Claude Code status-line payload.
- Never converts `Warming up` or missing data into a fabricated 100% value.
- Preserves an existing custom Claude Code status line and restores it on uninstall.
- Does not read Claude OAuth tokens, macOS Keychain items, or `~/.claude/.credentials.json`.
- Keeps each Claude and Codex window independent in both colour and visibility.
- Automatically adds Codex 5h when a real 300-minute window returns.
- Updates all 14 language READMEs.

After updating, open Claude Code and complete one response so Claude Code can provide the official `rate_limits` fields.
