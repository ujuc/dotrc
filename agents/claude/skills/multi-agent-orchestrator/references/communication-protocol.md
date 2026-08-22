# Canonical Communication Protocol

## Source of Truth

Run `workflow-hooks contract` before a managed run. Its embedded `agents/workflow-contract.json` defines exact artifact paths, writers, context restoration, archive destinations, cadence, and Superpowers boundaries. This reference explains orchestration behavior but does not override the contract.

All managed communication is file-based. Each artifact has one writer; all other stages are read-only consumers. Writers must not create aliases or "latest" copies.

## Active Artifacts

| Artifact | Exact path or pattern | Sole writer | Readers |
|---|---|---|---|
| Product spec | `spec.md` | `spec-planner` | contract, research, planning, implementation, evaluators |
| Acceptance contract | `.sprint/contract.md` | `sprint-contract-negotiator` | research, planning, implementation, evaluators, synthesis |
| Research | `.research/research-*.md` | `deep-read` | planning and implementation |
| Plan | `.plans/plan-*.md` | `annotate-plan` | implementation, evaluators, synthesis |
| QA report | `.plans/.qa-{feature}-r{round}.md` | `qa-evaluator` | orchestrator synthesis and implementation feedback |
| Design report | `.plans/.design-{feature}-r{round}.md` | `frontend-design-evaluator` | orchestrator synthesis and implementation feedback |
| Synthesized report | `.plans/.evaluation-{feature}-r{round}.md` | `multi-agent-orchestrator` | `implement-plan` finalization |
| Handoff | `.plans/.handoff-{feature}.md` | `multi-agent-orchestrator` | next orchestration session |

Implementation verification, blocker, debug, implementation-flag, plan baseline, and annotation-cycle files use the exact transient patterns returned by `workflow-hooks contract`. Their owners may replace or clean them as specified by their skills; they are never durable workflow records.

## Workflow Sources

Every managed plan contains this exact section:

```markdown
## Workflow Sources
- Product Spec: `spec.md` or `None (bounded work)`
- Sprint Contract: `.sprint/contract.md`
- Research:
  - `.research/research-{topic}.md` or `None`
```

`annotate-plan` owns this section. Archive rejects malformed, non-canonical, missing, or unsafe source paths. Legacy `## Research Sources` remains readable only for pre-contract plans; new plans never emit it.

## Evaluator Rounds

QA and design outputs are separate immutable reports for each round. They never share a path, overwrite a previous round, or synthesize each other.

The orchestrator writes one synthesized report per round only after all selected reports exist. It must:

1. cite every exact source report path;
2. list every active contract criterion with PASS/FAIL and evidence source;
3. preserve each selected evaluator's verdict;
4. return Overall FAIL for any failed criterion, failed evaluator, Critical/Major issue, or missing evidence;
5. send findings to `implement-plan` without editing source reports.

## Handoff Format

Use `.plans/.handoff-{feature}.md` only when context must reset:

```markdown
# Handoff: {feature}

## Active Stage
## Canonical Artifacts
## Selected Evaluators
## Latest Evaluation Round
## Completed Evidence
## Blockers
## Runtime Services
## Next Owner and Action
```

Include exact paths and observed state, not copies of artifact content. A handoff does not grant approval. On resume, cross-check every referenced path and continue only the same active feature.

## Active-State Rules

- Only one workflow may be active per checkout.
- If canonical active artifacts exist, resume that exact workflow or stop. Never create a parallel singleton spec or contract.
- If state belongs to different features or stages, stop for user resolution; never guess which state wins.
- If `.harness/` exists, treat it as unsupported legacy state. Stop and ask the user to preserve, manually translate, or remove it. Never migrate or delete it automatically.
- Missing expected input: stop and name the owning stage that must produce it.
- Malformed or wrong-writer output: do not repair it as a consumer; return it to its sole writer.
- A stale final verifier becomes invalid after implementation changes and must be regenerated before evaluation.

## Completion and Archive

Only `implement-plan` invokes archive: immediately after standalone full verification when no evaluators were selected, or in finalization mode with a synthesized PASS report. Archive preflights all inputs and destinations before moving anything.

Durable destinations are:

| Source | Destination |
|---|---|
| `spec.md` | `docs/specs/spec-{feature}.md` |
| `.sprint/contract.md` | `docs/contracts/contract-{feature}.md` |
| `.research/research-*.md` | `docs/research/` |
| `.plans/plan-{feature}.md` | `docs/plans/` |
| final synthesis, when present | `docs/reports/report-{feature}.md` |

Archive moves the plan last and rolls back completed renames if a later move fails. It removes only feature-owned transients and preserves sibling-feature files.

## Protocol Invariants

1. Contract before action.
2. One active workflow per checkout.
3. One writer per managed artifact.
4. Exact paths; no aliases or inferred latest file.
5. Explicit approval before implementation.
6. Independent reports before synthesis.
7. `implement-plan` is the sole managed executor and archive caller.
