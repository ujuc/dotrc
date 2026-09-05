# Eval Guide for Skills

> How to define binary evaluation criteria for skills.

---

## Why Binary Evals

Scales (1-7, 1-10) compound variability and give unreliable results across runs.
Binary outcomes apply to checks actually evaluated with adequate evidence.
Missing required evidence is UNVERIFIED; inapplicable checks are SKIP. Neither
is a passing result. Report evidence levels from quality-criteria.md separately.

---

## Writing Good Evals

### Format

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like — be specific]
Fail condition: [What triggers a "no"]
```

### Rules

1. **Binary outcomes, explicit evidence status.** Use PASS/FAIL when evaluable;
   otherwise SKIP/UNVERIFIED with the reason. A missing run cannot be guessed.
2. **Specific enough to be consistent.** Two reviewers should reach the same answer independently.
3. **Not so narrow the skill games it.** "Contains fewer than 200 words" makes the skill optimize for brevity at the expense of everything else.
4. **3-6 evals is the sweet spot.** Fewer misses coverage. More causes the skill to parrot eval criteria instead of improving.

### Good vs Bad Examples

| Bad (vague/scaled) | Good (binary/specific) |
|---|---|
| Is the output readable? | Are all words spelled correctly with no truncated sentences? |
| Rate code quality 1-5 | Does the code pass the project's lint rules without warnings? |
| Is the tone professional? | Does the output avoid first-person pronouns and slang? |
| How accurate is it? | Does every file path referenced in the output exist on disk? |

---

## Baseline and evidence integrity

Preserve exact prompts, fixture bytes, injected events and expected actions.
Compare the unchanged skill and candidate using the same inputs and execution
channel. Do not infer failure merely because a lower-priority sentence conflicts
with a user instruction that already produces the correct outcome.

Mock echo/keyword checks validate plumbing only. Artifact claims require actual
files, before/after comparisons and write-order evidence; live-tool claims require
actual tool results. A textual replay proves interpretation only. Do not compare
raw scores across different suites, executors or input sets.

Give evidence verifiers the facts, decisions, original files/diffs and scope they
must judge. Keep blind reviewers limited to observable properties; missing context
is not grounds for deleting a team rule. Rerun affected checks after final fixes.

## Placement

When defining evals for a new skill, record them in one of:

- **SKILL.md bottom section** — under an `## Eval Criteria` heading
- **Separate `evals.md`** — in the skill's root directory

Either location works. The autoresearch skill checks both when starting optimization.

---

## Common Pitfalls

1. **Eval measures effort, not output.** "Did the skill read the file?" is process. "Does the output contain data from the file?" is outcome.
2. **Evals overlap.** If eval 3 always passes when eval 2 passes, one of them is redundant.
3. **Evals test the wrong thing.** If all evals pass but the output is bad, the evals are wrong — not the skill.
4. **Too many evals.** Beyond 6, the skill starts optimizing for the eval surface rather than the actual job.
