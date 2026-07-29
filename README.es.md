🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 Español · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalación — pega esta única línea en Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

El mismo comando funciona en Mac con o sin Homebrew. Cuando hace falta, instala Homebrew, `jq`, SwiftBar, el complemento unificado y los auxiliares de Claude/Codex.

Un solo elemento de SwiftBar muestra ambos servicios. **La barra de menús de macOS no muestra los nombres Claude ni Codex.** Claude usa tonos naranjas y Codex tonos azules.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: corregidos los dos problemas de recuperación

- **Claude después de un reinicio:** si Claude devuelve `Warming up`, valores cero, ventanas nulas o una instantánea antigua cuyo momento de reinicio ya pasó, el complemento ya no queda bloqueado en un error. Restaura 5h y 7d como reiniciados/en espera con 100% disponible y los sustituye por datos en vivo en la siguiente actualización correcta. No hace falta reinstalar.
- **El límite 5h de Codex vuelve más tarde:** las ventanas de Codex se detectan dinámicamente. Si Codex vuelve a devolver una ventana de 300 minutos, la barra `5h` aparece automáticamente en la siguiente actualización. Si no existe, solo se muestra la ventana disponible, como `7d`.

Usa **Refresh now** en el menú para solicitar una actualización inmediata.

## 🎨 Tres niveles de color independientes

Cada ventana de 5h o 7d se evalúa por separado.

| Nivel | Uso | Claude | Codex |
|---|---:|---|---|
| 1 — normal | 0–69% usado | `#b54f02` | `#4F7FA8` |
| 2 — aviso | 70–89% usado | `#B85A00` | `#0e8ba1` |
| 3 — crítico | 90–100% usado | `#ff7045` | `#ed5d40` |

El encabezado se genera como un pequeño PDF vectorial con herramientas integradas de macOS, sin Xcode Command Line Tools.

## Ajustes y detalles

El menú muestra nombres de servicio, uso, capacidad restante y hora de reinicio. En **Settings** puedes mostrar u ocultar Claude y Codex por separado; siempre queda al menos uno visible. El intervalo puede ser de 1, 3 o 5 minutos.

> **Codex 5h:** el complemento no inventa un límite ausente. Oculta 5h hasta que Codex devuelve una ventana real de 300 minutos y entonces la añade automáticamente.

Los complementos independientes existentes se mueven a una carpeta auxiliar oculta para evitar elementos duplicados sin borrar los archivos.

## Requisitos y privacidad

- macOS; el instalador gestiona Homebrew, `jq` y SwiftBar.
- Claude Code con sesión iniciada.
- Codex CLI o la aplicación Codex usados en el Mac.
- Los tokens de autenticación nunca se imprimen ni se copian en la caché.
- Algunas interfaces de uso no son oficiales y pueden requerir futuras actualizaciones.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licencia

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
