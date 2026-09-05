# Instruction Quality Checks

These semantic audits supplement structure validation. They do not authorize
rewriting a workflow. Report core design changes through the existing manual
track; user-requested changes already approved in this session need no repeated
acceptance, and remain owned by the active authoring/execution workflow.

## B.9 — Authority and write scope

PASS when the target reuses existing approval, honors explicit user/repository
requirements over optimization defaults, resolves targets/dependencies before
writing and states the owner of side effects. Check source references as well as
the body for contradictory cache/date writes or new per-file approval gates.

FAIL examples: requiring approval again for the same exact approved patch;
changing a sibling/global cache during an unrelated project task; removing a
named team test gate under generic pruning; converting an upstream recommendation
into an unlabeled local hard limit. An actually new scope or destructive action
still follows applicable approval requirements. Quote that requirement and why
existing authorization is insufficient when a user decision is needed.

## B.10 — Verification evidence contract

PASS when expected claims have sufficient inputs and evidence levels are explicit:
structure/schema, fixed-input decision replay, actual artifact application, or
live integration. Inspect the target's evaluator prompts and checked-in suites.
The original contents/diff, facts, decisions, scope and effective guidance must
reach any verifier that judges preservation or confirmation. Blind reviewers
must not guess inaccessible facts or remove policy because approval is unseen.

FAIL examples: mock keyword success presented as behavior; simulated tool calls
presented as live runs; missing baseline treated as preservation PASS; final
repair not checked; skipped required evidence or a failed criterion hidden by a
score. SKIP/UNVERIFIED are evidence statuses, not binary PASS results. Compare
baseline/candidate only with matching inputs and channels; changed suites cannot
support a raw-score regression claim. A source contradiction can be repaired
without falsely claiming baseline behavior failed under higher-priority rules.

Review evidence and configuration only in this maintenance skill. Do not execute
the target workflow to fill a gap; request an authorized isolated behavior run
through the owning authoring/evaluation workflow and report the current gap.

## B.11 — Host capability and source integrity

PASS when tool/model names are supported or mapped to active-host capabilities,
unavailable roles are disclosed, and upstream requirements, recommendations,
local policy and model/study findings retain distinct scopes. Check references
for stale section names and changed writer roles, not just existing file paths.

FAIL examples: assuming AskUserQuestion absence means headless; claiming advisor
ran when unavailable; globally requiring a model-specific default; moving a shared
instruction exclusively into one host's rule files. Ordinary text can obtain a
needed answer in interactive sessions; unanswered material choices block only
dependent writes. A direct review is not independent verification.

## Run completion and recursion

Run once for the selected target batch. Preserve the existing three-iteration
limit for repairs and recheck affected criteria on final bytes. When this skill
is itself a target, do not invoke it recursively: the current run owns those
checks. Missing required evidence blocks only the claims that require it; optional
or non-attributable evidence stays visibly SKIP/UNVERIFIED. Never label an audit
as full end-to-end behavior verification.

The successful maintenance-run timestamp is owned solely by Phase 6. It records
that the declared audit completed, not that every possible integration was tested.
Do not update it while a required audit failure remains or a run is interrupted.
Session-derived behavior proposals still follow change-bar.md and remain drafts
until accepted. No evidence means no evidence-motivated rewrite; it does not
invalidate a separate explicit user request to improve a known instruction.
