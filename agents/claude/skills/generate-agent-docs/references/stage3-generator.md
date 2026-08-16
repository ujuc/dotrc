# Stage 3: Generator

> Defines file generation rules for CLAUDE.md, AGENTS.md, contributing-docs/, nested CLAUDE.md, and .claude/rules/. Adopts a single sub-agent execution model.
> Tier 2 reference — loaded during Stage 3 execution.

---

## Agent Definition

| Parameter         | Value           |
| ----------------- | --------------- |
| subagent_type     | general-purpose |
| model             | sonnet          |
| run_in_background | false           |

---

## What the Orchestrator Provides

The orchestrator pastes the following into the dispatch prompt:

- **Authoritative constraints**: the include/exclude table, prune test, and
  size budget from claude-code-best-practices.md (live-fetched result
  preferred — paste the text, since the fetch happened in the orchestrator's
  context, not the agent's)
- **Stage 1 summary**: Detected project facts (tech stack, monorepo structure, submodules, existing files)
- **Stage 2 answers**: User decisions (which nested CLAUDE.md to generate, scope boundaries)
- **Target files**: List of files to create or update (Root CLAUDE.md, AGENTS.md, contributing-docs/, nested CLAUDE.md, .claude/rules/)

The agent reads the rule files itself (this file, model-prompting-guides.md,
SOUL.md, entry-router-guidelines.md) — do not re-condense them into the prompt.

## Dispatch Prompt Template

`{skill_dir}` = this skill's absolute directory (the orchestrator knows it
from reading this file). Fill every placeholder before dispatching.

```
You are generating project documentation files. You did not analyze this
project yourself — rely only on the inputs below and the rule files you read.

1. Read {skill_dir}/references/stage3-generator.md. Follow its Common
   Writing Rules and the per-file section (A–E) for each target.
2. Read {skill_dir}/references/model-prompting-guides.md. Apply every rule
   tagged [W] to the lines you write. Ignore the [S] rules — those govern the
   skill itself, not your output.
3. Read {skill_dir}/references/context-engineering-claude5.md. Apply C1–C4 —
   they decide whether a candidate line belongs in a doc at all, where [W]
   decides how a kept line is phrased. Read its Reconciliation section before
   you rewrite or drop any prohibition.
4. Read {skill_dir}/references/tdd-agent-loop.md. Apply T1 to every candidate
   line that instructs a testing or verification workflow — reject
   agent-directed TDD/test-first process mandates and rewrite them as
   outcome-based verification, unless its Reconciliation keeps the line.
5. Read {skill_dir}/references/SOUL.md. If the targets include AGENTS.md,
   also read {skill_dir}/references/agents-md-best-practices.md. If they
   include governance content (AGENTS.md Boundaries, behavioral guidelines),
   also read {skill_dir}/references/entry-router-guidelines.md.

Authoritative constraints (live-fetched from the Claude Code docs — these
override anything else you know about CLAUDE.md):
{authoritative_constraints}

Confirmed project facts (Stage 1):
{stage1_summary}

User decisions (Stage 2):
{stage2_answers}

Targets to write: {target_file_list}

Rules of engagement:
- Confirmed facts only — no assumptions, no "nice to have" content.
- Create files with Write; never touch files outside the target list.
- When done, report each written file path with its line count.
```

---

## Common Writing Rules

Apply to all generated files. The authoritative ✅ include / ❌ exclude table and
the prune test live in `claude-code-best-practices.md` (live-fetched) — defer to
the freshest copy of it; the rules below are the operative shorthand.

- Do not include code snippets directly — use `file:line` references only
- **Discoverability test**: For every line, ask "Can an agent discover this by reading the code?" If yes, omit it
- **Prune test** (authoritative gate): ask "Would removing this cause Claude to make mistakes?" If not, cut it. Bloated files cause Claude to ignore real instructions
- **Placement test (cross-harness split)**: harness-neutral project content →
  AGENTS.md (detail → contributing-docs/); Claude Code-only content →
  CLAUDE.md below the `@AGENTS.md` import, or `.claude/rules/` when
  path-scoped
- No auto-generated summaries: Do not include LLM-generated summaries of code as-is
- A must-run-every-time rule (e.g., lint before commit) belongs in a **hook**, not a CLAUDE.md line — recommend the hook instead
- **Instruction-authoring constraints**: apply the [W] rules in
  model-prompting-guides.md. The three that reject a line outright: never
  instruct self-verification or re-checking (W1), never command reasoning
  visibility in either direction (W2), never set a severity or confidence
  filter bar on findings (W5). The two that shape a kept line: state its scope
  explicitly, since a model does not generalize a rule from one item to
  another (W3), and carry one clause of *why* when the why is non-obvious (W4)
- **Context-engineering constraints** (context-engineering-claude5.md) decide
  whether a line belongs in a doc at all: **C1** — replace an absolute
  prohibition with the observable signal the agent should match, unless its
  Reconciliation test keeps the line as a guard; **C2** — a sometimes-relevant
  multi-step procedure becomes a recommended skill plus one reference line,
  never a section; **C3** — never write memory, notes, session-log, or
  changelog instructions into an agent-config file; **C4** — place a finding
  across four layers (harness / config file / skill / referenced doc), and
  reference an executable spec rather than paraphrasing it into prose
- **Testing-instruction constraint** (tdd-agent-loop.md): **T1** — a line
  that prescribes TDD, test-first, or red-green-refactor to the agent's own
  loop is rejected by default and rewritten as outcome-based verification (a
  concrete test command as the done criterion, a mutation-score bar, static
  analysis access). It survives only as one of its Reconciliation's four
  shapes — a human-writes-tests split, an outcome requirement, an explicit
  team decision confirmed in Stage 2, or a test-quality monitoring bar. The
  rewrite must not itself violate W1

---

## Section A: Root CLAUDE.md — Claude Code-Specific Layer

### Role

CLAUDE.md does not carry general project documentation — that lives in
AGENTS.md (Section B), which Codex and Amp load natively and Claude Code loads
through the `@AGENTS.md` import (official pattern,
claude-code-best-practices.md → "AGENTS.md — the official cross-agent
pattern"). CLAUDE.md holds only:

1. The `@AGENTS.md` import (first content line)
2. Content meaningful **only** to Claude Code: hooks, skills, subagents,
   plan-/permission-mode rules, output styles, MCP notes, compaction
   instructions, `.claude/rules/` interplay

### Generation Principles

- **Import first**: `@AGENTS.md` as the first content line. Claude loads the
  import at session start, then appends the rest.
- **Claude-only test**: for every line below the import, ask *"Would this line
  mean anything to an agent that is not Claude Code?"* If yes → it belongs in
  AGENTS.md (or contributing-docs/), not here.
- **No duplication**: never restate AGENTS.md content below the import.
- **Combined size budget**: CLAUDE.md + imported AGENTS.md load together every
  session — soft ~100 lines combined, **hard ceiling 200**
  (claude-code-best-practices.md). Budget most of it for AGENTS.md; past the
  ceiling, split into `.claude/rules/` rather than letting either file sprawl.
- **Nearly-empty is valid**: if the project has no Claude-specific behavior,
  the correct CLAUDE.md is the import line alone — or recommend
  `ln -s AGENTS.md CLAUDE.md` instead of a file. Never pad with project
  content to make the file look substantial.
- Include only **confirmed facts** from Stages 1 and 2. Before adding any
  instruction, ask: **"Will Claude make a mistake without this?"**

### Structure Template

```markdown
@AGENTS.md

## Claude Code

(Claude-specific rules only — omit any line that fails the Claude-only test. E.g.:)
- Use plan mode for changes under `src/billing/`
- Hooks: `post-edit-lint` runs on PostToolUse — do not re-run lint manually
- Prefer the `/release` skill for deployment steps

## References
(Only if nested CLAUDE.md files exist — list their directories.
`.claude/rules/` needs no listing; rules load automatically.)
```

### Do-NOT-Include List

- Project overview, tech stack, dev commands, architecture, git workflow —
  AGENTS.md content (Section B); the import already delivers it
- Anything meaningful to non-Claude harnesses (fails the Claude-only test)
- Code examples or syntax demonstrations
- Information directly readable from config files (package.json, go.mod, etc.)
- Rules that a linter or formatter already enforces
- Content duplicated from AGENTS.md or contributing-docs/
- Self-verification steps, pre-response checklists, or "double-check your work"
  lines (W1) — these cause over-verification; use a hook for a real gate
- Any instruction about showing or suppressing reasoning (W2) — the former
  risks `reasoning_extraction` refusals, the latter internal-tag leakage
- Effort, thinking, or model-tier configuration (D2) — API/harness settings,
  not project knowledge, and they go stale per tier
- Memory / Notes / Session Log / Changelog sections, and any instruction to
  record decisions or learnings into this file (C3) — auto-memory owns that
  content, and a hand-maintained log goes stale
- A sometimes-relevant multi-step procedure — release runbook, migration
  steps, verification sequence (C2) — recommend a skill and leave at most one
  reference line

---

## Section B: AGENTS.md — Primary Cross-Harness Project Document

### Overview

The project's main agent documentation, consumed by **every** harness: Codex
and Amp read AGENTS.md natively; Claude Code loads it via the `@AGENTS.md`
import in CLAUDE.md (Section A). Points to detailed documents in
contributing-docs/. Standard-level guidance (format, monorepo nesting,
lifecycle) lives in references/agents-md-best-practices.md.

### Generation Principles

- **Harness-neutral and self-contained**: never reference features that exist
  in only one harness (Skill/Agent tools, hooks, plan mode, slash commands,
  Claude-specific settings). When a workflow depends on a harness-specific
  feature, describe the goal in tool-agnostic terms and name a fallback any
  agent can follow. Claude-only instructions go to CLAUDE.md (Section A).
- **Plain markdown, no YAML frontmatter**: the agents.md convention is plain
  markdown; frontmatter is inert noise to the harnesses that read it. In
  update mode, flag existing frontmatter for removal.
- **Every-session context**: through native loading (Codex/Amp) and the
  CLAUDE.md import (Claude), AGENTS.md is loaded in full each session. The
  prune test applies line by line, and the combined CLAUDE.md + AGENTS.md
  budget (Section A) constrains its size — detail belongs in
  contributing-docs/, read on demand.
- **Treat AGENTS.md as a codesmell list**: each gotcha entry should ideally be
  resolved via code, linters, or CI. Remove entries when the underlying code
  improves.
- If an existing AGENTS.md exists, re-apply the discoverability test to all
  entries and identify candidates for removal.

### Structure

- **Project Overview**: Project purpose (only if not in README)
- **Operational Gotchas**: Traps agents cannot discover from code (external system behavior, non-obvious ordering requirements, environment-specific constraints)
- **Non-Obvious Conventions**: Conventions not inferable from code patterns (only what linters do not enforce)
- **Build & Test Gotchas**: Non-obvious build/test requirements only (exclude standard commands)
- **Git Workflow**: Branch strategy, commit conventions (only if not in CONTRIBUTING.md)
- **Boundaries**: Always Do / Ask First / Never Do
- **Contributing Docs**: Reference section listing detailed documents in contributing-docs/

### Conditional Block: Workflow Orchestration (Cost-Aware)

Emit this block in the generated AGENTS.md **only** when Stages 1–2 show the
project does large-scale parallel/adversarial orchestration — eval/benchmark
harnesses, rule- or policy-conformance verification, claim-source
cross-checking, bulk triage, or multi-agent pipelines. Otherwise **omit** it
(prune test: a project that never orchestrates gains nothing from it). Keep
the phrasing harness-neutral — "multi-agent workflows / parallel agents",
never Claude-specific tool names.

Template to emit (adapt the parenthetical examples to the project's real workloads):

```markdown
## Workflow Orchestration (Cost-Aware)

- Use multi-agent workflows only for long / large-scale parallel / adversarial
  verification (e.g. <project's eval suites, compliance checks, bulk triage>).
  Not for ordinary coding or single-file edits.
- Gauge cost on a narrow slice (one directory, one narrow question) before any
  large run; state the token budget. Route steps that don't need a strong model
  down to a smaller model.
```

---

## Section C: contributing-docs/ Separate Documents

Generate as separate documents the detailed content referenced from AGENTS.md. Create only the documents applicable to the project:

- `contributing-docs/architecture.md`: Service structure, communication patterns, data flows
- `contributing-docs/building_the_project.md`: Detailed build/deployment procedures
- `contributing-docs/testing.md`: Test strategy, test data setup
- `contributing-docs/database.md`: Schema structure, migration procedures
- `contributing-docs/conventions.md`: Code conventions, naming rules (only what linters cannot enforce)
- `contributing-docs/behavioral.md`: Project-specific behavioral constraints (only if applicable)

Each separate document must also be concise and follow the common writing
rules — including harness neutrality: contributing-docs/ serves every agent
and human contributor, so no harness-specific feature references.

---

## Section D: Nested CLAUDE.md (Monorepo Packages / Submodules)

Generate for directories detected in Stage 1 and approved by the user in Stage 2.

### Generation Conditions

Generate **only** for directories that satisfy **all** of the following:

- Has its own package manager file, or is a git submodule
- Requires a different tech stack, build commands, or work rules from the root CLAUDE.md
- The user approved generation in Stage 2

### Generation Principles

Inherit principles from Section A, with the following additions:

- **Scope restriction**: Cover only context within this directory
- **No duplication**: Do not repeat content from the parent CLAUDE.md (or the
  AGENTS.md it imports). Describe only differences
- **Parent reference**: Reference the parent CLAUDE.md by explicit relative path for shared rules
- **Local AGENTS.md**: if the directory has its own AGENTS.md (e.g., a
  submodule that is itself a cross-harness repo), the nested CLAUDE.md
  imports it (`@AGENTS.md`) exactly as Section A prescribes for the root
- **Target line count**: 50 lines or fewer. Hard limit: 100 lines
- **Self-contained title**: Begin with `# CLAUDE.md — {package/submodule name}`

### Structure Template

```markdown
# CLAUDE.md — {name}

(1 line: purpose/role of this directory)

## Tech Stack
(Only differences from parent. Omit section if identical)

## Development Commands
(Build/test/lint commands unique to this directory)

## Work Rules
(Only if there are rules different from the parent. Omit if none)

## References
- **[{relative-path-to-root-CLAUDE.md}]({relative-path-to-root-CLAUDE.md})** — Project-wide common rules
(Import local AGENTS.md via `@AGENTS.md` if present; omit otherwise)
```

### Reference Path Rules

- Root CLAUDE.md: compute the depth-correct relative path from the nested file (for example, `../../CLAUDE.md` from `packages/core/CLAUDE.md`); replace the template placeholder before writing and never hardcode one `../`.
- Submodule: Reference parent repository CLAUDE.md via URL or relative path
- Sibling directories: Do not reference directly (route through parent)

---

## Section E: .claude/rules/ Rule Files

Auto-injected path-scoped rule files loaded by Claude Code each session. If contributing-docs/ serves as detailed documentation for all AI agents and human developers, rules/ serves as behavior rules exclusive to Claude Code.

### Generation Conditions

Generate **only** when one or more of the following is found in Stages 1–2:

1. **Path scoping needed**: Rules exist that apply only to specific directories
2. **CLAUDE.md exceeds size limit**: Non-universal rules need extraction because the combined CLAUDE.md + AGENTS.md budget will be exceeded
3. **3+ independent concerns**: 3 or more unrelated rule groups are identified

### Generation Principles

- **Path scoping first**: Rules that can specify `paths` must always include `paths`
- **Minimize unconditional rules**: Rules needed in every session go in CLAUDE.md (or AGENTS.md when harness-neutral) first. A rules/ file without `paths` (= loaded every session) is justified only when the CLAUDE.md size limit forces extraction
- **One concern per file**: Do not mix multiple concerns in a single file
- **File naming**: `{concern}.md` (e.g., `api-conventions.md`, `testing.md`, `database-safety.md`)
- **Size limit**: 50 lines or fewer per file
- **Discoverability test**: Inherit from common writing rules

### File Format

```markdown
---
paths:
  - "src/api/**/*.ts"
---

(Rule content — undiscoverable, Claude-specific information only)
```

- `paths` (glob array) is the **only** documented frontmatter field
  (claude-code-best-practices.md → "`.claude/rules/` format"); brace expansion
  is supported (`src/**/*.{ts,tsx}`). A rule without `paths` — omit the
  frontmatter block entirely — loads unconditionally at launch, same priority
  as `.claude/CLAUDE.md`.
- Never emit the legacy `description` / `globs` / `alwaysApply` fields. In
  update mode, migrate: `globs` → `paths`; `alwaysApply: true` → drop the
  frontmatter (unconditional); `alwaysApply: false` + `globs` → `paths`.

### Role Distinction: contributing-docs/ vs rules/

| Dimension        | contributing-docs/                         | rules/                          |
| ---------------- | ------------------------------------------ | ------------------------------- |
| Audience         | All AI agents + human developers           | Claude Code only                |
| Load mechanism   | Referenced from AGENTS.md, read on demand  | Auto-injected each session      |
| Path scoping     | Not possible                               | Possible via `paths`            |
| Content          | Detailed documents (architecture, testing) | Short behavior rules            |
