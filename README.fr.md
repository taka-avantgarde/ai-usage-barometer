🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 Français · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — collez cette ligne dans le Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

La même commande fonctionne avec ou sans Homebrew. Elle installe seulement ce qui manque : Homebrew, `jq`, SwiftBar, le plugin et ses assistants locaux. La relancer est sans risque, utilisez-la aussi pour mettre à jour.

## Un seul élément dans la barre de menus

Claude et Codex partagent un élément, séparés par un trait fin. Les barres sont de type batterie : **la partie pleine est la capacité restante**, la traîne pointillée est ce qui a été consommé. Les pourcentages indiquent aussi le restant.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

La barre de menus est dessinée en vectoriel afin que chaque service garde sa couleur dans un même élément. Un repli en texte simple est utilisé automatiquement si nécessaire.

Les deux palettes utilisent des couleurs saturées et très contrastées : Claude
utilise l’orange et Codex le cyan. Entre 11 et 30% restants, l’alerte incorpore
de l’orange ; à 10% ou moins, l’état critique incorpore un rouge vif. Codex
conserve du bleu dans les deux mélanges :

| Étape | Usage | Claude | Codex |
|---|---:|---|---|
| normal | 0–69% utilisé | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` |
| alerte | 70–89% utilisé | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` |
| critique | 90–100% utilisé | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` |

## Réglages

Ouvrez le menu et utilisez **⚙ Réglages d’affichage**. Chaque entrée bascule au clic et s’applique immédiatement.

| Réglage | Effet |
|---|---|
| Afficher Claude | Afficher ou masquer Claude |
| Afficher Claude 5h | Afficher ou masquer la fenêtre 5 heures |
| Pourcentage de Claude 5h | Afficher ou masquer son pourcentage |
| Afficher Claude 7d | Afficher ou masquer la fenêtre 7 jours |
| Pourcentage de Claude 7d | Afficher ou masquer son pourcentage |
| Afficher Codex | Afficher ou masquer Codex |
| Pourcentage de Codex | Afficher ou masquer les pourcentages Codex |
| Barre de menus en deux couleurs | Vectoriel (deux couleurs) ou texte (une couleur) |
| Intervalle d’actualisation | 1, 3 ou 5 minutes |
| Langue | 14 langues ; suit macOS par défaut |

Tout masquer laisserait un élément vide et non cliquable : la barre 5 heures de Claude est donc toujours conservée. La couleur ne dépend que des jauges affichées. Les réglages sont dans `~/.cache/claude-codex-bar/` et survivent aux mises à jour.

## Sources de données

**Claude** provient du point de terminaison OAuth `api.anthropic.com/api/oauth/usage`, avec le jeton que Claude Code stocke déjà dans le trousseau macOS (`Claude Code-credentials`, sinon `~/.claude/.credentials.json`). Rien n’y est écrit et le jeton ne quitte le Mac que dans la requête vers Anthropic. Au premier lancement, choisissez **Toujours autoriser**.

Les résultats sont mis en cache pendant l’intervalle : le point de terminaison n’est interrogé qu’une fois par intervalle. En cas d’échec, la dernière valeur valide reste affichée.

**Codex** est lu depuis l’assistant local `codex-usage.sh` placé par l’installateur dans `~/SwiftBar/.ai-usage-barometer/`. Ses fenêtres sont dynamiques.

## Dépannage

**Un avertissement Claude s’affiche.** L’élément du trousseau est introuvable. Connectez-vous à Claude Code puis cliquez sur **Actualiser**.

**Un avertissement Codex s’affiche.** L’assistant manque ou Codex n’a pas encore produit de données. Relancez l’installateur puis utilisez Codex CLI une fois.

**Les couleurs diffèrent entre la barre et le menu.** macOS peut considérer une barre translucide comme claire alors que les menus sont sombres. C’est pourquoi une seule couleur par étape est utilisée ; sinon, désactivez le dessin en deux couleurs.

## Désinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licence

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
