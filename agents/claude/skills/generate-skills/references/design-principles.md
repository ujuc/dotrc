# Skill design principles

Local defaults. What to cut and where each fact lives follow
[skill-diet](../../skill-diet/SKILL.md).

## Degrees of freedom

| Freedom | Instruction style | Best for |
| --- | --- | --- |
| Low | "ALWAYS use this exact format" | Format-critical, high-repetition tasks |
| Medium | "Follow this structure, adapt as needed" | Patterns with context variance |
| High | "Use your best judgment" | Creative or highly variable work |

Default up, not down: current models handle ambiguity, and a step-by-step recipe
tends to hinder them. Start at the highest freedom the task tolerates and lower
it only for a fragility you can name. State the goal and constraints; leave the
route to the model. (Model-specific finding: OpenAI, "Rethinking skills and
prompts for GPT-6 Astra"; Claude Code model-config, Fable guidance.)

A multi-workflow skill keeps `SKILL.md` a router: enough to pick the workflow
and find its reference or script, with each reference linked under its case
("`a.md` for migrations, `b.md` for rollout review"), never a blanket preload.

## Gotchas

Every skill keeps a Gotchas section: failure points the model hits, edge cases,
hard-to-debug mistakes, each stated with the correct approach. Seed it at
creation and add to it as new failures appear.

## Setup and state

- A skill that needs user-specific setup checks for a `config.json` (in the
  skill directory or `${CLAUDE_PLUGIN_DATA}`) and asks when it is missing.
- Store only approved, non-secret preferences, and only in an authorized state
  location.
- Persist run data (append-only log, JSON, SQLite) under `${CLAUDE_PLUGIN_DATA}`,
  which survives upgrades; the skill directory may not. Without that variable,
  use an explicitly authorized host location. Never invent a plugin variable or
  write another project's runtime data into global skill sources.

## On-demand hooks

Frontmatter `hooks` register when the skill is invoked and stay for the session.
Use them for guardrails too noisy to keep on always: block `rm -rf`, `DROP TABLE`
or force-push while touching prod, or block edits outside one directory while
debugging.

## Completion criteria and decision boundaries

- Say what "done" means up front. If done includes running, inspecting and
  fixing the result, write that in; a "stop for review after the first
  implementation" step pulls the model toward an early stop.
- Calibrate permission wording to real risk: grant safe automation explicitly
  ("local tests use disposable fixtures; run them, fix failures and rerun without
  asking"), and reserve "never without approval" for destructive or out-of-scope
  actions.
- Strong run-to-completion wording lowers the chance the model asks about a
  genuinely ambiguous request (model-specific finding, Prompting Claude Fable
  5.1); keep explicit stop conditions where ambiguity is costly.
