🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 Nederlands · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installatie — plak deze ene regel in Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Dezelfde opdracht werkt op Macs met of zonder Homebrew. Zo nodig worden Homebrew, `jq`, SwiftBar, de gecombineerde plugin en de Claude/Codex-helpers geïnstalleerd.

Eén SwiftBar-item toont beide diensten. **In de macOS-menubalk staan de namen Claude en Codex niet.** Claude gebruikt oranjetinten en Codex blauwtinten.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: beide herstelproblemen opgelost

- **Claude na een reset:** wanneer Claude `Warming up`, nulwaarden, lege vensters of een verouderde snapshot met een verstreken resetmoment teruggeeft, blijft de plugin niet langer op een fout hangen. De 5h- en 7d-balken keren terug als gereset/inactief met 100% over en worden bij de volgende succesvolle vernieuwing vervangen door live waarden. Opnieuw installeren is niet nodig.
- **Codex 5h komt later terug:** Codex-vensters worden dynamisch herkend. Zodra Codex opnieuw een venster van 300 minuten teruggeeft, verschijnt de `5h`-balk automatisch bij de volgende vernieuwing. Zonder dat venster wordt alleen het beschikbare venster, zoals `7d`, getoond.

Kies **Refresh now** voor een onmiddellijke vernieuwing.

## 🎨 Drie onafhankelijke kleurniveaus

Elk 5h- en 7d-venster wordt afzonderlijk beoordeeld.

| Niveau | Gebruik | Claude | Codex |
|---|---:|---|---|
| 1 — normaal | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — waarschuwing | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — kritiek | 90–100% | `#ff7045` | `#ed5d40` |

De header wordt met ingebouwde macOS-tools als een kleine vector-PDF gemaakt; Xcode Command Line Tools zijn niet nodig.

## Instellingen en details

Het menu toont dienstnamen, gebruik, resterende capaciteit en resetmoment. In **Settings** kunnen Claude en Codex afzonderlijk worden getoond of verborgen; minimaal één dienst blijft zichtbaar. Het interval is 1, 3 of 5 minuten.

> **Codex 5h:** de plugin verzint geen ontbrekende limiet. 5h blijft verborgen tot Codex een echt venster van 300 minuten teruggeeft en wordt daarna automatisch toegevoegd.

Bestaande losse plugins worden naar een verborgen ondersteuningsmap verplaatst om dubbele menubalkitems te voorkomen zonder bestanden te verwijderen.

## Vereisten en privacy

- macOS; de installer regelt Homebrew, `jq` en SwiftBar.
- Claude Code is aangemeld.
- Codex CLI of de Codex-app is op de Mac gebruikt.
- Authenticatietokens worden nooit afgedrukt of naar de cache gekopieerd.
- Sommige gebruiksinterfaces zijn onofficieel en kunnen toekomstige updates vereisen.

## Verwijderen

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licentie

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
