# Architecture Reference

## Version Comparison

### V1: 3-Agent + Sprint Architecture

The original design from Anthropic's harness design blog. Includes explicit sprint splitting as a core mechanism.

**Pipeline:**
```
Planner → Contract (per sprint) → Generator → Evaluator → [next sprint]
```

**Characteristics:**
- Sprint boundaries are mandatory, even for small tasks.
- Context resets between sprints.
- Handoff files bridge sprint boundaries.
- Higher ceremony, more artifacts.

**Best for:**
- Sonnet-class models with limited context.
- Very large tasks (4+ hours) that genuinely need phased delivery.
- Teams that want explicit checkpoints for human review.

### V2: Sprint Removal Architecture

Evolved design that removes sprint splitting as a mandatory component. With an Opus-class large context window, sprint boundaries are unnecessary for context management.

**Pipeline:**
```
Planner → Contract (single) → Generator → Evaluator → [feedback loop]
```

**Characteristics:**
- Single contract for the entire task.
- No mandatory context resets.
- Fewer artifacts, less ceremony.
- Relies on compaction instead of sprint boundaries.

**Best for:**
- Opus-class models with sufficient context.
- Tasks that can be completed in a single session.
- Faster iteration with less overhead.

**When to keep sprints even with Opus:**
- Task exceeds 6 hours (even Opus benefits from checkpoints).
- User explicitly wants phased delivery for review purposes.
- Multiple distinct deliverables that benefit from independent evaluation.

## Cost/Time Benchmarks

These are approximate figures based on typical usage patterns. Actual costs vary by task complexity and model pricing.

| Approach | Time | Cost (approx) | Agents Used | Overhead |
|----------|------|---------------|-------------|----------|
| Solo (no harness) | ~20 min | ~$9 | 1 | None |
| Generator + Evaluator | ~1-2 hr | ~$50 | 2 | Low |
| Full pipeline (no design) | ~3-6 hr | ~$150 | 3-4 | Medium |
| Full pipeline + design eval | ~4-6 hr | ~$200 | 4-5 | High |

### Cost Breakdown by Component

| Component | Typical Cost | Invocations |
|-----------|-------------|-------------|
| Planner (spec-planner) | ~$5-10 | 1 |
| Contract (sprint-contract-negotiator) | ~$5-10 | 1 per sprint |
| Generator (implementation) | ~$50-100 | 1 (bulk of work) |
| QA Evaluator (qa-evaluator) | ~$10-20 | 1-3 per round |
| Design Evaluator (frontend-design-evaluator) | ~$10-20 | 1-3 per round |

## Capstone Routing

This skill supports only `Planner → Contract → Generator`, optionally followed by QA and design evaluators. Solo and Generator+Evaluator rows above are external comparison architectures, not execution branches.

1. If the task is simple enough for Solo or Generator+Evaluator, recommend not using this capstone and stop before creating `.harness/`.
2. Otherwise run Planner, Contract, and Generator.
3. Add QA when independent functional verification is needed.
4. Add design evaluation when significant visual quality is in scope.

Never skip Contract after this capstone has started.

### When to Skip the Evaluator Entirely

The Evaluator adds value when the model might get something wrong. Skip it when:

- The task is routine and well within the model's capability (e.g., "add a REST endpoint for CRUD operations").
- Automated tests provide sufficient verification.
- The user prefers fast iteration over formal evaluation.
- Cost sensitivity: the evaluation rounds may cost more than the risk of a defect.

Signs the Evaluator IS needed:

- Subjective quality matters (UX, design, copy quality).
- Complex state management or edge cases.
- The task pushes the model's boundaries.
- First time building with an unfamiliar stack or pattern.

## Architecture Evolution

The harness is designed to evolve. As models improve:

1. **Components may become unnecessary.** If a future model no longer drifts on scope, the Planner becomes overhead.
2. **New components may be needed.** If a model gains capabilities (e.g., native visual evaluation), the pipeline adapts.
3. **The evaluation threshold shifts.** Tasks that once needed evaluation may become reliable enough to skip.

Re-evaluate the architecture on each major model release. See [harness-tuning-guide.md](harness-tuning-guide.md) for the re-validation checklist.
