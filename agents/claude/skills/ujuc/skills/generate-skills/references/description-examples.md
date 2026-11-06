# `description` writing guide

Write `[WHAT sentence]. [WHEN sentence].`: WHAT is the minimum capability label,
not a workflow summary; WHEN names the requests that should load the skill. The
matcher compares it with raw user input, so trigger phrases decide accuracy.

## Examples

```yaml
description: >-
  Analyzes Figma design files and generates developer handoff documentation.
  Use when user uploads .fig files, asks for "design specs",
  "component documentation", or "design-to-code handoff".
```

Korean descriptions keep their trigger phrases verbatim:

```yaml
description: >-
  새로운 Claude 스킬을 폴더 구조, 프론트매터, 지시사항까지 단계적으로 생성한다.
  스킬 만들어줘, 새 스킬 추가, SKILL.md 작성, generate-skills 요청 시 사용한다.
```

```yaml
description: >-
  스프린트 계획, 태스크 생성, 상태 추적 등 Linear 프로젝트 워크플로우를 관리한다.
  "스프린트", "Linear 태스크", "프로젝트 계획", "티켓 생성" 언급 시 사용한다.
```

**Trigger on the action, not the domain.** A domain-wide trigger loads the skill
for work that does not need it:

```yaml
# Bad
description: >-
  Create and validate Postgres schema migrations.
  Use when working with databases, queries, models, or persistence.

# Fix
description: >-
  Create and validate Postgres schema migrations.
  Use when adding or changing a migration, or reviewing its rollout.
```

Write triggers in the user's words, not internal jargon ("organize projects",
not "Project entity model"). Keep the description as short as an unambiguous
trigger allows: about 100–300 characters, front-loaded, no empty modifiers.

## Trigger tuning

**Under-triggering** (not loaded for related requests): first check the
[invocation controls](frontmatter-spec.md#invocation-control-matrix); a
manual-only skill is not expected to auto-load, so keep its selected mode.
Otherwise add the phrases users actually say, with synonyms, abbreviations and
colloquial variants ("PR 만들어줘", "풀리퀘 생성", "pull request").

**Over-triggering** (loaded for unrelated work): add a negative trigger ("Do NOT
use for simple data exploration"), narrow the scope, and drop generic lead words
such as "help" and "manage".
