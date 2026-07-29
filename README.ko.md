🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 한국어 · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 설치 — 터미널에 한 줄만 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew 설치 여부와 관계없이 같은 명령을 사용합니다. 필요하면 Homebrew, jq, SwiftBar와 통합 플러그인을 자동 설치합니다.

macOS 메뉴 막대에는 Claude나 Codex 이름 없이 하나의 항목만 표시됩니다. Claude는 짙은 주황색, Codex는 파란색입니다.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## 🎨 독립적인 3단계 색상

`5h`와 `7d`를 각각 별도로 판정합니다. 1단계: 사용량 0–69%, 2단계: 70–89%, 3단계: 90–100%.

| 단계 | Claude | Codex |
|---|---|---|
| 1 | `#b54f02` | `#4F7FA8` |
| 2 | `#B85A00` | `#0e8ba1` |
| 3 | `#ff7045` | `#ed5d40` |

메뉴 막대 헤더는 24비트 ANSI 텍스트가 아니라 macOS 내장 도구만으로 생성한 작은 벡터 PDF로 렌더링됩니다. 따라서 Xcode Command Line Tools 없이도 각 창의 정확한 HEX 색상을 유지합니다.

## 설정

드롭다운에서 Claude와 Codex를 각각 표시하거나 숨길 수 있습니다. 최소 하나는 항상 표시됩니다.

> **Codex 5h:** Codex는 항상 5시간 제한을 반환하지 않습니다. 계정에 해당 제한이 없거나 사용량 데이터에 포함되지 않으면 Codex의 5h 막대를 숨기고 7d 같은 실제 제공 창만 표시합니다. 없는 제한을 추정하지 않습니다.

The dropdown keeps the service names, percentages, remaining capacity and reset times. Existing standalone Claude/Codex plugins are moved into a hidden support folder to prevent duplicate menu-bar items.

## Privacy

Authentication tokens are never printed or copied into the unified plugin cache. The project partly relies on unofficial usage interfaces that providers may change.

## License

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
