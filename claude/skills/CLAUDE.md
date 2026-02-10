---
document: CLAUDE.md
role: Skills Directory Guide
priority: Medium
applies-to: Skill creation and maintenance in claude/skills/
optimized-for: Claude 4.5 (Sonnet/Opus)
last-updated: "2026-02-10"
context: |
  This document provides practical guidance for creating and maintaining Claude Code skills
  in the skills/ directory. It covers template usage, YAML structure, required sections,
  and conventions to ensure consistency across all auto-discovered skills.
---

# CLAUDE.md — claude/skills

Guide for creating and maintaining Claude Code skills in this directory.

## What Are Skills?

Skills are auto-discovered by Claude Code when their trigger phrases appear in conversation. Each skill lives in its own subdirectory as `skills/<skill-name>/SKILL.md`.

## Creating a New Skill

### Quick Start

1. Create a new directory: `skills/<skill-name>/`
2. Copy the template: `cp skills/skill-template.md skills/<skill-name>/SKILL.md`
3. Fill in each section following the template structure
4. Test activation by using trigger phrases in Claude

### Template Location

- **Template file**: [`skill-template.md`](./skill-template.md) in this directory
- The template contains placeholder values in `[brackets]` — replace all of them

### Required YAML Frontmatter

Every `SKILL.md` must start with YAML frontmatter:

```yaml
---
name: skill-name # Lowercase, hyphenated identifier
description: >- # One-line description with trigger phrases
  What this skill does. Use when "trigger phrase", "한국어 트리거".
allowed-tools: Read Edit # Space-delimited tool names
model: haiku # Optional: haiku (fast), sonnet (balanced), opus (complex)
version: 1.0.0 # Semver
metadata:
  role: "Role Name"
  priority: "High/Medium/Low"
  applies-to: "Scope"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "YYYY-MM-DD"
  context: |
    Brief explanation of purpose and workflow fit.
---
```

### Required Sections

| Section                | Purpose                                           |
| ---------------------- | ------------------------------------------------- |
| `# Display Name`       | H1 title + one-sentence summary                   |
| `## Source of Truth`   | Links to authoritative references                 |
| `## When to Activate`  | Trigger phrases (English + Korean) and contexts   |
| `## Instructions`      | Step-by-step features with **When** and **Steps** |
| `## Response Language` | Korean for user communication, English for files  |
| `## See Also`          | Related documents and references                  |

### Conventions

- **Trigger phrases**: Always include both English and Korean variants
- **Steps**: Use numbered lists with bold step names
- **Examples**: Include concrete input/output examples for each feature
- **Domain sections**: Add skill-specific sections between Instructions and Response Language
- **Supporting files**: Place additional resources (templates, configs) in the skill directory

## Directory Structure

```
skills/
├── CLAUDE.md            # THIS FILE - Skill creation guide
├── skill-template.md    # Base template for new skills
├── <skill-name>/
│   ├── SKILL.md         # Skill definition (required)
│   └── *.md             # Supporting files (optional)
```

## Existing Skills Reference

| Skill          | Trigger Examples                     | Model |
| -------------- | ------------------------------------ | ----- |
| `agents`       | "에이전트해줘", "AGENTS.md 만들어줘" | haiku |
| `commit`       | "커밋해줘", "commit changes"         | haiku |
| `interview`    | "인터뷰해줘", "스펙 작성해줘"        | -     |
| `refactor`     | "리팩토링 해줘", "정리해줘"          | -     |
| `review`       | "리뷰해줘", "이거 괜찮아?"           | -     |
| `troubleshoot` | "왜 안돼?", "에러 났어"              | -     |

## Checklist Before Committing

- [ ] All `[bracket]` placeholders replaced with actual values
- [ ] Trigger phrases include Korean variants
- [ ] `allowed-tools` lists only the tools the skill actually needs
- [ ] Steps are concrete and actionable (not vague "follow best practices")
- [ ] Examples use realistic input/output
- [ ] `metadata.last-updated` is set to today's date
- [ ] Skill registered in parent `claude/CLAUDE.md` skill table

## See Also

- [`skill-template.md`](./skill-template.md) - Base template
- [`../CLAUDE.md`](../CLAUDE.md) - Claude skills table and priority hierarchy
