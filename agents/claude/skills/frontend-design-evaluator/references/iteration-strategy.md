# Iteration Strategy

The evaluator advises when to refine, pivot, polish, or stop. It does not
implement changes, restore snapshots, or authorize another round.

## Managed and Standalone Boundaries

Managed runs follow the round limit and completion gates in
[multi-agent-orchestrator](../../multi-agent-orchestrator/SKILL.md): three rounds
by default, with a handoff and user decision after round 3 FAIL. A passing
synthesis returns to `implement-plan` for finalization; the standalone targets
below do not delay that completion or extend the managed loop.

For user-authorized standalone iterations, the following longer-loop guidance
helps choose advice. It is not a requirement to run additional evaluations.

## Standalone Round Guidance

| Rounds | Expected behavior | Evaluator mode |
| ------ | ----------------- | -------------- |
| 1–5    | Significant improvement. Major layout and identity changes. | Refine freely. Big-swing directives allowed. |
| 6–9    | Diminishing returns. Focus shifts to craft and polish. | Push on specific weak criteria, not broad restructure. |
| 10–14  | Plateau zone. If no criterion > 7 by round 10, recommend a fundamental redesign. | Issue a pivot directive; stop chasing delta points. |
| 15+    | Approach exhausted. | Stop. Report the best snapshot so far; suggest a new approach. |

## Directive decision matrix

Pick one per round based on the score trend vs. the prior round. Without a
prior report, use Baseline and do not infer improvement or regression.

| Trend | Condition | Directive phrasing |
| ----- | --------- | ------------------ |
| Baseline | No prior report | "Baseline. Address [specific observed weaknesses]." |
| Up    | At least one criterion improved, none regressed | "Refine current direction. Focus on [weak areas]." |
| Stagnant | All criteria within ±0.5 of last round | "Pivot. Current direction plateaued. Try [alternative aesthetic]." |
| Declining | Any criterion dropped ≥ 1.0 | "Consider restoring round N's design direction or pivoting: [evidence and alternative]." |
| Polish threshold | Weighted avg ≥ 7 and no criterion below 7 | "Polish phase. Address micro-details: [list]." |

Replace bracketed placeholders with observed details. Restoration or other
implementation work belongs to `implement-plan` in managed runs and requires
the applicable user authorization; this reference only supplies feedback.

## Standalone Stop Conditions

Recommend stopping the loop when any of these holds:

- Weighted average ≥ 8.0 for two consecutive rounds.
- Round counter reaches 15.
- Two consecutive pivot directives produced no score movement.
- The implementer reports it cannot satisfy a directive without breaking another criterion (trade-off floor reached).

## Anti-patterns in iteration

- **Chasing decimals**: refusing to stop because avg went 7.4 → 7.5. Not worth further cost.
- **Reward hacking**: The implementation adds gimmicks that satisfy rubric language but degrade real quality. Call it out in the report and flag Originality.
- **Score inflation by evaluator**: compare current scores against earlier-round snapshots before writing the new score; do not adjust to avoid reporting regression.
