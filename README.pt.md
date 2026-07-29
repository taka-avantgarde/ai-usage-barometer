🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 Português · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalação — cole esta única linha no Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

O mesmo comando funciona em Macs com ou sem Homebrew. Quando necessário, instala Homebrew, `jq`, SwiftBar, o plugin unificado e os auxiliares Claude/Codex.

Um único item do SwiftBar mostra os dois serviços. **A barra de menus do macOS não mostra os nomes Claude ou Codex.** Claude usa tons de laranja e Codex tons de azul.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: os dois problemas de recuperação foram corrigidos

- **Claude após a redefinição:** se o Claude devolver `Warming up`, valores zero, janelas nulas ou um instantâneo antigo cuja hora de redefinição já passou, o plugin deixa de ficar preso num erro. As barras 5h e 7d regressam ao estado redefinido/em espera com 100% disponível e são substituídas por valores em tempo real na atualização seguinte. Não é necessário reinstalar.
- **A janela Codex 5h regressa mais tarde:** as janelas Codex são detetadas dinamicamente. Se o Codex voltar a devolver uma janela de 300 minutos, a barra `5h` aparece automaticamente na atualização seguinte. Caso contrário, só aparece a janela disponível, como `7d`.

Use **Refresh now** para pedir uma atualização imediata.

## 🎨 Três níveis de cor independentes

Cada janela 5h ou 7d é avaliada separadamente.

| Nível | Utilização | Claude | Codex |
|---|---:|---|---|
| 1 — normal | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — aviso | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — crítico | 90–100% | `#ff7045` | `#ed5d40` |

O cabeçalho é gerado como um pequeno PDF vetorial com as ferramentas integradas do macOS, sem Xcode Command Line Tools.

## Definições e detalhes

O menu mostra nomes dos serviços, utilização, capacidade restante e hora de redefinição. Em **Settings**, Claude e Codex podem ser mostrados ou ocultados separadamente; pelo menos um fica visível. O intervalo pode ser de 1, 3 ou 5 minutos.

> **Codex 5h:** o plugin não inventa um limite ausente. Oculta 5h até receber uma janela real de 300 minutos e, então, adiciona-a automaticamente.

Os plugins autónomos existentes são movidos para uma pasta de suporte oculta para evitar itens duplicados sem apagar os ficheiros.

## Requisitos e privacidade

- macOS; o instalador trata de Homebrew, `jq` e SwiftBar.
- Claude Code com sessão iniciada.
- Codex CLI ou a aplicação Codex utilizados no Mac.
- Os tokens de autenticação nunca são mostrados nem copiados para a cache.
- Algumas interfaces de utilização não são oficiais e podem exigir futuras atualizações.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licença

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
