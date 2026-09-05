# Change Bar — evidence-motivated edits

Adapted from `skill-doctor`'s skill-improvement guidelines
([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills), `.agents/skills/skill-doctor/references/skill-improvements.md`).

## Scope

This bar governs **behavioral edits motivated by Dimension E** — changes to a
skill's procedure, constraints, or guidance, proposed because a real session
went wrong.

It does **not** replace explicit user-directed authoring work or require a second
approval for an already accepted exact proposal. Keep source-consistency fixes
separate from claims of observed behavior improvement. It does **not** govern
the Phase 4 auto-fix table. Broken reference paths,
catalog drift, and missing frontmatter fields are mechanical lint against a
known-correct spec; gating them behind conversation evidence would stop what
already works.

## Method

1. Cluster findings by root cause across sessions, after attribution.
2. Prioritize clusters by frequency × severity.
3. Verify each finding against the current file before proposing anything. The
   digest shows what happened weeks ago; the skill may already say the right
   thing. Drop what does not verify.
4. You are editing another agent's instructions. Before editing, state the
   intended behavioral rule and its owning surface in one sentence, then make
   the smallest change that expresses it.
5. Prefer **replacing** existing guidance over **appending** another paragraph.
   A skill that grows a paragraph per incident stops being read.

## When to propose a change

Do not propose changes by default. Ask: *would a competent agent following the
current instructions still be expected to fail this way?* If yes, there is a
gap. If no, defer.

Propose only when all of these hold:

- The failure was caused by a missing, wrong, or underspecified instruction on a
  concrete surface — this skill, another skill, an agent definition, or in-repo
  guidance.
- You can name that surface and the one reusable rule it should have stated.
- Had that rule been present and followed, the scored failure would not have
  happened.
- The gap appears in **more than one** sampled session, or a single occurrence is
  severe enough to prove a missing contract on its own.

Do not propose when:

- The instruction already required the correct behavior and the model ignored it.
- The failure is model variance: same prompt, same tools, a different choice.
- The only available edit is restating, hedging, or bolting examples from these
  runs onto existing guidance.
- The real fix is tooling, environment, or code — outside any instruction
  surface.

When nothing clears the bar, propose nothing and say per finding why not. **That
is a success, not an empty run.** A speculative change is worse than none.

## Owning-surface routing

| Finding | Owner | Handling |
|---------|-------|----------|
| Instruction gap in a target under review | that skill / agent | Draft a diff under the change bar |
| Instruction gap in a skill outside this run's targets | that skill | Record as a suggestion; do not edit an untargeted file |
| Skill never fires where it should | trigger description | `skill-engineer`; never auto-edit a WHEN clause |
| Missing global rule | `agents/rules/AGENTS.md` | Report only — a global rule change is the user's call |
| Tooling, environment, or contract change | out of scope | Report only |

## Draft-then-apply

Never edit a target file directly from an evidence finding.

1. Write the full improved file to `$REPORT_DIR/proposed/<target>/<file>`.
2. `diff -u <current> <proposed>` and keep the diff with the suggestion.
3. Show the diff and apply only accepted scope. A prior explicit acceptance
   remains valid; request a new decision only for a materially changed proposal.

The scratch draft is also the regression guard: when re-verification fails,
discard the draft instead of unwinding a partially applied edit.
