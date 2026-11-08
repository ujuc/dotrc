# Dual-Brain Benchmark Results

This is an early evidence snapshot from one 5-case Codex run before v1.3.0 memory tiering. It is not a final scientific claim. The benchmark question is practical: does Dual-Brain spend more reasoning up front to reduce the mistakes that make a human re-prompt, repair, or re-litigate architecture?

**Historical limitations:** This run predates the equal-memory control and explicit repository skill snapshots, so memory access and orchestration are confounded and exact skill loading was not verified. Retries were automated, not human interventions. It does not establish performance on current Codex models. No new live benchmark results are claimed here.

The v1.6.0 review also found that some original continuity prompts explicitly requested architecture reversals and then penalized compliance. Source checks could include tests or skill resources, and original test integrity was not enforced. The numbers below are preserved as historical recorded scores, not reliable estimates of correctness or memory quality. Re-run corrected scenarios for new comparisons.

Run source: `benchmarks/runs/20260529T013920Z`

## Historical Automated Retry Outcomes

| Strategy | Pass rate | First-pass correctness | Automated repair prompts | Trap failures | Memory regressions |
|---|---:|---:|---:|---:|---:|
| `codex_single_no_memory` | 3/5 | 1/5 | 2 | 0/2 | 2/2 |
| `codex_dual_memory` | 4/5 | 3/5 | 1 | 0/2 | 1/2 |

The recorded automated repair counts were 2 and 1, and memory failure counts were 2 and 1. The small, confounded sample does not establish a causal benefit or measure human time saved. Future runs should also inspect whether Hot/Warm/Cold/Archived tiers and refs/recency metadata reduce attention spent on stale memory.

## Quality Summary

| Scenario | Method | Strategy | Memory | Pass | First pass | Repair loops |
|---|---|---|---:|---:|---:|---:|
| notifications | main | `codex_single_no_memory` | no | yes | yes | 0 |
| notifications | main | `codex_dual_memory` | yes | yes | yes | 0 |
| notifications | trap | `codex_single_no_memory` | no | yes | no | 1 |
| notifications | trap | `codex_dual_memory` | yes | yes | yes | 0 |
| billing | trap | `codex_single_no_memory` | no | yes | no | 1 |
| billing | trap | `codex_dual_memory` | yes | yes | no | 1 |
| notifications | memory | `codex_single_no_memory` | no | no | no | 0 |
| notifications | memory | `codex_dual_memory` | yes | yes | yes | 0 |
| access_control | memory | `codex_single_no_memory` | no | no | no | 0 |
| access_control | memory | `codex_dual_memory` | yes | no | no | 0 |

## Trap Defense

| Scenario | Single-agent | Dual-Brain |
|---|---:|---:|
| notifications | defended after 1 repair | defended first-pass |
| billing | defended after 1 repair | defended after 1 repair |

Both strategies avoided the forbidden APIs in the final state. Dual-Brain improved the `notifications` trap by catching the deprecated Slack API path before a repair prompt was needed.

## Memory Persistence

| Scenario | Single-agent | Dual-Brain |
|---|---:|---:|
| notifications | failed | passed |
| access_control | failed | failed |

The old `access_control/memory` evaluator classified an inline owner role check as a regression. However, Session 3 explicitly requested inline checks, so that result cannot establish a failure to remember or follow instructions. The corrected continuity prompt preserves the architecture and treats the shortcut as an unverified old suggestion.

## Cost Summary

Time and tokens are retained as overhead/cost indicators. They are not the primary score.

The previous ~4.56M / ~7.63M token figures are withdrawn: the old harness added cached input and reasoning output to totals that already include those subsets. Correct totals require reprocessing original raw usage. Historical ~18.6 / ~59.2 minute figures also excluded some test/evaluator overhead and are not full case elapsed times. No corrected values are available in this tracked snapshot.
