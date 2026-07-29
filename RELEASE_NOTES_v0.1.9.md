# AI Usage Barometer v0.1.9

This release removes the Xcode Command Line Tools requirement from exact-colour menu-bar rendering.

- The unified menu-bar header is now a tiny vector PDF generated with built-in macOS shell tools.
- Claude 5h and 7d remain independently coloured: `#b54f02`, `#B85A00`, `#ff7045`.
- Codex windows remain independently coloured: `#4F7FA8`, `#0e8ba1`, `#ed5d40`.
- No Swift compiler, `xcrun`, ImageMagick, Python, or additional renderer is required.
- Existing Settings, refresh intervals, and one-line installation remain unchanged.
