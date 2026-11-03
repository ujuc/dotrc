# Agent Configuration

`agents/`는 AI 코딩 에이전트의 전역 설정을 관리하는 원본 디렉터리다.
설치 스크립트가 각 설정을 시스템 경로에 심링크하므로, 심링크 대상이 아닌
이 디렉터리의 파일을 직접 수정한다.

## 디렉터리

| 경로 | 역할 |
| --- | --- |
| `claude/` | Claude 전역 설정, 스킬 (`~/.claude`로 통짜 심링크) |
| `docs/` | 설계 및 구현 기록 |
| `.gitignore` | `claude/` 아래에 생성되는 런타임 파일 제외 |

## 설치

저장소 루트에서 실행한다.

```sh
scripts/install.sh --agents
```

## 관리 원칙

- `claude/`에는 추적하는 설정과 무시하는 런타임 상태가 함께 존재한다.
  런타임 파일을 강제로 추가하지 않는다.
- 전역 지침(`claude/CLAUDE.md`)과 에이전트 정체성(`claude/SOUL.md`)은 `claude/`에 둔다.
  다른 소비자가 생기면 그때 공용 위치로 옮긴다.
- 토큰, 자격 증명, 장비별 경로는 추적하지 않는다.
- 스킬을 변경한 뒤 해당 스킬을 검증한다.

```sh
bash agents/claude/skills/generate-skills/scripts/validate-skill \
  agents/claude/skills/<name>
```

## 라이선스

이 디렉터리에는 저장소 루트의 [MIT License](../LICENSE)가 적용된다.
