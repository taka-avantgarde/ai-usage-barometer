🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 한국어 · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 설치 — 터미널에 이 한 줄만 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew 설치 여부와 관계없이 같은 명령으로 필요한 구성 요소를 자동 설치합니다.

## ✅ v0.2.7: 메뉴 막대 표시 안정화

v0.2.7은 테스트된 Codex 헬퍼를 이 저장소에 고정하고, macOS 기본 Bash 3.2에서 동작하지 않는 `;;&` 문법을 제거하며, 업데이트할 때마다 정확한 색상의 벡터 헤더를 다시 생성합니다.

Claude와 Codex는 독립적으로 판정됩니다. 한 서비스의 데이터가 없어도 다른 서비스는 사라지지 않습니다. 각 5h/7d 창은 자체 색상 단계를 유지하고 기존 **Settings** 선택도 보존됩니다.

## Claude 데이터 소스


Claude 사용량은 문서화된 `statusLine` JSON의 `rate_limits.five_hour`와 `rate_limits.seven_day`에서 수집합니다. 기존 상태 표시줄 출력은 그대로 유지됩니다.

설치 후 Claude Code를 열고 응답 하나를 완료하세요. `rate_limits`는 세션의 첫 API 응답 후에만 제공되며 5h와 7d는 각각 없을 수 있습니다. 실제로 반환된 창만 표시하고 `Warming up`이나 누락 데이터를 가짜 100%로 바꾸지 않습니다.

OAuth 토큰, macOS Keychain, `~/.claude/.credentials.json`은 읽지 않습니다.

## 메뉴 막대 항목 하나

Claude는 주황색, Codex는 파란색이며 macOS 메뉴 막대에는 서비스 이름을 표시하지 않습니다. 각 창의 색을 독립적으로 결정합니다.

| 단계 | 사용률 | Claude | Codex |
|---|---:|---|---|
| 1 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 | 90–100% | `#ff7045` | `#ed5d40` |

Codex가 실제 300분 창을 반환하면 `5h`가 자동 추가되고, 주간 창만 있으면 `7d`만 표시합니다. **Settings**에서 서비스 표시와 1·3·5분 간격을 설정할 수 있습니다.

Claude 바가 보이지 않으면 Claude Code에서 응답 하나를 완료하세요. `statusLine`에는 워크스페이스 신뢰가 필요하며 `disableAllHooks: true`에서는 실행되지 않습니다.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
