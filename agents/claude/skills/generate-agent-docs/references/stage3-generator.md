# Stage 3 — Shared Instructions First

## Execution and evidence

Use the capability mapping in SKILL.md. One writer handles selected files;
fresh-context delegation is preferred when available. On hosts without it,
the orchestrator writes directly and reports the missing independent role.

Provide the writer with the following inputs:

```text
Selected files and authorized changes:
Original contents (existing files):
Confirmed project facts with source paths:
User decisions and preserved exceptions:
Effective upstream guidance, local defaults, and source status:
```

The writer reads this file, claude-code-best-practices.md,
model-prompting-guides.md, context-engineering-claude5.md and tdd-agent-loop.md.
Read agents-md-best-practices.md for shared targets, entry-router-guidelines.md
only for requested governance, and SOUL.md only if identity content is requested.
The static identity seed is optional inspiration, not a requirement to copy
persona claims into project documentation.

Create only authorized missing files. Use update-mode.md for existing ones.
Shared supporting documents precede AGENTS.md; AGENTS.md precedes any CLAUDE.md
that imports it. Report ordered writes, final contents, line counts and diffs.

## Common writing rules

- AGENTS.md owns shared Claude/Codex project instructions and shared links.
  CLAUDE.md imports it and contains only Claude-specific additions.
- Preserve explicit user and repository requirements, including nondefault
  conventions, testing gates, team TDD, and safety boundaries. General pruning
  defaults and model-specific research never silently override them.
- Prefer necessary, non-obvious instructions. Do not summarize the source tree
  or repeat linter-enforced defaults. Retain a discoverable command when the
  user requires it or its selection/conditions prevent a known mistake.
- Use source references for detailed explanations. Only link a skill or file
  that actually exists; recommend a missing skill without a fictitious link.
- Document clear outcomes. Generic "double-check" scaffolding is expendable;
  a concrete required test command is a project rule and may remain.
- Apply W/C/T reference rules within their documented scope and exceptions.
  Decision rationale is allowed; internal reasoning transcripts are not needed.
- Use the local budgets in claude-code-best-practices.md. Preserve shared
  accessibility when shortening: moving shared content exclusively into
  .claude/rules/ is not a valid size fix.
- Preserve unrelated content. Report optional improvements outside authorized
  changes separately, even when auditing every line.

## Section A — AGENTS.md

Create/update this shared source before the Claude-specific file.
Keep it harness-neutral: project constraints, non-obvious build/test conditions,
team conventions, workflow, boundaries, and links to shared supporting docs.
Use plain Markdown; no required template or mandatory section list.
Frontmatter removal from an existing file is a proposed structural change,
not an automatic consequence of the standard allowing Markdown.

A portable skill or workflow is not Claude-only merely because Claude can use
it. Describe shared requirements in host-neutral terms and name available
alternatives when useful. Claude-only commands, hook events and settings go
in CLAUDE.md or the selected Claude rules.

When Stage 1/2 establishes large parallel or adversarial workflows, include a
short project-specific condition for delegation and cost control. Otherwise
omit an orchestration section. Do not manufacture model budgets or new rules.

## Section B — CLAUDE.md

After AGENTS.md exists, begin the root file with:

```markdown
@AGENTS.md
```

Only append Claude-specific instructions not already managed in AGENTS.md:
Claude Code commands, specific hook behavior, permissions or path-rule details
that are relevant and confirmed. No heading or filler is needed when none exist;
the import alone is the full file. Do not duplicate shared text below the import.

For an existing combined file, transfer shared clauses into AGENTS.md first,
preserving meaning and exceptions, then replace those clauses with the import.
Preserve unrelated Claude-specific content. A later explicit CLAUDE-only
restriction with no shared prerequisite requires scope resolution, not a
standalone document or an unapproved companion write.

## Section C — Shared supporting documents

Selected contributing-docs/ files hold necessary detail shared by humans and
agents: non-obvious architecture decisions, build/test setup, migrations or
conventions. Link them from AGENTS.md after they exist. Prefer existing docs
over creating a parallel source. Do not move universally needed instructions
out of AGENTS.md merely to reach a default size target.

A sometimes-relevant procedure may warrant a skill recommendation, but that
recommendation does not authorize creating a skill or removing a team runbook.

## Section D — Nested instructions

For an authorized package-specific shared rule, use a nested AGENTS.md before
a nested CLAUDE.md. Do not generate nested files just because a package exists.
If shared rules differ, retain those differences in the selected nested shared
file. Its Claude companion imports the local AGENTS.md and adds only
Claude-specific differences.

If only Claude-specific differences exist and shared ancestor instructions
already load, a nested CLAUDE.md may contain only those differences; do not
import a nonexistent local AGENTS.md. Explain this case in the verifier input.
Compute every relative link from its containing file. Do not assume a submodule
can resolve parent-repository paths when checked out independently.
Never duplicate shared package commands in a Claude-only nested template.

## Section E — Claude path rules

Create selected .claude/rules/ files for confirmed Claude-specific scoped
behavior. Shared rules belong in shared instructions, even when path-scoped.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

(Confirmed Claude-specific rule)
```

Use documented paths globs; omit frontmatter for intentionally unconditional
rules. Unconditional files still load at startup and do not reduce total
context. Migrate legacy globs/alwaysApply syntax only within authorized scope,
preserving intended conditions. A pattern with no current matches warrants
checking intent, not automatic removal of a future-path rule.

## Delivery to verification

Supply final paths, original contents, diffs, facts, user decisions, source
status and ordered writes to Stage 4. A successful write is not a verified
result. Do not invent tool calls, interviews, source checks or reviewer passes.
