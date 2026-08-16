# Iteration Strategy — Round-Count Guidance

Budget for the Generator-Evaluator loop, by elapsed round count. The evaluator advises when to shift mode or stop.

## Round-by-round mode

| Rounds | Expected behavior | Evaluator mode |
| ------ | ----------------- | -------------- |
| 1–5    | Significant improvement. Major layout and identity changes. | Refine freely. Big-swing directives allowed. |
| 5–10   | Diminishing returns. Focus shifts to craft and polish. | Push on specific weak criteria, not broad restructure. |
| 10–15  | Plateau zone. If no criterion > 7 by round 10, recommend a fundamental redesign. | Issue a pivot directive; stop chasing delta points. |
| 15+    | Approach exhausted. | Stop. Report the best snapshot so far; suggest a new approach. |

## Directive decision matrix

Pick one per round based on the score trend vs. the prior round.

| Trend | Condition | Directive phrasing |
| ----- | --------- | ------------------ |
| Up    | At least one criterion improved, none regressed | "Refine current direction. Focus on [weak areas]." |
| Stagnant | All criteria within ±0.5 of last round | "Pivot. Current direction plateaued. Try [alternative aesthetic]." |
| Declining | Any criterion dropped ≥ 1.0 | "Revert to round N snapshot or pivot completely." |
| Polish threshold | Weighted avg ≥ 7 and no criterion below 7 | "Polish phase. Address micro-details: [list]." |

## Stop conditions

Recommend stopping the loop when any of these holds:

- Weighted average ≥ 8.0 for two consecutive rounds.
- Round counter reaches 15.
- Two consecutive pivot directives produced no score movement.
- Generator reports it cannot satisfy a directive without breaking another criterion (trade-off floor reached).

## Anti-patterns in iteration

- **Chasing decimals**: refusing to stop because avg went 7.4 → 7.5. Not worth further cost.
- **Reward hacking**: Generator adds gimmicks that satisfy rubric language but degrade real quality. Call it out in the report and flag Originality.
- **Score inflation by evaluator**: compare current scores against earlier-round snapshots before writing the new score; do not adjust to avoid reporting regression.
