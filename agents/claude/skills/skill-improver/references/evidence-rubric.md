# Evidence Rubric — Dimension E

Dimension E evaluates how a skill worked in recent local sessions; Dimensions
A–D evaluate whether it is well-formed. Score every sampled session digest, then
use only failed sessions as evidence for behavioral change proposals under
[`change-bar.md`](change-bar.md).

Adapted from `skill-doctor`'s efficiency scorer
([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills), `.agents/skills/skill-doctor/scorers/efficiency.md`).

Excluded adaptations:

- **Code-quality scorer:** evaluates produced code rather than skills and needs
  diffs that digests omit.
- **`curve()` and weighted `overall` grade:** aggregate grades do not identify
  actionable findings.

## Input

Read `$REPORT_DIR/transcripts/<session-id>.txt`, produced by
`scripts/collect-sessions`. Each line represents one event:

| Tag | Meaning |
|-----|---------|
| `USR` | a human turn |
| `CMD` | a slash-command turn |
| `AST` | assistant prose |
| `USE` | a tool call and its target |
| `ERR` | a failed tool result |

Digests omit thinking blocks and successful tool output. Score only the visible
events; do not infer content omitted by condensation or an elision marker.

## Scoring

Assign each sampled digest one label and its numeric score:

| Label | Score | Description |
|-------|-------|-------------|
| `highly_efficient` | 1.0 | A direct path: nothing re-read or re-run, independent steps batched, no work redone. |
| `mostly_efficient` | 0.8 | One or two slips: a duplicated read, an early retry, a small correction — no knock-on cost. |
| `mostly_inefficient` | 0.4 | Repeated wasted effort, or a round of rework an earlier check would have prevented. |
| `highly_inefficient` | 0.2 | Waste dominated the run: the same defect reworked across cycles, repeated user correction, extended flailing. |

A session **fails** when its score is below `0.5`: `mostly_inefficient` or
`highly_inefficient`. Minor issues in a `mostly_efficient` session do not qualify
as evidence for a behavioral edit.

### What to evaluate

Evaluate the full cost of reaching the result: steps, rework, and human attention.
Use a competent engineer with the same tools as the baseline. A mistake still
counts if better tooling, a skill, or an earlier check could have prevented it;
name that cause in the reason.

Common sources of waste include:

- **Rework:** avoidable test/build failures, wrong-file edits, or reverted work
  caused by misread requirements.
- **Human attention:** repeated correction or steering carries the highest cost;
  late clarification costs more when the wrong work has already been built.
- **Information gathering:** repeated reads or searches, or whole-file reads
  when a targeted search would suffice.
- **Routine overhead:** roundabout steps whose cost recurs across future sessions
  until a skill or rule fixes the pattern.
- **Missed batching:** independent reads, searches, or workstreams run serially.
- **Flailing:** unchanged retries or avoidable guesses. Count an abandoned path
  only when the information needed to avoid it was already available.
- **Verification timing:** checks deferred until after declaring completion or
  repeated unnecessarily, instead of run once early enough to catch defects.

### Record the reason

Alongside the label and score, write 1–3 sentences with concrete observations:

- Name the dominant waste and give a rough count, such as three fix-test cycles
  or two repeated user corrections.
- Identify the likely fixable cause: a missing or weak skill, an ambiguous
  instruction, or a late check.
- **Name any existing skill that should have prevented the waste** to support
  attribution.

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

## Coverage

Calculate coverage separately from efficiency scores, using `inventory.json`:

- A session **used a skill** when `skills_used` is non-empty or `commands_used`
  contains a name in the Phase 1 catalog. Filter `commands_used` against that
  catalog: it also contains built-ins (`/clear`, `/compact`, `/model`, `/effort`)
  and plugin commands.
- `skill_coverage` = sampled sessions that used a skill ÷ `sessions_sampled`.

If a catalog skill never appears despite the sample clearly exercising its
domain, record a **trigger-description** suggestion for `skill-engineer`.
This is not an instruction gap; never auto-edit a WHEN clause on this evidence.

## Privacy

Digests may include work repositories. Keep them only in the run's `mktemp`
scratch directory; never upload, commit, or paste them into a report.

A citation is a **session id plus a one-line paraphrase** — for example,
`54574efe: three fix-test cycles on the same import path`. Never quote digest
lines, file paths, branch names, or prose from another repository in anything
that lands in this repository.
