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

Ambas paletas usan colores saturados y de alto contraste: Claude usa naranja
y Codex cian. Con un 11–30% restante, el aviso mezcla naranja; con un 10% o
menos, el estado crítico mezcla rojo vivo. Codex conserva el azul en ambas
mezclas:

| Etapa | Uso | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% usado | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| aviso | 70–89% usado | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| crítico | 90–100% usado | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Ajustes

Abre el menú y elige **⚙ Ajustes de pantalla**. El panel permanece abierto para que puedas cambiar varias opciones seguidas sin que se cierre tras cada clic. Los cambios se aplican al instante.

| Ajuste | Efecto |
|---|---|
| Mostrar Claude | Mostrar u ocultar Claude |
| Mostrar Claude 5h | Mostrar u ocultar la ventana de 5 horas |
| Porcentaje de Claude 5h | Mostrar u ocultar su porcentaje |
| Mostrar Claude 7d | Mostrar u ocultar la ventana de 7 días |
| Porcentaje de Claude 7d | Mostrar u ocultar su porcentaje |
| Mostrar Codex | Mostrar u ocultar Codex |
| Mostrar Codex 5h | Mostrar u ocultar la ventana de 5 horas cuando esté disponible |
| Porcentaje de Codex 5h | Mostrar u ocultar el porcentaje de 5 horas |
| Mostrar Codex 7d | Mostrar u ocultar la ventana de 7 días |
| Porcentaje de Codex 7d | Mostrar u ocultar el porcentaje de 7 días |
| Intervalo de actualización | 1, 3 o 5 minutos |
| Idioma | 14 idiomas; sigue a macOS por defecto |

Si se ocultan todos los indicadores, queda un elemento neutro `AI …` para poder abrir los ajustes. El color depende solo de las barras visibles. Los ajustes están en `~/.cache/claude-codex-bar/` y se conservan al actualizar.

Al desactivar Claude o Codex, se detiene la actualización de datos de ese servicio. Los ajustes de 5h, 7d y porcentaje permanecen atenuados y bloqueados; al volver a activarlo se restauran sus valores anteriores.

El complemento comprueba GitHub Releases como máximo una vez al día. Si hay una actualización del operador, el menú y los ajustes muestran el aviso, las notas y **Actualizar ahora**.

## Fuentes de datos

**Claude** se lee del endpoint OAuth `api.anthropic.com/api/oauth/usage`, con el token que Claude Code ya guarda en el llavero de macOS (`Claude Code-credentials`, o `~/.claude/.credentials.json`). No se escribe en ninguno de los dos y el token solo sale del Mac en la petición a Anthropic. La primera vez, elige **Permitir siempre**.

Los resultados se guardan en caché durante el intervalo, así que solo se consulta una vez por intervalo. Si falla, se mantiene la última lectura válida.

**Codex** se lee del asistente local `codex-usage.sh` que el instalador coloca en `~/SwiftBar/.ai-usage-barometer/`. Sus ventanas son dinámicas.

## Solución de problemas

**Aparece un aviso de Claude.** No se encontró el elemento del llavero. Inicia sesión con Claude Code y pulsa **Actualizar ahora**.

**Aparece un aviso de Codex.** Falta el asistente o Codex aún no ha generado datos. Reinstala y usa Codex CLI una vez.

**Los colores difieren entre la barra y el menú.** macOS puede tratar una barra translúcida como clara aunque los menús sean oscuros. El renderizador vectorial de dos colores se usa cuando Python está disponible; el texto de un color solo se usa como alternativa cuando Python no está disponible.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licencia

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
