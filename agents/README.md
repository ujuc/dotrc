# Agent Configuration

`agents/`는 AI 코딩 에이전트의 전역 설정을 관리하는 원본 디렉터리다.
설치 스크립트가 각 설정을 시스템 경로에 심링크하므로, 심링크 대상이 아닌
이 디렉터리의 파일을 직접 수정한다.

## 디렉터리

| 경로 | 역할 |
| --- | --- |
| `workflow-contract.json` | 관리형 산출물·작성자·보관·유지보수·Superpowers 경계 계약 |
| `claude/` | Claude 전역 설정, 에이전트, 스킬 |
| `hooks/` | 공용 워크플로 훅의 셸 계약 테스트 |
| `tools/workflow-hooks/` | 공용 훅 정책과 Claude/Codex 이벤트 변환을 구현하는 Rust CLI |
| `amp/` | Amp 전역 설정, 지침, 플러그인 어댑터 (통짜 심링크 원본) |
| `codex/` | Codex 전역 설정, 훅, 스킬 (통짜 심링크 원본) |
| `pi/` | Pi 전역 설정, extension 어댑터 (통짜 심링크 원본) |
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
| `tools/workflow-hooks/` | `~/.local/bin/workflow-hooks`에 빌드 설치 |

`codex/`, `amp/`, `pi/`는 디렉터리 전체가 심링크되므로, 그 안의 개별 파일
(`hooks.json`, `AGENTS.md`, `plugins/workflow-hooks.ts`, `agent/extensions/workflow-hooks.ts`
등)은 별도 심링크 없이 자동으로 배포된다. `codex/AGENTS.md`와 `codex/skills`는
`rules/AGENTS.md`, `claude/skills`를 가리키는 레포 내부 상대 심링크다 (레포 밖으로
나가지 않으므로 다른 머신에서도 그대로 동작한다).

Amp는 `~/.claude/skills/`를 직접 읽고 Pi extension도 같은 경로를 등록하므로
별도의 하네스별 스킬 사본을 두지 않는다. `codex/`, `pi/`에는 각 도구가 생성하는
런타임 상태(세션, 캐시, sqlite, 인증 파일 등)가 함께 존재하므로, 파일을 하나씩
열거하는 대신 화이트리스트 방식을 쓴다: `codex/*` + `!codex/AGENTS.md` `!codex/README.md`
`!codex/hooks.json` `!codex/skills`, `pi/agent/*` + `!pi/agent/extensions`. 새로운 런타임 파일
종류가 느어누어도 패턴을 더 늘릴 필요 없이 그대로 제외된다.

## 공통 워크플로 계약

`agents/workflow-contract.json`은 Claude, Codex, Amp, Pi가 공유하는 관리형
워크플로의 단일 진실이다. Rust 바이너리에 빌드 시 포함되며 다음 명령으로
현재 설치된 계약을 확인한다.

```sh
workflow-hooks contract | jq .
```

활성 생명주기는 다음과 같다.

```text
spec.md (아키텍처 작업)
  → .sprint/contract.md
  → .research/research-*.md (필요 시)
  → .plans/plan-*.md
  → 승인·implement-plan
  → 선택적 QA/design 별도 보고서
  → multi-agent-orchestrator 종합
  → implement-plan 최종화·보관
```

한 체크아웃에는 활성 워크플로를 하나만 둔다. `annotate-plan`만 계획을
작성하고, `implement-plan`만 관리형 구현과 보관을 수행한다. QA는 기능
수용성을, design evaluator는 Design Quality·Originality·Craft·Visual
Usability를 담당하며 오케스트레이터만 두 결과를 종합한다.

완료 시 사용된 산출물을 `docs/specs/`, `docs/contracts/`, `docs/research/`,
`docs/plans/`, `docs/reports/`로 이동한다. `.harness/`는 이전 체계이므로
감지만 하고 자동 이전·삭제하지 않는다.

Superpowers 6.3.0의 brainstorming·writing-plans·writing-skills 원칙은 공통
스킬에 맞게 반영했다. `generate-skills`는 로컬 validator와 카탈로그를 계속
소유한다. TDD, 체계적 디버깅, 완료 전 검증, 리뷰, 병렬 디스패치는 선택적
보조 규율이다. Superpowers의 별도 계획·실행·worktree·브랜치 완료
흐름은 이 워크플로 안에서 사용하지 않는다. 계약 핀과 설치 버전이 다르면
`skill-improver`가 읽기 전용으로 경고하고 플러그인 캐시는 수정하지 않는다.

## 설치

저장소 루트에서 실행한다.

```sh
scripts/install.sh --agents
cargo install --locked --path agents/tools/workflow-hooks --root "$HOME/.local"
```

`scripts/install.sh --agents`가 `claude/`, `codex/`, `amp/`, `pi/`를 각각
`~/.claude`, `~/.codex`, `~/.config/amp`, `~/.pi`에 통짜 심링크하므로, 그 안의
`hooks.json`, `plugins/workflow-hooks.ts`, `agent/extensions/workflow-hooks.ts`도
자동으로 배포된다. Rust 바이너리(`workflow-hooks`)만 위 명령으로 별도 설치한다.

Codex에서는 새 명령 훅이나 변경된 훅을 `/hooks`에서 검토하고 신뢰해야 실행된다.

## 관리 원칙

- `claude/`에는 추적하는 설정과 무시하는 런타임 상태가 함께 존재한다.
  런타임 파일을 강제로 추가하지 않는다.
- 공용 규칙은 `rules/`에 두고 도구별 설정은 `claude/` 또는 `amp/`에 둔다.
- 관리형 워크플로 계약은 `workflow-contract.json`에 두고 경로·작성자·보관·주기 변경 시 Rust 검증과 계약 테스트를 함께 갱신한다.
- 공용 훅 정책은 `tools/workflow-hooks/`에 두고 Amp/Pi 어댑터에는 복제하지 않는다.
- `hooks/test-workflow-hooks.sh`는 Rust 바이너리의 블랙박스 계약 테스트로만 유지한다.
- 토큰, 자격 증명, 장비별 경로는 추적하지 않는다.
- 스킬을 변경한 뒤 해당 스킬을 검증한다.

```sh
bash agents/claude/skills/generate-skills/scripts/validate-skill \
  agents/claude/skills/<name>
```

## 라이선스

이 디렉터리에는 저장소 루트의 [MIT License](../LICENSE)가 적용된다.
