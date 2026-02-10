---
name: "dotrc-templates-agents"
description: "Document templates directory guide for the dotrc repository"
version: "1.1.0"
last_updated: "2026-02-10"
metadata:
  standard: "https://agents.md/"
  ai-compatibility: "Universal (Claude Code, GitHub Copilot, Cursor, Aider)"
---

# Document Templates

Shared document templates for the `dotrc` repository. Each template provides a standardized starting point for creating new documents with consistent structure and metadata.

## Overview

| Template | Purpose | Target Files |
|----------|---------|--------------|
| [guide-template.md](./guide-template.md) | Guide documents (roles, responsibilities, guidelines) | `claude/guides/*.md` |
| [work-template.md](./work-template.md) | Work log documents (analysis, planning, implementation, retrospective) | `docs/ai/*.md` |
| [agents-template.md](./agents-template.md) | AGENTS.md files for AI agent integration | `*/AGENTS.md` |
| [skill-template.md](./skill-template.md) | Claude Code skill definitions | `claude/skills/*/SKILL.md` |

## Template Inventory

### guide-template.md

Standard structure for guide documents. Includes role definition, responsibilities section, and content sections. Used primarily for `claude/guides/` documents.

**Key metadata fields**: `role`, `priority`, `applies-to`, `optimized-for`

### work-template.md

Comprehensive work log template covering the full lifecycle: analysis, planning, implementation, testing, results, documentation, follow-up, and retrospective. Includes version history tracking.

> **Note**: This template is written entirely in Korean. Documents created from this template must also be written in Korean.

**Key metadata fields**: `type`, `status`, `agent`, `related`, `started`

### agents-template.md

Template for creating AGENTS.md files following the [agents.md specification](https://agents.md/). Covers the 6 Core Areas: Commands, Testing, Project Structure, Code Style, Git Workflow, and Boundaries.

**Key metadata fields**: `standard`, `ai-compatibility`

### skill-template.md

Template for Claude Code auto-discovered skills. Follows the [agentskills.io specification](https://agentskills.io/specification). This template serves as the **reference implementation** for the `metadata:` block pattern used across all templates.

**Key metadata fields**: `role`, `priority`, `applies-to`, `optimized-for`, `last-updated`, `context`

## Common Conventions

### YAML Frontmatter

All templates use YAML frontmatter (`---`) with this structure:

```yaml
---
# Required fields (top-level)
name: "[template-specific-name]"
description: "[one-sentence description]"
version: "1.0.0"

# Optional fields (top-level)
tags: []
context: |
  [Document purpose and scope]
last_updated: "YYYY-MM-DD"

# Template-specific fields (nested under metadata)
metadata:
  field-one: "[value]"
  field-two: "[value]"
---
```

**Rules**:
- `name`, `description`, `version` are **required** at the top level
- Template-specific fields go under `metadata:` block
- Use **hyphens** (not underscores) for multi-word field names: `applies-to`, not `applies_to`
- Reference: [agentskills.io frontmatter spec](https://agentskills.io/specification#frontmatter-required)

### See Also Section

Every template must include a `## See Also` section at the bottom with:
- Link to [AGENTS.md](../../AGENTS.md) (root)
- Link to [CLAUDE.md](../../claude/CLAUDE.md) (Claude-specific)
- Related documents as needed

### Language Policy

- **All template content**: English (comments, placeholders, body text)
- **Placeholder descriptions**: English inside `<!-- -->` HTML comments

### Placeholder Convention

- Use `[brackets]` for values that must be replaced: `[project-name]`, `[description]`
- Use `<!-- HTML comments -->` for authoring guidance that should be removed
- Provide concrete examples alongside placeholders where helpful

## Creating a New Template

1. **Copy** the closest existing template as a starting point
2. **Update frontmatter**: Set `name`, `description`, `version`
3. **Add metadata block**: Place template-specific fields under `metadata:`
4. **Write body content**: Follow the placeholder convention
5. **Add See Also section**: Include AGENTS.md and CLAUDE.md links
6. **Update this AGENTS.md**: Add the new template to the Overview table and Template Inventory
7. **Update root AGENTS.md**: Add the template to the Document Templates section

## Boundaries

### Always Do

- Follow the `metadata:` block pattern for template-specific fields
- Include `name`, `description`, `version` as required top-level fields
- Add a `## See Also` section with AGENTS.md and CLAUDE.md links
- Use `[brackets]` for placeholder values
- Update this AGENTS.md when adding or removing templates

### Ask First

- Changing the required field set (`name`, `description`, `version`)
- Modifying the `metadata:` block structure convention
- Adding templates that overlap significantly with existing ones

### Never Do

- Use underscores in metadata field names (use hyphens)
- Omit the `## See Also` section
- Create templates without YAML frontmatter

## See Also

- [**AGENTS.md**](../../AGENTS.md) - Root repository AI agent guide
- [**CLAUDE.md**](../../claude/CLAUDE.md) - Claude-specific guidelines
- [**agentskills.io**](https://agentskills.io/specification) - Frontmatter specification
