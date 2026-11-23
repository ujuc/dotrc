@AGENTS.global.md

# Claude Code

## Model Quality

- Use `advisor()` only for a specific, high-impact uncertainty where an independent second review would materially change the decision.

## Delegation

- Use `Explore` for multi-file discovery.
- With ultracode on, run workflows as it directs and include an independent verification pass; state the token budget before each run. With it off, reserve `Workflow` for large evals, compliance checks, cross-verification, or bulk triage, and test a narrow slice first.

## Skills

- Personal skills are namespaced `ujuc:<name>`; `dual-brain` and `ego-browser` are bare, `ultra-config` is the `/ultra-config` command, and the upstream plugins use `skill-diet:<name>` and `egm:<name>`. When a project skill under `.claude/skills/` covers the same request, use the project skill.
- When a request matches an available skill, invoke it with the `Skill` tool before acting.
- Load a skill's references only for the workflow branch in progress; do not preload every linked document.
- When a skill names a tool this session lacks, use a local equivalent; if none exists, skip that step and report it.

## Writing

- Before handing over or seeking approval for Korean prose written for human readers, run the `ujuc:humanizer` skill in fast mode when the proactive-use clause in its `description` applies; that clause is the only copy of the target, length, and exclusion rules.
