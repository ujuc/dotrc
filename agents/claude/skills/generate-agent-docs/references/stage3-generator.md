# Stage 3 — Shared Instructions First

Per-file rules for the writer. Create only authorized missing files; existing
files follow update-mode.md U3.

## Common writing rules

- AGENTS.md owns shared Claude/Codex project instructions and shared links.
  CLAUDE.md imports it and holds only Claude-specific additions.
- Preserve explicit user and repository requirements, including nondefault
  conventions, testing gates, team TDD, and safety boundaries. General pruning
  defaults and model-specific research never silently override them.
- Prefer necessary, non-obvious instructions. Do not summarize the source tree
  or repeat linter-enforced defaults. Cut a line Claude could find by reading
  the code and would go and look for; keep the exact test, typecheck and lint
  commands, including how to run one test file, and any command the user requires.
- Leave out emphasis, context-window management, delegation for a better
  answer, thinking phrases, persistence lines and repository summaries Claude can read
  unless the user requires them.
- Use source references for detail. Link only skills and files that exist;
  recommend a missing skill without a link.
- Document clear outcomes. Generic "double-check" scaffolding is expendable; a
  concrete required test command is a project rule and may remain.
- Apply W/C/T reference rules within their documented scope and exceptions.
  Decision rationale is allowed; internal reasoning transcripts are not needed.
- Use the local budgets in claude-code-best-practices.md. Moving shared content
  exclusively into `.claude/rules/` is not a valid size fix.
- Preserve unrelated content. Report optional improvements outside authorized
  changes separately, even when auditing every line.
- Keep a rule with no exceptions as a line and recommend a hook, deny rule or
  managed setting for it.
- When a repository uses a lesser-known language, say what it is and link its
  documentation.
- Colleague test: someone with minimal context could follow each instruction.
  Add 3-5 examples only where behavior is hard to describe, and use XML tags
  only where one document mixes instructions, context and examples.

## Section A — AGENTS.md

Harness-neutral: project constraints, non-obvious build/test conditions, team
conventions, workflow, boundaries, links to shared supporting docs. Plain
Markdown; no required template or mandatory section list. Removing existing
frontmatter is a proposed structural change, not automatic.

A portable skill or workflow is not Claude-only merely because Claude can use
it. Describe shared requirements in host-neutral terms and name available
alternatives when useful. Claude-only commands, hook events and settings go in
CLAUDE.md or the selected Claude rules.

Only when Stage 1/2 establishes large parallel or adversarial workflows, add a
short project-specific condition for delegation and cost control; otherwise
omit an orchestration section. Do not manufacture model budgets or new rules.

## Section B — CLAUDE.md

After AGENTS.md exists, begin the root file with:

```markdown
@AGENTS.md
```

Then append only relevant, confirmed Claude-specific content: Claude Code
commands, specific hook behavior, permissions, path-rule details. With none,
the import alone is the full file, with no heading or filler. Never repeat
shared text below the import.

For an existing combined file, move shared clauses into AGENTS.md first with
their meaning and exceptions intact, then replace them with the import. Keep
unrelated Claude-specific content. A later explicit CLAUDE-only restriction
with no shared prerequisite requires scope resolution, not a standalone
document or an unapproved companion write.

## Section C — Shared supporting documents

Selected contributing-docs/ files hold necessary detail shared by humans and
agents: non-obvious architecture decisions, build/test setup, migrations or
conventions. Link them from AGENTS.md after they exist; prefer existing docs to
a parallel source. Do not move universally needed instructions out of AGENTS.md
merely to reach a default size target. Recommending a skill for a
sometimes-relevant procedure does not authorize creating it or removing a team
runbook.

## Section D — Nested instructions

For an authorized package-specific shared rule, use a nested AGENTS.md before a
nested CLAUDE.md, never just because a package exists. Differing shared rules
stay in the selected nested shared file; its Claude companion imports the local
AGENTS.md and adds only Claude-specific differences.

If only Claude-specific differences exist and shared ancestor instructions
already load, a nested CLAUDE.md may contain only those differences and imports
no nonexistent local AGENTS.md; explain this case in the verifier input.
Compute every relative link from its containing file. Do not assume a submodule
can resolve parent-repository paths when checked out independently.
Never duplicate shared package commands in a Claude-only nested template.

## Section E — Claude path rules

Selected `.claude/rules/` files hold confirmed Claude-specific scoped behavior.
Shared rules belong in shared instructions, even when path-scoped.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

(Confirmed Claude-specific rule)
```

Use documented `paths` globs; omit frontmatter for intentionally unconditional
rules, which still load at startup. Migrate legacy `globs`/`alwaysApply` only
within authorized scope, preserving intended conditions. A pattern with no
current matches warrants checking intent, not automatic removal of a
future-path rule.
