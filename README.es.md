🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 Español · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalación — pega esta línea en Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

El mismo comando funciona con o sin Homebrew. Instala solo lo que falta: Homebrew, `jq`, SwiftBar, el plugin y sus asistentes locales. Volver a ejecutarlo es seguro, úsalo también para actualizar.

## Un solo elemento en la barra de menús

Claude y Codex comparten un elemento, separados por una línea fina. Las barras son tipo batería: **la parte llena es la capacidad restante** y la cola punteada es lo consumido. Los porcentajes también son capacidad restante.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

La barra de menús se dibuja como imagen vectorial para que cada servicio conserve su color dentro de un mismo elemento. Si no es posible, se usa texto plano automáticamente.

El color depende del uso, así que una barra casi vacía se ve más intensa:

| Etapa | Uso | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% usado | `#F2C6A0` | `#BEEAF3` |
| aviso | 70–89% usado | `#EDA66F` | `#96DCE9` |
| crítico | 90–100% usado | `#E88952` | `#6BC9DC` |

## Ajustes

Abre el menú y usa **⚙ Ajustes de pantalla**. Cada entrada se alterna con un clic y se aplica al instante.

| Ajuste | Efecto |
|---|---|
| Mostrar Claude | Mostrar u ocultar Claude |
| Mostrar Claude 5h | Mostrar u ocultar la ventana de 5 horas |
| Porcentaje de Claude 5h | Mostrar u ocultar su porcentaje |
| Mostrar Claude 7d | Mostrar u ocultar la ventana de 7 días |
| Porcentaje de Claude 7d | Mostrar u ocultar su porcentaje |
| Mostrar Codex | Mostrar u ocultar Codex |
| Porcentaje de Codex | Mostrar u ocultar los porcentajes de Codex |
| Barra de menús a dos colores | Vectorial (dos colores) o texto (un color) |
| Intervalo de actualización | 1, 3 o 5 minutos |
| Idioma | 14 idiomas; sigue a macOS por defecto |

Ocultarlo todo dejaría un elemento vacío e imposible de pulsar, por eso siempre se conserva la barra de 5 horas de Claude. El color depende solo de las barras visibles. Los ajustes están en `~/.cache/claude-codex-bar/` y se conservan al actualizar.

## Fuentes de datos

**Claude** se lee del endpoint OAuth `api.anthropic.com/api/oauth/usage`, con el token que Claude Code ya guarda en el llavero de macOS (`Claude Code-credentials`, o `~/.claude/.credentials.json`). No se escribe en ninguno de los dos y el token solo sale del Mac en la petición a Anthropic. La primera vez, elige **Permitir siempre**.

Los resultados se guardan en caché durante el intervalo, así que solo se consulta una vez por intervalo. Si falla, se mantiene la última lectura válida.

**Codex** se lee del asistente local `codex-usage.sh` que el instalador coloca en `~/SwiftBar/.ai-usage-barometer/`. Sus ventanas son dinámicas.

## Solución de problemas

**Aparece un aviso de Claude.** No se encontró el elemento del llavero. Inicia sesión con Claude Code y pulsa **Actualizar ahora**.

**Aparece un aviso de Codex.** Falta el asistente o Codex aún no ha generado datos. Reinstala y usa Codex CLI una vez.

**Los colores difieren entre la barra y el menú.** macOS puede tratar una barra translúcida como clara aunque los menús sean oscuros. Por eso se usa un color por etapa; si aún se ve raro, desactiva el dibujo a dos colores.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licencia

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
