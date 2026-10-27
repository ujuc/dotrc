---
name: autoresearch
description: "편집 가능한 대상(프롬프트, 설정, 코드 등)을 실행 → 채점 → 변이 → 유지/폐기 루프로 자율 최적화한다."
when_to_use: "사용자가 `/autoresearch` 또는 autoresearch 실행을 명시적으로 요청했을 때만 사용한다. 자동 실험과 eval 루프 요청만으로는 실행하지 않는다."
group: meta
disable-model-invocation: true
argument-hint: "[target-path]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Autoresearch

Hill-climb any editable target (skill, prompt, config, code, query) against binary evals: run, score, make one mutation, keep or discard, repeat. Output: the improved target in place, plus `results.tsv` and `changelog.md` in the run directory.

## Model guidance

Use Advanced to design evals and interpret mutations; Standard suits a bounded loop with settled criteria. Recommend Frontier for coupled failure modes Advanced analysis leaves unexplained. For other model choices, apply the [shared selection guide](../generate-skills/references/model-selection.md).

## Before Starting: Gather Context

**STOP. Run no experiment until the user confirms every field below via AskUserQuestion** (or one plain-text message when it is unavailable, then wait). Prefill field 1 from `$ARGUMENTS` when non-empty.

| # | Field | Example values | Default |
|---|-------|---------------|---------|
| 1 | **Target file** (`{target}`) | `~/.claude/skills/foo/SKILL.md`, `config.yaml`, `prompts/extract.md` | from `$ARGUMENTS` |
| 2 | **Execution method** (`{exec}`) | see patterns below | none |
| 3 | **Test inputs** (`{inputs}`) | 3–5 scenarios | none |
| 4 | **Eval criteria** (`{evals}`) | 3–6 binary checks (Step 2) | none |
| 5 | **Runs per experiment** (`{runs}`) | integer | `5` |
| 6 | **Budget cap** (`{budget}`) | integer | `20` |

- `runs`: `1` for deterministic targets (static text rubric, fixed-output scripts); `3–5` for variable LLM output; `8+` only when noise swamps small deltas. Cost scales linearly with `runs × budget`.
- `budget` (total experiments): `5–10` for exploratory runs or small, near-ceiling targets; `20` typical; `30+` only for large targets with many independent failure modes (returns fall off past ~25).

Execution patterns; each must yield one scorable string:

```
# Skill invocation (target is a SKILL.md)
Skill("{skill-name}") with prompt {input} → capture transcript

# Shell command (target is a script/config)
bash -c "{cmd-using-target} < {input-file}" → capture stdout

# CLI (target is a prompt template)
echo "{input}" | claude -p --model <model-id> --effort <level> "$(cat {target})" → capture stdout
```

**Self-target:** never let `{target}` appear inside its own `{exec}`. When the target is autoresearch's own `SKILL.md`, `Skill("autoresearch")` recurses without end; use a static text rubric with new evals (`runs=1`), a synthetic transcript (`claude -p` with the SKILL.md as the prompt and sample user requests as input, scoring the plan), or a wet run of autoresearch on a small unrelated dummy target, scored against [evals.md](evals.md).

If the target already has a `## Eval Criteria` section or sibling `evals.md`, present them to the user and ask whether to reuse, modify, or replace.

## Step 1: Read the Target

Read the target in full and every file it references or depends on. Note its purpose, expected output, and any existing checks or anti-patterns before changing anything.

## Step 2: Build the Eval Suite

Write 3–6 evals, each a yes/no question about the output (no scales, no "partially"):

```
EVAL [n]: [Short name]
Question: [Yes/no question about the output]
Pass condition: [what "yes" looks like]
Fail condition: [what triggers "no"]
```

- **Consistent:** two independent reviewers reach the same answer ("Does every referenced path exist on disk?", not "Is it accurate?").
- **Outcome, not process or surface:** "Does the output reflect the config's settings?", not "Did it read the config?"; no gameable proxies like "fewer than 200 words".
- **Distinct:** drop an eval that always passes when another does.
- Fewer than 3 misses quality dimensions; more than 6 and the target starts parroting the criteria.
- Settle the set before the loop; changing it mid-run forces a re-baseline (Step 4-5).

Scoring: `max_score = evals × runs`, `pass_rate = passes / max_score`. Compare pass rates, not raw scores.

## Step 3: Establish Baseline

Run the target as-is first; this is experiment 0.

1. Create `${XDG_STATE_HOME:-$HOME/.local/state}/agents/autoresearch/{target-name}/{YYYY-MM-DD-NNN}/` (`{target-name}` = `basename({target})` minus extension; NNN = the day's sequence). Run artifacts live here, not in the target's repository.
2. Create `results.tsv` there with the header row.
3. Copy the original to `{run-dir}/{filename}.baseline`. The improved target overwrites the original in place; this copy is the only backup.
4. Run the target `{runs}` times with `{inputs}` and `{exec}`. Pin model and effort through the method's own options (`claude -p --model <model-id> --effort <level>` with a full ID such as `claude-opus-5-5`, not an alias). `Skill(...)` uses the target's `model`/`effort` frontmatter when set, else the session's.
5. Score every output against every eval.
6. Log experiment 0 with the resolved model ID and effort in its description (`unknown` when the host does not expose one; treat `unknown` as unchanged unless the host reports a change).

`results.tsv` (tab-separated):

```
experiment	score	max_score	pass_rate	status	stop_reason	description
0	14	20	70.0%	baseline	-	original target — no changes; model <id>, effort <level>
```

Report the baseline. At 90%+, ask the user (AskUserQuestion, or plain text) whether optimizing is still worth it.

## Step 4: Run the Experiment Loop

Once started, run autonomously until a stop condition.

### 4-1. Analyze Failures

Find the evals that fail most, read the actual outputs, and name the pattern:

| Pattern | How to detect | Fix direction |
|---------|---------------|---------------|
| **Format drift** | Output structure varies across runs | Add a format example; name required headers/keys |
| **Missing instruction** | An eval fails because the target never covers that case | Add one sentence for the gap |
| **Ambiguous instruction** | Meaning varies across runs on the same input | Reword; add a disambiguating example |
| **Buried instruction** | A critical rule sits late and is ignored | Move it to the top of its section |
| **Over-optimization** | One eval improves while another regresses | Soften the dominant instruction; add a counter-example |
| **Eval misalignment** | All pass on clearly bad output, or all fail on reasonable output | Fix the evals (Step 2), not the target |
| **Overfitting** | Better on test inputs, worse on novel ones | Add input variety (Gather Context) |

A failure that fits none: log `novel` in the row, propose a fix anyway, and flag the eval criteria for review.

### 4-2. Form a Hypothesis

Pick ONE change with a clear hypothesis. Position is priority, and removing a rule the target model already follows (e.g. carry-over from an earlier model) is a valid mutation. Never rewrite the whole file, bundle changes, or change the target's `model`/`effort` frontmatter (that changes the comparison, not the target).

Stay sequential: each mutation is judged against the last KEEP. Parallel candidates are beam search, a different algorithm; do not run them here.

### 4-3. Make the Change

Edit the target with that one mutation.

### 4-4. Run and Score

Run `{runs}` times with the same `{inputs}` and pinned `{exec}`, noting the model and effort used. Score against `{evals}`.

### 4-5. Keep or Discard

Compare against the **current baseline** (the latest KEEP or `baseline` row; experiment 0 initially) only when this experiment ran on the model and effort of the latest `baseline` row. If either changed, revert the mutation, log the experiment as `discard` noting the change, re-run the reverted target `{runs}` times, and log that as a new `baseline` row with the new model and effort; it becomes the current baseline. Do the same after any change to `{evals}`: scores from different eval sets are not comparable. That row takes the next experiment number, gets a `baseline` changelog entry, and counts toward neither `{budget}` nor the 95% streak. Otherwise:

- **Score improved** → KEEP. The mutation is now the new baseline.
- **Score unchanged** → KEEP only when every eval outcome is unchanged and the target is smaller; otherwise DISCARD.
- **Score worse** → DISCARD.

On DISCARD, revert the file fully; partial reverts accumulate drift.

### 4-6. Log and Report

Append a row to `results.tsv` and report:

```
[Experiment N] score/max (pass_rate%) — KEEP/DISCARD — one-line description
```

### 4-7. Repeat

Return to 4-1 until any of:

- the user stops the loop → `user_stop`;
- `{budget}` experiments reached → `budget_exhausted`;
- 95%+ pass rate for 3 consecutive experiments → `ceiling_3x`.

Set the final row's `stop_reason` to exactly that value; leave it `-` on other rows.

**Out of ideas, or the target has grown:** re-read failing outputs and try a removal or consolidation, still one change at a time.

## Step 5: Write the Changelog

After each experiment, append to `changelog.md`:

```markdown
## Experiment [N] — [keep/discard]

**Score:** [X]/[max] ([percent]%)
**Change:** [One sentence describing what was changed]
**Reasoning:** [Why this change was expected to help]
**Result:** [Which evals improved/declined]
**Remaining failures:** [What still fails, if anything]
```

## Step 6: Deliver Results

When the loop stops, report:

1. **Score summary:** latest `baseline` row → final (percent improvement); list earlier baselines with their model and effort, without a cross-model delta
2. **Total experiments**
3. **Keep rate:** kept vs discarded
4. **Top 3 changes** that helped most
5. **Remaining failure patterns**
6. **File locations** of `results.tsv` and `changelog.md`

## Look up the rest

- Eval ideas per target type, or a recorded static-rubric run to check KEEP/DISCARD calls against → [references/eval-guide.md](references/eval-guide.md)
