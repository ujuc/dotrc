# Change Bar — Evidence-Motivated Edits

Adapted from `skill-doctor`'s skill-improvement guidelines ([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills)).

## Scope

This bar covers **behavioral edits motivated by Dimension E**: procedure, constraint or guidance changes proposed because a real session went wrong.

- Explicit user-directed authoring stays separate; missing evidence blocks only evidence-motivated rewrites, not a user's request to improve a known instruction.
- An already accepted exact proposal needs no second approval.
- A source-consistency fix does not show observed behavior improved.
- Mechanical lint follows the Phase 4 auto-fix table and needs no session evidence: broken reference paths, catalog drift, missing frontmatter fields.

## Review the evidence

1. Cluster attributed findings by root cause across sessions; rank clusters by frequency × severity.
2. Verify each against the current file and drop any the file already fixes.

## When to propose

Ask: *would a competent agent following the current instructions still be expected to fail this way?* If not, defer. If so, propose only when all hold:

- **Cause:** a missing, wrong, or underspecified instruction in a skill, role file, or in-repo guidance caused the failure.
- **Owner and rule:** you can name the owning surface and one reusable rule it should have stated.
- **Prevention:** that rule, followed, would have prevented the scored failure.
- **Evidence:** the gap appears in **more than one** sampled session, or one occurrence is severe enough to prove a missing contract alone.

Do not propose when the instruction already required the right behavior and the model ignored it; when the failure is model variance (same prompt and tools, different choice); when the only edit restates, hedges, or bolts these runs' examples onto existing guidance; or when the real fix is tooling, environment, or code.

When nothing clears the bar, propose nothing and say why for each finding. **No proposal is a valid outcome.**

## Owning-surface routing

| Finding | Owner | Handling |
|---------|-------|----------|
| Instruction gap in a target under review | that skill / agent | Draft a diff under the change bar |
| Instruction gap in a skill outside this run's targets | that skill | Record as a suggestion; do not edit an untargeted file |
| Skill never fires where it should | trigger description | `skill-engineer`; never auto-edit a WHEN clause |
| Missing global rule | `agents/rules/AGENTS.md` | Report only — a global rule change is the user's call |
| Mechanical mistake a tool could catch, or an environment/contract change | the tool | Report the below-skill fix (clearer error, check, test), not prose |

## Draft and apply

State the behavioral rule and its owning surface in one sentence, then draft the smallest change that expresses it, replacing existing guidance rather than appending a paragraph.

1. Write the full improved file to `$REPORT_DIR/proposed/<target>/<file>`.
2. Keep `diff -u <current> <proposed>` with the suggestion.
3. Show the diff and apply only the accepted scope. A prior explicit acceptance stays valid; ask again only for a materially changed proposal.

If re-verification fails, discard the draft instead of unwinding a partial edit.
