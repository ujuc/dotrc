# agents/

Reference for the five subagents that power the planning-pipeline skills
(`deep-read` → `annotate-plan` → `implement-plan`).

Agents here are pipeline workers, not general-purpose assistants. They are
invoked via the `Agent` tool with `subagent_type: "<name>"` by exactly one
calling skill each.

For policy ("how to edit agents here"), see `../CLAUDE.md`.
This file is the **reference** for callers and contributors.

## Role Matrix

| Agent              | Calling skill       | Model  | Tools                                     | Writes code | Output path                       | Advisor |
|--------------------|---------------------|--------|-------------------------------------------|-------------|-----------------------------------|---------|
| `reference-finder` | `annotate-plan`     | sonnet | Read, Glob, Grep, advisor                 | no          | `.plans/.partial/references.md`   | ≤1      |
| `researcher`       | `deep-read` (×3)    | sonnet | Read, Glob, Grep, Bash, advisor           | no          | `.research/.partial/{role}.md`    | ≤1      |
| `verifier`         | `implement-plan`    | haiku  | Read, Glob, Grep, Bash, advisor           | no          | `.plans/.verify-{item-slug}.md`   | emergency only |
| `implementer`      | `implement-plan`    | sonnet | Read, Write, Edit, Glob, Grep, Bash, advisor | **yes**  | source files + `.plans/.blocker-{item-slug}.md` on failure | ≤1 (pre-blocker) |
| `debugger`         | `implement-plan`    | sonnet | Read, Grep, Glob, Bash, advisor           | no          | `.plans/.debug-{item-slug}.md`    | ≤1      |

Model selection: `haiku` for mechanical / high-volume parallel work, `sonnet`
for anything that requires reasoning or synthesis.

Tool minimalism: each agent gets the smallest tool set that lets it do its
job. `implementer` is the only one with `Write` / `Edit` for a reason.

## I/O Contract

Every agent is invoked with an output file path in its prompt. Rules that
apply to every agent:

1. **Write the output file even on partial success.** A missing file is
   indistinguishable from a silent crash to the caller.
2. **Cite sources with `file:line` or `file:start-end`.** Plain prose
   claims without citations are rejected by downstream skills.
3. **Markdown headings are part of the contract.** Callers grep for specific
   headings to split and merge partials — do not rename or drop headings.
4. **On partial or degraded output, prepend `<!-- PARTIAL: {reason} -->`.**
   `deep-read` and `annotate-plan` preserve this marker through their merge
   logic so the user can decide whether to retry.
5. **Never modify files outside the output path**, except `implementer`,
   which modifies source files scoped to its assigned todo item.

## Dependency Graph

```
          deep-read
              │
              ▼
 ┌──────── researcher ×3 (structure/dataflow/risks)
 │            │
 │            ▼
 │   .research/research-{feature}.md
 │            │
 │            ▼
 │       annotate-plan ─────────── reference-finder
 │            │                          │
 │            ▼                          ▼
 │   .plans/plan-{feature}.md   .plans/.references/{feature}.md
 │            │
 │            ▼
 │       implement-plan
 │            │
 │   ┌────────┼─────────┬─────────┐
 │   ▼        ▼         ▼         ▼
 │ implementer verifier debugger  (back to annotate-plan Phase B on RESET)
 │   │        │         │
 │   ▼        ▼         ▼
 │  source   .verify-   .debug-
 │  edits    {slug}.md  {slug}.md
 │   │
 │   ▼
 │  .plans/.blocker-{slug}.md (on failure, read by implement-plan Step 5a)
```

Artifact paths read by multiple skills:

- `.research/research-*.md` — produced by `deep-read`, consumed by
  `annotate-plan` Phase A.
- `.plans/.references/{feature}.md` — produced by `reference-finder` during
  `annotate-plan` Phase A, consumed by `implementer`.
- `.plans/plan-{feature}.md` — produced by `annotate-plan`, consumed by
  `implement-plan`.
- `.plans/.verify-{slug}.md` — produced by `verifier`, polled by
  `implement-plan` Step 3 Mode A.
- `.plans/.blocker-{slug}.md` — produced by `implementer`, consumed by
  `implement-plan` Step 5a and `annotate-plan` Phase B.
- `.plans/.debug-{slug}.md` — produced by `debugger`, consumed by
  `implement-plan` Step 5a and `annotate-plan` Phase B.

## Advisor Common Guide

All five agents have `advisor` in their `tools:` frontmatter, but the call
budget is deliberately tight:

- `advisor()` takes **no parameters** — the agent's full execution context
  is forwarded automatically.
- Call advisor AT MOST ONCE per run, at the standard point: **after
  orientation, before substantive work** (before writing the output file,
  before deep reading, before implementing).
- Do NOT call advisor for deterministic / mechanical work. It is not a
  sanity check; it is a judgment aid.
- The `verifier` is haiku-model and treats advisor as **emergency-only** —
  see its SKILL-side policy for the narrow exception.
- When advisor conflicts with tool output (files, test results), trust the
  tool output. You are allowed ONE reconcile call to surface the conflict
  explicitly; beyond that, record a blocker (implementer) or proceed with
  the primary evidence.

## Auxiliary Agents (out-of-pipeline)

Some agents are not part of the planning pipeline above. They are stateless
wrappers around external tools and are safe to share across multiple calling
skills (the "one caller per agent" rule applies to pipeline workers only).

| Agent             | Calling skills                | Model  | Tools                    | Writes code | Output                                                         | Advisor |
|-------------------|-------------------------------|--------|--------------------------|-------------|----------------------------------------------------------------|---------|
| `waza-runner`     | `generate-skills`, explicit eval requests | sonnet | Bash, Read               | no          | stdout + optional `claude/evals/<skill>/` scaffold + result JSON | no      |
| `skill-engineer`  | `skill-improver` (optional)   | sonnet | Read, Glob, Grep, advisor | no          | stdout (Korean report — trigger / overlap / model fitness)     | ≤1      |

`waza-runner` is the single entry point for all waza operations. Callers
dispatch with `scaffold <name>` to create a placeholder `eval.yaml` or
`eval <path-or-name>` to run a measurement (which auto-scaffolds the suite
when one is missing). The runner parses the resulting JSON and renders a
Korean summary table — or a before/after comparison when given a baseline
JSON. **Callers must never invoke the `waza` CLI directly; all subcommands
route through this agent.** On a host without `waza` installed it prints
the install guide at `references/waza-install.md` and exits cleanly so the
calling skill can degrade gracefully without a score.

When provisioned, `~/.claude/data/waza-workspace/` is gitignored and uses relative skill/eval paths with symlinks to `~/.claude/skills/` and `~/.claude/evals/`. This repository does not synthesize the evolving `.waza.yaml`; an absent workspace yields an advisory no-score exit.

`skill-engineer` is a read-only design analyst dispatched by
`skill-improver` (or directly by the user) for the analysis dimensions
that fall outside structural validation: trigger completeness, trigger
overlap across skills, and model fitness. It produces a Korean report
with PASS / WARN / FAIL verdicts per dimension and never edits skill
files. Dispatch with `Agent("skill-engineer", "<target> [--check
trigger|overlap|model|all]")`.

## Adding a New Agent — Checklist

1. `name` in frontmatter matches the filename (kebab-case).
2. `description` is one sentence in the definition's established language and names its caller or use case.
3. `tools:` contains the minimum set. Do not copy `implementer`'s tool list
   by default.
4. `model:` — `haiku` only if the work is mechanical and cost-sensitive;
   otherwise `sonnet`.
5. Decide advisor policy: `≤1`, `emergency only`, or `no advisor`.
6. Document Input, Output, and any Failure Policy explicitly in the body.
7. Add a row to the Role Matrix above and, if the agent produces a new
   artifact path, to the Dependency Graph.
8. Wire the dispatch into exactly one calling skill. Do not share agents
   across skills — that is what makes these pipeline workers instead of
   general-purpose assistants.
