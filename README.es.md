🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 Español · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalación — pega una sola línea en Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

El mismo comando funciona con o sin Homebrew. Instala Homebrew cuando hace falta, además de jq, SwiftBar y el complemento unificado.

La barra de macOS muestra un único elemento sin los nombres Claude o Codex. Claude aparece en naranja oscuro y Codex en azul.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## Ajustes

En el menú desplegable puedes mostrar u ocultar Claude o Codex por separado. Al menos uno permanece visible.

> **Codex 5h:** Codex no siempre devuelve un límite de 5 horas. Si no existe o no aparece en los datos, la barra 5h de Codex se oculta y solo se muestran ventanas disponibles como 7d. El complemento no inventa límites ausentes.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
