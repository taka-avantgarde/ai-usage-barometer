🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 Español · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalación — pega esta única línea en Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

El mismo comando funciona con o sin Homebrew e instala lo necesario automáticamente.

## ✅ v0.2.7: recuperación estable de la barra de menús

v0.2.7 incluye en este repositorio una copia probada del helper de Codex, elimina la sintaxis `;;&` incompatible con Bash 3.2 de macOS y regenera el encabezado vectorial con colores exactos después de cada actualización.

Claude y Codex se evalúan por separado: si un proveedor no tiene datos, el otro sigue visible. Cada ventana de 5h/7d conserva su propio nivel de color y se mantienen los ajustes existentes de **Settings**.

## Fuente de datos de Claude


El uso de Claude se captura desde el JSON documentado de `statusLine`, mediante `rate_limits.five_hour` y `rate_limits.seven_day`. El instalador conserva cualquier línea de estado existente.

Después de instalar, abre Claude Code y completa una respuesta. `rate_limits` aparece después de la primera respuesta de API y cada ventana puede faltar por separado. Solo se muestran ventanas reales; `Warming up` o datos ausentes nunca se convierten en un 100% inventado.

No se leen tokens OAuth, el Llavero de macOS ni `~/.claude/.credentials.json`.

## Un único elemento en la barra

Claude usa naranja y Codex azul, sin mostrar sus nombres en la barra de macOS. Cada ventana se colorea de forma independiente.

| Nivel | Uso | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex añade automáticamente `5h` cuando devuelve una ventana real de 300 minutos; si solo existe la semanal, muestra únicamente `7d`. En **Settings** puedes ocultar cada servicio y elegir 1, 3 o 5 minutos.

Si Claude no aparece, abre Claude Code y completa una respuesta. La línea de estado necesita confianza del espacio de trabajo y no funciona con `disableAllHooks: true`.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
