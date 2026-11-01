---
source_url: https://agents.md/
last_upstream_check: 2026-11-01
check_interval_days: 30  # the standard site changes rarely; re-fetch only when stale
---

# AGENTS.md Standard — Best Practices

The agents.md standard's own guidance for the cross-harness AGENTS.md
(stage3-generator.md Section A). The Claude Code side (the `@AGENTS.md` import
pattern, size budget) is in claude-code-best-practices.md. Freshness and fetch
failure follow SKILL.md's load guidance.

## Cached snapshot (last verified 2026-11-01)

- **Format**: plain Markdown, any headings, no required fields; the agent simply
  parses the text. This skill defaults to plain Markdown; review existing
  frontmatter before proposing a structural change.
- **Status**: the site states no spec version. It is *"stewarded by the Agentic
  AI Foundation under the Linux Foundation"* and reports adoption by over 60k
  open-source projects.
- **Content**: "Commit messages or pull request guidelines, security gotchas,
  large datasets, deployment steps: anything you'd tell a new teammate belongs
  here too." Suggested sections: project overview, build/test commands, code
  style, testing, security. Agents "attempt to execute relevant programmatic
  checks and fix failures" when test commands are listed, so a **non-obvious**
  test invocation survives the filter even though a standard one does not.
- **Monorepos**: "Place another AGENTS.md inside each package. Agents
  automatically read the nearest file in the directory tree, so the closest one
  takes precedence." The main OpenAI repo carries 88 of them. A package with its
  own AGENTS.md gets a nested CLAUDE.md that imports it (Section D). At runtime,
  "explicit user chat prompts override everything."
- **Lifecycle**: "Treat AGENTS.md as living documentation" — review obsolete
  entries as the code improves, preserving explicit project policy and
  authorized scope. Existing docs can be renamed with a backward-compatible
  symlink for the old name (`mv AGENT.md AGENTS.md && ln -s AGENTS.md AGENT.md`).

## Reconciliation with this skill's defaults

AGENTS.md is the shared source and is written before its Claude companion.
Preserve explicit repository and user requirements, including concrete test
commands and nondefault conventions. The standard's lack of required fields is
not a prohibition on all frontmatter. Never remove intentional existing content
without authorized scope.

The standard permits broader content than this skill emits. The skill's
discoverability/prune filter applies only where no explicit project requirement
takes precedence:

- Style rules a linter enforces and commands readable from
  package.json/Makefile stay excluded: they fail the prune test and burn the
  every-session size budget.
- What survives is what code cannot reveal: Operational Gotchas, Non-Obvious
  Conventions, Build & Test **Gotchas** (not standard commands), Boundaries.

## Cross-vendor finding — GPT-6 Astra guidance (2026)

Source: [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)
(OpenAI). Model-specific finding, applied as a local writing default for the
cross-harness AGENTS.md because the same instruction shapes recur across current
frontier models. Explicit repository and user requirements still win.

### A1 — Route documents by situation, never as a blanket preload

- Bad: "Before every edit, read architecture.md, database.md, and deployment.md."
- Good: "Use architecture.md for service boundaries, database.md for schema
  changes, and deployment.md when preparing a deployment."

### A2 — Drop test encouragement; keep non-obvious invocations

Omit "always run the tests" lines (see W1 in model-prompting-guides.md); keep a
test command only when it is non-obvious or gated by a team decision.

### A3 — Grant safe automation explicitly; calibrate restrictions to risk

Where a workflow is safe to run unattended, say so with its reason, e.g. "Local
tests use disposable fixtures with no production access; run them, fix
failures, and rerun affected tests without asking per step." Reserve "ask
first" language for destructive, production, or out-of-scope actions: blanket
restrictions over-constrain current models, which already refuse unsafe work.
Never weaken an explicit user or repository safety boundary to satisfy this
default.

### A4 — Define done where the repository has a fixed notion of it

If completing a change in this repository means running it, inspecting the
result, and fixing what fails, write that completion criterion once. Emit a
"stop for review after the first implementation" line only when the team
actually wants that checkpoint.
