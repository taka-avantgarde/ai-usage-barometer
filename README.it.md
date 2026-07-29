🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 Italiano · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installazione — incolla questa sola riga nel Terminale

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Lo stesso comando funziona sui Mac con o senza Homebrew. Se necessario installa Homebrew, `jq`, SwiftBar, il plugin unificato e gli helper Claude/Codex.

Un solo elemento SwiftBar mostra entrambi i servizi. **La barra dei menu di macOS non mostra i nomi Claude o Codex.** Claude usa tonalità arancioni e Codex tonalità blu.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: risolti entrambi i problemi di ripristino

- **Claude dopo un reset:** se Claude restituisce `Warming up`, valori zero, finestre nulle o uno snapshot obsoleto con l’ora di reset già trascorsa, il plugin non rimane più bloccato su un errore. Le barre 5h e 7d tornano allo stato ripristinato/in attesa con 100% disponibile e vengono sostituite dai valori live al successivo aggiornamento riuscito. Non serve reinstallare.
- **La finestra Codex 5h ritorna in seguito:** le finestre Codex vengono rilevate dinamicamente. Se Codex torna a restituire una finestra di 300 minuti, la barra `5h` appare automaticamente al successivo aggiornamento. Se manca, viene mostrata solo la finestra disponibile, ad esempio `7d`.

Usa **Refresh now** per richiedere subito un aggiornamento.

## 🎨 Tre livelli di colore indipendenti

Ogni finestra 5h o 7d viene valutata separatamente.

| Livello | Utilizzo | Claude | Codex |
|---|---:|---|---|
| 1 — normale | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — avviso | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — critico | 90–100% | `#ff7045` | `#ed5d40` |

L’intestazione viene generata come piccolo PDF vettoriale con gli strumenti integrati di macOS, senza Xcode Command Line Tools.

## Impostazioni e dettagli

Il menu mostra nomi dei servizi, utilizzo, capacità residua e ora di reset. In **Settings** Claude e Codex possono essere mostrati o nascosti separatamente; almeno un servizio resta visibile. L’intervallo può essere 1, 3 o 5 minuti.

> **Codex 5h:** il plugin non inventa un limite assente. Nasconde 5h finché Codex non restituisce una vera finestra di 300 minuti, quindi la aggiunge automaticamente.

I plugin autonomi esistenti vengono spostati in una cartella di supporto nascosta per evitare duplicati senza eliminare i file.

## Requisiti e privacy

- macOS; l’installer gestisce Homebrew, `jq` e SwiftBar.
- Claude Code con accesso effettuato.
- Codex CLI o l’app Codex già utilizzati sul Mac.
- I token di autenticazione non vengono mai stampati né copiati nella cache.
- Alcune interfacce di utilizzo non sono ufficiali e potrebbero richiedere aggiornamenti futuri.

## Disinstallazione

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licenza

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
