---
source_url: https://github.com/obra/superpowers/tree/main/skills/writing-skills
source_commit: 2ce8aa15d05b  # tag v7.0.1
last_upstream_check: 2026-11-01
check_interval_days: 14
---

# Testing guidance before it ships

Adapted from `writing-skills` in obra/superpowers (MIT, Copyright (c) 2025 Jesse
Vincent). Findings marked upstream are that project's; local measurements are labeled local. When `superpowers-upstream check` reports an
update, read the compare link, adapt what changed, then update `source_commit`
and `last_upstream_check` here.

Left out on purpose: the TDD mandate and "delete it and start over", because
Behavior baseline already covers it with a stop when the baseline passes; the
`Use when` description format, because this repository writes Korean WHAT and
WHEN; word-count targets for existing skills, because skill-diet's budget owns
their size.

## Match the form to the failure

Classify the baseline failure before writing guidance. The form that fixes one
failure type backfires on another.

| Baseline failure | Right form | Wrong form |
| --- | --- | --- |
| Knows a rule and skips it under pressure | Prohibition, rationalization table, red flags | Soft guidance ("prefer", "consider") |
| Complies, but the output has the wrong shape | A recipe: state what the output is, its parts, in order | A prohibition list ("don't restate") |
| Omits a required element from something it already produces | A required field or slot in the template | A prose reminder near the template |
| Behavior should depend on a condition | A conditional on an observable predicate | An unconditional rule plus exemptions |

Upstream finding: in head-to-head tests on dispatch-prompt guidance under a competing
incentive, a prohibition produced more of the unwanted content than a recipe.

- **No nuance clauses.** "Don't X unless it matters" reopens the negotiation. Write a
  real exception as its own conditional on an observable predicate.
- **Exemptions don't scope.** "This limit doesn't apply to code blocks" still
  suppresses code blocks. Restructure so the rule can't reach what must be exempt.

## Force without emphasis

Use the first level that holds. A discipline skill may use all three, a technique
or pattern skill gets plain imperatives, and a reference skill gets none.

1. **Enforce it.** A rule with no exceptions belongs in a hook, deny rule, validator
   or test.
2. **Force it in plain words**, once a baseline shows the agent knows the rule and
   skips it. Name an observable trigger and the action ("before the final report,
   run X"), and give a command to run rather than a status to fill in. Add the
   recorded excuses as a rationalization table. Write "no exceptions" only for a
   rule that has none.
3. **Emphasis.** Capitals or MUST ship only when a micro-test beats the plain
   wording on the model the skill runs on.

Leave out false urgency, guilt, and any "every time" nobody measured. Upstream's
persuasion figures come from a study of compliance with objectionable requests, so
they do not measure adherence to a skill.

Local measurements (2026-11-01, `generate-skills`, fixed-input replay and live tool runs):

| Test | Result |
| --- | --- |
| Plain against emphasis, 12 reps per cell, blind double scoring | Emphasis beat plain in one cell of nine: not reporting unfinished work as done on Haiku 5.5, 5/12 to 10/12 (p = 0.09). The other cells tied or had too few answers to compare |
| Three Step 5 gates on a one-line edit, 12 reps per cell | Sonnet 5.5 ran all three 0/24 unchanged and 24/24 with a command before the final report. Required status rows gave 11/12 calm, 0/12 urgent. Opus 5.5 ran all three in every completed run of each variant |

## Micro-test the wording

Run this before full scenarios, for guidance meant to change behavior.

1. Use one fresh context per sample, with the whole skill as context and a task
   that tempts the failure.
2. Always run a no-guidance control. If the control does not show the failure,
   stop: there is nothing to fix. With Waza, the control is a scratch copy of the
   suite with `inject_skill_body: false`; compare trial pass rates.
3. Run at least five repetitions per variant.
4. Read every flagged match. Echoes of the template and quoted counter-examples
   pass as hits.
5. Treat variance as a result: reps that diverge mean the wording does not bind.
   Tighten the form before adding words.

## Pressure scenarios

A discipline skill also needs pressure, since agents follow rules when nothing is
at stake. Combine three or more of these in one scenario that forces a choice:

| Pressure | Example |
| --- | --- |
| Time | Deploy window closing |
| Sunk cost | Hours of work to throw away |
| Authority | A senior says to skip it |
| Economic | Revenue or a job at stake |
| Exhaustion | End of a long day |
| Social | Looking dogmatic |
| Pragmatic | "Being pragmatic, not dogmatic" |

Record the agent's excuses verbatim. Each excuse that recurs becomes a row in the
skill's red flags, in plain words.

## Discovery tests

Use these when an instruction must send an agent to a skill: a rules file, a
bootstrap block, or a skill newly allowed to load on its own. Adapted from
`CLAUDE_MD_TESTING.md`, whose expected results are predictions, so measure your own.

1. Write scenarios where skipping the skill looks reasonable: a choice between
   checking it and acting now, with the pressures above.
2. Run a no-mention baseline, then each variant on the same scenarios: a soft
   suggestion, a directive, and a step placed inside the workflow.
3. PASS: the agent opens the skill unprompted, reads it before acting, and follows
   it under pressure. FAIL: it skips the check, works from the description or from
   memory, or treats the skill as optional.
4. After a failure, ask what wording would have made the step hard to miss. Ask for
   a wording change, not an account of its reasoning: Fable 5.1 subagents refused
   that request with `reasoning_extraction` (local finding).
