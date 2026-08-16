# Agent Configuration

`agents/`는 AI 코딩 에이전트의 전역 설정을 관리하는 원본 디렉터리다.
설치 스크립트가 각 설정을 시스템 경로에 심링크하므로, 심링크 대상이 아닌
이 디렉터리의 파일을 직접 수정한다.

## 디렉터리

| 경로 | 역할 |
| --- | --- |
| `claude/` | Claude 전역 설정, 에이전트, 훅, 스킬 |
| `amp/` | Amp 전용 전역 지침과 설정 |
| `rules/` | Claude, Amp, Codex가 공유하는 지침과 에이전트 정체성 |
| `docs/` | 설계 및 구현 기록 |
| `.gitignore` | `claude/` 아래에 생성되는 런타임 파일 제외 |

## 배포 경로

| 원본 | 심링크 대상 |
| --- | --- |
| `claude/` | `~/.claude` |
| `rules/AGENTS.md` | `~/.codex/AGENTS.md` |
| `amp/AGENTS.md` | `~/.config/amp/AGENTS.md` |
| `amp/settings.json` | `~/.config/amp/settings.json` |
| `claude/skills/<name>/` | `~/.codex/skills/<name>/` |

Amp는 `~/.claude/skills/`를 직접 읽으므로 별도의 Amp 스킬 사본을 두지 않는다.

## 설치

저장소 루트에서 실행한다.

```sh
scripts/install.sh --agents
```

## 관리 원칙

- `claude/`에는 추적하는 설정과 무시하는 런타임 상태가 함께 존재한다.
  런타임 파일을 강제로 추가하지 않는다.
- 공용 규칙은 `rules/`에 두고 도구별 설정은 `claude/` 또는 `amp/`에 둔다.
- 토큰, 자격 증명, 장비별 경로는 추적하지 않는다.
- 스킬을 변경한 뒤 해당 스킬을 검증한다.

```sh
bash agents/claude/skills/generate-skills/scripts/validate-skill \
  agents/claude/skills/<name>
```

## 라이선스

이 디렉터리에는 저장소 루트의 [MIT License](../LICENSE)가 적용된다.
