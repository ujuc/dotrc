# Managed Workflow Tuning Guide

## Tune Against Evidence

Tune a stage only after identifying a repeatable disagreement between its documented contract and observed output. Preserve one-writer boundaries while testing changes.

1. Capture the exact canonical input, output path, contract criterion, and observed defect.
2. Decide which stage owns the defect.
3. Change that owner's instruction or reference, not a downstream consumer.
4. Validate the skill and rerun the same representative case.
5. Check that the fix did not weaken unrelated criteria.
6. Record why the workflow contract changed when compatibility is affected.

## Evaluator Calibration

### Fresh-Agent Anti-Leniency

Use a fresh evaluator context for every round. Give it canonical spec/contract/plan/final-verifier paths, the stable runtime environment, and only prior findings that require explicit regression checks. Do not include implementation effort or conversational history.

Each report judges the current product against the original active criteria, not improvement since the previous round. Previous findings are RESOLVED, PARTIALLY RESOLVED, or NOT ADDRESSED; resolution does not relax the contract.

### Severity and Verdict Thresholds

QA Overall PASS requires every active acceptance criterion PASS and no Critical or Major issue. Numerical category scores are diagnostic only. Stubbed contracted behavior is a functional FAIL.

Design Overall PASS requires weighted average ≥ 7, every design criterion ≥ 7, and no Critical or Major visual-usability issue. Anti-pattern caps and mobile requirements remain defined by the design evaluator. Design does not convert incidental business-function defects into design-owned acceptance verdicts; link that evidence to QA.

Synthesis is stricter than either score display: any selected evaluator FAIL, active criterion FAIL, severe issue, or missing evidence makes Overall FAIL.

### Common Failure Modes

#### Lenient Approval

**Signal:** A report describes a material defect but returns PASS.

**Action:** Make the owning evaluator's criterion and severity mapping explicit. Do not compensate in synthesis with an uncited opinion.

#### Happy-Path-Only QA

**Signal:** State-changing workflows lack boundary, invalid-input, failure-state, or persistence evidence.

**Action:** Add concrete interaction cases to the contract or QA criteria, then rerun in a fresh context.

#### Screenshot-Only QA

**Signal:** Functional acceptance relies on source reading or static screenshots.

**Action:** Stop the managed QA round if browser interaction is unavailable. Static evidence may supplement, not replace, runtime interaction for contracted behavior.

#### Functional/Visual Ownership Drift

**Signal:** QA grades aesthetic originality, or design decides business acceptance.

**Action:** Return the report to its evaluator. Keep QA on Product Depth, Functionality, Functional Usability, and Code Quality; keep design on Design Quality, Originality, Craft, and Visual Usability.

#### Round Sympathy

**Signal:** A later report passes because of visible implementation effort rather than stronger evidence.

**Action:** use a new evaluator context, remove implementation narrative, and compare every verdict directly with the active criterion.

#### Missing Synthesis Coverage

**Signal:** Overall PASS omits a criterion or does not cite a selected report.

**Action:** The orchestrator rewrites its own synthesis. Never modify source evaluator reports to fit it.

## Component Revalidation

Revalidate after a meaningful model/harness change or observed workflow regression, not merely on a calendar.

For each component:

- [ ] Is its sole-writer boundary still distinct and useful?
- [ ] Does removing it measurably reduce acceptance quality or recoverability?
- [ ] Is another stage duplicating its decision?
- [ ] Are inputs and outputs still aligned with `workflow-hooks contract`?
- [ ] Can the same result be achieved with fewer roles or artifacts?
- [ ] Do representative success, failure, stale-state, and resume cases still behave correctly?

For evaluators:

- [ ] Does a fresh context reproduce the intended verdict?
- [ ] Are severity thresholds applied consistently?
- [ ] Are previous findings explicitly rechecked without score inflation?
- [ ] Are QA and design concerns still separate?
- [ ] Does synthesis cite every criterion and source report?

For completion:

- [ ] Does no-evaluator implementation archive only after fresh full verification?
- [ ] Does evaluator-bearing implementation return `AWAITING_EVALUATION`?
- [ ] Does only a synthesized PASS re-enter finalization?
- [ ] Does archive preserve every source and clean only feature-owned transients?

## Change Discipline

- Simplify before adding another stage, wrapper, or artifact.
- Update `agents/workflow-contract.json` and Rust validation together when machine-readable behavior changes.
- Never tune by editing plugin cache or active runtime reports.
- Validate every changed skill and run the black-box hook suite for contract/archive changes.
- Preserve old durable docs; mark obsolete architecture documents superseded rather than rewriting historical decisions.
