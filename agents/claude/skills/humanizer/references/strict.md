# Strict and redo

Dispatch every worker with `Agent`, `subagent_type: "general-purpose"`, the routing named below, the prompt "Read `<abs>/references/roles/<role>.md` first and follow it." and absolute paths in the run directory.

## Phase A — Detection

`scanner` with `mode: baseline` (Standard): `input_path` (`01_input.txt`), `taxonomy_path` ([taxonomy-ko.md](taxonomy-ko.md)), `output_path` (`02_detection.json`), `run_id`, `genre_hint`, `min_severity`, `include_document_level: true`.

## Phase B — Rewrite

`rewriter` (Advanced): `original_path` (always `01_input.txt`), `source_path` (round 1: `01_input.txt`; later: the prior candidate), `detection_path`, `playbook_path` ([playbook-ko.md](playbook-ko.md)), `rewrite_path`, `diff_path`, and from round 2 the current `review_path`. Versions: `03_rewrite.md` + `03_rewrite_diff.json`, then `_v2`, then `_v3`.

## Phase C — Verification

Two `Agent` calls in parallel with this round's paths:

- `fidelity-auditor` (Advanced): `original_path`, `rewrite_path`, `diff_path`, `output_path` (`04_fidelity_audit{_vN}.json`).
- `scanner` with `mode: review` (Advanced): `original_path`, `original_detection_path`, `rewrite_path`, `taxonomy_path`, `output_path` (`05_naturalness_review{_vN}.json`), and `round` (1–3; pass it, the scanner never infers it from file names).

**Verdict.** Any `hold_and_report` stops first; then fidelity `fail`, then `conditional_pass`, then naturalness.

| fidelity | naturalness | verdict | next |
|---|---|---|---|
| full_pass | accept / accept_with_note | final approval | Phase D |
| full_pass | rewrite_round_2 | 2nd rewrite | Phase B on the target finding |
| full_pass | rollback_and_rewrite | rollback then rewrite | tell the rewriter to roll back that edit |
| full_pass | hold_and_report | hold | recommend human review |
| conditional_pass | - | retry rolled-back edits only | Phase B |
| fail | - | full rework | full Phase B |
| hold_and_report | - | hold | ask for human review; do not rewrite |

## Phase D — Final output

1. Copy the latest `03_rewrite*.md` to `final.md`.
2. Write `summary.md` in the fast format, adding any `unclassified_candidates` from the final naturalness JSON.
3. Return the four-part response.

## Redo

Use the most recent run directory (also when the user says "이전 거 다시"); if none exists, say so and stop.

- English or mixed run: redo the current `final.md` through the inline fast track and rerun its checks.
- Korean fast run without strict files: run Phase A on `final.md`, then Phase B with `final.md` as the prior candidate. Fidelity still compares against `01_input.txt`.

Parse the instruction with the [redo table](../SKILL.md#strict-and-redo).

For Korean, then run Phase C on the new version (`03_rewrite_v2.md` or `_v3`).
