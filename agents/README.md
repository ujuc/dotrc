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
| `amp/` | Amp 전용 전역 지침, 설정, 플러그인 어댑터 |
| `codex/` | Codex 전역 훅 설정 |
| `pi/` | Pi 전역 extension 어댑터 |
| `rules/` | Claude, Amp, Codex, Pi가 공유하는 지침과 에이전트 정체성 |
| `docs/` | 설계 및 구현 기록 |
| `.gitignore` | `claude/` 아래에 생성되는 런타임 파일 제외 |

## 배포 경로

| 원본 | 심링크 대상 |
| --- | --- |
| `claude/` | `~/.claude` |
| `tools/workflow-hooks/` | `~/.local/bin/workflow-hooks`에 빌드 설치 |
| `rules/AGENTS.md` | `~/.codex/AGENTS.md` |
| `amp/AGENTS.md` | `~/.config/amp/AGENTS.md` |
| `amp/settings.json` | `~/.config/amp/settings.json` |
| `amp/plugins/workflow-hooks.ts` | `~/.config/amp/plugins/workflow-hooks.ts` |
| `codex/hooks.json` | `~/.codex/hooks.json` |
| `pi/extensions/workflow-hooks.ts` | `~/.pi/agent/extensions/workflow-hooks.ts` |
| `claude/skills/<name>/` | `~/.codex/skills/<name>/` |

Amp는 `~/.claude/skills/`를 직접 읽고 Pi extension도 같은 경로를 등록하므로
별도의 하네스별 스킬 사본을 두지 않는다.

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

Rust 바이너리를 먼저 설치한 뒤 네이티브 훅 어댑터를 다음 파일 심링크로
배포한다. 기존 파일이나 다른 대상의 심링크가 있으면 덮어쓰지 말고 먼저
충돌을 해결한다.

```sh
mkdir -p ${HOME}/.codex ${XDG_CONFIG_HOME:-${HOME}/.config}/amp/plugins ${HOME}/.pi/agent/extensions

link_file() {
  source=$1 destination=$2
  if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
    return
  fi
  if [ -e "$destination" ] || [ -L "$destination" ]; then
    printf 'conflict: %s\n' "$destination" >&2
    return 1
  fi
  ln -s "$source" "$destination"
}

link_file "${DOTRCDIR}/agents/codex/hooks.json" "${HOME}/.codex/hooks.json"
link_file "${DOTRCDIR}/agents/amp/plugins/workflow-hooks.ts" "${XDG_CONFIG_HOME:-${HOME}/.config}/amp/plugins/workflow-hooks.ts"
link_file "${DOTRCDIR}/agents/pi/extensions/workflow-hooks.ts" "${HOME}/.pi/agent/extensions/workflow-hooks.ts"
```

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
