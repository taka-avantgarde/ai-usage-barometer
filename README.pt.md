🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 Português · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalação — cole uma única linha no Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

O mesmo comando funciona com ou sem Homebrew. Quando necessário, instala Homebrew, jq, SwiftBar e o plugin unificado.

A barra de menus do macOS mostra apenas um item, sem os nomes Claude ou Codex. Claude aparece em laranja e Codex em azul.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## Definições

No menu, Claude e Codex podem ser mostrados ou ocultados separadamente. Pelo menos um serviço permanece visível.

> **Codex 5h:** O Codex nem sempre devolve um limite de 5 horas. Se o limite não existir ou não vier nos dados, a barra 5h do Codex fica oculta e apenas janelas disponíveis, como 7d, são mostradas. O plugin não inventa limites ausentes.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
