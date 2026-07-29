🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 Deutsch · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — diese eine Zeile in Terminal einfügen

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Derselbe Befehl funktioniert mit und ohne Homebrew. Bei Bedarf installiert er Homebrew, `jq`, SwiftBar, das kombinierte Plugin und die Claude/Codex-Helfer.

Ein SwiftBar-Eintrag zeigt beide Dienste. **In der macOS-Menüleiste erscheinen die Namen Claude und Codex nicht.** Claude verwendet Orangetöne, Codex Blautöne.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: Beide Wiederherstellungsprobleme sind behoben

- **Claude nach einem Reset:** Gibt Claude `Warming up`, Nullwerte, fehlende Zeitfenster oder einen veralteten Snapshot mit bereits vergangener Reset-Zeit zurück, bleibt das Plugin nicht mehr in einer Fehlermeldung hängen. 5h und 7d werden als zurückgesetzt/inaktiv mit 100 % Restkapazität wiederhergestellt und beim nächsten erfolgreichen Abruf durch Live-Werte ersetzt. Eine Neuinstallation ist nicht nötig.
- **Codex-5h kehrt später zurück:** Codex-Zeitfenster werden dynamisch erkannt. Sobald Codex wieder ein 300-Minuten-Fenster liefert, erscheint die `5h`-Anzeige beim nächsten Aktualisieren automatisch. Fehlt es, wird nur das verfügbare Fenster wie `7d` angezeigt.

Mit **Refresh now** kann jederzeit sofort aktualisiert werden.

## 🎨 Drei unabhängige Farbstufen

Jedes 5h- und 7d-Fenster wird getrennt bewertet.

| Stufe | Nutzung | Claude | Codex |
|---|---:|---|---|
| 1 — normal | 0–69 % | `#b54f02` | `#4F7FA8` |
| 2 — Warnung | 70–89 % | `#B85A00` | `#0e8ba1` |
| 3 — kritisch | 90–100 % | `#ff7045` | `#ed5d40` |

Der Header wird mit integrierten macOS-Werkzeugen als kleines Vektor-PDF erzeugt; Xcode Command Line Tools sind nicht erforderlich.

## Einstellungen und Details

Das Menü zeigt Dienstnamen, Nutzung, Restkapazität und Reset-Zeit. Unter **Settings** lassen sich Claude und Codex getrennt ein- oder ausblenden; mindestens ein Dienst bleibt sichtbar. Das Aktualisierungsintervall ist 1, 3 oder 5 Minuten.

> **Codex 5h:** Das Plugin erfindet kein fehlendes Limit. Die 5h-Anzeige bleibt ausgeblendet, bis Codex ein echtes 300-Minuten-Fenster liefert, und wird dann automatisch hinzugefügt.

Vorhandene Einzel-Plugins werden in einen versteckten Support-Ordner verschoben, damit keine doppelten Einträge entstehen und die Dateien erhalten bleiben.

## Voraussetzungen und Datenschutz

- macOS; Homebrew, `jq` und SwiftBar werden vom Installer verwaltet.
- Claude Code ist angemeldet.
- Codex CLI oder die Codex-App wurde auf dem Mac verwendet.
- Authentifizierungstoken werden nie ausgegeben oder in den Cache kopiert.
- Einige Nutzungsschnittstellen sind inoffiziell und können spätere Anpassungen erfordern.

## Deinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lizenz

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
