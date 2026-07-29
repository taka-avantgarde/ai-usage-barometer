🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 Français · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — collez cette seule ligne dans Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

La même commande fonctionne avec ou sans Homebrew. Elle installe au besoin Homebrew, `jq`, SwiftBar, le plugin unifié et les assistants Claude/Codex.

Un seul élément SwiftBar affiche les deux services. **La barre de menus macOS n’affiche pas les noms Claude ou Codex.** Claude utilise des tons orange et Codex des tons bleus.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0 : les deux problèmes de récupération sont corrigés

- **Claude après une réinitialisation :** si Claude renvoie `Warming up`, des valeurs nulles, des fenêtres absentes ou un ancien instantané dont l’heure de réinitialisation est passée, le plugin ne reste plus bloqué sur une erreur. Les jauges 5h et 7d reviennent à un état réinitialisé/en attente avec 100 % disponibles, puis sont remplacées par les valeurs en direct au prochain rafraîchissement réussi. Aucune réinstallation n’est nécessaire.
- **Retour ultérieur de la fenêtre Codex 5h :** les fenêtres Codex sont détectées dynamiquement. Si Codex renvoie de nouveau une fenêtre de 300 minutes, la jauge `5h` apparaît automatiquement au prochain rafraîchissement. Sinon, seule la fenêtre disponible, comme `7d`, est affichée.

Utilisez **Refresh now** pour demander une mise à jour immédiate.

## 🎨 Trois niveaux de couleur indépendants

Chaque fenêtre 5h ou 7d est évaluée séparément.

| Niveau | Utilisation | Claude | Codex |
|---|---:|---|---|
| 1 — normal | 0–69 % | `#b54f02` | `#4F7FA8` |
| 2 — alerte | 70–89 % | `#B85A00` | `#0e8ba1` |
| 3 — critique | 90–100 % | `#ff7045` | `#ed5d40` |

L’en-tête est généré sous forme de petit PDF vectoriel avec les outils intégrés à macOS, sans Xcode Command Line Tools.

## Réglages et détails

Le menu affiche les noms des services, l’utilisation, la capacité restante et l’heure de réinitialisation. Dans **Settings**, Claude et Codex peuvent être affichés ou masqués séparément ; au moins un service reste visible. L’intervalle peut être réglé sur 1, 3 ou 5 minutes.

> **Codex 5h :** le plugin n’invente jamais une limite absente. Il masque 5h jusqu’à ce qu’une vraie fenêtre de 300 minutes soit renvoyée, puis l’ajoute automatiquement.

Les anciens plugins autonomes sont déplacés dans un dossier d’assistance masqué afin d’éviter les doublons sans supprimer les fichiers.

## Prérequis et confidentialité

- macOS ; l’installateur gère Homebrew, `jq` et SwiftBar.
- Claude Code connecté.
- Codex CLI ou l’application Codex déjà utilisée sur le Mac.
- Les jetons d’authentification ne sont jamais affichés ni copiés dans le cache.
- Certaines interfaces d’utilisation ne sont pas officielles et peuvent nécessiter de futures mises à jour.

## Désinstallation

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## Licence

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
