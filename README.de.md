🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 Deutsch · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — diese eine Zeile ins Terminal einfügen

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Derselbe Befehl funktioniert mit und ohne Homebrew und installiert die Abhängigkeiten automatisch.

## ✅ v0.2.7: stabile Wiederherstellung der Menüleiste

v0.2.7 enthält eine getestete Codex-Hilfsdatei direkt in diesem Repository, entfernt die mit macOS-Bash 3.2 inkompatible Syntax `;;&` und baut den Vektor-Header mit exakten Farben nach jedem Update neu auf.

Claude und Codex werden unabhängig ausgewertet: Fehlende Daten eines Anbieters blenden den anderen nicht mehr aus. Jedes 5h-/7d-Fenster behält seine eigene Farbstufe, und vorhandene **Settings**-Auswahlen bleiben erhalten.

## Claude-Datenquelle


Claude-Nutzung wird aus dem dokumentierten `statusLine`-JSON über `rate_limits.five_hour` und `rate_limits.seven_day` erfasst. Eine vorhandene Statuszeile bleibt erhalten.

Nach der Installation Claude Code öffnen und eine Antwort abschließen. `rate_limits` erscheint erst nach der ersten API-Antwort; 5h und 7d können unabhängig fehlen. Es werden nur echte Fenster angezeigt. `Warming up` oder fehlende Daten werden niemals als erfundene 100 % dargestellt.

OAuth-Token, macOS-Schlüsselbund und `~/.claude/.credentials.json` werden nicht gelesen.

## Ein Menüleisteneintrag

Claude ist orange, Codex blau; die Namen erscheinen nicht in der macOS-Menüleiste. Jedes Fenster wird separat eingefärbt.

| Stufe | Nutzung | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69 % | `#b54f02` | `#4F7FA8` |
| 2 | 70–89 % | `#B85A00` | `#0e8ba1` |
| 3 | 90–100 % | `#ff7045` | `#ed5d40` |

Codex fügt `5h` automatisch hinzu, sobald ein echtes 300-Minuten-Fenster zurückgegeben wird; andernfalls erscheint nur `7d`. Unter **Settings** lassen sich Dienste ausblenden und 1, 3 oder 5 Minuten wählen.

Falls Claude fehlt, Claude Code öffnen und eine Antwort abschließen. `statusLine` benötigt Workspace-Vertrauen und läuft nicht mit `disableAllHooks: true`.

## Deinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
