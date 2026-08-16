---
name: autoresearch
description: "편집 가능한 대상(프롬프트, 설정, 코드 등)을 반복 실행-평가-변이하여 자율적으로 최적화한다. Karpathy의 autoresearch 방법론(execute → score → mutate → keep/discard) 기반."
when_to_use: "자동 실험, eval 루프, autoresearch 트리거 시. `/autoresearch` 명시 호출로 실행하며, description 매칭 시 자동 호출도 가능하다."
group: meta
model: opus
argument-hint: "[target-path]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Autoresearch

Adapts Andrej Karpathy's autoresearch methodology (autonomous experimentation loops) to any editable artifact — skills, prompts, configurations, code, queries, or any file where output quality can be measured.

---

## The Core Job

Take any editable target, define what "good output" looks like as binary yes/no checks, then run an autonomous loop that:

1. Runs the target using test inputs and the specified execution method
2. Scores every output against the eval criteria
3. Mutates the target file to fix failures
4. Keeps mutations that improve the score, discards the rest
5. Repeats until the score ceiling is hit or the budget is exhausted

**Output:** An improved target file + `results.tsv` log + `changelog.md` of every mutation attempted.

---

## Before Starting: Gather Context

**STOP. Do not run any experiments until all fields below are confirmed with the user via AskUserQuestion.**

If `$ARGUMENTS` (the `[target-path]` from `argument-hint`) is non-empty, prefill field 1 with it and confirm. If empty, ask the user.

| # | Field | Example values | Default |
|---|-------|---------------|---------|
| 1 | **Target file** (`{target}`) | `~/.claude/skills/foo/SKILL.md`, `config.yaml`, `prompts/extract.md`, `queries/top.sql` | from `$ARGUMENTS` |
| 2 | **Execution method** (`{exec}`) | see exec patterns below | none |
| 3 | **Test inputs** (`{inputs}`) | 3–5 scenarios as a list | none |
| 4 | **Eval criteria** (`{evals}`) | 3–6 binary checks ([references/eval-guide.md](references/eval-guide.md)) | none |
| 5 | **Runs per experiment** (`{runs}`) | integer | `5` |
| 6 | **Budget cap** (`{budget}`) | integer | `20` |

**Choosing `runs` and `budget`:**

- `runs` controls how many times each experiment is executed to reduce noise. Use **`1`** for deterministic targets (static text rubric, scripts with fixed output). Use **`3–5`** when the exec produces variable LLM output (prompts, skill invocations). Use **`8+`** only when noise dominates and you need tight confidence on small score deltas — costs scale linearly.
- `budget` caps total experiments. Use **`5–10`** for exploratory short runs or when the target is small and likely near its ceiling already. Use the default **`20`** for typical optimization. Use **`30+`** only for large targets with many independent failure modes; expect diminishing returns past 25 in practice.

### Execution method patterns

Pick the pattern that fits the target. Each must produce a single string output that can be scored.

```
# Skill invocation (when target is a SKILL.md)
Skill("{skill-name}") with prompt {input} → capture transcript

# Shell command (when target is a script/config)
bash -c "{cmd-using-target} < {input-file}" → capture stdout

# API/CLI tool (when target is a prompt template)
echo "{input}" | claude -p "$(cat {target})" → capture stdout
```

If the target already has a `## Eval Criteria` section or sibling `evals.md`, present them to the user and ask whether to reuse, modify, or replace.

---

## Step 1: Read the Target

Before changing anything, read and understand the target completely.

1. Read the target file in full
2. Read any related files it references or depends on
3. Identify the target's core purpose, structure, and expected output
4. Note any existing quality checks or anti-patterns

Do NOT skip this. You need to understand what the target does before you can improve it.

---

## Step 2: Build the Eval Suite

Convert the user's eval criteria into structured tests. Write 3-6 binary pass/fail evals.

See [references/eval-guide.md](references/eval-guide.md) for the eval format, rules for good evals, scoring formula, and type-specific examples.

---

## Step 3: Establish Baseline

Run the target AS-IS before changing anything. This is experiment #0.

1. Create working directory: `autoresearch-{target-name}/` next to the target file (where `{target-name}` is `basename({target})` minus extension).
2. Create `results.tsv` inside the working directory with the header row.
3. Copy the original file to `autoresearch-{target-name}/{filename}.baseline` (NOT next to the original — keeps cleanup atomic).
4. Run the target `{runs}` times (the value confirmed in context-gathering, default `5`) using `{inputs}` and `{exec}`.
5. Score every output against every eval in `{evals}`.
6. Record the baseline score as experiment 0.

**results.tsv format (tab-separated):**

```
experiment	score	max_score	pass_rate	status	stop_reason	description
0	14	20	70.0%	baseline	-	original target — no changes
```

**After baseline:** Report the baseline summary to the user. If baseline is 90%+, confirm with the user via AskUserQuestion whether optimization is worthwhile (diminishing returns near the ceiling).

---

## Step 4: Run the Experiment Loop

This is the core autoresearch loop. Once started, run autonomously until stopped.

**LOOP:**

### 4-1. Analyze Failures

Look at which evals fail most. Read the actual outputs. Classify the failure into one of these named patterns:

| Pattern | How to detect | Typical fix direction |
|---------|---------------|------------------------|
| **Format drift** | Output structure differs across runs (JSON/Markdown/list shape varies) | Add explicit format example; specify required headers/keys |
| **Missing instruction** | A specific eval fails because the target never tells the model what to do for that case | Add a single-sentence rule addressing the gap |
| **Ambiguous instruction** | Output varies semantically across runs on the same input | Reword the instruction; add disambiguating example |
| **Buried instruction** | Critical rule appears late in the file and is ignored | Move it to the top of the relevant section |
| **Over-optimization** | One eval improves while another regresses | Soften the dominant instruction; add counter-example |
| **Eval misalignment** | All evals pass but output is clearly bad, OR all fail despite reasonable output | Fix evals (Step 2), not target |

If the failure does not fit any pattern, log "novel" in the experiment row and propose a fix anyway — but flag it for Eval Criteria review.

### 4-2. Form a Hypothesis

Pick ONE thing to change. Never change multiple things at once.

**Good mutations (prompts/skills):**
- Add a specific instruction addressing the most common failure
- Reword an ambiguous instruction to be more explicit
- Add an anti-pattern ("Do NOT do X") for a recurring mistake
- Move a buried instruction higher (priority = position)
- Add or improve an example showing correct behavior
- Remove an instruction causing over-optimization for one thing

**Good mutations (code/config):**
- Adjust a parameter or threshold value
- Change algorithm or logic flow
- Reorganize structure or ordering
- Toggle an option on/off
- Simplify a complex section

**Bad mutations:**
- Rewriting the entire file
- Changing multiple things at once
- Making vague changes without a clear hypothesis

### 4-3. Make the Change

Edit the target file with ONE targeted mutation.

### 4-4. Run and Score

Run the target `{runs}` times with the same `{inputs}`. Score every output against `{evals}`.

### 4-5. Keep or Discard

Compare against the **current baseline** (the last KEEP, or experiment 0 initially):

- **Score improved** → KEEP. The mutation is now the new baseline.
- **Score unchanged** → KEEP only when every eval outcome is unchanged and the target is smaller; otherwise DISCARD.
- **Score worse** → DISCARD.

On DISCARD, revert the file fully. This makes score-neutral simplification the only tie that can win.

### 4-6. Log and Report

Append a row to `results.tsv`. Report progress to the user:

```
[Experiment N] score/max (pass_rate%) — KEEP/DISCARD — one-line description
```

### 4-7. Repeat

Go back to 4-1. Continue until any of:
- User manually stops the loop.
- `{budget}` experiment cap reached.
- 95%+ pass rate for 3 consecutive experiments (diminishing returns).

When stopping, set the final row's `stop_reason` to exactly `user_stop`, `budget_exhausted`, or `ceiling_3x`; leave it `-` on other rows.

**If out of ideas:** Re-read failing outputs. Try removal instead of addition; do not bundle multiple mutations.

---

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

---

## Step 6: Deliver Results

When the loop stops, report to the user:

1. **Score summary:** Baseline → Final (percent improvement)
2. **Total experiments:** How many mutations tried
3. **Keep rate:** Kept vs discarded
4. **Top 3 changes** that helped most
5. **Remaining failure patterns**
6. **File locations** of `results.tsv` and `changelog.md`

---

## Output Structure

All artifacts live inside the working directory next to the target. Cleanup is one `rm -rf` of the working dir; the original target stays in place (improved version overwrites it).

```
autoresearch-{target-name}/
├── results.tsv          # score log for every experiment
├── changelog.md         # detailed mutation log
└── {filename}.baseline  # copy of the original target before optimization
```

The improved target file is saved back to its original location — only the unchanged baseline copy lives inside the working directory.

---

## Worked Example

A real meta-optimization run on this very SKILL.md (recorded session, not synthetic):

- **`{target}`**: `claude/skills/autoresearch/SKILL.md` (this file)
- **`{exec}`**: text-based static rubric — operator scores the SKILL.md content directly against custom evals (the Option A path from Gotcha 9)
- **`{inputs}`**: the SKILL.md content itself (single artifact)
- **`{evals}`** (5 binary checks, distinct from the runtime `Eval Criteria` below):
  - T1 — anti-recursion safeguard present
  - T2 — runs/budget tradeoff guidance present
  - T3 — worked example present
  - T4 — all 6 procedural steps in order
  - T5 — Step 4-1 names ≥3 failure patterns with detection method
- **`{runs}`**: 1 (deterministic — static text yields the same score each evaluation)
- **`{budget}`**: 8

| Exp | Score | Δ | Mutation | Decision |
|-----|-------|---|----------|----------|
| 0 | 1/5 (20%) | — | baseline | — |
| 1 | 2/5 (40%) | +20% | add Gotcha 9 (anti-recursion) | KEEP |
| 2 | 3/5 (60%) | +20% | replace Step 4-1 prose with named failure pattern table | KEEP |
| 3 | 4/5 (80%) | +20% | add runs/budget tradeoff guidance below context table | KEEP |
| 4 | 5/5 (100%) | +20% | add this Worked Example section | KEEP |
| 5 | 5/5 (100%) | 0% | shorten "to average out stochastic variance" to "to reduce noise" | KEEP (score-neutral size reduction) |
| 6 | 5/5 (100%) | 0% | remove a duplicated baseline reminder | KEEP (score-neutral size reduction) |

Stopped at experiment 6 after three consecutive 100% experiments; the final results row records `stop_reason=ceiling_3x`.

---

## Gotchas

1. **Never skip the baseline.** Without it, you cannot measure improvement.
2. **One change at a time.** Multi-variable changes make it impossible to attribute improvement.
3. **Revert fully on discard.** Partial reverts accumulate drift.
4. **Evals can be wrong.** If all evals pass but output quality is bad, fix the evals first — go back to Step 2.
5. **Overfitting to test inputs.** If the target improves on test inputs but degrades on novel inputs, the test inputs lack variety — go back to context gathering.
6. **Size creep.** Each kept mutation adds complexity. Periodically check if the target has grown significantly and consolidate if needed.
7. **Sequential by construction.** This skill implements hill-climbing — each mutation is evaluated against the last KEEP. Do not parallelize candidate mutations; that is beam search and changes the algorithm. If the user wants beam search, treat it as a different skill.
8. **Triggers come from `description` + `/autoresearch`.** This skill has no `disable-model-invocation` flag, so Claude may auto-trigger it from `description` matches, and it can also be run explicitly via `/autoresearch`. There is no separate per-skill "CLAUDE.md Skills table" — skill classification is driven by the `group:` frontmatter field, mirrored in the sibling [`../README.md`](../README.md) catalog table. To adjust triggers, edit this skill's `description` / `when_to_use`.

9. **Meta-recursion: target == this skill itself.** When the target file is autoresearch's own `SKILL.md`, the execution method must NOT be `Skill("autoresearch")` — that would invoke this skill within itself and either deadlock or create unbounded recursion. Pick one instead:
   - **Text-based static rubric** — score the SKILL.md content against new evals (clarity, structure, coverage). `runs=1` is sufficient; static text yields deterministic scores.
   - **Synthetic transcript via `claude -p`** — pipe `claude -p "$(cat {target})"` with sample user prompts, score the planning quality of the output.
   - **Wet execution on a separate dummy target** — run autoresearch on a small unrelated file (e.g., a short prompt or config) and score the resulting `results.tsv` / `changelog.md` against the runtime evals.

   Never let the target path appear inside its own `{exec}` definition.

---

## Eval Criteria

Self-referential checks. The autoresearch skill itself can be optimized using these.

```
EVAL 1: Baseline established
  Question: Does results.tsv contain a row with experiment=0 and
            status=baseline before any mutation runs?
  Pass: Row exists with the unmutated target's score.
  Fail: Mutation occurred before experiment 0 was logged.

EVAL 2: One-change discipline
  Question: For every kept experiment N (N>0), does the diff between
            target@N and target@N-1 represent a single coherent change
            (one section edited, one parameter adjusted, one
            instruction added/removed)?
  Pass: Every kept diff is one logical change.
  Fail: Any kept diff bundles multiple unrelated changes.

EVAL 3: Full revert on discard
  Question: After a DISCARD experiment, does the target file's content
            match the prior baseline byte-for-byte (excluding
            whitespace-only edits)?
  Pass: File matches prior baseline.
  Fail: Partial revert detected.

EVAL 4: Changelog completeness
  Question: Does changelog.md contain one entry per experiment with
            all five fields (Score, Change, Reasoning, Result,
            Remaining failures)?
  Pass: Every experiment row in results.tsv has a matching
        changelog entry with all five fields populated.
  Fail: Any entry missing or any field empty.

EVAL 5: Stop condition honored
  Question: Did the loop stop on exactly one of: (a) explicit user
            stop, (b) {budget} cap reached, (c) 95%+ for 3
            consecutive experiments?
  Pass: Final row's `stop_reason` is `user_stop`, `budget_exhausted`,
        or `ceiling_3x`, matching the observed condition.
  Fail: Loop ran past budget or stopped without the matching reason.
```
