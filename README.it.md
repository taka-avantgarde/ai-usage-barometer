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

Entrambe le palette usano colori saturi e ad alto contrasto: Claude usa
l’arancione e Codex il ciano. Con l’11–30% rimanente, l’avviso incorpora
arancione; con il 10% o meno, lo stato critico incorpora rosso vivo. Codex
mantiene una forte componente blu in entrambe le miscele:

| Fase | Uso | Claude | Codex |
|---|---:|---|---|
| normale | 0–69% usato | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| attenzione | 70–89% usato | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| critico | 90–100% usato | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Impostazioni

Apri il menu e scegli **⚙ Impostazioni di visualizzazione**. Il pannello resta aperto, così puoi modificare più opzioni di seguito senza riaprirlo dopo ogni clic. Le modifiche hanno effetto immediato.

| Impostazione | Effetto |
|---|---|
| Mostra Claude | Mostra o nascondi Claude |
| Mostra Claude 5h | Mostra o nascondi la finestra di 5 ore |
| Percentuale di Claude 5h | Mostra o nascondi la relativa percentuale |
| Mostra Claude 7d | Mostra o nascondi la finestra di 7 giorni |
| Percentuale di Claude 7d | Mostra o nascondi la relativa percentuale |
| Mostra Codex | Mostra o nascondi Codex |
| Mostra Codex 5h | Mostra o nascondi la finestra di 5 ore se disponibile |
| Percentuale di Codex 5h | Mostra o nascondi la percentuale di 5 ore |
| Mostra Codex 7d | Mostra o nascondi la finestra di 7 giorni |
| Percentuale di Codex 7d | Mostra o nascondi la percentuale di 7 giorni |
| Intervallo di aggiornamento | 1, 3 o 5 minuti |
| Lingua | 14 lingue; segue macOS per impostazione predefinita |

Quando tutti gli indicatori sono nascosti, rimane una voce neutra `AI …` per aprire le impostazioni. Il colore dipende solo dalle barre visibili. Le impostazioni sono in `~/.cache/claude-codex-bar/` e sopravvivono agli aggiornamenti.

Disattivando Claude o Codex, l’aggiornamento dei dati di quel servizio viene sospeso. Le impostazioni 5h, 7d e percentuale restano attenuate e bloccate; i valori precedenti vengono ripristinati quando il servizio viene riattivato.

Il plugin controlla GitHub Releases al massimo una volta al giorno. Se è disponibile un aggiornamento dell’operatore, menu e impostazioni mostrano avviso, note e **Aggiorna ora**.

## Origini dei dati

**Claude** viene letto dall’endpoint OAuth `api.anthropic.com/api/oauth/usage`, con il token che Claude Code salva già nel portachiavi di macOS (`Claude Code-credentials`, altrimenti `~/.claude/.credentials.json`). Non vi si scrive nulla e il token lascia il Mac solo nella richiesta ad Anthropic. Al primo avvio scegli **Consenti sempre**.

I risultati sono memorizzati per la durata dell’intervallo, quindi l’endpoint viene interrogato al massimo una volta per intervallo. Se un aggiornamento fallisce, resta l’ultimo valore valido.

**Codex** viene letto dall’helper locale `codex-usage.sh` che l’installer colloca in `~/SwiftBar/.ai-usage-barometer/`. Le sue finestre sono dinamiche.

## Risoluzione dei problemi

**Compare un avviso di Claude.** La voce del portachiavi non è stata trovata. Accedi a Claude Code su questo Mac e fai clic su **Aggiorna ora**.

**Compare un avviso di Codex.** L’helper manca o Codex non ha ancora prodotto dati. Riesegui l’installer e usa Codex CLI una volta.

**I colori differiscono tra barra e menu.** macOS può trattare una barra traslucida come chiara mentre i menu sono scuri. Il renderer vettoriale a due colori viene usato quando Python è disponibile; il testo a un colore è solo il fallback quando Python non è disponibile.

## Disinstallazione

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licenza

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
