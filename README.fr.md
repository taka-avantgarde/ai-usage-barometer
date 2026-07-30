🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 Français · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — collez cette ligne dans Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

La même commande fonctionne avec ou sans Homebrew et installe automatiquement les dépendances.

## ✅ v0.2.7 : rétablissement stable de la barre des menus

v0.2.7 intègre dans ce dépôt une copie testée de l’assistant Codex, supprime la syntaxe `;;&` incompatible avec le Bash 3.2 fourni par macOS et régénère l’en-tête vectoriel aux couleurs exactes après chaque mise à jour.

Claude et Codex sont évalués séparément : l’absence de données pour un fournisseur ne masque plus l’autre. Chaque fenêtre 5h/7d conserve son propre niveau de couleur et les choix **Settings** existants sont préservés.

## Source des données Claude


L’utilisation de Claude est capturée depuis le JSON documenté de `statusLine`, avec `rate_limits.five_hour` et `rate_limits.seven_day`. Toute ligne d’état existante est préservée.

Après l’installation, ouvrez Claude Code et terminez une réponse. `rate_limits` n’apparaît qu’après la première réponse API et chaque fenêtre peut être absente indépendamment. Seules les limites réellement retournées sont affichées ; `Warming up` ou une donnée absente ne devient jamais un faux 100 %.

Aucun jeton OAuth, élément du Trousseau macOS ou fichier `~/.claude/.credentials.json` n’est lu.

## Un seul élément dans la barre

Claude est orange, Codex bleu, sans afficher leurs noms dans la barre macOS. Chaque fenêtre est colorée séparément.

| Niveau | Utilisation | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69 % | `#b54f02` | `#4F7FA8` |
| 2 | 70–89 % | `#B85A00` | `#0e8ba1` |
| 3 | 90–100 % | `#ff7045` | `#ed5d40` |

Codex ajoute automatiquement `5h` lorsqu’une vraie fenêtre de 300 minutes est retournée ; sinon seule `7d` apparaît. **Settings** permet de masquer chaque service et de choisir 1, 3 ou 5 minutes.

Si Claude n’apparaît pas, ouvrez Claude Code et terminez une réponse. `statusLine` exige la confiance du workspace et ne s’exécute pas avec `disableAllHooks: true`.

## Désinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
