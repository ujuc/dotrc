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

## 워크플로우 색인

```
[새 프로젝트]   spec-planner → sprint-contract-negotiator → annotate-plan
                → implement-plan → qa-evaluator → commit
[기존 코드]     deep-read → annotate-plan → implement-plan → commit
[스킬 정비]     skill-improver → generate-skills → maintain
[글쓰기]        prompting-assist → humanizer
[디자인]        frontend-design-evaluator → multi-agent-orchestrator
```

`maintain`은 project-scoped (`agent-stuff/.claude/skills/maintain/`)이라 user-scope 카탈로그에는 포함되지 않으나, 워크플로우 단계로는 등장한다.

## Harness Pipeline

Planner·Contract·Generator가 기본 파이프라인을 이루고 QA·Design Evaluator는 필요할 때 추가된다 (`build` / `verify` / `planning`에 분포):

```
[User Prompt]
    │
    ▼
[spec-planner] ── Product spec
    │
    ▼
[sprint-contract-negotiator] ── Done criteria
    │
    ▼
[Generator] ── Implementation
    │
    ├── [qa-evaluator] ── Functional QA
    └── [frontend-design-evaluator] ── Design QA
    │
    ▼
[multi-agent-orchestrator] orchestrates the selected stages
```

Chrome 의존 스킬(`qa-evaluator`, `frontend-design-evaluator`)은 `--chrome` 플래그 또는 `/chrome` 명령으로 활성화한다.

## Skill Structure Convention

각 스킬은 `<skill>/SKILL.md` 패턴이며 선택적으로 `references/`, `scripts/`, `tools/` 디렉토리를 둔다. 전체 frontmatter 스펙은 [`generate-skills/references/frontmatter-spec.md`](generate-skills/references/frontmatter-spec.md).

신규 스킬 추가 시 frontmatter에 **반드시** `group: <slug>` 필드를 둔다 — 위 8개 슬러그 중 선택. 누락하거나 목록 밖 값이면 `validate-skill`이 실패한다 (`generate-skills/tools/skill-core/src/rules.rs::ALLOWED_GROUPS`).

## References

- [`CLAUDE.md`](./CLAUDE.md) — skill 작성 규약과 conventions
- [`../CLAUDE.md`](../CLAUDE.md) — Claude Code global configuration
