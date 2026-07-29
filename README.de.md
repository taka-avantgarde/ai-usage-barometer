🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 Deutsch · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — eine Zeile in Terminal einfügen

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Derselbe Befehl funktioniert mit und ohne Homebrew. Falls nötig, werden Homebrew, jq, SwiftBar und das kombinierte Plugin installiert.

In der macOS-Menüleiste erscheint nur ein Eintrag ohne die Namen Claude oder Codex. Claude ist dunkelorange, Codex blau.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Drei unabhängige Farbstufen

Die Fenster `5h` und `7d` werden getrennt bewertet. Stufe 1: 0–69 % genutzt; Stufe 2: 70–89 %; Stufe 3: 90–100 %.

| Stufe | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

Die Menüleistenanzeige wird mit den integrierten macOS-Werkzeugen als kleines Vektor-PDF statt als 24-Bit-ANSI-Text gerendert. So behält SwiftBar die exakte HEX-Farbe jedes Fensters bei, ohne dass die Xcode Command Line Tools erforderlich sind.

## Einstellungen

Claude und Codex lassen sich im Menü getrennt ein- oder ausblenden. Mindestens ein Dienst bleibt sichtbar.

> **Codex 5h:** Codex liefert nicht immer ein 5-Stunden-Limit. Wenn es nicht vorhanden ist oder nicht in den Nutzungsdaten erscheint, wird die Codex-5h-Anzeige ausgeblendet und nur ein verfügbares Fenster wie 7d gezeigt. Das Plugin erfindet keine fehlenden Limits.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
