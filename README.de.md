🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 Deutsch · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — diese eine Zeile ins Terminal einfügen

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Derselbe Befehl funktioniert mit und ohne Homebrew. Es wird nur installiert, was fehlt: Homebrew, `jq`, SwiftBar, das Plugin und seine lokalen Helfer. Erneutes Ausführen ist unbedenklich und dient auch als Update.

## Ein Element in der Menüleiste

Claude und Codex teilen sich ein Element, getrennt durch eine feine Linie. Die Balken sind batterieartig: **der gefüllte Teil ist die verbleibende Kapazität**, der gepunktete Rest ist verbraucht. Auch die Prozentwerte zeigen den Rest.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

Die Menüleiste wird als Vektorbild gezeichnet, damit jeder Dienst innerhalb eines Elements seine eigene Farbe behält. Andernfalls wird automatisch Text verwendet.

Beide Paletten verwenden gesättigte, kontrastreiche Farben: Claude verwendet
Orange, Codex Cyan. Bei 11–30% Restkapazität mischt die Warnfarbe Orange bei;
bei höchstens 10% enthält die kritische Farbe kräftiges Rot. Codex behält in
beiden Mischungen einen starken Blauanteil:

| Stufe | Nutzung | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% genutzt | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| Warnung | 70–89% genutzt | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| kritisch | 90–100% genutzt | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Einstellungen

Öffne das Menü und wähle **⚙ Anzeigeeinstellungen**. Das Einstellungsfenster bleibt geöffnet, sodass mehrere Optionen nacheinander geändert werden können, ohne dass es sich nach jedem Klick schließt. Änderungen wirken sofort.

| Einstellung | Wirkung |
|---|---|
| Claude anzeigen | Claude ein-/ausblenden |
| Claude 5h anzeigen | 5-Stunden-Fenster ein-/ausblenden |
| Prozent von Claude 5h | Dessen Prozentwert ein-/ausblenden |
| Claude 7d anzeigen | 7-Tage-Fenster ein-/ausblenden |
| Prozent von Claude 7d | Dessen Prozentwert ein-/ausblenden |
| Codex anzeigen | Codex ein-/ausblenden |
| Prozent von Codex | Codex-Prozentwerte ein-/ausblenden |
| Aktualisierungsintervall | 1, 3 oder 5 Minuten |
| Sprache | 14 Sprachen; folgt standardmäßig macOS |

Alles auszublenden ergäbe ein leeres, nicht anklickbares Element – der 5-Stunden-Balken von Claude bleibt daher immer erhalten. Die Farbe richtet sich nur nach sichtbaren Balken. Einstellungen liegen in `~/.cache/claude-codex-bar/` und überstehen Updates.

Wenn Claude oder Codex deaktiviert wird, wird die Datenaktualisierung für diesen Dienst angehalten. Die Einstellungen für 5h, 7d und Prozent bleiben abgeblendet und gesperrt; beim erneuten Aktivieren werden ihre vorherigen Werte wiederhergestellt.

## Datenquellen

**Claude** wird vom OAuth-Endpunkt `api.anthropic.com/api/oauth/usage` gelesen, mit dem Token, das Claude Code bereits im macOS-Schlüsselbund (`Claude Code-credentials`, sonst `~/.claude/.credentials.json`) ablegt. Dorthin wird nichts geschrieben, und das Token verlässt den Mac nur in der Anfrage an Anthropic. Wähle beim ersten Start **Immer erlauben**.

Ergebnisse werden für das Intervall zwischengespeichert, der Endpunkt wird also höchstens einmal pro Intervall abgefragt. Schlägt eine Aktualisierung fehl, bleibt der letzte gültige Wert stehen.

**Codex** wird aus dem lokalen Helfer `codex-usage.sh` gelesen, den der Installer nach `~/SwiftBar/.ai-usage-barometer/` legt. Seine Fenster sind dynamisch.

## Fehlerbehebung

**Eine Claude-Warnung erscheint.** Der Schlüsselbund-Eintrag fehlt. Melde dich in Claude Code an und klicke **Jetzt aktualisieren**.

**Eine Codex-Warnung erscheint.** Der Helfer fehlt oder Codex hat noch keine Daten geliefert. Installer erneut ausführen und Codex CLI einmal nutzen.

**Farben unterscheiden sich zwischen Menüleiste und Menü.** macOS kann eine transluzente Menüleiste als hell behandeln, während Menüs dunkel sind. Genau deshalb gibt es nur eine Farbe pro Stufe; andernfalls die Zweifarbdarstellung abschalten.

## Deinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Lizenz

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
