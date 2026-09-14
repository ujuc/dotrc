---
source_url: https://agents.md/
last_upstream_check: 2026-08-22
check_interval_days: 30  # the standard site changes rarely; re-fetch only when stale
---

# AGENTS.md Standard — Best Practices

Authoritative guidance from the agents.md standard site for writing the
cross-harness AGENTS.md file (stage3-generator.md Section A). Freshness policy:
re-fetch `source_url` only when `today - last_upstream_check >
check_interval_days`; on fetch failure use this snapshot and say so in one line.

This file covers the **standard's own guidance**; the Claude Code side (the
`@AGENTS.md` import pattern, size budget) lives in
claude-code-best-practices.md. Where the two differ, see "Reconciliation"
below.

---

## Cached snapshot (last verified 2026-08-22)

### Format: plain markdown, no required fields

> "AGENTS.md is just standard Markdown. Use any headings you like; the agent
> simply parses the text you provide."

- No required fields or rigid structure. This skill defaults to plain Markdown;
  review existing frontmatter before proposing a structural change.

### Recommended content

> "Commit messages or pull request guidelines, security gotchas, large
> datasets, deployment steps: anything you'd tell a new teammate belongs
> here too."

The standard's own suggested sections (project overview, build/test commands,
code style, testing, security) are deliberately broader than what this skill
emits — see Reconciliation below. One claim worth keeping: agents "attempt to
execute relevant programmatic checks and fix failures" when test commands are
listed, which is why a **non-obvious** test invocation survives the filter
even though a standard one does not.

### Monorepo placement & precedence

> "Place another AGENTS.md inside each package. Agents automatically read the
> nearest file in the directory tree, so the closest one takes precedence."

- Nested AGENTS.md per package is the standard's monorepo answer (the main
  OpenAI repo carries 88 of them). This composes with Section D: a package
  with its own AGENTS.md gets a nested CLAUDE.md that imports it.
- Precedence at runtime: "explicit user chat prompts override everything."

### Lifecycle

- "Treat AGENTS.md as living documentation" — review obsolete entries as the
  code improves, preserving explicit project policy and authorized scope.
- Migration: existing docs can be renamed to AGENTS.md with a
  backward-compatible symlink for the old name.

---

## Reconciliation with this skill's defaults

AGENTS.md is the shared source and is written before its Claude companion.
Preserve explicit repository and user requirements, including concrete test
commands and nondefault conventions. The standard's lack of required fields is
not a prohibition on all frontmatter; plain Markdown is this skill's default.
Never remove intentional existing content without authorized scope.

The standard *permits* broader content ("code style guidelines", "build and
test commands") than this skill emits. The skill's discoverability/prune
filter applies only where no explicit project requirement takes precedence:

- Style rules a linter enforces and commands readable from
  package.json/Makefile stay excluded — the standard allows them, but they
  fail the prune test and burn the every-session size budget.
- What survives the filter maps onto the standard's intent: Operational
  Gotchas, Non-Obvious Conventions, Build & Test **Gotchas** (not standard
  commands), Boundaries — i.e., the "anything you'd tell a new teammate"
  material that code cannot reveal.

---

## Cross-vendor finding — GPT-6 Astra guidance (2026)

Source: [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)
(OpenAI). Model-specific finding, applied as a local writing default for the
cross-harness AGENTS.md because the same instruction shapes recur across
current frontier models. Explicit repository and user requirements still win.

### A1 — Route documents by situation, never as a blanket preload

- Bad: "Before every edit, read architecture.md, database.md, and deployment.md."
- Good: "Use architecture.md for service boundaries, database.md for schema
  changes, and deployment.md when preparing a deployment."

A blanket read burns every-session context; a contextual pointer costs one line
and loads only the branch in use. Emit pointers with their condition.

### A2 — Drop test encouragement; keep non-obvious invocations

Current models run relevant checks unprompted (see W1 in
model-prompting-guides.md). Omit "always run the tests" lines; keep a test
command only when it is non-obvious or gated by a team decision.

### A3 — Grant safe automation explicitly; calibrate restrictions to risk

Where a workflow is safe to run unattended, say so with its reason, e.g. "Local
tests use disposable fixtures with no production access; run them, fix
failures, and rerun affected tests without asking per step." Reserve "ask
first" language for destructive, production, or out-of-scope actions. Blanket
restrictive phrasing written for weaker models over-constrains current ones,
which already refuse unsafe work. Never weaken an explicit user or repository
safety boundary to satisfy this default.

### A4 — Define done where the repository has a fixed notion of it

If completing a change in this repository means running it, inspecting the
result, and fixing what fails, write that completion criterion once. A
"stop for review after the first implementation" line pulls the agent toward
an earlier stop; emit it only when the team actually wants that checkpoint.
