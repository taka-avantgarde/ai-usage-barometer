🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 Nederlands · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installatie — plak één regel in Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Dezelfde opdracht werkt met en zonder Homebrew. Zo nodig worden Homebrew, jq, SwiftBar en de gecombineerde plugin geïnstalleerd.

De macOS-menubalk toont één item zonder de namen Claude of Codex. Claude is donkeroranje en Codex blauw.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Drie onafhankelijke kleurniveaus

De vensters `5h` en `7d` worden afzonderlijk beoordeeld. Niveau 1: 0–69% gebruikt; niveau 2: 70–89%; niveau 3: 90–100%.

| Niveau | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## Instellingen

In het menu kun je Claude en Codex afzonderlijk tonen of verbergen. Minstens één dienst blijft zichtbaar.

> **Codex 5h:** Codex geeft niet altijd een limiet van 5 uur terug. Als die niet bestaat of niet in de gebruiksgegevens staat, wordt de Codex-5h-balk verborgen en worden alleen beschikbare vensters zoals 7d getoond. De plugin verzint geen ontbrekende limiet.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
