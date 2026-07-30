🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 Português · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalação — cole esta única linha no Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

O mesmo comando funciona com ou sem Homebrew e instala automaticamente os componentes necessários.

## ✅ v0.2.7: recuperação estável da barra de menus

A v0.2.7 inclui neste repositório uma cópia testada do helper do Codex, remove a sintaxe `;;&` incompatível com o Bash 3.2 do macOS e recria o cabeçalho vetorial com cores exatas após cada atualização.

Claude e Codex são avaliados de forma independente: a falta de dados de um serviço não oculta o outro. Cada janela de 5h/7d mantém o seu próprio nível de cor e as escolhas atuais de **Settings** são preservadas.

## Fonte de dados do Claude


O uso do Claude é capturado do JSON documentado de `statusLine`, usando `rate_limits.five_hour` e `rate_limits.seven_day`. Qualquer linha de estado existente é preservada.

Depois da instalação, abra o Claude Code e conclua uma resposta. `rate_limits` só aparece após a primeira resposta da API e cada janela pode estar ausente separadamente. Apenas janelas reais são exibidas; `Warming up` ou dados ausentes nunca viram 100% inventado.

Nenhum token OAuth, item do Keychain do macOS ou `~/.claude/.credentials.json` é lido.

## Um único item na barra

Claude usa laranja e Codex azul, sem nomes na barra do macOS. Cada janela recebe cor de forma independente.

| Nível | Uso | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Quando o Codex devolve uma janela real de 300 minutos, `5h` aparece automaticamente; com apenas a janela semanal, só `7d` é mostrado. **Settings** permite ocultar serviços e escolher 1, 3 ou 5 minutos.

Se o Claude não aparecer, abra o Claude Code e conclua uma resposta. `statusLine` exige confiança no workspace e não roda com `disableAllHooks: true`.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
