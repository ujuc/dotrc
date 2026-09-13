# Eval Guide for Skills

> How to define binary evaluation criteria for skills.

---

## Why Binary Evals

Scales (1-7, 1-10) compound variability and give unreliable results across runs.
Binary outcomes apply to checks actually evaluated with adequate evidence.
Missing required evidence is UNVERIFIED; inapplicable checks are SKIP. Neither
is a passing result. Report [evidence levels](quality-criteria.md#evidence-and-completion) separately.

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

## Waza suites

A suite under `claude/evals/<skill>/` feeds the `skill-improver` regression
guard, so it must be able to fail when the skill degrades. Placeholder scaffolds
cannot: their `contains` graders check words that already appear in the prompt.

- **Executor.** `executor: copilot-sdk` injects SKILL.md into the session;
  `executor: mock` echoes the prompt and never reads the skill, so mock suites
  are reference-only and score 1.0 whatever the skill says.
- **Graders that carry signal.** Grade what the skill changes in the output:
  a `text` `regex_match` on the required shape (a `-다` subject, a report
  heading, a status line), a `program`/`file` grader on a produced artifact, or
  a `prompt` grader whose judge (`config.judge_model` in eval.yaml; the launcher
  exposes no judge flag) is not the eval model. Keep the `behavior` token budget
  as a side check, not the only one.
- **Negative task.** Keep at least one prompt where the skill must not change
  the answer, graded with `text` `not_contains` or a `skill_invocation` grader
  that lists the skill under `forbidden_skills`.
- **Trials and IDs.** Set `trials_per_task: 3` (or run with `--trials 3`) and
  freeze task IDs before the baseline run; the launcher marks a later run
  `⚠️ incomparable` when engine, model, trials, or the task set differ, and
  skips the run entirely when eval.yaml already shows the mismatch.
- **Trigger precision.** `inject_skill_body: false` with a `skill_invocation`
  grader measures whether the agent calls the `skill` tool. Validate the
  channel first: in a 2026-09-13 probe the local `gemma4:26b-mlx` never invoked
  `commit` on a direct commit request (0 invocations, 272k tokens), so a 0 there
  reflects the eval model, not the skill. Trust a positive-trigger grader only
  after a control task shows the model invoking some skill under the same
  executor and model.
- **Budget.** One 3-trial copilot-sdk run measured 13–20 minutes on the local
  model; keep suites to 3–6 tasks.

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
