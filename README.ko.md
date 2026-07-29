🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 한국어 · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 설치 — 터미널에 이 한 줄만 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew 설치 여부와 관계없이 같은 명령을 사용합니다. 필요하면 Homebrew, `jq`, SwiftBar, 통합 플러그인과 Claude/Codex 도우미를 자동으로 설치합니다.

SwiftBar 항목 하나에 두 서비스를 함께 표시합니다. **macOS 메뉴 막대에는 Claude 또는 Codex 이름을 표시하지 않습니다.** Claude는 주황색 계열, Codex는 파란색 계열입니다.

```text
5h ███░░  7d ████░  │  7d ███░░
```

## ✅ v0.2.0: 두 복구 문제 수정

- **Claude 한도 재설정 후:** Claude가 `Warming up`, 0 값, null 창 또는 재설정 시간이 지난 오래된 스냅샷을 반환해도 오류 상태에 고정되지 않습니다. Claude 5h와 7d를 재설정/대기 상태의 100% 남음으로 복원하고, 다음 정상 새로고침에서 실시간 값으로 자동 교체합니다. 재설치할 필요가 없습니다.
- **Codex 5h가 나중에 돌아오는 경우:** Codex 창을 동적으로 감지합니다. Codex가 다시 300분 창을 반환하면 다음 새로고침에서 `5h` 막대가 자동으로 추가됩니다. 반환되지 않으면 `7d`처럼 실제로 제공되는 창만 표시합니다.

즉시 갱신하려면 드롭다운에서 **Refresh now**를 선택하세요.

## 🎨 독립적인 3단계 색상

각 5h 및 7d 창을 별도로 판정합니다.

| 단계 | 사용량 | Claude | Codex |
|---|---:|---|---|
| 1 — 정상 | 0–69% | `#b54f02` | `#4F7FA8` |
| 2 — 경고 | 70–89% | `#B85A00` | `#0e8ba1` |
| 3 — 위험 | 90–100% | `#ff7045` | `#ed5d40` |

메뉴 막대 헤더는 macOS 내장 도구로 작은 벡터 PDF를 생성하므로 Xcode Command Line Tools가 필요하지 않습니다.

## 설정과 세부 정보

드롭다운에는 서비스 이름, 사용량, 남은 용량, 재설정 시간이 표시됩니다. **Settings**에서 Claude와 Codex를 각각 표시하거나 숨길 수 있으며 최소 한 서비스는 유지됩니다. 갱신 간격은 1분, 3분, 5분입니다.

> **Codex 5h:** 없는 한도를 추정하지 않습니다. 실제 300분 창이 반환될 때까지 5h를 숨기고, 반환되면 자동으로 추가합니다.

기존 단독 플러그인은 숨겨진 지원 폴더로 이동하여 파일을 보존하면서 중복 메뉴 항목을 방지합니다.

## 요구 사항과 개인정보 보호

- macOS; 설치 프로그램이 Homebrew, `jq`, SwiftBar를 처리합니다.
- Claude Code 로그인 상태.
- Mac에서 Codex CLI 또는 Codex 앱을 사용한 상태.
- 인증 토큰은 출력되거나 캐시에 복사되지 않습니다.
- 일부 사용량 인터페이스는 비공식이므로 향후 호환성 업데이트가 필요할 수 있습니다.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## 라이선스

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
