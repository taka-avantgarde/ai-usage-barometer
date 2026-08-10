🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 Nederlands · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installatie — plak deze ene regel in Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Dezelfde opdracht werkt met en zonder Homebrew. Alleen wat ontbreekt wordt geïnstalleerd: Homebrew, `jq`, SwiftBar, de plugin en de lokale helpers. Opnieuw uitvoeren is veilig en werkt ook als update.

## Eén item in de menubalk

Claude en Codex delen één item, gescheiden door een dunne streep. De balken zijn batterij-stijl: **het gevulde deel is de resterende capaciteit**, de gestippelde staart is verbruikt. Percentages tonen eveneens het restant.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

De menubalk wordt als vectorafbeelding getekend zodat elke dienst binnen één item zijn eigen kleur houdt. Anders wordt automatisch platte tekst gebruikt.

De kleur volgt het verbruik, dus een bijna lege balk oogt dieper:

| Fase | Verbruik | Claude | Codex |
|---|---:|---|---|
| normaal | 0–69% gebruikt | `#F2C6A0` | `#BEEAF3` |
| waarschuwing | 70–89% gebruikt | `#EDA66F` | `#96DCE9` |
| kritiek | 90–100% gebruikt | `#E88952` | `#6BC9DC` |

## Instellingen

Open het menu en gebruik **⚙ Weergave-instellingen**. Elk item schakelt met één klik en werkt direct.

| Instelling | Effect |
|---|---|
| Claude tonen | Claude tonen of verbergen |
| Claude 5h tonen | Venster van 5 uur tonen of verbergen |
| Percentage van Claude 5h | Bijbehorend percentage tonen of verbergen |
| Claude 7d tonen | Venster van 7 dagen tonen of verbergen |
| Percentage van Claude 7d | Bijbehorend percentage tonen of verbergen |
| Codex tonen | Codex tonen of verbergen |
| Percentage van Codex | Codex-percentages tonen of verbergen |
| Menubalk in twee kleuren | Vector (twee kleuren) of tekst (één kleur) |
| Vernieuwingsinterval | 1, 3 of 5 minuten |
| Taal | 14 talen; volgt standaard macOS |

Alles verbergen zou een leeg, niet-klikbaar item opleveren; daarom blijft de 5-uursbalk van Claude altijd staan. De kleur volgt alleen zichtbare balken. Instellingen staan in `~/.cache/claude-codex-bar/` en blijven behouden.

## Gegevensbronnen

**Claude** wordt gelezen van het OAuth-eindpunt `api.anthropic.com/api/oauth/usage`, met het token dat Claude Code al bewaart in de macOS-sleutelhanger (`Claude Code-credentials`, anders `~/.claude/.credentials.json`). Er wordt niets naar geschreven en het token verlaat je Mac alleen in het verzoek aan Anthropic. Kies bij de eerste keer **Altijd toestaan**.

Resultaten worden gecachet gedurende het interval, dus het eindpunt wordt hoogstens één keer per interval bevraagd. Mislukt dat, dan blijft de laatste geldige waarde staan.

**Codex** wordt gelezen uit de lokale helper `codex-usage.sh` die het installatieprogramma in `~/SwiftBar/.ai-usage-barometer/` plaatst. De vensters zijn dynamisch.

## Problemen oplossen

**Er verschijnt een Claude-waarschuwing.** Het sleutelhangeritem is niet gevonden. Log in bij Claude Code en klik op **Nu vernieuwen**.

**Er verschijnt een Codex-waarschuwing.** De helper ontbreekt of Codex heeft nog geen gegevens. Voer het installatieprogramma opnieuw uit en gebruik Codex CLI één keer.

**Kleuren verschillen tussen menubalk en menu.** macOS kan een doorschijnende menubalk als licht behandelen terwijl menu’s donker zijn. Daarom één kleur per fase; zo niet, schakel tweekleurentekening uit.

## Verwijderen

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licentie

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
