# Stage 3 — Agent Instruction Files

Per-file rules for the writer. Create only authorized missing files; existing
files follow update-mode.md U3.

## Ownership: AGENTS.md shared, CLAUDE.md Claude-only

- This skill writes AGENTS.md (root and nested), CLAUDE.md (root,
  `.claude/CLAUDE.md`, nested), `.claude/rules/` and contributing-docs/.
- AGENTS.md holds every rule another coding agent would also need: build, test
  and lint commands, conventions, boundaries, gotchas, commit and review rules.
- CLAUDE.md beside an AGENTS.md starts with `@AGENTS.md` and holds only lines
  that make sense inside Claude Code alone: the `Skill`, `Agent`/`Explore`,
  `AskUserQuestion` or `advisor` tools, slash commands, hooks, `.claude/`
  settings and permissions, plan mode, `/context` or `/memory`, output styles.
  Unsure → AGENTS.md: Claude still reads it through the import. An existing
  CLAUDE.md without the import keeps receiving shared rules until the import
  is approved.
- One rule, one file. Never copy an AGENTS.md rule into CLAUDE.md, never use
  `/import` (it appends a duplicate copy), and keep an existing `@AGENTS.md`
  import. A symlinked CLAUDE.md → AGENTS.md is an existing layout to keep, not
  one to create.
- A CLAUDE.md-only repository is a structural change away from this layout:
  propose the split with its reason and apply it only on approval or a request
  naming AGENTS.md. The split moves shared lines verbatim, with their
  headings and order, into AGENTS.md and leaves `@AGENTS.md` plus the
  Claude-only rest in CLAUDE.md.
- Loading differences between harnesses, and why the import stays even where
  Claude Code reads AGENTS.md directly:
  [agents-md-best-practices.md](agents-md-best-practices.md).

## Common writing rules

- Never duplicate a rule across AGENTS.md, CLAUDE.md, their imports and
  `.claude/rules/`.
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
- Use the local budgets in claude-code-best-practices.md, counting AGENTS.md
  inside its importing CLAUDE.md. When a write adds to AGENTS.md, report the
  project AGENTS.md chain's bytes (git root down to the target) against
  Codex's default 32 KiB `project_doc_max_bytes` (agents-md-best-practices.md).
  If the new text would push the chain past it, write nothing yet: propose a
  shorter wording that keeps every fact, or a nested AGENTS.md, and wait for
  approval, which may also accept the text as is; a headless run leaves that
  write pending and reports it.
- Preserve unrelated content. Report optional improvements outside authorized
  changes separately, even when auditing every line.
- Keep a rule with no exceptions as a line and recommend a hook, deny rule or
  managed setting for it.
- When a repository uses a lesser-known language, say what it is and link its
  documentation.
- Colleague test: someone with minimal context could follow each instruction.
  Add 3-5 examples only where behavior is hard to describe, and use XML tags
  only where one document mixes instructions, context and examples.

## Section A — AGENTS.md and CLAUDE.md

Plain Markdown holding the confirmed project instructions: constraints,
non-obvious build/test conditions, team conventions, workflow, boundaries and
links to supporting docs in AGENTS.md; Claude Code commands, hook behavior and
permissions in CLAUDE.md. No required template or mandatory section list.
Removing existing frontmatter is a proposed structural change, not automatic.

AGENTS.md is read by agents that do not expand imports: name a supporting file
by plain path with when to read it, never as `@path`. Keep Claude tool names
and slash commands out of it. A CLAUDE.md with no Claude-only line is exactly
`@AGENTS.md`.

Only when Stage 1/2 establishes large parallel or adversarial workflows, add a
short project-specific condition for delegation and cost control; otherwise
omit an orchestration section. Do not manufacture model budgets or new rules.

## Section B — Supporting documents

Selected contributing-docs/ files hold necessary detail shared by humans and
agents: non-obvious architecture decisions, build/test setup, migrations or
conventions. Link them from AGENTS.md when CLAUDE.md imports it or no CLAUDE.md
exists, else from CLAUDE.md, after they exist; prefer existing docs to a
parallel source. Do not move universally needed instructions out of
AGENTS.md or CLAUDE.md merely to reach a default size target. Recommending a
skill for a sometimes-relevant procedure does not authorize creating it or
removing a team runbook.

## Section C — Nested instructions

An authorized package-specific rule goes in a nested AGENTS.md, never just
because a package exists. Ancestor files already load, so a nested file holds
only its differences. Claude Code in its default mode skips a nested AGENTS.md
once any CLAUDE.md sits at or above the working directory, so give each new
nested AGENTS.md a sibling CLAUDE.md that imports it. Compute every relative
link from its containing file. Do not assume a submodule can resolve
parent-repository paths when checked out independently.

## Section D — Path rules

Selected `.claude/rules/` files hold confirmed path-scoped behavior that only
Claude needs. A path-scoped rule every agent needs goes in the nested AGENTS.md
of that directory (Section C); if the user selects `.claude/rules/` for it
anyway, write it there and report that other agents will not see it.

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
