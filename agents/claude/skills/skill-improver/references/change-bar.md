# Change Bar — Evidence-Motivated Edits

Adapted from `skill-doctor`'s skill-improvement guidelines
([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills), `.agents/skills/skill-doctor/references/skill-improvements.md`).

## Scope

Apply this bar to **behavioral edits motivated by Dimension E**: changes to
procedures, constraints, or guidance proposed because a real session went wrong.

- Explicit user-directed authoring remains separate; this bar does not replace it.
- An already accepted exact proposal needs no second approval.
- Source-consistency fixes do not establish observed behavior improvement.
- Mechanical lint follows the Phase 4 auto-fix table, without requiring session
  evidence. Examples include broken reference paths, catalog drift, and missing
  frontmatter fields, subject to that table's limits.

## Review the evidence

1. Attribute findings, then cluster them by root cause across sessions.
2. Prioritize clusters by frequency × severity.
3. Verify each finding against the current file. A historical digest may describe
   a gap that has already been fixed; drop findings that no longer verify.

## When to propose a change

Ask: *would a competent agent following the current instructions still be
expected to fail this way?* If no, defer. If yes, check all conditions below.

Propose only when all of these hold:

- **Cause:** a missing, wrong, or underspecified instruction caused the failure
  in a skill, agent definition, or in-repo guidance.
- **Owner and rule:** you can name the owning surface and one reusable rule it
  should have stated.
- **Prevention:** that rule, if present and followed, would have prevented the
  scored failure.
- **Evidence:** the gap appears in **more than one** sampled session, or one
  occurrence is severe enough to prove a missing contract on its own.

Do not propose when:

- The instruction already required the correct behavior and the model ignored it.
- The failure is model variance: the same prompt and tools led to a different choice.
- The only available edit is restating, hedging, or bolting examples from these
  runs onto existing guidance.
- The real fix is tooling, environment, or code — outside any instruction
  surface.

When nothing clears the bar, propose nothing and explain why for each finding.
**No proposal is a valid outcome.**

## Owning-surface routing

| Finding | Owner | Handling |
|---------|-------|----------|
| Instruction gap in a target under review | that skill / agent | Draft a diff under the change bar |
| Instruction gap in a skill outside this run's targets | that skill | Record as a suggestion; do not edit an untargeted file |
| Skill never fires where it should | trigger description | `skill-engineer`; never auto-edit a WHEN clause |
| Missing global rule | `agents/rules/AGENTS.md` | Report only — a global rule change is the user's call |
| Tooling, environment, or contract change | out of scope | Report only |

## Draft and apply

Never edit a target file directly from an evidence finding. State the intended
behavioral rule and its owning surface in one sentence, then draft the smallest
change that expresses it. Prefer **replacing** existing guidance over
**appending** another paragraph.

1. Write the full improved file to `$REPORT_DIR/proposed/<target>/<file>`.
2. `diff -u <current> <proposed>` and keep the diff with the suggestion.
3. Show the diff and apply only accepted scope. A prior explicit acceptance
   remains valid; request a new decision only for a materially changed proposal.

Keep the scratch draft as the regression guard: if re-verification fails,
discard it instead of unwinding a partially applied edit.
