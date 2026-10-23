🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 Español · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Controla Claude, Codex y Gemini de un vistazo en tiempo real en 3 lugares de tu Mac: barra de menús, icono del Dock y barra flotante.**

| Servicio AI | Color | Fuentes compatibles |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (API de uso OAuth y llavero) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI y tokens web (`5h` y `1w`) |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop e IDE (`5h` y `1w`) |

<img src="assets/hero.svg" alt="AI Usage Barometer en la barra de menús, el icono del Dock y una barra flotante" width="725">

## ⚡ Instalación — pega esta línea en Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

Esa es la app. Sin Homebrew, sin Xcode. macOS 13 o posterior. La primera vez que se ejecuta pregunta dónde quieres que viva —barra de menús, icono del Dock o barra flotante— y puedes cambiarlo desde su menú cuando quieras.

## Un solo elemento en la barra de menús

Claude, Codex y Gemini comparten un elemento, separados por una línea fina. Las barras son tipo batería: **la parte llena es la capacidad restante** y la cola punteada es lo consumido. Los porcentajes también son capacidad restante.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

La barra de menús se dibuja como imagen vectorial para que cada servicio conserve su color dentro de un mismo elemento. Si no es posible, se usa texto plano automáticamente.

Ambas paletas usan colores saturados y de alto contraste: Claude usa naranja
y Codex cian. Con un 11–30% restante, el aviso mezcla naranja; con un 10% o
menos, el estado crítico mezcla rojo vivo. Codex conserva el azul en ambas
mezclas:

| Etapa | Uso | Claude | Codex | Gemini |
|---|---:|---|---|---|
| normal | 0–69% usado | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| aviso | 70–89% usado | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| crítico | 90–100% usado | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Ajustes

Abre el menú y elige **⚙ Display settings**. El panel permanece abierto para que puedas cambiar varias opciones seguidas sin que se cierre tras cada clic. Los cambios se aplican al instante.

La interfaz del complemento está disponible solo en inglés. Esta documentación de GitHub sigue disponible en 14 idiomas.

| Ajuste | Efecto |
|---|---|
| **Claude** (`ON` / `OFF`) | Mostrar u ocultar Claude por completo (se aplica a `5h` y `1w`) |
| **Claude `5h`** + **`%`** | Mostrar u ocultar la ventana de 5 horas y su porcentaje |
| **Claude `1w`** + **`%`** | Mostrar u ocultar la ventana de 1 semana (7d) y su porcentaje |
| **Codex** (`ON` / `OFF`) | Mostrar u ocultar Codex por completo (se aplica a `5h` y `1w`) |
| **Codex `5h`** + **`%`** | Mostrar u ocultar la ventana de 5 horas (Codex 5h) y su porcentaje |
| **Codex `1w`** + **`%`** | Mostrar u ocultar la ventana de 1 semana (Codex 7d) y su porcentaje |
| **Gemini** (`ON` / `OFF`) | Mostrar u ocultar Gemini por completo (se aplica a `5h` y `1w`) |
| **Gemini `5h`** + **`%`** | Mostrar u ocultar la ventana de 5 horas (`5h`) y su porcentaje |
| **Gemini `1w`** + **`%`** | Mostrar u ocultar la ventana de 1 semana (`1w` / 7d) y su porcentaje |
| **Ubicación** (`Menu bar` / `Dock icon` / `Floating bar`) | Elegir cualquier combinación de los tres lugares de visualización |
| **Intervalo de actualización** (`1m` / `3m` / `5m`) | 1 minuto, 3 minutos o 5 minutos |

Si se ocultan todos los indicadores, queda un elemento neutro `AI …` para poder abrir los ajustes. El color depende solo de las barras visibles. Los ajustes están en `~/.cache/claude-codex-bar/` y se conservan al actualizar.

Al desactivar Claude o Codex, se detiene la actualización de datos de ese servicio. Los ajustes de 5h, 7d y porcentaje permanecen atenuados y bloqueados; al volver a activarlo se restauran sus valores anteriores.

Si se desmarcan las ventanas de 5h y 7d de un servicio, el servicio y sus errores se ocultan por completo y no se consulta su fuente de datos.

La app y el complemento comprueban GitHub Releases automáticamente cada 15 minutos y se actualizan en segundo plano cuando se publica una nueva versión.

## La app — elige dónde vive

La barra de menús no siempre está disponible. En algunos Mac el elemento de
estado se coloca fuera de la pantalla y nunca se dibuja, y junto a la muesca
puede que sencillamente no quede sitio. La app coloca los mismos medidores
donde tú elijas.

| Lugar | Qué es |
|---|---|
| **Barra de menús** | El propio elemento de estado de la app, en una línea |
| **Icono del Dock** | El icono del Dock se convierte en el medidor. No ocupa pantalla |
| **Barra flotante** | Una barra pequeña siempre visible. Arrástrala donde quieras |

Los tres son independientes: activa la combinación que prefieras. Haz clic
derecho en la barra, en el icono del Dock o en el elemento de la barra de
menús para los ajustes: cada servicio activado o no, porcentajes, dónde vive
y **Details…** para el panel con los tiempos de recuperación.

Apagar un medidor devuelve el ancho: el elemento se encoge hasta ajustarse a lo que queda, y la barra de menús se queda con la diferencia.

Una flecha naranja indica que hay una actualización esperando. **Update to vX.Y.Z**, en el mismo menú, la instala sin más pasos.

Una sola línea, sin Xcode. macOS 13 o posterior.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

La app está firmada y notarizada por Apple, así que se abre directamente tras la descarga: sin avisos y sin clic derecho.

O ejecútala desde el código fuente, para lo que sí hace falta Xcode:

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

## Fuentes de datos

**Claude** se lee del endpoint OAuth `api.anthropic.com/api/oauth/usage`, con el token que Claude Code ya guarda en el llavero de macOS (`Claude Code-credentials`, o `~/.claude/.credentials.json`). No se escribe en ninguno de los dos y el token solo sale del Mac en la petición a Anthropic. La primera vez, elige **Permitir siempre**.

Los resultados se guardan en caché durante el intervalo, así que solo se consulta una vez por intervalo. Si falla, se mantiene la última lectura válida.

**Codex** se lee del asistente local `codex-usage.sh` que el instalador coloca en `.ai-usage-barometer/`. Rastrea tanto la ventana de `5h` como la de `1w` (`7d`) en orden `5h → 1w` (incluso cuando la ventana de 5 horas aún no se ha consumido).

**Gemini** se lee del asistente local `gemini-usage.sh` incluido con la app. Es compatible tanto con Antigravity Desktop App 2.0 como con Antigravity IDE, leyendo de forma segura las ventanas de `5h` y `1w` localmente a través de Connect RPC (`RetrieveUserQuotaSummary` / `GetUserStatus`), SQLite (`state.vscdb`) y respaldo en caché, sin llamadas a API externas ni escritura de credenciales.

## Solución de problemas

**Aparece un aviso de Claude.** Abre el menú desplegable para ver el motivo. *Sign in to Claude Code again* significa que el token OAuth caducó — vuelve a autenticarte con la CLI de Claude Code o la extensión del IDE. **No es la app de escritorio Claude**: iniciar sesión en Claude.app no renueva este token. *Rate limited* se resuelve solo; el plugin espera 15 minutos y muestra el tiempo restante.

**Aparece un aviso de Codex.** Falta el asistente o Codex aún no ha generado datos. Reinstala y usa Codex CLI una vez.

**Aparece un aviso de Gemini.** Antigravity aún no se ha iniciado o el asistente local espera datos. Abre Antigravity Desktop o Antigravity IDE.

**Los colores difieren entre la barra y el menú.** macOS puede tratar una barra translúcida como clara aunque los menús sean oscuros. El renderizador vectorial de dos colores se usa cuando Python está disponible; el texto de un color solo se usa como alternativa cuando Python no está disponible.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licencia

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
