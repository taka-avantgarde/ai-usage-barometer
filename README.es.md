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

## 🎨 Tres niveles de color independientes

Cada ventana `5h` y `7d` se evalúa por separado. Nivel 1: 0–69% usado; nivel 2: 70–89%; nivel 3: 90–100%.

| Nivel | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

El encabezado de la barra de menús se renderiza como un pequeño PDF vectorial usando solo herramientas integradas de macOS, no como texto ANSI de 24 bits. Así se conserva el color HEX exacto de cada ventana sin necesitar Xcode Command Line Tools.

## Ajustes

En el menú desplegable puedes mostrar u ocultar Claude o Codex por separado. Al menos uno permanece visible.

> **Codex 5h:** Codex no siempre devuelve un límite de 5 horas. Si no existe o no aparece en los datos, la barra 5h de Codex se oculta y solo se muestran ventanas disponibles como 7d. El complemento no inventa límites ausentes.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
