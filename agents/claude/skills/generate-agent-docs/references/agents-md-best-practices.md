---
source_url: https://agents.md/
last_upstream_check: 2026-07-19
check_interval_days: 30  # the standard site changes rarely; re-fetch only when stale
---

# AGENTS.md Standard — Best Practices

Authoritative guidance from the agents.md standard site for writing the
cross-harness AGENTS.md file (stage3-generator.md Section B). Freshness policy:
re-fetch `source_url` only when `today - last_upstream_check >
check_interval_days`; on fetch failure use this snapshot and say so in one line.

This file covers the **standard's own guidance**; the Claude Code side (the
`@AGENTS.md` import pattern, size budget) lives in
claude-code-best-practices.md. Where the two differ, see "Reconciliation"
below.

---

## Cached snapshot (last verified 2026-07-19)

### Format: plain markdown, no required fields

> "AGENTS.md is just standard Markdown. Use any headings you like; the agent
> simply parses the text you provide."

- No required fields, no frontmatter, no rigid structure — this is why
  Section B mandates plain markdown and flags YAML frontmatter for removal.

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

- "Treat AGENTS.md as living documentation" — matches Section B's codesmell
  principle (entries are removed as the code improves).
- Migration: existing docs can be renamed to AGENTS.md with a
  backward-compatible symlink for the old name.

---

## Reconciliation with this skill's stricter filter

The standard *permits* broader content ("code style guidelines", "build and
test commands") than this skill emits. The skill's discoverability/prune
filter **still governs**:

- Style rules a linter enforces and commands readable from
  package.json/Makefile stay excluded — the standard allows them, but they
  fail the prune test and burn the every-session size budget.
- What survives the filter maps onto the standard's intent: Operational
  Gotchas, Non-Obvious Conventions, Build & Test **Gotchas** (not standard
  commands), Boundaries — i.e., the "anything you'd tell a new teammate"
  material that code cannot reveal.
