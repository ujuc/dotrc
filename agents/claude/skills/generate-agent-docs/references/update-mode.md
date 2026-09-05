# Update Mode: U1–U3

U1 follows Stage 1, U2 runs during Stage 2, and U3 replaces Stage 3 for
existing files. Missing selected files use the generation rules. Stage 4 follows
all writes. An existing file is a baseline regardless of its author or origin.

## U1 — Audit selected targets

1. Retain original contents of every selected existing file for preservation
   checks. Record absent files and unresolved import dependencies.
2. Inventory section headings, sizes, shared/Claude-only content, imports and
   supporting references. Inspect dependencies read-only even when unselected.
3. Detect shared instructions in CLAUDE.md that belong in AGENTS.md, duplicate
   rules, stale facts supported by repository evidence, and broken references.
4. Present a compact table: path, exists/missing, shared/Claude-only role, proposed
   change, evidence. Do not treat unfamiliar structure as proof of drift.
5. If no selected files exist, use creation rules when generation is already
   authorized. Resolve any material ambiguity before dependent writes.

For paired migration, retain the exact original shared rules until they are
present in AGENTS.md with equivalent meaning. Do not delete an exception or
team requirement merely because it is discoverable or exceeds a default budget.

## U2 — Compare and resolve scope

Compare current repository facts, applicable project instructions and user
decisions with the audit. Separate evidence-backed corrections from optional
pruning. Use the policy precedence and local budgets in
claude-code-best-practices.md, and the exceptions in model-prompting-guides.md,
context-engineering-claude5.md and tdd-agent-loop.md.

Report: path, original text, proposed text, reason, source, and authorization
status. Check these relationships:

- Shared content remains in AGENTS.md or its shared references.
- CLAUDE.md imports the actual AGENTS.md and adds only Claude-specific content.
- Shared supporting links and nested imports resolve relative to their files.
- Claude-only rules use paths where relevant; a glob without current matches is
  a review observation, not proof that a deliberate future rule is invalid.

Reuse explicit authorization already present in the conversation. A user's
"apply all listed edits" approves those exact edits once; do not ask per file.
Ask only for a material unresolved choice, newly expanded scope, a destructive
operation, or an explicit repository approval requirement. Preserve unselected
or unapproved content and report observations separately.

A CLAUDE.md-only restriction with no AGENTS.md is a prerequisite conflict.
Resolve it before writing; do not silently create the companion or substitute a
standalone shared document. Already approved paired setup needs no new question.

Existing team TDD, nondefault conventions, safety rules, and test gates are
preserved unless the user requests their change. Prior explicit decisions count
as confirmation; do not force a fresh interview for the same decision.

## U3 — Apply authorized patches

Write in dependency order:

1. Selected shared contributing-docs/ files.
2. Selected root or nested AGENTS.md files.
3. Selected CLAUDE.md files importing those shared instructions.
4. Selected Claude-specific .claude/rules/ files.

Use the active harness's editing tool for surgical changes. For each patch,
retain before/after content and authorized scope. Move shared clauses into
AGENTS.md before replacing their original CLAUDE.md location with the import;
preserve all unrelated bytes. If a needed destination is outside explicit
scope, present that dependency before altering either file.

Create missing authorized files with Stage 3 rules; do not regenerate existing
ones. Deletion requires explicit authorization. A fix suggested during review
has the same scope and preservation requirements as the original patch.

## Verification handoff

Pass original contents, final diff, selected targets, authorizations, confirmed
facts, team exceptions and effective guidance to the checklist verifier.
Keep the separate blind review limited to document-visible properties.
Follow stage4-verifier.md for bounded checks and final status.
