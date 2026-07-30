🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 Nederlands · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installatie — plak deze ene regel in Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Dezelfde opdracht werkt met of zonder Homebrew en installeert automatisch de benodigde onderdelen.

## ✅ v0.2.7: stabiel herstel van de menubalk

v0.2.7 bundelt een geteste Codex-helper in deze repository, verwijdert de `;;&`-syntaxis die niet werkt met de standaard Bash 3.2 van macOS en bouwt de vectorheader met exacte kleuren na elke update opnieuw op.

Claude en Codex worden onafhankelijk beoordeeld: ontbrekende gegevens van de ene dienst verbergen de andere niet meer. Elk 5h-/7d-venster behoudt zijn eigen kleurniveau en bestaande **Settings**-keuzes blijven behouden.

## Claude-gegevensbron


Claude-gebruik wordt vastgelegd uit de gedocumenteerde `statusLine`-JSON via `rate_limits.five_hour` en `rate_limits.seven_day`. Een bestaande statusregel blijft behouden.

Open na installatie Claude Code en voltooi één antwoord. `rate_limits` verschijnt pas na de eerste API-respons; 5h en 7d kunnen afzonderlijk ontbreken. Alleen echte vensters worden getoond. `Warming up` of ontbrekende data wordt nooit een verzonnen 100%.

OAuth-tokens, macOS Keychain en `~/.claude/.credentials.json` worden niet gelezen.

## Eén menubalkitem

Claude is oranje, Codex blauw en de namen staan niet in de macOS-menubalk. Elk venster krijgt onafhankelijk een kleur.

| Niveau | Gebruik | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex voegt `5h` automatisch toe bij een echt venster van 300 minuten; anders verschijnt alleen `7d`. Via **Settings** verberg je diensten en kies je 1, 3 of 5 minuten.

Verschijnt Claude niet, open Claude Code en voltooi een antwoord. `statusLine` vereist workspace trust en werkt niet met `disableAllHooks: true`.

## Verwijderen

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
