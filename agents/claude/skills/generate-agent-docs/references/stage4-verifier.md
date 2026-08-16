# Stage 4 Verifier — Reference

This document defines the full verification pipeline for Stage 4: Checklist Verification, Iterative Fix Loop, and Blind Reviewer.

---

## Phase 1 — Checklist Verification

### Agent Definition

- `subagent_type`: `general-purpose`
- `model`: sonnet
- `run_in_background`: false

### Dispatch Prompt Template

`{skill_dir}` = this skill's absolute directory. Fill every placeholder
before dispatching.

```
You are verifying generated documentation files against a fixed checklist.
You did not write these files.

1. Read {skill_dir}/references/stage4-verifier.md. Apply its "Verification
   Checklist", "Anti-Pattern Detection", and "Self-Test Questions" sections
   line by line to every file below.
2. Files to verify: {list_of_generated_file_paths}
3. This is an update-mode run: {yes/no}. If yes, also apply the "Update Mode
   Additional Checks" section.

Return the VERIFICATION REPORT in the exact Output Format defined in that
file. Do NOT fix anything — report only.
```

### Verification Checklist

Apply line by line to every generated/modified file:

1. **Universality / Necessity / Redundancy (prune test)**: Apply the authoritative prune test (claude-code-best-practices.md) — *"Would removing this cause Claude to make mistakes?"* If not, cut it. Also: does it apply to all tasks? Is it obvious from reading the code? → If it fails the prune test, delete or move to AGENTS.md / contributing-docs/
2. **Linter role**: Is this a code style rule? → Delete and recommend replacing with a linter or hook
3. **Speculation exclusion**: Does it include anything not confirmed in Stage 1–2? → If so, delete
4. **Verifiability**: Can compliance with each instruction be verified? → If not, make it concrete
5. **Size constraints**: CLAUDE.md + imported AGENTS.md **combined** under 100 lines soft / **200 hard** (official ceiling, claude-code-best-practices.md)? Nested CLAUDE.md under 50 lines (hard limit 100)? Individual instructions under 50 items? → If exceeded, consolidate, delete, or split into `.claude/rules/`
6. **Hierarchy / Role split**: Does CLAUDE.md start with the `@AGENTS.md` import instead of restating project content? Does CLAUDE.md carry project-general content that belongs in AGENTS.md (fails the Claude-only test)? Does AGENTS.md contain harness-specific content (Claude-only tools, hooks, skills, plan mode) or YAML frontmatter? Does CLAUDE.md reference contributing-docs/ directly (should go via AGENTS.md)? Does a nested CLAUDE.md cover content outside its directory or repeat parent content? Do rules/ files duplicate CLAUDE.md content, use legacy `globs`/`alwaysApply` frontmatter instead of `paths`, or overlap in role with contributing-docs/? Can unconditional rules (no `paths`) be moved to CLAUDE.md? → If any, move/delete/migrate or replace with parent reference
7. **Reference integrity**: Are relative paths in nested CLAUDE.md valid? → Verify relative paths
8. **Discoverability**: Can an agent learn this by reading the code? → If yes, delete
9. **Staleness risk**: Does the line reference specific versions, tool names, or dependencies that may become inaccurate within 6 months? → If risky, delete or add expiry comment
10. **Scope statement**: Is this an unconditional instruction that applies identically to all task types? → If it can be made conditional, add explicit conditions. Check the reverse too (model-prompting-guides.md W3): does the line leave its scope *implied*? Current models do not generalize an instruction from one item to another, so an unstated scope silently narrows — name the paths/directories/file types, or move the rule into `.claude/rules/` with `paths`
11. **Instruction-authoring anti-patterns** (model-prompting-guides.md W1/W2/W5): does any line (a) instruct self-verification or re-checking — "double-check", "re-verify before responding", "add a final verification step", "use a subagent to verify"; (b) command reasoning visibility in either direction — "explain your reasoning in the response", "do not think"; or (c) set a confidence/severity filter bar — "only report high-severity", "be conservative", "don't nitpick"? → Delete. (a) causes over-verification at no quality gain, (b) risks `reasoning_extraction` refusals or internal-tag leakage, (c) suppresses real findings. A genuine must-run gate becomes a hook, not a documented line

12. **Context-engineering constraints** (context-engineering-claude5.md C1–C4): does any line (a) forbid a behavior outright where the right answer depends on the surrounding code, without qualifying under the Reconciliation test as a regression guard, a safety boundary, or a "don't" with no nameable alternative (C1); (b) spell out a multi-step procedure needed only sometimes — a release runbook, migration steps, a verification sequence — instead of pointing at a skill (C2); (c) tell anyone to record notes, decisions, session logs, or learnings into the file, or otherwise prescribe maintaining it as a memory store (C3); or (d) paraphrase a spec that already exists in executable form — a test, a function, a mockup, a rubric — instead of referencing that file (C4)? → (a) rewrite to name the observable signal the agent should match; (b) recommend a skill and keep one reference line; (c) delete — auto-memory owns that content; (d) replace the paraphrase with the reference

13. **Testing-instruction constraint** (tdd-agent-loop.md T1): does any line prescribe a TDD / test-first / red-green-refactor process to the agent's own development loop, without qualifying under that file's Reconciliation as a human-writes-tests split, an outcome requirement, an explicit team decision confirmed in Stage 2, or a test-quality monitoring bar? → Rewrite as outcome-based verification (named test command as the done criterion, mutation-score bar, static analysis) — never into self-verification scaffolding (W1)

### Anti-Pattern Detection

Warn the user when any of the following are detected:

- **Over-specified CLAUDE.md** (primary anti-pattern, claude-code-best-practices.md): the file is long enough that real rules get lost in the noise and adherence drops. Fix: ruthlessly prune, or convert a must-run rule to a hook
- **Auto-generated content**: LLM-summarized content of the codebase is included verbatim
- **Information duplication**: Content already present in README, CONTRIBUTING.md, or CI configuration is repeated
- **Stale content**: Technologies, dependencies, or patterns are described that do not match the current codebase

### Self-Test Questions

Four questions the per-line checklist cannot ask, because each spans files or
looks outside the documentation:

- "Would a Codex or Amp session, which reads only AGENTS.md (+ contributing-docs/), miss anything it needs to work safely in this repo?" → If yes, the missing content is misplaced in a Claude-only file
- "Would root CLAUDE.md alone be sufficient for work in a nested directory, making the nested file removable?" → If sufficient, recommend deleting the nested file
- "Do any nested CLAUDE.md files contradict each other?"
- "Can this item be solved by code / linter / CI instead?" → If yes, recommend fixing it there and removing the item

### Output Format

Return a structured report:

```
VERIFICATION REPORT
===================
PASS items: [count]
FAIL items: [count]
WARNINGS: [count]

FAIL — [Checklist item number]: [Specific line quoted] — [Reason]
WARNING — [Anti-pattern name]: [Location] — [Description]
```

---

## Phase 2 — Iterative Fix Loop

**Maximum 3 verification runs total** — the initial run plus up to 2 fix
rounds (matches SKILL.md Stage 4 and advisor gate ③). Any run with zero FAIL
items ends the loop and proceeds to Phase 3.

### Fix Rules

- **Orchestrator applies fixes**, not the Verifier agent
- Address only specific FAIL items from the Verification Report
- Do not introduce new content; only remove or restructure existing content
- Track which FAIL items have been resolved across iterations
- After iteration 3: if FAIL items remain, call advisor once, then surface them to the user with explanation and proceed

---

## Phase 3 — Blind Reviewer

### Trigger

Spawn the Blind Reviewer when output includes more than a single root CLAUDE.md (i.e., AGENTS.md, contributing-docs/, or nested CLAUDE.md files are included).

### Skip Conditions

- Generated output is a single root CLAUDE.md only
- User explicitly requested fast generation

### Agent Definition

- `subagent_type`: `general-purpose`
- `model`: sonnet
- advisor: the Reviewer calls `advisor()` (opus per settings `advisorModel`) for any criterion it cannot confidently score — a cross-model second opinion. advisor forwards only the reviewer's transcript (the generated files), so the review stays blind.
- `run_in_background`: false (orchestrator must receive results before final report)

### What to Provide

Generated file contents **only**.

### What NOT to Provide

- Stage 1 or Stage 2 analysis results
- User interview answers
- Orchestrator reasoning or internal notes
- Verifier results from Phase 1/2

Providing only the generated files ensures the Reviewer evaluates independently without context bias.

### Reviewer Prompt

```
You are reviewing generated CLAUDE.md and related files. You did NOT write these.
Review independently using these criteria:

Files to review: {list_of_generated_file_paths}

1. Discoverability: Does each line pass the test "Can an agent learn this by reading the code?" If yes → flag for removal
2. Staleness risk: Does any line reference specific versions, tool names, or dependencies that may become inaccurate within 6 months? → flag with reason
3. Redundancy: Is any content duplicated between CLAUDE.md, AGENTS.md, and contributing-docs/? (CLAUDE.md imports AGENTS.md via `@AGENTS.md` — restating imported content is duplication) → flag the duplicate
4. Hierarchy / role split: Does CLAUDE.md start with `@AGENTS.md` and contain only Claude Code-specific content below it (hooks, skills, subagents, plan mode)? Is AGENTS.md harness-neutral (no Claude-only tools/features, no YAML frontmatter)? Does CLAUDE.md reference contributing-docs/ directly (should go through AGENTS.md)? Do .claude/rules/ files use `paths` frontmatter (not legacy `globs`/`alwaysApply`)? → flag
5. Nested CLAUDE.md: Does any nested file repeat content from root CLAUDE.md? Does scope exceed its directory? → flag
6. Size: Are CLAUDE.md + imported AGENTS.md combined under 100 lines soft / 200 hard (official ceiling)? Nested under 50 (hard limit 100)? Flag any line that fails the prune test ("would removing this cause a mistake?")
7. Actionability: Is every instruction verifiable? Any vague guidance? → flag with suggestion
8. Instruction-authoring: Does any line tell its reader to verify or double-check its own work, to show or to suppress its reasoning, or to filter findings by severity or confidence? Does any rule leave its scope implied rather than naming the paths or file types it covers? → flag for removal or for an explicit scope

9. Context engineering: Does any line forbid a behavior outright where the surrounding code already answers the question, and is not a regression guard or a safety boundary? Does any line spell out a procedure needed only sometimes instead of pointing at a skill? Does any line tell a reader to record notes, decisions, or session logs into the file? Does any line paraphrase a spec that exists in executable form elsewhere? → flag with the replacement

10. Testing instructions: Does any line mandate TDD, test-first, or red-green-refactor for the agent's own workflow, rather than stating an outcome (a named test command that must pass, a mutation-score or coverage bar) or splitting roles (human-written tests the agent implements against)? → flag with the outcome-based replacement

For any criterion where your PASS/FAIL call is low-confidence, call advisor() for an independent opus second opinion before finalizing.

Report: PASS/FAIL per criterion. For each FAIL, quote the specific line and explain why.
Do NOT fix issues — only report them.
```

### After Reviewer

The orchestrator applies the Reviewer's grounded FAIL fixes once before producing the final output. The Reviewer's own low-confidence advisor call is the blind second opinion; do not create another reviewer loop.

---

## Update Mode Additional Checks

When running in update mode, apply these checks in addition to the common checklist:

- Were any lines that should not have changed modified unintentionally?
- Are all reference paths still valid after the modification?
- Is cross-file consistency maintained? (Re-verify U2 axis 3)
