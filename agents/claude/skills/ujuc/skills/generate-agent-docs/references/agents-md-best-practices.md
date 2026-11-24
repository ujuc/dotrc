---
source_url: https://agents.md/
source_urls:
  - https://learn.chatgpt.com/docs/agent-configuration/agents-md.md
  - https://raw.githubusercontent.com/can1357/oh-my-pi/main/docs/context-files.md
last_upstream_check: 2026-11-24
source_sha256:
  https://agents.md/: 6438e1ff8cf75cb9ec51a39cc98cf8c6210f0a9e9d4a28c83188fe40d866c20e
  https://learn.chatgpt.com/docs/agent-configuration/agents-md.md: 9d1f87a2d1cb55b4782b95abe710692b35b9659789c2db31a22c7074a3383e8e
  https://raw.githubusercontent.com/can1357/oh-my-pi/main/docs/context-files.md: 30393c492d558ff204d2f49991410ab664f3161b42985511e033ebaa03ab438c
---

# AGENTS.md — Shared Instructions for Every Coding Agent

The cross-harness half of the instruction pair (stage3-generator.md
[ownership](stage3-generator.md#ownership-agentsmd-shared-claudemd-claude-only)).
Claude Code's side (the `@AGENTS.md` import, read modes, size warnings) lives in
claude-code-best-practices.md. Freshness and fetch failure follow SKILL.md's
load guidance.

## Cached snapshot (last verified 2026-11-24)

### The standard (source: agents.md)

- Plain Markdown, any headings, no required fields; *"the agent simply parses
  the text you provide."* Stewarded by the Agentic AI Foundation under the
  Linux Foundation; no spec version.
- Content: project overview, build and test commands, code style, testing,
  security, plus *"Commit messages or pull request guidelines, security
  gotchas, large datasets, deployment steps: anything you'd tell a new teammate
  belongs here too."* Agents *"attempt to execute relevant programmatic checks
  and fix failures"* when test commands are listed.
- Monorepos: *"Place another AGENTS.md inside each package. Agents
  automatically read the nearest file in the directory tree, so the closest one
  takes precedence."* Conflicts: *"The closest AGENTS.md to the edited file
  wins; explicit user chat prompts override everything."*
- Lifecycle: *"Treat AGENTS.md as living documentation."* Migration renames an
  old file and leaves a symlink (`mv AGENT.md AGENTS.md && ln -s AGENTS.md
  AGENT.md`).

### How each harness loads it

| Harness | User-global file | Project discovery | Imports | Notes |
| --- | --- | --- | --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` only | AGENTS.md only when no CLAUDE.md, `.claude/CLAUDE.md` or `CLAUDE.local.md` sits at or above cwd (default `claude-md-or-agents-md`) | `@path` expanded | `@AGENTS.md` in CLAUDE.md works in every read mode and never loads twice |
| Codex | `~/.codex/AGENTS.override.md`, else `~/.codex/AGENTS.md` | Git root down to cwd, one file per directory (`AGENTS.override.md` › `AGENTS.md` › fallback names), concatenated root first | Not expanded: `@path` stays literal text | Stops adding project files at `project_doc_max_bytes` (32 KiB default, configurable; the user-global file is loaded separately and does not count); never reads CLAUDE.md |
| omp | `~/.omp/agent/AGENTS.md`, shadows every other user file | One file per directory depth, cwd up to the repo root (then enclosing workspace directories up to, not including, home); at the same depth AGENTS.md wins and CLAUDE.md is not loaded (equal priority, registration order; undocumented) | `@path` expanded, 5 hops | Task subagents drop files named AGENTS.md and get no user-global file, so they see no instructions in an AGENTS.md + CLAUDE.md pair |
| pi | `~/.pi/agent/AGENTS.md` | AGENTS.md or CLAUDE.md in cwd and its parents | — | — |

Claude Code reads neither `AGENTS.local.md`, `AGENTS.override.md` nor anything
under `.agents/`.

## Consequences for this skill

- AGENTS.md is the shared source: every rule an agent other than Claude would
  also need. Its importing CLAUDE.md keeps Claude Code–only lines.
- Write AGENTS.md for every reader: no Claude tool names (`Skill`, `Agent`,
  `Explore`, `AskUserQuestion`, `advisor`), slash commands, hook or
  `.claude/` settings instructions. Name a supporting document by plain path
  with when to read it, never as an `@path` import that Codex shows literally.
- Keep the `@AGENTS.md` line in CLAUDE.md even where Claude Code would read
  AGENTS.md directly: some sessions cannot, and a `CLAUDE.local.md` silently
  turns direct reading off.
- omp task subagents receive no AGENTS.md: rules a subagent needs travel in
  its task prompt. Do not duplicate AGENTS.md rules into `.omp/RULES.md` to
  work around this.
- A nested AGENTS.md below a directory that has a CLAUDE.md at or above it is
  invisible to Claude Code in the default mode, so a selected nested AGENTS.md
  gets a sibling CLAUDE.md that imports it.
- Never create `AGENTS.override.md` or `AGENTS.local.md`: Claude Code ignores
  both, so a rule there forks the agents. Report an existing one and its effect.
- Size: Codex stops adding project files once the chain from the git root
  down to cwd reaches `project_doc_max_bytes`, 32 KiB by default
  (`codex-rs/core/src/agents_md.rs`); the user-global file is outside that
  budget. When a run adds to AGENTS.md, report the measured bytes of the
  project chain it sits in. Text that would push the chain past 32 KiB is not
  written as is: propose a shorter wording that keeps every fact (or a nested
  AGENTS.md) and wait for approval, because Codex silently drops the tail.
  Excess that predates the run, with nothing added past it, is an observation.

## Reconciliation with this skill's defaults

Preserve explicit repository and user requirements, including concrete test
commands and nondefault conventions. The standard's lack of required fields is
not a prohibition on frontmatter. Never remove intentional existing content
without authorized scope.

The standard permits broader content than this skill emits. The prune filter
applies where no explicit project requirement takes precedence:

- Style rules a linter enforces stay excluded; the exact test, typecheck and
  lint commands stay (claude-code-best-practices.md).
- What survives is what code cannot reveal: operational gotchas, non-obvious
  conventions, build and test gotchas, boundaries.

## Cross-vendor finding — GPT-6 Astra guidance (2026)

Source: [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra)
(OpenAI). Model-specific finding, applied as a local writing default for
AGENTS.md because the same instruction shapes recur across current frontier
models. Explicit repository and user requirements still win.

### A1 — Route documents by situation, never as a blanket preload

- Bad: "Before every edit, read architecture.md, database.md, and deployment.md."
- Good: "Use architecture.md for service boundaries, database.md for schema
  changes, and deployment.md when preparing a deployment."

### A2 — Drop test encouragement; keep non-obvious invocations

Omit "always run the tests" lines (see W1 in model-prompting-guides.md); keep
the test commands themselves.

### A3 — Grant safe automation explicitly; calibrate restrictions to risk

Where a workflow is safe to run unattended, say so with its reason, e.g.
"Local tests use disposable fixtures with no production access; run them, fix
failures, and rerun affected tests without asking per step." Reserve "ask
first" language for destructive, production, or out-of-scope actions. Never
weaken an explicit user or repository safety boundary to satisfy this default.

### A4 — Define done where the repository has a fixed notion of it

If completing a change in this repository means running it, inspecting the
result, and fixing what fails, write that completion criterion once. Emit a
"stop for review after the first implementation" line only when the team
actually wants that checkpoint.
