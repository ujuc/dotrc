# Stage 4 — Evidence-Based Verification

The short route in update-mode.md runs only the final artifact check and
reports PARTIAL. Elsewhere the checklist verifier and blind reviewer are separate
read-only roles. Use
SKILL.md's Host capabilities; unavailable independent execution must be
reported. The orchestrator alone applies authorized fixes.

## Phase 1 — Checklist verifier

Dispatch `references/roles/verifier.md` as read-only `Explore` at Advanced
routing, in a fresh context: "Read `<abs>/references/roles/verifier.md` first
and follow it." followed by the six inputs that file lists, every placeholder
resolved. A missing baseline, approval record or fact source makes its
dependent check UNVERIFIED, never PASS.

The role owns the ten-item checklist and the `VERIFICATION REPORT` format. A
required FAIL or UNVERIFIED prevents overall PASS; SKIP is only for an
inapplicable check or an explicitly permitted optional role, with a reason.

## Phase 2 — Bounded repair

Fix only grounded findings within authorized scope. A repair requiring new
files, policy changes or deletion outside authorization returns to scope
resolution. Preserve unrelated content.

Run the checklist at most three times (initial plus two repairs). If a required
FAIL/UNVERIFIED remains, consult an available advisor once if useful, then
report incomplete verification; do not claim completion or start a fourth loop.
A checklist PASS proceeds to the selected blind review.

## Phase 3 — Blind reviewer

Run for outputs beyond a single root CLAUDE.md, unless the user explicitly
requests fast mode. Fast mode or unavailable independent delegation skips this
optional role: report SKIP and PARTIAL, even if the checklist passes.
Self-review is not independence.

Dispatch `references/roles/blind-reviewer.md` as read-only `Explore` at
Standard routing, in a fresh context: "Read
`<abs>/references/roles/blind-reviewer.md` first and follow it." plus only file
names and final document contents — no Stage 1/2 notes, user decisions,
checklist results or the writer's transcript.

Only a fresh-context role given these documents alone counts as blind review.
The Claude `advisor` tool forwards the whole transcript, so it never does. Never
claim a review ran when unavailable. External-evidence questions do not fail a valid team
policy; the checklist resolves them.

## Final artifact check

Apply grounded blind fixes once, within the original scope. Check each changed
reference, role-placement rule, preserved clause and affected checklist
criterion against the resulting files: a bounded check of the final patch, not
another reviewer loop. A file restriction is not a role-placement defect. Newly
broken references or unresolved required evidence
block PASS.

Report actual paths, changes, source fallbacks, checklist status, blind status
and final-check result. Overall PASS requires all required checks and selected
roles to pass on the final bytes. Persistent defects are FAIL/incomplete. Never
describe PARTIAL or FAIL/incomplete as fully verified.
