# Evidence Rubric — Dimension E

Dimensions A–D ask whether a skill is *well-formed*. Dimension E asks whether it
*worked*: it scores condensed digests of recent local sessions and keeps only the
failures, because a failure is the only thing that justifies editing another
agent's instructions.

Adapted from `skill-doctor`'s efficiency scorer
([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills), `.agents/skills/skill-doctor/scorers/efficiency.md`).
Deliberately **not** adapted: the code-quality scorer (skill-improver improves
skills, not the code a session produced, and it needs diffs the digest drops),
the `curve()` transform, and the weighted `overall` grade — a letter grade is a
report headline, not an actionable finding.

## Input

`$REPORT_DIR/transcripts/<session-id>.txt`, produced by
`scripts/collect-sessions`. Each line is one event:

| Tag | Meaning |
|-----|---------|
| `USR` | a human turn |
| `CMD` | a slash-command turn |
| `AST` | assistant prose |
| `USE` | a tool call and its target |
| `ERR` | a failed tool result |

Thinking blocks and successful tool output are dropped — the digest carries the
*shape* of the run, not its content. A digest may end with an elision marker;
score what is present and do not infer what was cut.

## Scoring

Score every sampled digest against the efficiency rubric below. Record: the
label, its numeric score, and a 1–3 sentence reason citing specifics.

| Label | Score | Description |
|-------|-------|-------------|
| `highly_efficient` | 1.0 | A direct path: nothing re-read or re-run, independent steps batched, no work redone. |
| `mostly_efficient` | 0.8 | One or two slips: a duplicated read, an early retry, a small correction — no knock-on cost. |
| `mostly_inefficient` | 0.4 | Repeated wasted effort, or a round of rework an earlier check would have prevented. |
| `highly_inefficient` | 0.2 | Waste dominated the run: the same defect reworked across cycles, repeated user correction, extended flailing. |

Evaluate the full cost of reaching the result: the steps taken, the rework
caused, and the human attention consumed. Score against what a competent
engineer with the same tools would have needed, not against what was achievable
with only what the agent happened to have. A mistake that looks unavoidable in
context still counts if better tooling, a skill, or a check would have prevented
it — name that cause in the reason. These are common sources of waste, not an
exhaustive checklist:

- **Rework from mistakes.** Work redone because the agent got it wrong the first
  time: a test or build failure a local check would have caught, edits to the
  wrong file, a misread requirement later reverted.
- **Cost to the human.** Repeated correction or steering is the most expensive
  waste. A question asked up front is cheap; the same question asked after
  building the wrong thing is not.
- **Information gathering.** Re-reading, re-running, or re-searching for
  something already found; reading a large file end to end when a targeted
  search would answer it.
- **Routine-step overhead.** A roundabout way of doing something that is a
  standard, repeated part of this agent's job. Weight this beyond its one-run
  cost: the same overhead recurs on every future conversation until a skill or
  rule fixes the pattern.
- **Batching.** Independent reads, searches, or workstreams run serially across
  turns instead of together.
- **Flailing.** Retrying a failing approach unchanged, or guessing when reading
  the code or docs would have settled it. An abandoned path only counts when the
  information to avoid it was already available.
- **Verification timing.** Checks run once, early enough to catch a defect before
  declaring done — not deferred until after, not re-run redundantly.

**Reason format.** One to three sentences naming the dominant source of waste
with a rough count (three fix-test cycles, four redundant reads, two repeated
user corrections), and the likely fixable cause — a missing or weak skill, an
ambiguous instruction, a late check. **When a skill exists that should have
prevented the waste, name it**; that name is what makes the finding attributable.

## Failed conversations

A session **fails** when its efficiency score is below `0.5` — that is,
`mostly_inefficient` or `highly_inefficient`.

Only failed sessions may motivate a behavioral edit. A `mostly_efficient` run
with a nit in it is not evidence; it is a run that went fine.

## Coverage

Coverage is mechanical, not scored. From `inventory.json`:

- A session **used a skill** when `skills_used` is non-empty, or `commands_used`
  contains a name present in the Phase 1 catalog. `commands_used` also records
  built-in CLI commands (`/clear`, `/compact`, `/model`, `/effort`) and plugin
  commands — filter against the catalog before counting.
- `skill_coverage` = sampled sessions that used a skill ÷ `sessions_sampled`.

A catalog skill that never appears across the sample, in a domain the sample
clearly exercised, is a **trigger-description** signal — not an instruction gap.
Record it as a suggestion and route it to `skill-engineer`; never auto-edit a
WHEN clause on this evidence.

## Attribution

A finding belongs to a target only when the digest shows that target's work.
Attribute by, in order of strength:

1. The session invoked the skill (`USE Skill | <name>` or a matching `CMD`), and
   the waste happened inside that stretch of the run.
2. The waste happened in the surface the skill owns (its scripts, its artifacts,
   its documented procedure), whether or not it was invoked.
3. The reason field names the skill that should have prevented the waste.

Unattributable findings stay in the run summary and motivate no edit. Do not
stretch an attribution to reach a target that happens to be under review.

## Privacy

Digests are built from sessions across every local project, including work
repositories. They live only in the run's `mktemp` scratch directory and are
never uploaded, committed, or pasted into a report.

A citation is a **session id plus a one-line paraphrase** — for example,
`54574efe: three fix-test cycles on the same import path`. Never quote digest
lines, file paths, branch names, or prose from another repository in anything
that lands in this repository.
