🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 Français · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

**Suivez Claude, Codex et Gemini en un coup d'œil et en temps réel sur 3 surfaces Mac : barre de menus, icône du Dock et barre flottante.**

| Service IA | Couleur | Sources compatibles |
|:---|:---|:---|
| **Claude** | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | Claude Code (API d'utilisation OAuth et trousseau) |
| **Codex** | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | Codex CLI et jetons web (`5h` et `1w`) |
| **Gemini** | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` | Google Antigravity Desktop & IDE (`5h` et `1w`) |

<img src="assets/hero.svg" alt="AI Usage Barometer dans la barre de menus, l'icône du Dock et une barre flottante" width="725">

## ⚡ Installation — collez cette ligne dans le Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

C'est l'application. Sans Homebrew, sans Xcode. macOS 13 ou ultérieur. Au premier lancement elle demande où elle doit vivre — barre de menus, icône du Dock ou barre flottante — et son menu permet d'en changer à tout moment.

## Un seul élément dans la barre de menus

Claude, Codex et Gemini partagent un élément, séparés par un trait fin. Les barres sont de type batterie : **la partie pleine est la capacité restante**, la traîne pointillée est ce qui a été consommé. Les pourcentages indiquent aussi le restant.

```text
5h ███░·  1w ██░░·  │  5h ████·  1w ███░·  │  5h ████·  1w ███░·
└──── Claude ────┘     └───── Codex ─────┘     └──── Gemini ────┘
```

La barre de menus est dessinée en vectoriel afin que chaque service garde sa couleur dans un même élément. Un repli en texte simple est utilisé automatiquement si nécessaire.

Les deux palettes utilisent des couleurs saturées et très contrastées : Claude
utilise l’orange et Codex le cyan. Entre 11 et 30% restants, l’alerte incorpore
de l’orange ; à 10% ou moins, l’état critique incorpore un rouge vif. Codex
conserve du bleu dans les deux mélanges :

| Étape | Usage | Claude | Codex | Gemini |
|---|---:|---|---|---|
| normal | 0–69% utilisé | ![#C66D28](assets/colors/claude-healthy.svg) `#C66D28` | ![#1A8BA6](assets/colors/codex-healthy.svg) `#1A8BA6` | ![#158F6A](assets/colors/gemini-healthy.svg) `#158F6A` |
| alerte | 70–89% utilisé | ![#B65A1E](assets/colors/claude-warning.svg) `#B65A1E` | ![#52768A](assets/colors/codex-warning.svg) `#52768A` | ![#5E7B3A](assets/colors/gemini-warning.svg) `#5E7B3A` |
| critique | 90–100% utilisé | ![#C52E22](assets/colors/claude-critical.svg) `#C52E22` | ![#783F78](assets/colors/codex-critical.svg) `#783F78` | ![#8C3B5A](assets/colors/gemini-critical.svg) `#8C3B5A` |

## Réglages

Ouvrez le menu et choisissez **⚙ Display settings**. Le panneau reste ouvert afin de modifier plusieurs options à la suite sans qu’il se ferme après chaque clic. Les changements s’appliquent immédiatement.

L’interface du module est uniquement en anglais. Cette documentation GitHub reste disponible en 14 langues.

| Réglage | Effet |
|---|---|
| **Claude** (`ON` / `OFF`) | Afficher ou masquer Claude entièrement (s'applique à `5h` et `1w`) |
| **Claude `5h`** + **`%`** | Afficher ou masquer la fenêtre de 5 heures et son pourcentage |
| **Claude `1w`** + **`%`** | Afficher ou masquer la fenêtre d'une semaine (7d) et son pourcentage |
| **Codex** (`ON` / `OFF`) | Afficher ou masquer Codex entièrement (s'applique à `5h` et `1w`) |
| **Codex `5h`** + **`%`** | Afficher ou masquer la fenêtre de 5 heures (Codex 5h) et son pourcentage |
| **Codex `1w`** + **`%`** | Afficher ou masquer la fenêtre d'une semaine (Codex 7d) et son pourcentage |
| **Gemini** (`ON` / `OFF`) | Afficher ou masquer Gemini entièrement (s'applique à `5h` et `1w`) |
| **Gemini `5h`** + **`%`** | Afficher ou masquer la fenêtre de 5 heures (`5h`) et son pourcentage |
| **Gemini `1w`** + **`%`** | Afficher ou masquer la fenêtre d'une semaine (`1w` / 7d) et son pourcentage |
| **Emplacement** (`Menu bar` / `Dock icon` / `Floating bar`) | Choisir n'importe quelle combinaison des trois emplacements d'affichage |
| **Intervalle d'actualisation** (`1m` / `3m` / `5m`) | 1 minute, 3 minutes ou 5 minutes |

Si toutes les jauges sont masquées, un élément neutre `AI …` reste disponible pour ouvrir les réglages. La couleur ne dépend que des jauges affichées. Les réglages sont dans `~/.cache/claude-codex-bar/` et survivent aux mises à jour.

Lorsque Claude ou Codex est désactivé, la mise à jour des données de ce service est arrêtée. Les réglages 5h, 7d et pourcentage restent grisés et verrouillés ; leurs valeurs précédentes sont restaurées lors de la réactivation.

Si les fenêtres 5h et 7d d’un service sont toutes deux décochées, le service et ses erreurs sont entièrement masqués et sa source de données n’est pas interrogée.

L'application et le plugin vérifient automatiquement GitHub Releases toutes les 15 minutes et se mettent à jour en arrière-plan lorsqu'une nouvelle version est publiée.

## L'application — choisissez où elle vit

La barre de menus n'est pas toujours disponible. Sur certains Mac l'élément
d'état est placé hors de l'écran et n'est jamais dessiné, et à côté de
l'encoche il n'y a parfois tout simplement plus de place. L'application place
les mêmes jauges là où vous le décidez.

| Emplacement | Description |
|---|---|
| **Barre de menus** | L'élément d'état de l'application elle-même, sur une ligne |
| **Icône du Dock** | L'icône du Dock devient la jauge. N'occupe aucun espace écran |
| **Barre flottante** | Une petite barre toujours au premier plan. Déplacez-la où vous voulez |

Les trois sont indépendants : activez la combinaison qui vous convient. Un
clic droit sur la barre, sur l'icône du Dock ou sur l'élément de la barre de
menus ouvre les réglages : chaque service activé ou non, les pourcentages,
l'emplacement, et **Details…** pour le panneau avec les temps de récupération.

Désactiver une jauge rend la largeur : l'élément se réduit à ce qui reste, et la barre de menus récupère la différence.

Une flèche orange signale une mise à jour en attente. **Update to vX.Y.Z**, dans le même menu, l'installe sur place.

Une seule ligne, sans Xcode. macOS 13 ou ultérieur.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install-app.sh)"
```

L'application est signée et notarisée par Apple : elle s'ouvre directement après le téléchargement, sans avertissement ni clic droit.

Ou lancez-la depuis les sources, ce qui demande Xcode :

```bash
git clone https://github.com/taka-avantgarde/ai-usage-barometer.git
cd ai-usage-barometer/app && swift run
```

## Sources de données

**Claude** provient du point de terminaison OAuth `api.anthropic.com/api/oauth/usage`, avec le jeton que Claude Code stocke déjà dans le trousseau macOS (`Claude Code-credentials`, sinon `~/.claude/.credentials.json`). Rien n’y est écrit et le jeton ne quitte le Mac que dans la requête vers Anthropic. Au premier lancement, choisissez **Toujours autoriser**.

Les résultats sont mis en cache pendant l’intervalle : le point de terminaison n’est interrogé qu’une fois par intervalle. En cas d’échec, la dernière valeur valide reste affichée.

**Codex** est lu à partir de l'assistant local `codex-usage.sh` placé dans `.ai-usage-barometer/`. Il suit les fenêtres `5h` et `1w` (`7d`) dans l'ordre `5h → 1w` (même lorsque la fenêtre de 5 heures n'a pas encore été consommée).

**Gemini** est lu à partir de l'assistant local `gemini-usage.sh` fourni avec l'application. Il prend en charge Antigravity Desktop App 2.0 et Antigravity IDE, lisant en toute sécurité les fenêtres `5h` et `1w` localement via Connect RPC (`RetrieveUserQuotaSummary` / `GetUserStatus`), SQLite (`state.vscdb`) et cache de secours, sans appel d'API externe ni écriture d'identifiants.

## Dépannage

**Un avertissement Claude s’affiche.** Ouvrez le menu déroulant pour connaître la raison. *Sign in to Claude Code again* signifie que le jeton OAuth a expiré — reconnectez-vous via la CLI Claude Code ou l’extension IDE. **Ce n’est pas l’application de bureau Claude** : se connecter à Claude.app ne renouvelle pas ce jeton. *Rate limited* se résout tout seul ; le plugin patiente 15 minutes et affiche le temps restant.

**Un avertissement Codex s’affiche.** L’assistant manque ou Codex n’a pas encore produit de données. Relancez l’installateur puis utilisez Codex CLI une fois.

**Gemini affiche un avertissement.** Antigravity n'a pas encore été lancé ou l'assistant local attend des données. Lancez Antigravity Desktop ou Antigravity IDE.

**Les couleurs diffèrent entre la barre et le menu.** macOS peut considérer une barre translucide comme claire alors que les menus sont sombres. Le rendu vectoriel en deux couleurs est utilisé lorsque Python est disponible ; le texte en une couleur ne sert que de solution de secours si Python manque.

## Désinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licence

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
