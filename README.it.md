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

## Impostazioni

Dal menu puoi mostrare o nascondere Claude e Codex separatamente. Almeno un servizio rimane visibile.

> **Codex 5h:** Codex non restituisce sempre un limite di 5 ore. Se non esiste o non è incluso nei dati, la barra 5h di Codex viene nascosta e vengono mostrate solo le finestre disponibili, come 7d. Il plugin non inventa limiti mancanti.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
