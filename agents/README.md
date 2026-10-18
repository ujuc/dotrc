# Agent Configuration

`agents/`는 AI 코딩 에이전트의 전역 설정을 관리하는 원본 디렉터리다.
설치 스크립트가 각 설정을 시스템 경로에 심링크하므로, 심링크 대상이 아닌
이 디렉터리의 파일을 직접 수정한다.

## 디렉터리

| 경로 | 역할 |
| --- | --- |
| `claude/` | Claude 전역 설정, 스킬 |
| `amp/` | Amp 전역 설정, 지침 (통짜 심링크 원본) |
| `codex/` | Codex 전역 설정, 훅, 스킬 (통짜 심링크 원본) |
| `pi/` | Pi 전역 설정 (통짜 심링크 원본) |
| `rules/` | Claude, Amp, Codex, Pi가 공유하는 지침과 에이전트 정체성 |
| `docs/` | 설계 및 구현 기록 |
| `.gitignore` | `claude/`, `codex/`, `amp/`, `pi/` 아래에 생성되는 런타임 파일 제외 |

## 배포 경로

최상위 디렉터리 단위로만 심링크한다. 파일 하나씩 개별로 심링크하지 않는다.

| 원본 | 심링크 대상 |
| --- | --- |
| `claude/` | `~/.claude` |
| `codex/` | `~/.codex` |
| `amp/` | `~/.config/amp` |
| `pi/` | `~/.pi` |

`codex/`, `amp/`, `pi/`는 디렉터리 전체가 심링크되므로, 그 안의 개별 파일
(`hooks.json`, `AGENTS.md` 등)은 별도 심링크 없이 자동으로 배포된다. `codex/AGENTS.md`와 `codex/skills`는
`rules/AGENTS.md`, `claude/skills`를 가리키는 레포 내부 상대 심링크다 (레포 밖으로
나가지 않으므로 다른 머신에서도 그대로 동작한다).

Amp는 `~/.claude/skills/`를 직접 읽으므로 별도의 하네스별 스킬 사본을 두지 않는다. `codex/`, `pi/`에는 각 도구가 생성하는
런타임 상태(세션, 캐시, sqlite, 인증 파일 등)가 함께 존재하므로, 파일을 하나씩
열거하는 대신 화이트리스트 방식을 쓴다: `codex/*` + `!codex/AGENTS.md` `!codex/README.md`
`!codex/hooks.json` `!codex/hooks` `!codex/skills`, `pi/agent/*`. 새로운 런타임 파일
종류가 늘어나도 패턴을 더 늘릴 필요 없이 그대로 제외된다.

## 설치

저장소 루트에서 실행한다.

```sh
scripts/install.sh --agents
```

`scripts/install.sh --agents`가 `claude/`, `codex/`, `amp/`, `pi/`를 각각
`~/.claude`, `~/.codex`, `~/.config/amp`, `~/.pi`에 통짜 심링크하므로, 그 안의
`hooks.json`도 자동으로 배포된다.

Codex에서는 새 명령 훅이나 변경된 훅을 `/hooks`에서 검토하고 신뢰해야 실행된다.

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
