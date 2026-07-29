🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 한국어 · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 설치 — 터미널에 한 줄만 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew 설치 여부와 관계없이 같은 명령을 사용합니다. 필요하면 Homebrew, jq, SwiftBar와 통합 플러그인을 자동 설치합니다.

macOS 메뉴 막대에는 Claude나 Codex 이름 없이 하나의 항목만 표시됩니다. Claude는 주황색, Codex는 파란색입니다.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 설정

드롭다운에서 Claude와 Codex를 각각 표시하거나 숨길 수 있습니다. 최소 하나는 항상 표시됩니다.

> **Codex 5h:** Codex는 항상 5시간 제한을 반환하지 않습니다. 계정에 해당 제한이 없거나 사용량 데이터에 포함되지 않으면 Codex의 5h 막대를 숨기고 7d 같은 실제 제공 창만 표시합니다. 없는 제한을 추정하지 않습니다.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
