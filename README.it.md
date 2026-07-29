🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 Italiano · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installazione — incolla una sola riga nel Terminale

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Lo stesso comando funziona con o senza Homebrew. Se necessario installa Homebrew, jq, SwiftBar e il plugin unificato.

La barra dei menu di macOS mostra un solo elemento, senza i nomi Claude o Codex. Claude è arancione scuro e Codex blu.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Tre livelli di colore indipendenti

Le finestre `5h` e `7d` vengono valutate separatamente. Livello 1: 0–69% usato; livello 2: 70–89%; livello 3: 90–100%.

| Livello | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

L’intestazione della barra dei menu viene renderizzata come un piccolo PDF vettoriale usando soltanto gli strumenti integrati di macOS, anziché come testo ANSI a 24 bit. SwiftBar mantiene così il colore HEX esatto di ogni finestra senza richiedere Xcode Command Line Tools.

## Impostazioni

Dal menu puoi mostrare o nascondere Claude e Codex separatamente. Almeno un servizio rimane visibile.

> **Codex 5h:** Codex non restituisce sempre un limite di 5 ore. Se non esiste o non è incluso nei dati, la barra 5h di Codex viene nascosta e vengono mostrate solo le finestre disponibili, come 7d. Il plugin non inventa limiti mancanti.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
