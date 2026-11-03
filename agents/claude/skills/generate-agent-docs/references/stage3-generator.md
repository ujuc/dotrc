# Stage 3 — CLAUDE.md Instructions

Per-file rules for the writer. Create only authorized missing files; existing
files follow update-mode.md U3.

## Scope: CLAUDE.md only

- This skill writes CLAUDE.md (root, `.claude/CLAUDE.md`, nested),
  `.claude/rules/` and contributing-docs/. It never creates, edits or deletes
  AGENTS.md.
- An existing AGENTS.md is read-only input. Claude Code stops reading it once a
  CLAUDE.md exists at or above it, so keep an existing `@AGENTS.md` import, and
  start a new CLAUDE.md beside a rule-bearing AGENTS.md with `@AGENTS.md`. Never
  copy its rules into CLAUDE.md. Folding AGENTS.md into CLAUDE.md is a
  structural change: propose it with the reason, never apply it unapproved.
- A request naming AGENTS.md, or a rule meant for every coding agent: place
  the rule in CLAUDE.md and say this skill writes CLAUDE.md only.

## Common writing rules

- Never duplicate a rule across CLAUDE.md, its imports and `.claude/rules/`.
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
- Use the local budgets in claude-code-best-practices.md.
- Preserve unrelated content. Report optional improvements outside authorized
  changes separately, even when auditing every line.
- Keep a rule with no exceptions as a line and recommend a hook, deny rule or
  managed setting for it.
- When a repository uses a lesser-known language, say what it is and link its
  documentation.
- Colleague test: someone with minimal context could follow each instruction.
  Add 3-5 examples only where behavior is hard to describe, and use XML tags
  only where one document mixes instructions, context and examples.

## Section A — CLAUDE.md

Plain Markdown holding the confirmed project instructions: constraints,
non-obvious build/test conditions, team conventions, workflow, boundaries,
Claude Code commands, hook behavior, permissions and links to supporting docs.
No required template or mandatory section list. Removing existing frontmatter
is a proposed structural change, not automatic.

Only when Stage 1/2 establishes large parallel or adversarial workflows, add a
short project-specific condition for delegation and cost control; otherwise
omit an orchestration section. Do not manufacture model budgets or new rules.

## Section B — Supporting documents

Selected contributing-docs/ files hold necessary detail shared by humans and
Claude: non-obvious architecture decisions, build/test setup, migrations or
conventions. Link them from CLAUDE.md after they exist; prefer existing docs to
a parallel source. Do not move universally needed instructions out of
CLAUDE.md merely to reach a default size target. Recommending a skill for a
sometimes-relevant procedure does not authorize creating it or removing a team
runbook.

## Section C — Nested instructions

An authorized package-specific rule goes in a nested CLAUDE.md, never just
because a package exists. Ancestor CLAUDE.md files already load, so a nested
file holds only its differences. Compute every relative link from its
containing file. Do not assume a submodule can resolve parent-repository paths
when checked out independently.

## Section D — Path rules

Selected `.claude/rules/` files hold confirmed path-scoped behavior.

```markdown
---
paths:
  - "src/api/**/*.ts"
---

(Confirmed path-scoped rule)
```

Use documented `paths` globs; omit frontmatter for intentionally unconditional
rules, which still load at startup. Migrate legacy `globs`/`alwaysApply` only
within authorized scope, preserving intended conditions. A pattern with no
current matches warrants checking intent, not automatic removal of a
future-path rule.
