# Agent 설정

[dotrc](https://github.com/ujuc/dotrc)에서 AI 에이전트 설정을 함께 관리하는 디렉터리. 각 도구의 시스템 경로에 심링크로 배포된다.

## 구조

| 소스 | 대상 | 상태 |
| -------- | ----------- | ----------- |
| `claude/` | `~/.claude` | 활성 |
| `amp/AGENTS.md` | `~/.config/amp/AGENTS.md` | 활성 |
| `amp/settings.json` | `~/.config/amp/settings.json` | 활성 |

`rules/SOUL.md`에 에이전트 공통 미션과 가치관을 정의한다.

## 설치

저장소 루트에서 에이전트 설정을 설치한다:

```bash
scripts/install.sh --agents
```

## 라이선스

[MIT](LICENSE)
