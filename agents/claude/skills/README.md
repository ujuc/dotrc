# Skills

이 디렉토리는 Claude Code 자체 스킬을 담는다. 아래 그룹 표가 카탈로그이며, SKILL.md frontmatter의 `group:` 필드를 단일 진실 소스로 삼아 손으로 유지한다 — `generate-skills`의 `register-skill` 런처가 신규 스킬을 이 표에 등록한다.

## 그룹

| slug | 한글 라벨 | 스킬 (`codex:` 접두는 플러그인) |
| --- | --- | --- |
| `planning` | 🧭 기획·스펙 | `spec-planner`, `sprint-contract-negotiator` |
| `analysis` | 📐 분석·계획 | `deep-read`, `annotate-plan` |
| `build` | 🛠 구현·실행 | `implement-plan`, `multi-agent-orchestrator` |
| `verify` | ✅ 검증·QA | `qa-evaluator`, `frontend-design-evaluator` |
| `docs` | 📝 문서·커밋 | `commit`, `generate-agent-docs` |
| `writing` | ✍️ 글쓰기 | `humanizer`, `prompting-assist` |
| `llm` | 🤖 외부 LLM | `gemma`, `codex:codex-cli-runtime`, `codex:codex-result-handling`, `codex:gpt-5-4-prompting` |
| `meta` | 🧪 메타·관리 | `generate-skills`, `skill-improver`, `autoresearch` |

`gemma`는 로컬 Ollama의 `gemma4:26b-mlx` 모델만 기본 실행 경로로 사용한다.

## 모델 선택

각 스킬과 에이전트 본문에 작업별 권장 수준과 상향 조건을 둔다.
[공통 모델 선택 가이드](generate-skills/references/model-selection.md)가 기준이며,
아래 묶음은 비슷한 작업에 배정할 후보를 뜻한다. 회사 간 성능 동등성을 보장하지 않는다.

| 수준 | 작업 기준 | GPT 후보 | Claude 후보 |
| --- | --- | --- | --- |
| 경량 | 정형 추출·분류·서식·검사 결과 보고 | Luna | Haiku |
| 표준 | 범위가 정해진 커밋·구현·탐색 | Terra | Sonnet |
| 고급 | 다중 파일 구현·설계·복잡한 디버깅·의미 검토 | Sol | Opus |
| 최상위 | 장기·고난도 추론, 고급 수준에서도 해결되지 않은 복합 문제 | Astra | Fable |

예: “이 작업은 변경 범위가 정해진 표준 실행 수준이므로 Terra 또는 Sonnet을
권장합니다. 복잡한 변경 분류나 충돌 해결이 필요하면 Sol 또는 Opus 수준으로
상향을 권장합니다.”

실제 모델은 사용자 선택과 호스트의 지원·허용 범위 안에서 지정한다. 전환할 수
없으면 권장 모델과 현재 실행 상태를 구분해 알린다. `model` 생략에 따른 상속은
실행상의 대체 수단이며 역할별 추천을 대신하지 않는다. 독립 검토는 별도 문맥으로
확보하고, Gemma·Waza처럼 특정 모델을 실행 대상으로 삼는 설정은 별도로 유지한다.

## 워크플로우 색인

```
[아키텍처 작업] spec-planner → sprint-contract-negotiator → deep-read(필요 시)
                → annotate-plan → 승인 → implement-plan
[범위가 작은 작업] 승인된 간단 설계 → sprint-contract-negotiator
                → annotate-plan → 승인 → implement-plan
[독립 평가]     qa-evaluator / frontend-design-evaluator
                → multi-agent-orchestrator 종합 → implement-plan 최종화
[완료 보관]     docs/{specs,contracts,research,plans,reports}
[스킬 정비]     로컬 세션 기록 → skill-improver → generate-skills
[글쓰기]        prompting-assist → (선택) humanizer 후처리
```

`workflow-hooks contract`가 노출하는 `agents/workflow-contract.json`이 경로,
작성자, 보관 위치, 유지보수 주기와 Superpowers 기준 버전의 단일 진실이다.
한 체크아웃에서는 하나의 워크플로만 활성화한다. `annotate-plan`만 계획을
작성하고 `implement-plan`만 코드를 실행하고 완료 산출물을 보관한다.

## Managed Pipeline

QA와 Design Evaluator는 같은 안정 빌드를 서로 독립적으로 평가하고 라운드별
별도 보고서를 작성한다. 오케스트레이터만 모든 계약 기준과 보고서를 종합하며,
PASS 종합 보고서를 받은 `implement-plan`이 최종 보관을 수행한다. 평가가
필요하지 않은 작업은 전체 검증 직후 `implement-plan`이 바로 보관한다.

```
spec-planner → sprint-contract-negotiator → deep-read? → annotate-plan
    → user approval → implement-plan
       ├─ no evaluator → archive
       └─ QA/design reports → orchestrator synthesis → implement-plan → archive
```

Chrome 의존 스킬(`qa-evaluator`, `frontend-design-evaluator`)은 `--chrome` 플래그 또는 `/chrome` 명령으로 활성화한다.

Superpowers 6.3.0의 brainstorming·writing-plans·writing-skills 원칙은 공통
스킬에 맞게 반영했다. `generate-skills`는 로컬 validator·카탈로그를 유지하며
행동 기준 변경에 baseline/candidate 검증을 적용한다. TDD, 체계적 디버깅,
완료 전 검증, 리뷰, 병렬 디스패치는 선택적
보조 규율로 사용할 수 있지만 `writing-plans`, SDD/`executing-plans`, worktree,
브랜치 완료 흐름은 관리형 워크플로의 계획·실행 소유권을 대체하지 않는다.
설치 버전이 계약 핀과 달라지면 `skill-improver`가 경고하며 플러그인 캐시를
자동 수정하지 않는다. `skill-improver`는 정적 점검(A–D)에 더해 로컬 세션 기록을
요약·채점하는 Dimension E를 수행한다. 트랜스크립트는 기기 밖으로 나가지 않고,
관찰된 실패가 `references/change-bar.md`의 기준을 통과할 때만 동작 수정을
제안한다.

## Skill Structure Convention

각 스킬은 `<skill>/SKILL.md` 패턴이며 선택적으로 `references/`, `scripts/`, `tools/` 디렉토리를 둔다. 전체 frontmatter 스펙은 [`generate-skills/references/frontmatter-spec.md`](generate-skills/references/frontmatter-spec.md).

신규 스킬 추가 시 frontmatter에 **반드시** `group: <slug>` 필드를 둔다 — 위 8개 슬러그 중 선택. 누락하거나 목록 밖 값이면 `validate-skill`이 실패한다 (`generate-skills/tools/skill-core/src/rules.rs::ALLOWED_GROUPS`).

## References

- [`CLAUDE.md`](./CLAUDE.md) — skill 작성 규약과 conventions
- [`../CLAUDE.md`](../CLAUDE.md) — Claude Code global configuration
