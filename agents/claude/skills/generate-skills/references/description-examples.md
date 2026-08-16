# `description` writing guide

> How to write the `description` field in SKILL.md frontmatter, with examples.

---

## The WHAT + WHEN formula

`description` must include two things:

1. **WHAT**: what the skill does.
2. **WHEN**: in what situations / requests it should be used.

```
[WHAT sentence]. [WHEN sentence].
```

The system matches `description` against user input to auto-load the skill. Description quality determines trigger accuracy.

---

## Good examples

### English

```yaml
description: >-
  Analyzes Figma design files and generates developer handoff documentation.
  Use when user uploads .fig files, asks for "design specs",
  "component documentation", or "design-to-code handoff".
```

```yaml
description: >-
  Sets up a new Next.js project with TypeScript, ESLint, and testing
  configuration. Use when user asks to "create a project",
  "initialize Next.js", or "scaffold a new app".
```

```yaml
description: >-
  Runs TDD workflow: write failing test, implement, refactor.
  Use when implementing features, fixing bugs, or when user mentions
  "TDD", "test first", or "red-green-refactor".
```

### Korean

Korean descriptions are kept verbatim because trigger phrases are language-specific.

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

```yaml
description: >-
  CLAUDE.md 및 AGENTS.md 파일을 가이드 원칙에 따라 생성한다.
  프로젝트 분석, 인터뷰, 생성, 검증의 4단계 워크플로우를 수행한다.
```

---

## Bad → fixed

### Too vague

```yaml
# Bad: doesn't say what it does or when to use it
description: Helps with projects.

# Fix: state WHAT + WHEN
description: >-
  Creates project scaffolding with recommended directory structure and configs.
  Use when starting a new project or asking to "set up a project".
```

### Missing trigger

```yaml
# Bad: WHAT only, no WHEN
description: Creates sophisticated multi-page documentation systems.

# Fix: add WHEN (trigger phrases)
description: >-
  Creates multi-page documentation from source code and comments.
  Use when user asks for "generate docs", "API documentation",
  or "document this project".
```

### Internal jargon only

```yaml
# Bad: not phrasing the user would actually say
description: Implements the Project entity model with hierarchical relationships.

# Fix: rewrite from the user's perspective
description: >-
  Sets up project hierarchy with parent-child relationships and permissions.
  Use when user asks to "organize projects", "create project structure",
  or "set up project permissions".
```

### Contains XML tags

```yaml
# Bad: XML tags are forbidden
description: Use for <important>project setup</important> tasks.

# Fix: drop the tags
description: >-
  Handles project setup tasks including directory creation and config files.
  Use when user asks to "set up" or "initialize" a project.
```

---

## Length tips

- **Hard max**: 1,536 characters — `description` + `when_to_use` combined (truncated above this).
- **Recommended**: 100–300 characters (just the essentials).
- Drop empty modifiers: "sophisticated", "comprehensive", "advanced", ...
- Front-load concrete trigger phrases.
- Use YAML folded scalar (`>-`) for readability when the description is multi-line.

> For trigger over- and under-trigger remediation, see the "Trigger tuning" section in `references/review-checklist.md`.
