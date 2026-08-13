🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 Português · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Instalação — cole esta linha no Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

O mesmo comando funciona com ou sem Homebrew. Instala apenas o que falta: Homebrew, `jq`, SwiftBar, o plugin e seus auxiliares locais. Executar de novo é seguro e serve como atualização.

## Um único item na barra de menus

Claude e Codex dividem um item, separados por um traço fino. As barras são estilo bateria: **a parte preenchida é a capacidade restante** e a cauda pontilhada é o que já foi gasto. As porcentagens também são do restante.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

A barra de menus é desenhada como imagem vetorial para que cada serviço mantenha sua cor dentro de um mesmo item. Caso não seja possível, usa-se texto simples automaticamente.

As duas paletas usam cores saturadas e de alto contraste: Claude usa laranja e
Codex ciano. Com 11–30% restante, o aviso mistura laranja; com 10% ou menos, o
estado crítico mistura vermelho vivo. Codex mantém azul forte nas duas
misturas:

| Estágio | Uso | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% usado | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| aviso | 70–89% usado | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| crítico | 90–100% usado | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Configurações

Abra o menu e escolha **⚙ Configurações de exibição**. O painel permanece aberto para alterar várias opções em sequência, sem fechar após cada clique. As mudanças entram em vigor imediatamente.

| Ajuste | Efeito |
|---|---|
| Mostrar Claude | Mostrar ou ocultar o Claude |
| Mostrar Claude 5h | Mostrar ou ocultar a janela de 5 horas |
| Porcentagem de Claude 5h | Mostrar ou ocultar sua porcentagem |
| Mostrar Claude 7d | Mostrar ou ocultar a janela de 7 dias |
| Porcentagem de Claude 7d | Mostrar ou ocultar sua porcentagem |
| Mostrar Codex | Mostrar ou ocultar o Codex |
| Mostrar Codex 5h | Mostrar ou ocultar a janela de 5 horas quando disponível |
| Porcentagem do Codex 5h | Mostrar ou ocultar a porcentagem de 5 horas |
| Mostrar Codex 7d | Mostrar ou ocultar a janela de 7 dias |
| Porcentagem do Codex 7d | Mostrar ou ocultar a porcentagem de 7 dias |
| Intervalo de atualização | 1, 3 ou 5 minutos |
| Idioma | 14 idiomas; segue o macOS por padrão |

Quando todos os medidores estão ocultos, um item neutro `AI …` permanece para abrir as configurações. A cor considera apenas as barras visíveis. As configurações ficam em `~/.cache/claude-codex-bar/` e sobrevivem a atualizações.

Ao desativar o Claude ou o Codex, a atualização de dados desse serviço é interrompida. As configurações de 5h, 7d e porcentagem permanecem esmaecidas e bloqueadas; ao reativar o serviço, os valores anteriores são restaurados.

O plugin verifica o GitHub Releases no máximo uma vez por dia. Se houver atualização do operador, o menu e as configurações mostram o aviso, as notas e **Atualizar agora**.

## Fontes de dados

**Claude** é lido do endpoint OAuth `api.anthropic.com/api/oauth/usage`, com o token que o Claude Code já guarda nas Chaves do macOS (`Claude Code-credentials`, ou `~/.claude/.credentials.json`). Nada é escrito nesses locais e o token só sai do Mac na requisição à Anthropic. Na primeira execução, escolha **Sempre permitir**.

Os resultados ficam em cache durante o intervalo, então o endpoint é consultado no máximo uma vez por intervalo. Se falhar, a última leitura válida permanece.

**Codex** é lido do auxiliar local `codex-usage.sh` que o instalador coloca em `~/SwiftBar/.ai-usage-barometer/`. Suas janelas são dinâmicas.

## Solução de problemas

**Aparece um aviso do Claude.** A entrada das Chaves não foi encontrada. Entre no Claude Code neste Mac e clique em **Atualizar agora**.

**Aparece um aviso do Codex.** O auxiliar está ausente ou o Codex ainda não gerou dados. Reexecute o instalador e use o Codex CLI uma vez.

**As cores diferem entre a barra e o menu.** O macOS pode tratar uma barra translúcida como clara enquanto os menus são escuros. O renderizador vetorial de duas cores é usado quando o Python está disponível; o texto de uma cor só é usado como fallback quando o Python não está disponível.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licença

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
