# Eval Guide — Designing Binary Evaluation Criteria

> Detailed guide for writing effective evals for skill optimization.

---

## Core Principle

Every eval must be a binary yes/no question. Scales (1-7, 1-10) compound variability across runs and give unreliable signals for autonomous optimization loops.

---

## Eval Format

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like — be specific]
Fail condition: [What triggers a "no"]
```

---

## Rules for Good Evals

### 1. Binary Only

No scales, no "mostly," no "partially." The answer is yes or no.

### 2. Specific Enough to Be Consistent

Two independent reviewers should reach the same answer. If they might disagree, the eval is too vague.

| Vague | Specific |
|---|---|
| Is the output readable? | Are all words spelled correctly with no truncated sentences? |
| Is the code clean? | Does the code pass the project's lint rules without warnings? |
| Is the tone professional? | Does the output avoid first-person pronouns and slang? |
| Is it accurate? | Does every file path referenced in the output exist on disk? |

### 3. Not So Narrow the Skill Games It

"Contains fewer than 200 words" makes the skill optimize for brevity at the expense of everything else. Good evals measure outcome quality, not surface features.

### 4. Sweet Spot: 3-6 Evals

- **Fewer than 3**: Misses important quality dimensions.
- **More than 6**: The skill starts parroting eval criteria instead of actually improving.

---

## Common Pitfalls

### Measuring Process Instead of Output

- Bad: "Did the skill read the config file?"
- Good: "Does the output reflect the settings defined in the config file?"

### Overlapping Evals

If eval 3 always passes when eval 2 passes, one is redundant. Each eval should independently capture a distinct quality dimension.

### Testing the Wrong Thing

If all evals pass but the output is clearly bad, the evals are wrong — not the skill. Rewrite the evals before continuing the optimization loop.

### Eval Creep

Resist the urge to add evals mid-run. Adding evals changes the scoring baseline and invalidates comparison with earlier experiments. If you must add one, re-run the baseline.

---

## Designing Evals by Skill Type

### Code Generation Skills

- Does the generated code compile/parse without errors?
- Does it follow the project's naming conventions?
- Does it handle the specified edge case correctly?

### Content/Writing Skills

- Does the output stay within the specified word count range?
- Does it address all required sections from the brief?
- Is every claim backed by a specific reference or example?

### Workflow/Process Skills

- Did the skill produce all expected output files?
- Does each output file match the specified format?
- Did the skill complete without requiring user intervention?

### Review/Analysis Skills

- Does the output identify at least one real issue (verified manually)?
- Are all referenced line numbers accurate?
- Does the output avoid false positives on known-clean code?

---

## Scoring

```
max_score = [number of evals] × [runs per experiment]
pass_rate = (total_passes / max_score) × 100%
```

Example: 4 evals × 5 runs = max score of 20.
If 17 individual checks pass: 17/20 = 85% pass rate.

Track pass rate, not raw score. Pass rate normalizes across different eval counts and run counts.
