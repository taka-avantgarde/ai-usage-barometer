🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 Français · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 [한국어](README.ko.md) · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ Installation — collez une seule ligne dans Terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

La même commande fonctionne avec ou sans Homebrew. Elle installe Homebrew si nécessaire, puis jq, SwiftBar et le plugin unifié.

La barre de menus macOS affiche un seul élément, sans les noms Claude ou Codex. Claude est orange foncé et Codex bleu.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 Trois niveaux de couleur indépendants

Chaque fenêtre `5h` et `7d` est évaluée séparément. Niveau 1 : 0–69 % utilisés ; niveau 2 : 70–89 % ; niveau 3 : 90–100 %.

| Niveau | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

## Réglages

Le menu permet d’afficher ou de masquer Claude et Codex séparément. Au moins un service reste visible.

> **Codex 5h:** Codex ne renvoie pas toujours une limite de 5 heures. Si elle n’existe pas ou n’est pas fournie, la jauge 5h de Codex est masquée et seules les fenêtres disponibles, comme 7d, sont affichées. Le plugin n’invente jamais une limite absente.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
