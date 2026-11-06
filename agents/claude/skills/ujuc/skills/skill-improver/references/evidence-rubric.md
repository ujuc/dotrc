# Evidence Rubric — Dimension E

Score every sampled session digest; only failed sessions can motivate a behavioral proposal, and only through [`change-bar.md`](change-bar.md). Adapted from `skill-doctor`'s efficiency scorer ([warpdotdev/common-skills](https://github.com/warpdotdev/common-skills)).

## Input

`$REPORT_DIR/transcripts/<session-id>.txt` from `scripts/collect-sessions`, one event per line:

| Tag | Meaning |
|-----|---------|
| `USR` | a human turn |
| `CMD` | a slash-command turn |
| `AST` | assistant prose |
| `USE` | a tool call and its target |
| `ERR` | a failed tool result |

Digests omit thinking and successful tool output. Score only visible events; infer nothing behind condensation or an elision marker.

## Scoring

Give each digest one label:

| Label | Score | Description |
|-------|-------|-------------|
| `highly_efficient` | 1.0 | A direct path: nothing re-read or re-run, independent steps batched, no work redone. |
| `mostly_efficient` | 0.8 | One or two slips: a duplicated read, an early retry, a small correction — no knock-on cost. |
| `mostly_inefficient` | 0.4 | Repeated wasted effort, or a round of rework an earlier check would have prevented. |
| `highly_inefficient` | 0.2 | Waste dominated the run: the same defect reworked across cycles, repeated user correction, extended flailing. |

A session **fails** below `0.5`. Slips in a `mostly_efficient` session are not evidence for an edit.

Judge the full cost of reaching the result against a competent engineer with the same tools. Repeated user correction costs the most; late clarification costs more once wrong work exists. An abandoned path counts only when the information to avoid it was already available. A mistake still counts if a tool, a skill, or an earlier check could have prevented it. Waste also includes whole-file reads where a targeted search would do, independent steps run serially, roundabout steps that will recur every session until a skill or rule fixes them, and checks deferred until after declaring done or repeated needlessly.

With the label, write 1–3 sentences: the dominant waste with a rough count (such as three fix-test cycles), its likely fixable cause (missing or weak skill, ambiguous instruction, late check), and **any existing skill that should have prevented it**.

## Attribution

A finding belongs to a target only when the digest shows that target's work. In order of strength:

1. The session invoked the skill (`USE Skill | <name>` or a matching `CMD`), and the waste happened inside that stretch.
2. The waste happened in a surface the skill owns (its scripts, artifacts, documented procedure), invoked or not.
3. The reason names the skill that should have prevented the waste.

Unattributable findings stay in the run summary and motivate no edit. Never stretch an attribution to reach a target under review.

## Coverage

From `inventory.json`, separate from scores:

- A session **used a skill** when `skills_used` is non-empty or `commands_used` holds a name in the Phase 1 catalog. Filter `commands_used` against that catalog first: it also holds built-ins (`/clear`, `/compact`, `/model`, `/effort`) and plugin commands.
- `skill_coverage` = sessions that used a skill ÷ `sessions_sampled`.

A catalog skill that never appears although the sample clearly exercises its domain is a **trigger-description** suggestion for `skill-engineer`, not an instruction gap; never auto-edit a WHEN clause on it.

## Privacy

Digests may include work repositories. Keep them only in the run's `mktemp` scratch directory; never upload, commit, or paste them into a report.

A citation is a **session id plus a one-line paraphrase**, such as `54574efe: three fix-test cycles on the same import path`. Never quote digest lines, file paths, branch names, or prose from another repository in anything that lands in this repository.
