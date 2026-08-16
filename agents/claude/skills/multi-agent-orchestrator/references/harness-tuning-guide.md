# Harness Tuning Guide

## Evaluator Tuning Loop

The Evaluator is the most critical component to tune. Its judgment directly determines whether the Generator's output ships or iterates. A miscalibrated Evaluator wastes cycles (too strict) or ships defects (too lenient).

### Tuning Process

1. **Read Evaluator logs.** After an evaluation round, review `.harness/evaluation-report.md` in detail.
2. **Find disagreement points.** Identify where your judgment differs from the Evaluator's judgment. Did it approve something you would reject? Did it flag something you consider acceptable?
3. **Modify the prompt.** Update the Evaluator skill's instructions to resolve that specific disagreement. Be precise — vague instructions create new failure modes.
4. **Repeat.** Run the Evaluator again on the same input. Check if the disagreement is resolved without introducing new ones.

This is an iterative loop. Expect several rounds of tuning before the Evaluator matches your quality bar. Document each change and its rationale.

### Tuning Tips

- **Start strict, then relax.** It is easier to reduce strictness than to increase it. An overly strict Evaluator wastes time but does not ship defects.
- **Use concrete examples.** Instead of "be more thorough," provide specific scenarios: "when testing form validation, always check empty input, maximum length, and special characters."
- **Separate concerns.** Tune QA evaluation and design evaluation independently. They have different failure modes.
- **Version your prompts.** Keep a changelog of Evaluator prompt modifications so you can revert if a change makes things worse.

## Common Evaluator Failure Modes

### 1. Lenient Approval ("Not a Big Deal")

**Symptom:** The Evaluator identifies a genuine problem but then approves the build anyway, saying "this is minor" or "not a blocker."

**Root cause:** The Evaluator's prompt does not clearly distinguish severity levels, or it defaults to PASS when uncertain.

**Fix:** Add explicit severity thresholds to the prompt:
- Any critical or major issue → automatic FAIL.
- 3+ minor issues → FAIL.
- Cosmetic issues only → PASS with notes.

### 2. Surface-Level Testing

**Symptom:** The Evaluator only tests the happy path. No edge cases, no error states, no boundary conditions.

**Root cause:** The Evaluator was not instructed to explore beyond obvious functionality.

**Fix:** Add explicit edge case requirements:
- "For every form, test: empty submission, maximum length input, special characters, duplicate submission."
- "For every list, test: empty state, single item, many items, pagination boundaries."
- "For every action, test: success, failure, network error, timeout."

### 3. Inconsistent Follow-up Evaluation

**Symptom:** The Evaluator flags an issue in Round 1, the Generator fixes it, but in Round 2 the Evaluator does not verify the fix or raises a different concern about the same area.

**Root cause:** The Evaluator does not systematically re-check previous feedback items.

**Fix:** Add to the Evaluator prompt:
- "Before evaluating new areas, first verify that ALL issues from the previous round are resolved."
- "Reference the previous evaluation-report.md explicitly. For each previous issue, state: RESOLVED, PARTIALLY RESOLVED, or NOT ADDRESSED."

### 4. Score Inflation Over Rounds

**Symptom:** Scores trend upward across evaluation rounds even when quality improvements are marginal. By Round 3, everything passes regardless.

**Root cause:** Context accumulation makes the Evaluator sympathetic to the Generator's effort. Also known as "evaluator fatigue."

**Fix:**
- Reset the Evaluator's context between rounds (invoke a fresh Agent subagent each time).
- Include in the prompt: "Your score must reflect the current state of the application against the contract, not the delta from the previous round."
- Compare Round N scores against Round 1 criteria, not Round N-1 scores.

### 5. Evaluation Without Interaction

**Symptom:** The Evaluator reads the source code or takes a screenshot but does not actually interact with the running application.

**Root cause:** Chrome integration is not active or the Evaluator fell back to static analysis.

**Fix:** This is a hard prerequisite. If Chrome is not available, the evaluation must not proceed. Add explicit checks:
- "Before starting evaluation, verify you can navigate to the application URL."
- "Every criterion must be verified through browser interaction, not source code reading."

## Harness Component Re-validation Checklist

Use this checklist when a new model version is released or on a regular cadence (e.g., quarterly).

### Per-Component Assessment

For each component in the harness (Planner, Contract, QA Evaluator, Design Evaluator):

- [ ] **Is this component still addressing a real model limitation?**
  - Test: Run a representative task WITHOUT this component. Does quality suffer?
  - If quality is equivalent → component is overhead. Remove it.

- [ ] **Has any component become redundant due to model improvements?**
  - Test: Compare the component's output to what the model produces natively.
  - If the model now handles this natively → component is redundant. Remove it.

- [ ] **Are there new model capabilities that could be leveraged?**
  - Review the model's release notes for new features.
  - Consider: better tool use, longer context, improved reasoning, new modalities.
  - Add new components or modify existing ones to leverage improvements.

- [ ] **Is the overhead of each component justified by its contribution?**
  - Measure: cost and time added by this component.
  - Measure: quality improvement attributable to this component.
  - If cost/time exceeds quality benefit → simplify or remove.

### Pipeline-Level Assessment

- [ ] **Is the pipeline still the right structure?**
  - Could a simpler 2-agent setup (Generator + Evaluator) replace the full pipeline?
  - Could a single agent with self-evaluation replace the pipeline entirely?

- [ ] **Are the inter-agent boundaries in the right places?**
  - Does the Planner/Generator boundary still make sense?
  - Does the Generator/Evaluator separation still add value?

- [ ] **Is the file-based communication protocol still appropriate?**
  - Would a simpler protocol work?
  - Is the overhead of structured files justified?

### Documentation After Re-validation

After completing the checklist:

1. Update the architecture decision in [architecture.md](architecture.md).
2. Record what changed and why.
3. Update cost/time benchmarks if the pipeline configuration changed.
4. Communicate changes to users who depend on the harness.
