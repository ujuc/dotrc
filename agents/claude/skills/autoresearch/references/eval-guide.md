# Eval Guide

Eval rules live in [SKILL.md Step 2](../SKILL.md#step-2-build-the-eval-suite). This file holds examples.

## Eval ideas by target type

| Target | Example checks |
|---|---|
| Code generation | Compiles/parses without errors? Follows the project's naming conventions? Handles the named edge case? |
| Content/writing | Within the word-count range? Covers every required section of the brief? Every claim backed by a reference or example? |
| Workflow/process | Produced every expected output file? Each file in the specified format? Finished without user intervention? |
| Review/analysis | Finds at least one real (manually verified) issue? All cited line numbers accurate? No false positives on known-clean code? |

## Worked Example

A recorded meta-optimization run on the [autoresearch SKILL.md](../SKILL.md):

- **`{target}`**: `claude/skills/autoresearch/SKILL.md`
- **`{exec}`**: text-based static rubric — the operator scores the SKILL.md content directly (the static-rubric option for a self-target)
- **`{inputs}`**: the SKILL.md content itself
- **`{evals}`** (5 binary checks, distinct from the runtime checks in [evals.md](../evals.md)):
  - T1 — anti-recursion safeguard present
  - T2 — runs/budget tradeoff guidance present
  - T3 — worked example present
  - T4 — all 6 procedural steps in order
  - T5 — Step 4-1 names ≥3 failure patterns with detection method
- **`{runs}`**: 1 (static text scores the same every time)
- **`{budget}`**: 8

| Exp | Score | Δ | Mutation | Decision |
|-----|-------|---|----------|----------|
| 0 | 1/5 (20%) | — | baseline | — |
| 1 | 2/5 (40%) | +20% | add anti-recursion gotcha | KEEP |
| 2 | 3/5 (60%) | +20% | replace Step 4-1 prose with named failure pattern table | KEEP |
| 3 | 4/5 (80%) | +20% | add runs/budget tradeoff guidance below context table | KEEP |
| 4 | 5/5 (100%) | +20% | add this Worked Example section | KEEP |
| 5 | 5/5 (100%) | 0% | shorten "to average out stochastic variance" to "to reduce noise" | KEEP (score-neutral size reduction) |
| 6 | 5/5 (100%) | 0% | remove a duplicated baseline reminder | KEEP (score-neutral size reduction) |

Stopped at experiment 6 after three consecutive 100% experiments; the final row records `stop_reason=ceiling_3x`.
