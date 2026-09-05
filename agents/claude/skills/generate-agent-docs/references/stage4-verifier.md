# Stage 4 — Evidence-Based Verification

The checklist verifier and blind reviewer are separate read-only roles.
Use SKILL.md's capability mapping; unavailable independent execution must be
reported. The orchestrator alone applies authorized fixes.

## Phase 1 — Checklist verifier

Dispatch in a fresh context, with these inputs:

```text
Read {skill_dir}/references/stage4-verifier.md and apply Phase 1.
Selected files and authorized changes: {targets_and_scope}
Original contents and final diff: {baseline_and_diff}
Confirmed facts with source locations: {facts}
User decisions and preserved team exceptions: {decisions}
Effective guidance, local policy, and source status: {guidance}
Final files and ordered writes: {artifacts}
Report only; do not edit files.
```

All placeholders must be resolved. Read actual target files and scoped source
evidence as necessary. A missing baseline, approval record or fact source is
UNVERIFIED for its dependent check, never assumed PASS.

### Checklist

1. **Scope and preservation**: only selected/authorized files changed;
   untouched text is byte-preserved; migrated shared clauses retain meaning
   and exceptions. Destructive changes require explicit authorization.
2. **Shared ownership and order**: shared supporting files and AGENTS.md exist
   before their importing CLAUDE.md. Shared rules remain accessible to both
   Claude and Codex. No shared rule is hidden exclusively in Claude rules.
3. **Claude layer**: root CLAUDE.md starts with @AGENTS.md and adds only
   Claude-specific content; import-only is valid. Apply the documented
   ancestor-only nested exception from stage3-generator.md, not a universal
   local import mandate.
4. **Evidence and necessity**: facts are grounded in supplied sources and
   decisions. Prune redundant summaries and linter defaults within authorized
   scope. Preserve explicit project requirements, nondefault conventions and
   concrete test gates. Report unrelated optional pruning separately.
5. **References**: imports resolve relative to the containing file; shared
   links and recommended existing skills resolve. Check intended path globs;
   no current match alone does not prove a future-path rule is invalid.
6. **Budgets**: apply claude-code-best-practices.md's local 100/200 combined
   targets and 50/100 nested targets, separately from the upstream per-file
   recommendation. Report measured counts and rationale for necessary excess;
   no silent deletion of requirements to achieve a number.
7. **Instruction scope and exceptions**: apply the scoped W/C/T reference
   defaults and preserved team decisions. Internal-reasoning extraction differs
   from explaining a decision. Team TDD and named test gates survive generic
   anti-scaffolding defaults. Do not infer approval from a rule's wording.
8. **Execution integrity**: effective live/cache guidance is the one actually
   used; no global skill/cache/date edits; managed ownership boundaries hold.
   Report unavailable roles and source fallbacks accurately.

### Report format

```text
VERIFICATION REPORT
PASS: count
FAIL: count
SKIP: count
UNVERIFIED: count
CHECK n — status — file:line — evidence — reason
FINAL: PASS | FAIL | PARTIAL
```

A required FAIL or UNVERIFIED prevents overall PASS. SKIP is only for an
inapplicable check or an explicitly permitted optional role, with a reason.
Do not count missing evidence as inapplicability.

## Phase 2 — Bounded repair

The orchestrator fixes only grounded findings within authorized scope.
A proposed repair requiring new files, policy changes or deletion outside
authorization returns to scope resolution. Preserve unrelated content.

Run the checklist at most three times (initial plus two repairs). If a required
FAIL/UNVERIFIED remains, consult an available advisor once if useful, then
report incomplete verification. Do not claim completion or start a fourth loop.
A checklist PASS proceeds to the selected blind review.

## Phase 3 — Blind reviewer

Run for outputs beyond a single root CLAUDE.md, unless the user explicitly
requests fast mode. Fast mode skips this optional role and yields PARTIAL
verification, even if the checklist passes. If independent delegation is
unavailable, likewise report SKIP and PARTIAL; self-review is not independence.

Provide only file names and final document contents, plus the following rubric.
Do not pass Stage 1/2 notes, user decisions or checklist results. Use a fresh
context rather than inheriting the writer's transcript.

```text
Review only properties visible in these documents:
- Shared/Claude-specific placement and duplicated clauses.
- Contradictions within the supplied documents.
- Import syntax, explicit path scope, clarity and measured line counts.
- Vague instructions or unfilled templates.

Report PASS/FAIL for observable findings with file:line and quotes.
Repository discoverability, file existence, approved team policy and historical
preservation cannot be established from these contents alone: mark any such
question UNVERIFIED and return it to the evidence checklist. Do not propose
deleting TDD, test gates or other possible team decisions from missing context.
Report only; do not edit.
```

An advisor, if available, receives the same blind inputs only. Never claim one
ran when unavailable. External-evidence questions do not fail a valid team
policy; the checklist owns resolving them.

## Final artifact check

Apply grounded blind fixes once, subject to the original scope. Check each
changed reference, role-placement rule, preserved clause and affected checklist
criterion against the resulting files. This is a bounded check of the final
patch, not another open-ended reviewer loop. Newly broken references or
unresolved required evidence block PASS.

Report actual paths, changes, source fallbacks, checklist status, blind status
and final-check result. Overall PASS requires all required checks and selected
roles to pass on the final bytes. A skipped optional blind role is PARTIAL;
persistent defects are FAIL/incomplete. Never describe either as fully verified.
