🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 Italiano · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installazione — incolla questa riga nel Terminale

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Lo stesso comando funziona con o senza Homebrew. Installa solo ciò che manca: Homebrew, `jq`, SwiftBar, il plugin e i suoi helper locali. Rieseguirlo è sicuro e serve anche ad aggiornare.

## Un solo elemento nella barra dei menu

Claude e Codex condividono un elemento, separati da una linea sottile. Le barre sono in stile batteria: **la parte piena è la capacità rimasta**, la coda punteggiata è ciò che è stato consumato. Anche le percentuali indicano il residuo.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

La barra dei menu è disegnata come immagine vettoriale, così ogni servizio mantiene il proprio colore in un unico elemento. Altrimenti si passa automaticamente al testo semplice.

Entrambe le palette restano chiare e mescolate con il bianco: Claude usa
bianco-arancio e Codex bianco-azzurro. La tonalità si intensifica leggermente
con l’aumentare dell’uso:

| Fase | Uso | Claude | Codex |
|---|---:|---|---|
| normale | 0–69% usato | ![#F2C6A0](assets/colors/claude-healthy.svg) `#F2C6A0` | ![#BEEAF3](assets/colors/codex-healthy.svg) `#BEEAF3` |
| attenzione | 70–89% usato | ![#EDA66F](assets/colors/claude-warning.svg) `#EDA66F` | ![#96DCE9](assets/colors/codex-warning.svg) `#96DCE9` |
| critico | 90–100% usato | ![#E88952](assets/colors/claude-critical.svg) `#E88952` | ![#6BC9DC](assets/colors/codex-critical.svg) `#6BC9DC` |

## Impostazioni

Apri il menu e usa **⚙ Impostazioni di visualizzazione**. Ogni voce si alterna con un clic e ha effetto immediato.

| Impostazione | Effetto |
|---|---|
| Mostra Claude | Mostra o nascondi Claude |
| Mostra Claude 5h | Mostra o nascondi la finestra di 5 ore |
| Percentuale di Claude 5h | Mostra o nascondi la relativa percentuale |
| Mostra Claude 7d | Mostra o nascondi la finestra di 7 giorni |
| Percentuale di Claude 7d | Mostra o nascondi la relativa percentuale |
| Mostra Codex | Mostra o nascondi Codex |
| Percentuale di Codex | Mostra o nascondi le percentuali di Codex |
| Barra dei menu a due colori | Vettoriale (due colori) o testo (un colore) |
| Intervallo di aggiornamento | 1, 3 o 5 minuti |
| Lingua | 14 lingue; segue macOS per impostazione predefinita |

Nascondere tutto lascerebbe un elemento vuoto e non cliccabile, perciò la barra di 5 ore di Claude resta sempre. Il colore dipende solo dalle barre visibili. Le impostazioni sono in `~/.cache/claude-codex-bar/` e sopravvivono agli aggiornamenti.

## Origini dei dati

**Claude** viene letto dall’endpoint OAuth `api.anthropic.com/api/oauth/usage`, con il token che Claude Code salva già nel portachiavi di macOS (`Claude Code-credentials`, altrimenti `~/.claude/.credentials.json`). Non vi si scrive nulla e il token lascia il Mac solo nella richiesta ad Anthropic. Al primo avvio scegli **Consenti sempre**.

I risultati sono memorizzati per la durata dell’intervallo, quindi l’endpoint viene interrogato al massimo una volta per intervallo. Se un aggiornamento fallisce, resta l’ultimo valore valido.

**Codex** viene letto dall’helper locale `codex-usage.sh` che l’installer colloca in `~/SwiftBar/.ai-usage-barometer/`. Le sue finestre sono dinamiche.

## Risoluzione dei problemi

**Compare un avviso di Claude.** La voce del portachiavi non è stata trovata. Accedi a Claude Code su questo Mac e fai clic su **Aggiorna ora**.

**Compare un avviso di Codex.** L’helper manca o Codex non ha ancora prodotto dati. Riesegui l’installer e usa Codex CLI una volta.

**I colori differiscono tra barra e menu.** macOS può trattare una barra traslucida come chiara mentre i menu sono scuri. Per questo si usa un colore per fase; se non basta, disattiva il disegno a due colori.

## Disinstallazione

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licenza

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
