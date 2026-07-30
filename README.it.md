🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 Italiano · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installazione — incolla questa unica riga nel Terminale

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Lo stesso comando funziona con o senza Homebrew e installa automaticamente i componenti necessari.

## ✅ v0.2.7: ripristino stabile della barra dei menu

v0.2.7 include in questo repository una copia testata dell’helper Codex, rimuove la sintassi `;;&` non compatibile con Bash 3.2 di macOS e rigenera l’intestazione vettoriale con colori esatti dopo ogni aggiornamento.

Claude e Codex vengono valutati separatamente: i dati mancanti di un servizio non nascondono più l’altro. Ogni finestra 5h/7d mantiene il proprio livello di colore e le scelte esistenti in **Settings** vengono conservate.

## Origine dei dati Claude


L’uso di Claude viene acquisito dal JSON documentato di `statusLine`, tramite `rate_limits.five_hour` e `rate_limits.seven_day`. Un’eventuale status line esistente viene preservata.

Dopo l’installazione apri Claude Code e completa una risposta. `rate_limits` compare solo dopo la prima risposta API e ogni finestra può mancare in modo indipendente. Sono mostrate solo finestre reali; `Warming up` o dati mancanti non diventano mai un 100% inventato.

Non vengono letti token OAuth, il Keychain di macOS o `~/.claude/.credentials.json`.

## Un solo elemento nella barra

Claude usa l’arancione e Codex il blu, senza nomi nella barra macOS. Ogni finestra viene colorata separatamente.

| Livello | Uso | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex aggiunge automaticamente `5h` quando restituisce una vera finestra di 300 minuti; altrimenti mostra solo `7d`. In **Settings** puoi nascondere i servizi e scegliere 1, 3 o 5 minuti.

Se Claude non appare, apri Claude Code e completa una risposta. `statusLine` richiede la fiducia del workspace e non funziona con `disableAllHooks: true`.

## Disinstallazione

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
