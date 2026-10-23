🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 Deutsch · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Behalte Claude, Codex und Gemini auf einen Blick in Echtzeit im Auge — an 3 Orten auf dem Mac: Menüleiste, Dock-Symbol und schwebende Leiste.**

| KI-Dienst | Farbe | Unterstützte Quellen |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (offizielle Statuszeile) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI und Web-Token |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Sitzungskontingente für Google Antigravity Desktop & IDE |

<img src="assets/hero.svg" alt="AI Usage Barometer in der Menüleiste, im Dock-Symbol und in einer schwebenden Leiste" width="725">

## ⚡ Installation — diese eine Zeile ins Terminal einfügen

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Das ist die App. Ohne Homebrew, ohne Xcode. macOS 13 oder neuer. Beim ersten Start fragt sie, wo sie wohnen soll — Menüleiste, Dock-Symbol oder schwebende Leiste — und über ihr Menü lässt sich das jederzeit ändern.

## Ein Element in der Menüleiste

Claude, Codex und Gemini teilen sich ein Element, getrennt durch eine feine Linie. Die Balken sind batterieartig: **der gefüllte Teil ist die verbleibende Kapazität**, der gepunktete Rest ist verbraucht. Auch die Prozentwerte zeigen den Rest.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

Die Menüleiste wird als Vektorbild gezeichnet, damit jeder Dienst innerhalb eines Elements seine eigene Farbe behält. Andernfalls wird automatisch Text verwendet.

Beide Paletten verwenden gesättigte, kontrastreiche Farben: Claude verwendet
Orange, Codex Cyan. Bei 11–30% Restkapazität mischt die Warnfarbe Orange bei;
bei höchstens 10% enthält die kritische Farbe kräftiges Rot. Codex behält in
beiden Mischungen einen starken Blauanteil:

| Stufe | Nutzung | Claude | Codex | Gemini |
|---|---:|---|---|---|
| normal | 0–69% genutzt | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| Warnung | 70–89% genutzt | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| kritisch | 90–100% genutzt | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Einstellungen

Öffne das Menü und wähle **⚙ Display settings**. Das Einstellungsfenster bleibt geöffnet, sodass mehrere Optionen nacheinander geändert werden können, ohne dass es sich nach jedem Klick schließt. Änderungen wirken sofort.

Die Plugin-Oberfläche ist ausschließlich auf Englisch. Diese GitHub-Dokumentation bleibt in 14 Sprachen verfügbar.

| Einstellung | Wirkung |
|---|---|
| **Claude** (`ON` / `OFF`) | Claude vollständig ein- oder ausblenden (wirkt auf `5h` und `1w`) |
| **Claude `5h`** + **`%`** | 5-Stunden-Fenster und Prozentangabe ein- oder ausblenden |
| **Claude `1w`** + **`%`** | 1-Wochen-Fenster (7d) und Prozentangabe ein- oder ausblenden |
| **Codex** (`ON` / `OFF`) | Codex vollständig ein- oder ausblenden (wirkt auf `5h` und `1w`) |
| **Codex `5h`** + **`%`** | 5-Stunden-Fenster (Codex 5h) und Prozentangabe ein- oder ausblenden |
| **Codex `1w`** + **`%`** | 1-Wochen-Fenster (Codex 7d) und Prozentangabe ein- oder ausblenden |
| **Gemini** (`ON` / `OFF`) | Gemini vollständig ein- oder ausblenden (wirkt auf `5h` und `1w`) |
| **Gemini `5h`** + **`%`** | 5-Stunden-Fenster (`5h`) und Prozentangabe ein- oder ausblenden |
| **Gemini `1w`** + **`%`** | 1-Wochen-Fenster (`1w` / 7d) und Prozentangabe ein- oder ausblenden |
| **Platzierung** (`Menu bar` / `Dock icon` / `Floating bar`) | Beliebige Kombination der drei Anzeigeorte wählen |
| **Aktualisierungsintervall** (`1m` / `3m` / `5m`) | 1 Minute, 3 Minuten oder 5 Minuten |

Sind alle Anzeigen ausgeblendet, bleibt ein neutraler Eintrag `AI …`, über den die Einstellungen erreichbar sind. Die Farbe richtet sich nur nach sichtbaren Balken. Einstellungen liegen in `~/.cache/claude-codex-bar/` und überstehen Updates.

Wenn Claude oder Codex deaktiviert wird, wird die Datenaktualisierung für diesen Dienst angehalten. Die Einstellungen für 5h, 7d und Prozent bleiben abgeblendet und gesperrt; beim erneuten Aktivieren werden ihre vorherigen Werte wiederhergestellt.

Sind bei einem Dienst sowohl 5h als auch 7d abgewählt, werden der Dienst und seine Fehler vollständig ausgeblendet und seine Datenquelle nicht abgefragt.

Die App und das Plugin prüfen GitHub Releases automatisch alle 15 Minuten und aktualisieren sich im Hintergrund, sobald eine neue Version veröffentlicht wird.

## Die App — wähle, wo sie wohnt

Die Menüleiste steht nicht immer zur Verfügung. Auf manchen Macs wird das
Statusobjekt außerhalb des Bildschirms platziert und nie gezeichnet, und neben
der Notch ist schlicht kein Platz. Die App stellt dieselben Anzeigen dorthin,
wo du sie haben willst.

| Ort | Was es ist |
|---|---|
| **Menüleiste** | Das eigene Statusobjekt der App, einzeilig |
| **Dock-Symbol** | Das Dock-Symbol selbst wird zur Anzeige. Kostet keinen Bildschirmplatz |
| **Schwebende Leiste** | Eine kleine Leiste immer im Vordergrund. Zieh sie, wohin du willst |

Alle drei sind unabhängig — schalte jede Kombination ein. Ein Rechtsklick auf
die Leiste, das Dock-Symbol oder das Menüleistenobjekt öffnet die
Einstellungen: jeder Dienst an oder aus, Prozentwerte, der Ort und
**Details…** für das Fenster mit den Erholungszeiten.

Eine Anzeige abzuschalten gibt die Breite zurück: das Element schrumpft auf das, was übrig bleibt, und die Menüleiste behält die Differenz.

Ein oranger Pfeil heißt, dass ein Update wartet. **Update to vX.Y.Z** im selben Menü installiert es an Ort und Stelle.

Eine Zeile, kein Xcode nötig. macOS 13 oder neuer.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Die App ist von Apple signiert und notarisiert und lässt sich direkt nach dem Download öffnen — ohne Warnung, ohne Rechtsklick.

Oder aus dem Quellcode starten — dafür wird Xcode gebraucht:

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

## Datenquellen

**Claude** wird vom OAuth-Endpunkt `api.anthropic.com/api/oauth/usage` gelesen, mit dem Token, das Claude Code bereits im macOS-Schlüsselbund (`Claude Code-credentials`, sonst `~/.claude/.credentials.json`) ablegt. Dorthin wird nichts geschrieben, und das Token verlässt den Mac nur in der Anfrage an Anthropic. Wähle beim ersten Start **Immer erlauben**.

Ergebnisse werden für das Intervall zwischengespeichert, der Endpunkt wird also höchstens einmal pro Intervall abgefragt. Schlägt eine Aktualisierung fehl, bleibt der letzte gültige Wert stehen.

**Codex** wird aus dem lokalen Helfer `codex-usage.sh` in `.ai-usage-barometer/` gelesen. Es verfolgt die Fenster `5h` und `1w` (`7d`) in der Reihenfolge `5h → 1w` (selbst wenn das 5-Stunden-Fenster noch nicht verbraucht wurde).

**Gemini** wird aus dem lokalen Helfer `gemini-usage.sh` gelesen, der mit der App gebündelt ist. Es unterstützt sowohl Antigravity Desktop App 2.0 als auch Antigravity IDE und liest die Fenster `5h` und `1w` lokal über Connect RPC (`RetrieveUserQuotaSummary` / `GetUserStatus`), SQLite (`state.vscdb`) und Cache-Fallback sicher aus, ohne externe API-Aufrufe oder Schreibvorgänge von Anmeldedaten.

## Fehlerbehebung

**Eine Claude-Warnung erscheint.** Öffne das Dropdown, um den Grund zu sehen. *Sign in to Claude Code again* bedeutet, dass das OAuth-Token abgelaufen ist — melde dich über die Claude-Code-CLI oder die IDE-Erweiterung neu an. **Das ist nicht die Claude-Desktop-App**: Ein Login in Claude.app erneuert dieses Token nicht. *Rate limited* löst sich von selbst; das Plugin wartet 15 Minuten und zeigt die verbleibende Zeit an.

**Eine Codex-Warnung erscheint.** Der Helfer fehlt oder Codex hat noch keine Daten geliefert. Installer erneut ausführen und Codex CLI einmal nutzen.

**Gemini zeigt eine Warnung.** Antigravity wurde noch nicht gestartet oder das lokale Hilfsskript wartet auf Daten. Starten Sie Antigravity Desktop oder Antigravity IDE.

**Farben unterscheiden sich zwischen Menüleiste und Menü.** macOS kann eine transluzente Menüleiste als hell behandeln, während Menüs dunkel sind. Genau deshalb gibt es nur eine Farbe pro Stufe; andernfalls die Zweifarbdarstellung abschalten.

## Deinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lizenz

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
