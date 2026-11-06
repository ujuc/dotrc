## Eval Criteria

Runtime checks for a run of autoresearch, used when the target is autoresearch itself (score a wet run's `results.tsv` and `changelog.md`).

```
EVAL 1: Baseline established
  Question: Does results.tsv contain a row with experiment=0 and
            status=baseline before any mutation runs?
  Pass: Row exists with the unmutated target's score and its recorded
        model and effort (or `unknown`).
  Fail: Mutation occurred before experiment 0 was logged, or the row
        lacks model and effort (or `unknown`).

EVAL 2: One-change discipline
  Question: For every kept experiment N (N>0), does the diff between
            target@N and target@N-1 represent a single coherent change
            (one section edited, one parameter adjusted, one
            instruction added/removed)?
  Pass: Every kept diff is one logical change.
  Fail: Any kept diff bundles multiple unrelated changes.

EVAL 3: Full revert on discard
  Question: After a DISCARD experiment, does the target file's content
            match the prior baseline byte-for-byte (excluding
            whitespace-only edits)?
  Pass: File matches prior baseline.
  Fail: Partial revert detected.

EVAL 4: Changelog completeness
  Question: Does changelog.md contain one entry per experiment with
            all five fields (Score, Change, Reasoning, Result,
            Remaining failures)?
  Pass: Every experiment row in results.tsv has a matching
        changelog entry with all five fields populated.
  Fail: Any entry missing or any field empty.

EVAL 5: Stop condition honored
  Question: Did the loop stop on exactly one of: (a) explicit user
            stop, (b) {budget} cap reached, (c) 95%+ for 3
            consecutive experiments?
  Pass: Final row's `stop_reason` is `user_stop`, `budget_exhausted`,
        or `ceiling_3x`, matching the observed condition.
  Fail: Loop ran past budget or stopped without the matching reason.
```
