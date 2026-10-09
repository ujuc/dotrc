# Stage 4 — Evidence-Based Verification

The checklist verifier and blind reviewer are separate read-only roles
(`references/roles/verifier.md`, `references/roles/blind-reviewer.md`). Use
SKILL.md's capability mapping; unavailable independent execution must be
reported. The orchestrator alone applies authorized fixes.

## Phase 1 — Checklist verifier

Dispatch the verifier role (`references/roles/verifier.md`) as read-only
`Explore` at Advanced routing, in a fresh context, with the prompt "Read
`<abs>/references/roles/verifier.md` first and follow it." followed by the
six inputs that file lists. All placeholders must be resolved; a missing
baseline, approval record or fact source makes its dependent check
UNVERIFIED, never PASS.

The role owns the eight-item checklist and the `VERIFICATION REPORT` format.
A required FAIL or UNVERIFIED prevents overall PASS; SKIP is only for an
inapplicable check or an explicitly permitted optional role, with a reason.

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

Dispatch the blind-reviewer role (`references/roles/blind-reviewer.md`) as
read-only `Explore` at Standard routing, in a fresh context, with the prompt
"Read `<abs>/references/roles/blind-reviewer.md` first and follow it." plus
only file names and final document contents. Do not pass Stage 1/2 notes, user
decisions or checklist results, and never inherit the writer's transcript.

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
