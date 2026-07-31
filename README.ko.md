🇬🇧 [English](README.md) · 🇯🇵 [日本語](README.ja.md) · 🇪🇸 [Español](README.es.md) · 🇸🇦 [العربية](README.ar.md) · 🇫🇷 [Français](README.fr.md) · 🇩🇪 [Deutsch](README.de.md) · 🇨🇳 [简体中文](README.zh.md) · 🇰🇷 한국어 · 🇧🇷 [Português](README.pt.md) · 🇳🇱 [Nederlands](README.nl.md) · 🇮🇹 [Italiano](README.it.md) · 🇻🇳 [Tiếng Việt](README.vi.md) · 🇮🇩 [Bahasa Indonesia](README.id.md) · 🇹🇭 [ไทย](README.th.md)

# 🎚️ AI Usage Barometer

## ⚡ 설치 — 이 한 줄을 터미널에 붙여넣기

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/install.sh)"
```

Homebrew 유무와 관계없이 같은 한 줄로 동작합니다. 없는 것만(Homebrew, `jq`, SwiftBar, 플러그인, 로컬 헬퍼) 설치합니다. 다시 실행해도 안전하며 업데이트에도 같은 줄을 씁니다.

## 메뉴 막대 항목은 하나

Claude와 Codex가 얇은 구분선을 사이에 두고 한 항목을 공유합니다. 막대는 배터리 방식으로 **채워진 부분이 남은 용량**, 점으로 표시된 꼬리가 사용한 양입니다. 퍼센트도 남은 양입니다.

```text
5h ███░·  7d ██░░·  │  7d ████·
└──── Claude ────┘     └─ Codex ─┘
```

메뉴 막대는 벡터 이미지로 그려지므로 한 항목 안에서 서비스별 색을 유지합니다. 불가능한 환경에서는 자동으로 텍스트로 전환됩니다.

색은 사용량으로 결정되므로 거의 비어 있을수록 진해집니다:

| 단계 | 사용량 | Claude | Codex |
|---|---:|---|---|
| 정상 | 0–69% 사용 | `#B86B54` | `#4F7FA8` |
| 경고 | 70–89% 사용 | `#A85337` | `#0E8BA1` |
| 위험 | 90–100% 사용 | `#9C3D21` | `#ED5D40` |

## 설정

막대를 클릭해 **⚙ 표시 설정**에서 전환합니다. 클릭할 때마다 반전되며 즉시 반영됩니다.

| 설정 | 효과 |
|---|---|
| Claude 표시 | Claude 전체 표시/숨김 |
| Claude 5h 표시 | 5시간 한도 표시/숨김 |
| Claude 5h 퍼센트 | 해당 퍼센트 표시/숨김 |
| Claude 7d 표시 | 7일 한도 표시/숨김 |
| Claude 7d 퍼센트 | 해당 퍼센트 표시/숨김 |
| Codex 표시 | Codex 전체 표시/숨김 |
| Codex 퍼센트 | Codex 퍼센트 표시/숨김 |
| 메뉴 막대 2색 표시 | 벡터(2색) 또는 텍스트(1색) |
| 새로고침 간격 | 1분, 3분, 5분 |
| 언어 | 14개 언어, 기본값은 macOS 설정 |

모두 숨기면 클릭할 수 없는 빈 항목이 되므로 Claude의 5시간 막대는 항상 남습니다. 색은 실제로 표시 중인 막대만으로 결정됩니다. 설정은 `~/.cache/claude-codex-bar/`에 저장되어 업데이트 후에도 유지됩니다.

## 데이터 출처

**Claude**는 OAuth 사용량 엔드포인트 `api.anthropic.com/api/oauth/usage`에서 읽습니다. 인증에는 Claude Code가 macOS 키체인 `Claude Code-credentials`(없으면 `~/.claude/.credentials.json`)에 저장해 둔 토큰을 사용합니다. 두 위치에 쓰지 않으며, 토큰은 Anthropic 요청 외에는 Mac을 벗어나지 않습니다. 첫 실행 시 **항상 허용**을 선택하세요.

결과는 새로고침 간격 동안 캐시되므로 간격당 최대 한 번만 조회합니다. 실패해도 마지막 정상 값이 그대로 표시됩니다.

**Codex**는 설치 프로그램이 `~/SwiftBar/.ai-usage-barometer/`에 배치한 로컬 헬퍼 `codex-usage.sh`의 출력에서 읽습니다. 한도 창은 동적입니다.

## 문제 해결

**Claude 경고가 표시됨** — 키체인 항목을 찾지 못했습니다. 이 Mac에서 Claude Code에 로그인한 뒤 **지금 새로고침**을 누르세요.

**Codex 경고가 표시됨** — 헬퍼가 없거나 Codex 데이터가 아직 없습니다. 설치 프로그램을 다시 실행하고 Codex CLI를 한 번 사용하세요.

**메뉴 막대와 드롭다운의 색이 다름** — macOS는 반투명 메뉴 막대를 밝게 처리할 수 있습니다. 그래서 단계마다 한 가지 색만 사용하며, 그래도 이상하면 2색 표시를 끄고 비교하세요.

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/taka-avantgarde/ai-usage-barometer/main/uninstall.sh | bash
```

## 라이선스

[MIT](LICENSE) © 2026 Takayuki Miyano · Atlas Associates Inc.
