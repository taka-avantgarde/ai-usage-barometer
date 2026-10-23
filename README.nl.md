🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 Nederlands · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Volg Claude, Codex en Gemini in één oogopslag in realtime op 3 Mac-plekken: menubalk, Dock-symbool en zwevende balk.**

| AI-dienst | Kleur | Ondersteunde bronnen |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (officiële statusregel) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI en web-tokens |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop & IDE sessiequota |

<img src="assets/hero.svg" alt="AI Usage Barometer in de menubalk, het Dock-icoon en een zwevende balk" width="725">

## ⚡ Installatie — plak deze ene regel in Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Dat is de app. Geen Homebrew, geen Xcode. macOS 13 of nieuwer. Bij de eerste start vraagt hij waar hij moet wonen — menubalk, Dock-icoon of zwevende balk — en via zijn menu verander je dat wanneer je wilt.

## Eén item in de menubalk

Claude, Codex en Gemini delen één item, gescheiden door een dunne streep. De balken zijn batterij-stijl: **het gevulde deel is de resterende capaciteit**, de gestippelde staart is verbruikt. Percentages tonen eveneens het restant.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

De menubalk wordt als vectorafbeelding getekend zodat elke dienst binnen één item zijn eigen kleur houdt. Anders wordt automatisch platte tekst gebruikt.

Beide paletten gebruiken verzadigde kleuren met hoog contrast: Claude gebruikt
oranje en Codex cyaan. Bij 11–30% resterend mengt de waarschuwing oranje bij;
bij 10% of minder bevat de kritieke kleur helder rood. Codex houdt in beide
mengkleuren duidelijk blauw:

| Fase | Verbruik | Claude | Codex | Gemini |
|---|---:|---|---|---|
| normaal | 0–69% gebruikt | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| waarschuwing | 70–89% gebruikt | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| kritiek | 90–100% gebruikt | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Instellingen

Open het menu en kies **⚙ Display settings**. Het instellingenpaneel blijft open, zodat je meerdere opties achter elkaar kunt wijzigen zonder het na elke klik opnieuw te openen. Wijzigingen werken direct.

De plugininterface is uitsluitend in het Engels. Deze GitHub-documentatie blijft beschikbaar in 14 talen.

| Instelling | Effect |
|---|---|
| **Claude** (`ON` / `OFF`) | Claude volledig weergeven of verbergen (werkt door naar `5h` en `1w`) |
| **Claude `5h`** + **`%`** | Het venster van 5 uur en het percentage weergeven of verbergen |
| **Claude `1w`** + **`%`** | Het venster van 1 week (7d) en het percentage weergeven of verbergen |
| **Codex** (`ON` / `OFF`) | Codex volledig weergeven of verbergen (werkt door naar `5h` en `1w`) |
| **Codex `5h`** + **`%`** | Het venster van 5 uur (Codex 5h) en het percentage weergeven of verbergen |
| **Codex `1w`** + **`%`** | Het venster van 1 week (Codex 7d) en het percentage weergeven of verbergen |
| **Gemini** (`ON` / `OFF`) | Gemini volledig weergeven of verbergen (werkt door naar `5h` en `1w`) |
| **Gemini `5h`** + **`%`** | Het venster van 5 uur (`5h`) en het percentage weergeven of verbergen |
| **Gemini `1w`** + **`%`** | Het venster van 1 week (`1w` / 7d) en het percentage weergeven of verbergen |
| **Plaatsing** (`Menu bar` / `Dock icon` / `Floating bar`) | Kies elke gewenste combinatie van de drie weergavelocaties |
| **Vernieuwingsinterval** (`1m` / `3m` / `5m`) | 1 minuut, 3 minuten of 5 minuten |

Wanneer alle meters verborgen zijn, blijft een neutraal item `AI …` beschikbaar om de instellingen te openen. De kleur volgt alleen zichtbare balken. Instellingen staan in `~/.cache/claude-codex-bar/` en blijven behouden.

Wanneer Claude of Codex wordt uitgeschakeld, stopt het vernieuwen van de gegevens voor die dienst. De instellingen voor 5h, 7d en percentages blijven gedimd en vergrendeld; bij opnieuw inschakelen worden de vorige waarden hersteld.

Als voor een dienst zowel 5h als 7d is uitgeschakeld, worden de dienst en de bijbehorende fouten volledig verborgen en wordt de gegevensbron niet geraadpleegd.

De app en plug-in controleren GitHub Releases automatisch elke 15 minuten en werken op de achtergrond bij wanneer er een nieuwe release wordt gepubliceerd.

## De app — kies waar hij woont

De menubalk is niet altijd beschikbaar. Op sommige Macs wordt het statusitem
buiten het scherm geplaatst en nooit getekend, en naast een notch is er soms
simpelweg geen ruimte. De app zet dezelfde meters op de plek die jij kiest.

| Plek | Wat het is |
|---|---|
| **Menubalk** | Het eigen statusitem van de app, op één regel |
| **Dock-icoon** | Het Dock-icoon zelf wordt de meter. Kost geen schermruimte |
| **Zwevende balk** | Een kleine balk altijd vooraan. Sleep hem waarheen je wilt |

Alle drie staan los van elkaar — zet elke combinatie aan. Klik met rechts op de
balk, het Dock-icoon of het menubalkitem voor de instellingen: elke dienst aan
of uit, percentages, waar hij woont, en **Details…** voor het paneel met
hersteltijden.

Een meter uitzetten geeft de breedte terug: het item krimpt tot precies wat overblijft, en de menubalk houdt het verschil over.

Een oranje pijl betekent dat er een update klaarstaat. **Update to vX.Y.Z** in hetzelfde menu installeert hem ter plekke.

Eén regel, geen Xcode nodig. macOS 13 of nieuwer.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

De app is door Apple ondertekend en genotariseerd en gaat na het downloaden gewoon open — geen waarschuwing, geen rechtermuisknop.

Of draai hem vanaf de broncode; daarvoor is Xcode wel nodig:

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

## Gegevensbronnen

**Claude** wordt gelezen van het OAuth-eindpunt `api.anthropic.com/api/oauth/usage`, met het token dat Claude Code al bewaart in de macOS-sleutelhanger (`Claude Code-credentials`, anders `~/.claude/.credentials.json`). Er wordt niets naar geschreven en het token verlaat je Mac alleen in het verzoek aan Anthropic. Kies bij de eerste keer **Altijd toestaan**.

Resultaten worden gecachet gedurende het interval, dus het eindpunt wordt hoogstens één keer per interval bevraagd. Mislukt dat, dan blijft de laatste geldige waarde staan.

**Codex** wordt gelezen uit de lokale helper `codex-usage.sh` in `.ai-usage-barometer/`. Het volgt zowel de `5h`- als de `1w`-vensters (`7d`) in de volgorde `5h → 1w` (zelfs wanneer het 5-uursvenster nog niet is verbruikt).

**Gemini** wordt gelezen uit de lokale helper `gemini-usage.sh` die bij de app wordt geleverd. Het ondersteunt zowel Antigravity Desktop App 2.0 als Antigravity IDE en leest zowel `5h`- als `1w`-vensters lokaal via Connect RPC (`RetrieveUserQuotaSummary` / `GetUserStatus`), SQLite (`state.vscdb`) en cache-terugval, zonder externe API-aanroepen of het opslaan van inloggegevens.

## Problemen oplossen

**Er verschijnt een Claude-waarschuwing.** Open het dropdownmenu voor de reden. *Sign in to Claude Code again* betekent dat het OAuth-token is verlopen — meld je opnieuw aan via de Claude Code CLI of de IDE-extensie. **Dit is niet de Claude-desktopapp**: inloggen bij Claude.app vernieuwt dit token niet. *Rate limited* lost zichzelf op; de plugin wacht 15 minuten en toont de resterende tijd.

**Er verschijnt een Codex-waarschuwing.** De helper ontbreekt of Codex heeft nog geen gegevens. Voer het installatieprogramma opnieuw uit en gebruik Codex CLI één keer.

**Gemini toont een waarschuwing.** Antigravity is nog niet gestart of de lokale helper wacht op gegevens. Start Antigravity Desktop of Antigravity IDE.

**Kleuren verschillen tussen menubalk en menu.** macOS kan een doorschijnende menubalk als licht behandelen terwijl menu’s donker zijn. De tweekleurige vectorweergave wordt gebruikt als Python beschikbaar is; tekst in één kleur is alleen de fallback wanneer Python ontbreekt.

## Verwijderen

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licentie

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
