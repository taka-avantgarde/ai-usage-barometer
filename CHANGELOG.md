# Changelog

## 0.1.7 — 2026-07-29

- Apply the requested three-stage palette directly to the macOS menu-bar header.
- Evaluate Claude 5h and 7d independently, so 99% left and 3% left cannot share a colour.
- Install the local SwiftBar plugin before publishing to GitHub, so the visible bar updates immediately.
- Claude: `#b54f02`, `#B85A00`, `#ff7045`; Codex: `#4F7FA8`, `#0e8ba1`, `#ed5d40`.

## 0.1.6 — 2026-07-29

- Force Claude 5h and 7d to calculate their colour independently from each window’s own percentage.
- Add a per-window gauge fallback when a helper does not include a numeric percentage.
- Keep the requested palettes exactly: Claude `#b54f02`, `#B85A00`, `#ff7045`; Codex `#4F7FA8`, `#0e8ba1`, `#ed5d40`.
- Restart SwiftBar during the update so an older cached plugin cannot remain visible.

## 0.1.5 — 2026-07-29

- Colour each 5h/7d window independently instead of applying one provider-wide colour.
- Claude palette: `#b54f02`, `#B85A00`, `#ff7045`.
- Codex palette: `#4F7FA8`, `#0e8ba1`, `#ed5d40`.
- Thresholds remain 0–69%, 70–89%, and 90–100% used.
- Use exact 24-bit RGB ANSI colours in the macOS menu bar and matching colours in the dropdown.

## 0.1.4 — 2026-07-29

- Keep Claude unmistakably orange while reducing only its brightness.
- Claude now uses dark saturated orange (ANSI 166 / `#B85A00`) instead of brown-leaning amber.
- Codex remains unchanged at muted steel blue (ANSI 67 / `#4F7FA8`).

## 0.1.3 — 2026-07-29

- Darken only the Claude segment for a quieter menu-bar appearance.
- Claude now uses deep burnt amber (ANSI 130 / `#8F4F1F`).
- Codex remains unchanged at muted steel blue (ANSI 67 / `#4F7FA8`).

## 0.1.2 — 2026-07-29

- Tone down the macOS menu-bar palette for a calmer appearance.
- Claude now uses muted amber (ANSI 172 / `#B86F27`).
- Codex now uses muted steel blue (ANSI 67 / `#4F7FA8`).
- The separator is slightly dimmer (ANSI 242).

## 0.1.1 — 2026-07-29

- Force colour rendering in the macOS menu bar with SwiftBar ANSI mode.
- Claude uses ANSI 256-colour orange (208); Codex uses blue (39).
- Explicitly disable symbol parsing in the header to avoid conflicts with ANSI styling.

## 0.1.0 — 2026-07-29

- First unified Claude + Codex release.
- One multi-colour menu-bar item: Claude orange, Codex blue.
- Service names removed from the macOS menu bar.
- Per-service visibility toggles under Settings.
- One-line installer for Macs with or without Homebrew.
