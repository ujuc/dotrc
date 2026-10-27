# Eval guide for skills

## Binary criteria

Write 3–6 yes/no checks, under `## Eval Criteria` at the bottom of `SKILL.md` or
in a root `evals.md` (autoresearch reads both). Fewer misses coverage; more makes
the skill optimize for the eval surface.

```
EVAL [number]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [What "yes" looks like — be specific]
Fail condition: [What triggers a "no"]
```

- Two reviewers must reach the same answer alone ("Does every file path in the
  output exist on disk?", not "How accurate is it?").
- Grade the output, not the effort ("contains data from the file", not "read the file").
- Not so narrow the skill can game it: "fewer than 200 words" buys brevity at any cost.
- If one check always passes with another, drop one. If every check passes on a
  bad output, the checks are wrong.
- Report each result with the statuses in [evidence levels](../SKILL.md#evidence-levels).

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
  grader measures whether the agent calls the `skill` tool. Trust a
  positive-trigger grader only after a control task shows the same executor and
  model invoking some skill: a local model may never invoke one, so a 0 there
  reflects the eval model, not the skill.
- **Budget.** A 3-trial copilot-sdk run takes 13–20 minutes on the local model;
  keep suites to 3–6 tasks. A diet eval follows
  [skill-diet's eval](../../skill-diet/references/eval.md) instead.

### Running baseline and candidate

The [`waza` skill](../../waza/SKILL.md) owns scaffolding, commands, existing-suite
preservation and result paths. Its launcher refuses baselines it cannot compare:

1. Scaffold, then refine the placeholder tasks against real triggers and outputs
   **before** the baseline. Changing task IDs, the executor or
   `trials_per_task` afterwards makes the candidate `⚠️ incomparable`; rerun the
   baseline on the unchanged skill instead of comparing across suites.
2. Run baseline and candidate with the same `--trials 3` and distinct labels,
   passing the baseline JSON to the candidate run with `--baseline-json`.
3. Read the verdict, not the raw delta: `⚠️ **regression**` (rounded weighted Δ
   below −0.1 by default) blocks the candidate until inspected; a smaller drop is
   run-to-run noise; a `reference-only` mock result and an `⚠️ incomparable`
   report are not behavior evidence.

A new skill uses the no-guidance transcript as its baseline, since no runnable skill exists yet.
