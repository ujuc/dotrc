# File Format Specification

Defines the on-disk format for every file the negotiation produces. The whole protocol relies on both roles parsing each other's files mechanically — formats here are normative, not suggestive.

## `contract-draft-{n}.md`

Written by the Generator. One per round.

```markdown
# Contract Draft {n} — [Sprint Name]

## Sprint Goal
[One sentence: what value does this sprint deliver to the user?]

## Implementation Scope
1. [Feature Name] — [What it does in 1 sentence]
2. [Feature Name] — [What it does in 1 sentence]

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | [Subject + Verb + Observable Result] | [What an outside observer sees] | [Manual / API call / UI step] |
| 2 | ...                                 | ...                              | ...                          |

## Exclusions
- [Explicitly out of scope]

## Changes from Previous Draft
- (Round 1: write "Initial draft")
- (Round 2+: bullet list referring to review feedback by criterion #)
```

Rules:

- The criterion `#` is stable across rounds. If a criterion is removed, leave the row but mark `Criterion: REMOVED — see Changes`.
- `Changes from Previous Draft` MUST cite review-comment numbers from the previous review file (e.g., `#3: rewrote per review-1#3 — added explicit verification method`).
- Never silently change a criterion. Every edit traces to a review.

## `contract-review-{n}.md`

Written by the Evaluator. One per draft.

```markdown
# Contract Review {n} — [Sprint Name]

Reviewed: contract-draft-{n}.md

## Verdicts

| # | Verdict | Reason |
|---|---------|--------|
| 1 | ACCEPT  | (empty or one-line affirmation) |
| 2 | REJECT  | Missing [subject / verb / observable result / verification method]: [concrete explanation] |
| 3 | REJECT  | [reason] |

## Summary
- Accepted: [count]
- Rejected: [count]
- Escalation triggered: [yes/no, with reason if yes]
```

Rules:

- Every criterion in the latest draft MUST appear exactly once in the verdicts table.
- A `REJECT` MUST cite which of the four parts (subject / verb / observable result / verification method) is missing or unverifiable. "Vague" alone is itself a rejected review and the Evaluator must rewrite it.
- The summary's escalation flag triggers per the rules in the skill body.

## `contract.md`

Written by the Generator on full acceptance. Final, stable form.

```markdown
# Sprint Contract — [Sprint Name]

## Sprint Goal
[Final wording]

## Implementation Scope
1. [Feature Name] — [What it does in 1 sentence]
2. ...

## Verification Criteria

| # | Criterion | Expected Behavior | Test Method |
|---|-----------|-------------------|-------------|
| 1 | ... | ... | ... |

## Exclusions
- ...

## Negotiation History
- Draft 1 ([date]): N proposed, M accepted, K rejected
- Draft 2 ([date]): N revised, M accepted, K rejected
- Final ([date]): N criteria agreed in {rounds} rounds
```

Rules:

- `contract.md` is immutable once written. A changed scope requires preserving the current workspace and starting a new sprint workspace; never rewrite the existing contract in place.
- Negotiation History is the audit trail: every round's counts are reported, even if zero criteria changed.

## `escalation.md`

Written by either role when an early-escalation trigger fires.

```markdown
# Sprint Negotiation Escalated — [Sprint Name]

## Trigger
[Which trigger fired — repeated rejection, > 50% rejection rate, or insufficient criteria]

## Unresolved Criteria
| # | Criterion (current draft) | Last Reject Reason |
|---|---------------------------|---------------------|
| ... | ... | ... |

## Question for User
[Concrete question, e.g.: "The spec calls for 'fast' map loading.
 What latency threshold should we treat as 'fast'?"]
```

Rules:

- The escalation file blocks further auto-negotiation. The skill returns control to the user and waits.
- If escalation occurs before review 3, resume at `contract-draft-{n+1}.md` and cite the user's resolution. If review 3 triggered escalation, preserve/archive the workspace and start a fresh workspace at draft 1; draft 4 is forbidden.
