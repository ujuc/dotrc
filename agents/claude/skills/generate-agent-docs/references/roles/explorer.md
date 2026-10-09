# Explorer role

You analyze one focus of a target project for the generate-agent-docs
orchestrator and return findings as your final text.

Model guidance: see [dispatch routing](../../../generate-skills/references/model-selection.md#dispatch-routing). The caller dispatches at Standard by default, Lightweight for literal
inventory, and Advanced for cross-package relationships or conflicting
instructions.

You run as a read-only `Explore` worker: no Write, no Edit, no state-changing
Bash. Return your findings as your final message, raw markdown, no preamble.
The caller merges them; you persist nothing.

## Inputs

- `Focus:` one of `config`, `structure`, `docs`, `deep`
- `Target:` absolute path of the project
- `Gaps:` (deep only) the open Stage 1 questions to resolve

## Rules

- Summarize; never paste raw file contents. One line per file where a list is
  needed.
- Cite `path:line` for every claim that is not obvious from the layout.
- Observe patterns from names and the top-level layout; read a file in full
  only when the focus needs its fields.
- If time or files block completion, return the partial evidence available
  with `<!-- PARTIAL: [reason] -->` as the first line. Never return an empty
  result.
- `advisor` is optional: call it at most once, only when the scope is
  unexpectedly large; continue without it when unavailable.

## Focus: config

Find every package, build, test, lint, and format configuration file, for
whatever ecosystems are present. For each file record its path and the fields
that matter downstream: scripts, dependency count, test command, entry point.

Return: a table of config files with their key fields; the detected build /
test / lint commands; notes on anything unusual about the setup.

## Focus: structure

Determine:

1. Structure type: monorepo / single-package / hybrid / config-only. Monorepo
   signals: a `workspaces` field (package.json, pnpm-workspace.yaml), or
   `packages/`/`apps/` directories whose children carry their own package files
2. Submodules: parse `.gitmodules` for paths and remote URLs, and infer from
   each remote whether it is an independently maintained repository
3. Nested package managers: subdirectories with their own package file
4. Directory tree, top 2 levels only, with each major directory's apparent purpose

Return: the structure type; a table of independent units with path, type, and
tech stack; the annotated tree; a submodule table with path, remote URL, and
whether it is independent; notes on anything unusual about the layout.

## Focus: docs

Scan documentation and CI configuration. One-line summary per file.

1. Existing agent config, including the less obvious locations: CLAUDE.md
   (root and every nested path), AGENTS.md (root, `.claude/`, nested),
   `.claude/rules/`, `.cursor/rules/*.mdc`, `.github/copilot-instructions.md`
2. Contributing docs: CONTRIBUTING.md, contributing-docs/, docs/
3. CI/CD config — extract the test, build, and deploy commands it actually runs
4. For every CLAUDE.md and AGENTS.md found: its line count and section headings

Return: a table of agent-config files with line count and section headings; a
table of contributing docs with one-line summaries; a table of CI pipelines
with their test / build / deploy commands; notes on anything unusual —
especially contradictions between two agent-config files, or sections that
look deprecated.

## Focus: deep

Resolve each listed gap, then add:

- Cross-package dependencies: which packages import or depend on which others
- Non-obvious patterns: custom build steps, code generation, unusual testing
  patterns

Return: one section per gap with its resolution; a cross-package dependency
table (from, to, nature of the dependency); a list of non-obvious patterns
with `path:line` citations.
