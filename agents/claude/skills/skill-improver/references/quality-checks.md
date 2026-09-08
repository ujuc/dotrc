# Instruction Quality Checks

These semantic audits supplement structural validation. Route core design
changes through the existing manual track; the audit does not authorize workflow
rewrites. Reuse approval for user-requested changes already accepted in this
session. The active authoring/execution workflow retains ownership of those edits.

## B.9 — Authority and write scope

**PASS when the target:**

- Reuses existing approval and honors explicit user/repository requirements over
  optimization defaults.
- Resolves targets and dependencies before writing and names the owner of side
  effects.
- Keeps the body and references consistent on cache/date writes and approval
  scope, without introducing new per-file approval gates.

**FAIL examples:** repeated approval for the same exact patch; unrelated
sibling/global cache edits; removing a named team test gate as generic pruning;
presenting an upstream recommendation as an unlabeled local hard limit.

New scope or destructive actions still follow applicable approval requirements.
When a decision is needed, quote the requirement and explain why existing
authorization is insufficient.

## B.10 — Verification evidence contract

Inspect the target's evaluator prompts and checked-in suites.

**PASS when:**

- Claims have sufficient inputs and an explicit evidence level: structure/schema,
  fixed-input decision replay, actual artifact application, or live integration.
- Verifiers judging preservation or confirmation receive original contents/diff,
  facts, decisions, scope, and effective guidance. Blind reviewers do not guess
  inaccessible facts or remove policy because approval is unseen.
- Baseline/candidate comparisons use matching inputs and channels. Changed suites
  do not support raw-score regression claims.
- SKIP and UNVERIFIED remain evidence statuses, never binary PASS results.

**FAIL examples:** mock keyword success presented as behavior; simulated tool
calls presented as live runs; preservation PASS without a baseline; unchecked
final repairs; skipped required evidence or failed criteria hidden by a score.

A source contradiction may be repaired without claiming that baseline behavior
failed under higher-priority rules.

Review evidence and configuration only. To fill a behavior-evidence gap, report
it and request an authorized isolated run through the owning authoring/evaluation
workflow; do not execute the target workflow from this maintenance skill.

## B.11 — Host capability and source integrity

**PASS when the target:**

- Uses supported tool/model names or maps them to active-host capabilities, and
  discloses unavailable roles.
- Distinguishes upstream requirements, recommendations, local policy, and
  model/study findings without changing their scopes.
- Keeps reference paths, section names, and writer roles current.

**FAIL examples:** treating missing AskUserQuestion as headless operation;
claiming an unavailable advisor ran; requiring a model-specific default globally;
moving shared instructions exclusively into one host's rule files.

Ordinary text remains available for needed answers in interactive sessions.
Unanswered material choices block only dependent writes. A direct review is not
independent verification.

## Run completion and recursion

1. Run once for the selected target batch, with at most three repair iterations.
   Recheck affected criteria on final bytes. Self-maintenance belongs to the
   current run; do not invoke this skill recursively.
2. Missing required evidence blocks only the claims that need it. Keep optional
   or non-attributable evidence visibly SKIP/UNVERIFIED. Do not label an audit as
   full end-to-end behavior verification.
3. Phase 6 alone owns the successful maintenance-run timestamp. It records
   completion of the declared audit, not coverage of every integration. Do not
   update it while a required audit failure remains or the run is interrupted.

Session-derived behavior proposals follow [`change-bar.md`](change-bar.md) and
remain drafts until accepted. Missing evidence prevents evidence-motivated
rewrites; it does not invalidate a separate explicit user request to improve a
known instruction.
