# Update Mode: U1–U3

U1 follows Stage 1, U2 runs during Stage 2, U3 replaces Stage 3 for existing
files, and stage4-verifier.md follows all writes. Any existing file is a
baseline, regardless of its author or origin.

## U1 — Audit selected targets

1. Keep the original contents of every selected existing file in the
   conversation for preservation checks, never as a copy on disk. Diff with
   `git diff` for tracked files, otherwise
   `diff -u <(printf '%s' "$original") path`. Record absent files and
   unresolved imports.
2. Inventory headings, sizes, shared vs Claude-only content, imports and
   supporting references. Inspect dependencies read-only even when unselected.
3. Detect shared instructions in CLAUDE.md that belong in AGENTS.md, duplicate
   rules, stale facts with repository evidence, broken references, and
   pre-direct-read workarounds (a prose "read AGENTS.md" line or a SessionStart
   hook printing it; claude-code-best-practices.md AGENTS.md section).
4. Present a compact table: path, exists/missing, shared/Claude-only role,
   proposed change, evidence. Unfamiliar structure is not proof of drift.

For paired migration, keep the exact original shared rules until AGENTS.md
holds them with equivalent meaning. Never delete an exception or team
requirement merely because it is discoverable or exceeds a default budget.

## U2 — Compare and resolve scope

Compare current repository facts, applicable project instructions and user
decisions with the audit. Separate evidence-backed corrections from optional
pruning. Use the policy precedence and local budgets in
claude-code-best-practices.md, and the exceptions in model-prompting-guides.md,
context-engineering-claude5.md and tdd-agent-loop.md.

Report: path, original text, proposed text, reason, source, authorization
status. Check that:

- shared content stays in AGENTS.md or its shared references;
- CLAUDE.md imports the actual AGENTS.md and adds only Claude-specific content;
- shared links and nested imports resolve relative to their files;
- Claude-only rules use paths where relevant (a glob without current matches is
  a review observation, not proof a deliberate future rule is invalid).

Reuse explicit authorization already in the conversation: "apply all listed
edits" approves those exact edits once; do not ask per file. Ask only for a
material unresolved choice, newly expanded scope, a destructive operation, or
an explicit repository approval requirement, and resolve it before dependent
writes. Preserve unselected or unapproved content and report observations
separately.

A CLAUDE.md-only restriction with no AGENTS.md is a prerequisite conflict.
Resolve it before writing; do not silently create the companion or substitute a
standalone shared document. Already approved paired setup needs no new question.

Preserve existing team TDD, nondefault conventions, safety rules and test gates
unless the user requests their change. Prior explicit decisions count as
confirmation; do not force a fresh interview for the same decision.

## U3 — Apply authorized patches

Write in dependency order:

1. Selected shared contributing-docs/ files.
2. Selected root or nested AGENTS.md files.
3. Selected CLAUDE.md files importing them.
4. Selected Claude-specific .claude/rules/ files.

Edit surgically. For each patch, keep before/after content and authorized scope
in the conversation, not in a backup file. Move shared clauses into AGENTS.md
before replacing their CLAUDE.md origin with the import; preserve all unrelated
bytes. If a needed destination is outside explicit scope, present that
dependency before altering either file.

Create missing authorized files with Stage 3 rules; never regenerate existing
ones. Deletion requires explicit authorization. A fix suggested during review
has the same scope and preservation requirements as the original patch.
