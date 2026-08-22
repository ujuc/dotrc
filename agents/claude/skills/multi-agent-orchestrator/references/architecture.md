# Canonical Workflow Architecture

## Purpose

The orchestrator coordinates a shared workflow rather than introducing a second planning or execution system. `agents/workflow-contract.json`, exposed by `workflow-hooks contract`, is the machine-readable authority.

```text
approved request
  → product classification/design
  → immutable acceptance contract
  → repository research when needed
  → annotated implementation plan
  → user approval
  → managed implementation and full verification
  → optional independent evaluator reports
  → synthesized criterion verdicts
  → managed finalization and durable archive
```

## Boundaries

The architecture separates coherent responsibilities:

- `spec-planner` owns product intent and architectural design.
- `sprint-contract-negotiator` owns testable acceptance boundaries.
- `deep-read` owns repository evidence.
- `annotate-plan` is the only implementation-plan writer.
- `implement-plan` is the only managed executor and archive caller.
- QA owns functional runtime acceptance and defect severity.
- Design owns Design Quality, Originality, Craft, and Visual Usability.
- The orchestrator owns sequencing, evaluator selection, synthesized evaluation, and handoff.

This avoids conflicting plans, self-evaluation, and competing completion claims.

## Request Classes

- **Spike:** answer uncertainty with bounded exploration; do not enter this pipeline.
- **Bounded work:** use an approved concise design without `spec.md`, but retain contract, plan, approval, execution, and verification boundaries.
- **Architectural work:** require approved `spec.md` before contract negotiation.

The classification is based on product and repository impact, not a duration estimate.

## Evaluator Selection

Select evaluators before implementation so `implement-plan` knows whether to archive or return `AWAITING_EVALUATION`.

- Select **QA** when runtime interaction, state transitions, error behavior, or independent functional evidence materially reduces risk.
- Select **design** when aesthetic direction, originality, craft, responsive composition, or visual usability is acceptance-critical.
- Select **both** when those concerns are independently material; run them in parallel against one stable build when state-safe.
- Select **none** when fresh automated verification objectively covers the work.

Evaluator selection is risk-based. Do not use unsupported cost, time, model-capability, or context-window claims as routing rules.

## Evaluation Architecture

Each selected evaluator receives a fresh context and writes an immutable round-specific report. Passing only canonical artifacts and relevant prior findings limits sympathy toward implementation effort while preserving regression evidence.

The orchestrator then writes a separate synthesis. Overall PASS requires:

1. every active acceptance criterion PASS;
2. every selected evaluator PASS under its own rules;
3. no Critical or Major issue;
4. exact evidence references for every verdict.

Numerical scores are diagnostic. They cannot override failed criteria, severe findings, or absent evidence.

## State and Recovery

One checkout has at most one active workflow. Artifacts survive context resets through canonical files, while `.plans/.handoff-{feature}.md` records only current routing state. Resume cross-checks paths before action.

Failures return to the owning stage:

- product ambiguity → `spec-planner`;
- acceptance ambiguity → new contract negotiation before implementation;
- evidence gap → `deep-read`;
- plan gap or repository drift → `annotate-plan`;
- implementation, test, or debug failure → `implement-plan`;
- evaluator report defect → the report's evaluator;
- synthesis defect → orchestrator.

Consumers do not silently repair another owner's artifact.

## Completion

A no-evaluator run archives after `implement-plan` completes fresh full verification. An evaluator-bearing run pauses at `AWAITING_EVALUATION`, then re-enters `implement-plan` with the exact synthesized PASS report. This keeps one completion authority while retaining independent judgment.

Archive preserves product intent, acceptance contract, research, plan, and optional final synthesis under `docs/`. Active state is not considered complete until that archive succeeds.

## Superpowers Relationship

Useful Superpowers principles are adapted, not installed as a competing controller:

- brainstorming informs product discovery and approval gates;
- writing-plans informs exact paths, commands, and verification detail;
- TDD, systematic debugging, verification, review, and safe parallel dispatch remain optional implementation disciplines.

Within managed runs, `annotate-plan` replaces `writing-plans`, and `implement-plan` replaces `subagent-driven-development` and `executing-plans`. Generic worktree and branch-finishing workflows do not override repository Git policy.

## Evolution Rule

Retain a stage only while evidence shows its boundary improves correctness, independence, or recoverability. Revalidate one component at a time against representative tasks; simplify before adding new roles or files. Contract compatibility and one-writer ownership take precedence over preserving historical process.
