# Managed Plan Format

Superpowers `writing-plans` writes managed plans; `implement-plan` parses them and `workflow-hooks archive` validates their sources.

## Workflow Sources

Every managed plan contains `## Workflow Sources`. Use exact canonical
backticked paths for present sources, or the plain value `None` for absent ones.
For example, architectural work with material research uses:

```markdown
## Workflow Sources
- Product Spec: `spec.md`
- Sprint Contract: `.sprint/contract.md`
- Research:
  - `.research/research-{topic}.md`
```

Bounded work without material research uses:

```markdown
## Workflow Sources
- Product Spec: None
- Sprint Contract: `.sprint/contract.md`
- Research: None
```

Use `- Sprint Contract: None` only when no active contract exists. Never include
alternatives or explanatory prose in field values, or put `None` in a research
list. The topic placeholder above must be replaced with an existing source path.

Archive rejects malformed, non-canonical, missing, or unsafe source paths. Legacy `## Research Sources` remains readable only for pre-contract plans; new plans never emit it.

## Managed Plan Requirements

The contract overrides the `writing-plans` defaults, so whoever invokes it for a managed plan passes these as its plan-location and execution-method preferences:

- Save to `.plans/plan-{feature}.md`, never `docs/superpowers/plans/`. Stop when a different active plan exists.
- Include `## Workflow Sources` in the format above, and copy every active contract criterion and exclusion verbatim.
- Give every task checkbox steps, exact implementation and test paths, `Consumes`/`Produces` interfaces, and a verification command.
- Name `implement-plan` as the execution method in the plan header and the execution handoff; do not offer `subagent-driven-development` or `executing-plans`.
- Revise the same file through `writing-plans` for user edits and for `.plans/.blocker-*.md` or `.plans/.debug-*.md` feedback. A change to scope, exclusions, or acceptance criteria under an active contract returns to `sprint-contract-negotiator` instead.

