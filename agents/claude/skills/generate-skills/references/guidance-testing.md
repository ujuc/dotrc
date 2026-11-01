---
source_url: https://github.com/obra/superpowers/tree/main/skills/writing-skills
source_commit: 2ce8aa15d05b  # tag v7.0.1
last_upstream_check: 2026-11-01
check_interval_days: 14
---

# Testing guidance before it ships

Adapted from `writing-skills` in obra/superpowers (MIT, Copyright (c) 2025 Jesse
Vincent). The wording-test results below are that project's findings, not
measurements from this repository. When `superpowers-upstream check` reports an
update, read the compare link, adapt what changed, then update `source_commit`
and `last_upstream_check` here.

Left out on purpose: the TDD mandate and "delete it and start over", because
Behavior baseline already covers it with a stop when the baseline passes; the
`Use when` description format, because this repository writes Korean WHAT and
WHEN; word-count targets, because skill-diet owns size.

## Match the form to the failure

Classify the baseline failure before writing guidance. The form that fixes one
failure type backfires on another.

| Baseline failure | Right form | Wrong form |
| --- | --- | --- |
| Knows a rule and skips it under pressure | Prohibition, rationalization table, red flags | Soft guidance ("prefer", "consider") |
| Complies, but the output has the wrong shape | A recipe: state what the output is, its parts, in order | A prohibition list ("don't restate") |
| Omits a required element from something it already produces | A required field or slot in the template | A prose reminder near the template |
| Behavior should depend on a condition | A conditional on an observable predicate | An unconditional rule plus exemptions |

Upstream finding: in head-to-head wording tests, a prohibition produced more of the
unwanted content than a recipe, because agents negotiate with "don't X".

- **No nuance clauses.** "Don't X unless it matters" reopens the negotiation. Write a
  real exception as its own conditional on an observable predicate.
- **Exemptions don't scope.** "This limit doesn't apply to code blocks" still
  suppresses code blocks. Restructure so the rule can't reach what must be exempt.

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
