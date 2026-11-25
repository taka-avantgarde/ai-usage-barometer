---
name: barometer-multilingual-sync
description: Synchronize and audit all 14 README*.md languages, assets/hero.svg (6 bars across 3 surfaces), and all 21 official marketing website locales (Arc/marketing/src/messages/*.json cub.* keys).
---

# AI Usage Barometer — 14-README + 21-Web Multilingual Parity Skill

Use this skill whenever any UI text, setting row, service window (`5h` / `1w`), or feature changes in `ai-usage-barometer`.

## 1. 14-Language GitHub `README*.md` Parity
Target files:
`README.md`, `README.ja.md`, `README.es.md`, `README.ar.md`, `README.fr.md`, `README.de.md`, `README.zh.md`, `README.ko.md`, `README.pt.md`, `README.nl.md`, `README.it.md`, `README.vi.md`, `README.id.md`, `README.th.md`

Invariants enforced by `scripts/verify-release.sh`:
- Zero mentions of `SwiftBar` or `30d`.
- Settings table must have **exactly 11 data rows** (`Claude`, `Claude 5h`, `Claude 1w`, `Codex`, `Codex 5h`, `Codex 1w`, `Gemini`, `Gemini 5h`, `Gemini 1w`, `Placement`, `Refresh interval`).
- `Data sources` section must include **Claude**, **Codex**, and **Gemini (`gemini-usage.sh`)** paragraphs.
- Required test tokens preserved in every file: `install-app.sh`, `**⚙ Display settings**`, `Codex 5h`, `Codex 7d`, `GitHub Releases`, `14`, and all 9 palette hex codes (`#C66D28`, `#B65A1E`, `#C52E22`, `#1A8BA6`, `#52768A`, `#783F78`, `#158F6A`, `#5E7B3A`, `#8C3B5A`).

## 2. Visual Asset Parity (`assets/hero.svg`)
- Must render all 6 bars (`Claude 5h/1w`, `Codex 5h/1w`, `Gemini 5h/1w` in `5h → 1w` order) consistently across **Menu bar**, **Dock icon**, and **Floating bar**.
- Copy updated `assets/hero.svg` to `/Users/takayukimiyano/StudioProjects/Arc/marketing/public/ai-usage-barometer-hero.svg`.

## 3. 21-Language Official Website Parity (`Arc/marketing`)
- Path: `/Users/takayukimiyano/StudioProjects/Arc/marketing/src/messages/*.json` (`cub.*` keys only — never touch unrelated uncommitted files in `Arc/marketing`).
- Zero occurrences of `SwiftBar`, `5h/7d`, `5-hour/7-day`, or hardcoded stale version strings (`v0.10.0`, `v0.9.0`, `v0.8.0`).
- Verify with:
  ```bash
  bash /Users/takayukimiyano/ai-usage-barometer/scripts/verify-release.sh
  ```
