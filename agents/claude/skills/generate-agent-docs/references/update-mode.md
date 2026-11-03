# Update Mode: U1–U3

U1 follows Stage 1, U2 runs during Stage 2, U3 replaces Stage 3 for existing
files, and the Stage 4 roles follow all writes outside the short route. Any
existing file is a baseline, regardless of its author or origin.

## U1 — Audit selected targets

1. Keep the original contents of every selected existing file in the
   conversation for preservation checks, never as a copy on disk. Diff with
   `git diff` for tracked files, otherwise
   `diff -u <(printf '%s' "$original") path`. Record absent files and
   unresolved imports.
2. Inventory headings, sizes, imports (including `@AGENTS.md`) and supporting
   references. Inspect dependencies, AGENTS.md included, read-only even when
   unselected.
3. Detect a rule-bearing AGENTS.md that no CLAUDE.md imports, duplicate
   rules, stale facts with repository evidence, broken references, and
   pre-direct-read workarounds (a prose "read AGENTS.md" line or a SessionStart
   hook printing it; claude-code-best-practices.md AGENTS.md section). A
   `CLAUDE.local.md` with no CLAUDE.md or `.claude/CLAUDE.md` at or above the
   target stops Claude reading AGENTS.md: name that cause.
4. Present a compact table: path, exists/missing, role, proposed change,
   evidence. Unfamiliar structure is not proof of drift.

Never delete an exception or team
requirement merely because it is discoverable or exceeds a default budget.

## U2 — Compare and resolve scope

Compare current repository facts, applicable project instructions and user
decisions with the audit. Separate evidence-backed corrections from optional
pruning. Use the policy precedence and local budgets in
claude-code-best-practices.md, and the exceptions in model-prompting-guides.md,
context-engineering-claude5.md and tdd-agent-loop.md.

Report: path, original text, proposed text, reason, source, authorization
status. Check that:

- every new rule lands in CLAUDE.md, its supporting docs or `.claude/rules/`,
  never in AGENTS.md, and an existing `@AGENTS.md` import stays;
- links and nested imports resolve relative to their files;
- path-scoped rules use paths where relevant (a glob without current matches is
  a review observation, not proof a deliberate future rule is invalid).

Reuse explicit authorization already in the conversation: "apply all listed
edits" approves those exact edits once; do not ask per file. Ask only for a
material unresolved choice, newly expanded scope, a destructive operation, or
an explicit repository approval requirement, and resolve it before dependent
writes. Preserve unselected or unapproved content and report observations
separately.

Never create AGENTS.md or split CLAUDE.md. Folding an imported AGENTS.md into
CLAUDE.md is a proposal that needs approval, not an authorized edit.

Preserve existing team TDD, nondefault conventions, safety rules and test gates
unless the user requests their change. Prior explicit decisions count as
confirmation; do not force a fresh interview for the same decision.

## U3 — Apply authorized patches

Write in dependency order:

1. Selected contributing-docs/ files.
2. Selected root or nested CLAUDE.md files.
3. Selected .claude/rules/ files.

Edit surgically. For each patch, keep before/after content and authorized scope
in the conversation, not in a backup file. Preserve all unrelated bytes. If a needed destination is outside explicit
scope, present that dependency before altering either file.

Create missing authorized files with Stage 3 rules; never regenerate existing
ones. Deletion requires explicit authorization. A fix suggested during review
has the same scope and preservation requirements as the original patch.

## Short route

Use it when the user supplies the facts and CLAUDE.md exists; otherwise take
the normal path. Stage 0 still runs. Facts land in CLAUDE.md, even when it
imports `@AGENTS.md`.

1. Run U1 steps 1 and 3 on the owning files only.
2. Place each fact:

   | Fact | Destination |
   | --- | --- |
   | Project rule | CLAUDE.md, or an existing `.claude/rules/` file when path-scoped |
   | Personal | No write, not even a new `CLAUDE.local.md` or `.gitignore` entry; name `~/.claude/CLAUDE.md`, or `CLAUDE.local.md` when a CLAUDE.md exists |
   | From session corrections: one-off or discoverable | Drop and say why |
   | Dictated with "add this" | Keep under policy precedence, in the owner above or a restricted file (`CLAUDE.md만`); only a named file overrides Personal |

3. Run U2 and U3 on the placed facts only: add no other line the user did
   not supply, and report U1 findings without patching them. Then run stage4-verifier.md's
   final artifact check. Report PARTIAL.
