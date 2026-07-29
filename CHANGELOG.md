# Changelog

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
