---
name: maintain
description: "agent-stuff 저장소의 구조 정합성, 문서 동기화, 스킬 품질을 점검하고 유지보수한다. /maintain, 정비해줘, 헬스체크, 문서 동기화, 스킬 점검, 스킬 감사 요청 시 반드시 이 스킬을 사용할 것."
group: meta
model: opus
allowed-tools: Agent, Read, Glob, Grep, Bash, Edit, Write, TaskCreate, TaskUpdate
user-invocable: true
argument-hint: "[full|skill|docs|health]"
---

# Maintain — Agent-stuff Repository Maintenance Orchestrator

Dispatches specialist agents to verify and maintain the agent-stuff configuration repository.

## Modes

| Mode | Agents Dispatched | Purpose |
|------|-------------------|---------|
| `health` (default) | health-checker | Structure validation report |
| `docs` | health-checker → doc-syncer | Detect issues then fix documentation |
| `skill` | skill-maintainer | Skill audit or lifecycle task |
| `full` | health-checker → doc-syncer → skill-maintainer | Complete maintenance pass |

## Workflow

### 1. Parse Mode

```
mode = $ARGUMENTS or "health"
valid modes: health, docs, skill, full
```

If `$ARGUMENTS` does not match a valid mode, treat the full string as a
free-form task and route using this keyword table (case-insensitive,
substring match). Pick the first agent whose keyword list hits; fall back
to `health-checker` when nothing matches (read-only, side-effect free).

| Agent | Trigger keywords |
|-------|------------------|
| `health-checker` | `구조`, `헬스`, `점검`, `검증`, `structure`, `health`, `audit repo`, `validate` |
| `doc-syncer` | `문서`, `동기화`, `CLAUDE.md`, `AGENTS.md`, `SOUL.md`, `docs`, `sync`, `readme` |
| `skill-maintainer` | `스킬`, `skill`, `frontmatter`, `description`, `audit skill`, `생성`, `최적화` |

When the free-form request clearly involves multiple concerns (e.g.,
"스킬 audit 후 문서까지 맞춰줘"), escalate to `full` mode instead of
picking a single agent.

### 2. Dispatch Agents

All agents run as sub-agents (not agent teams). Each agent uses its own model from frontmatter.

**health mode:**
```
Agent(subagent_type: "health-checker")
→ Return health report to user
```

**docs mode:**
```
Agent(subagent_type: "health-checker")
→ Read health report
→ Agent(subagent_type: "doc-syncer",
        prompt: include health report findings)
→ Summarize changes made
```

**skill mode:**
```
Agent(subagent_type: "skill-maintainer",
      prompt: include $ARGUMENTS context if provided)
→ Return audit results or delegate to generate-skills/autoresearch
```

**full mode:**
```
health → docs → skill (sequential)
→ Comprehensive summary of all findings and changes
```

### 3. Present Results

Summarize findings in Korean. Do NOT auto-commit — let the user invoke `/commit` when ready.

Format:
```
## 정비 결과 ({mode} 모드)

### 검증 결과
- PASS: N건
- WARN: N건
- FAIL: N건

### 수행한 변경
- [변경 목록]

### 미해결 항목
- [수동 처리 필요 항목]
```
