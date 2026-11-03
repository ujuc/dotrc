# Eval Criteria — generate-agent-docs

Evaluate six binary properties below. For a run that cannot establish a
property, record UNVERIFIED or an allowed SKIP rather than manufacturing a
binary answer. Overall PASS requires all applicable properties on final bytes;
fast, short-route or unavailable blind review yields PARTIAL, not fully verified
completion. `disable-model-invocation` stays unset on purpose; set it and rely
on `/generate-agent-docs` only if false triggers become a problem.

1. **Target routing and CLAUDE.md ownership**
   Pass: targets and dependencies are resolved before routing; every new rule
   lands in CLAUDE.md, a supporting doc or `.claude/rules/`; an existing
   `@AGENTS.md` import survives; existing files receive surgical edits; each
   rule has one source. Explicit file restrictions are respected.
   Fail: a broken import, a regenerated existing file, any AGENTS.md write, a
   dropped `@AGENTS.md` import, or an AGENTS.md rule copied into CLAUDE.md.

2. **Authorization and preservation**
   Pass: existing explicit approval is reused; original snapshots/diffs prove
   unrelated bytes and migrated meaning are preserved. New material scope or
   destructive changes receive required authorization.
   Fail: repeated per-file approval after an unchanged approved patch, scope
   expansion, unapproved deletion, or lost team exception.

3. **Grounded content and scoped policy**
   Pass: facts and decisions support retained rules; explicit team conventions,
   TDD and test gates survive generic defaults. Upstream per-file sizing,
   local combined budgets and model-specific findings are distinguished.
   Lines pass the prune test and stop-list; no-exception rules carry an
   enforcement recommendation.
   Fail: unsupported facts or policy deletion, or local defaults presented as
   universal official requirements. Budget excess is reported with rationale,
   not hidden by moving common requirements into Claude-only files. A stop-list
   line survives without a user decision.

4. **Reference and execution integrity**
   Pass: final imports/shared links resolve; intended future globs are evaluated
   using their confirmed scope; effective fetched/cached guidance is supplied
   downstream. Project-doc runs leave global skill files and dates unchanged.
   Fail: new broken references, fabricated fetch/role results, or incidental cache
   maintenance. Tool equivalents and fallback notices must match real actions.

5. **Verification evidence and final status**
   Pass: checklist receives originals/diffs, decisions, facts, scope and
   effective guidance; blind review sees documents only and evaluates only
   observable properties; final patches are checked. Required unresolved
   FAIL/UNVERIFIED prevents PASS; skipped blind review is PARTIAL.
   Fail: unsupported preservation/confirmation claims, blind deletion of an
   unobserved team exception, unchecked final patch, unbounded repair loop,
   or fully verified completion with failed/unavailable required checks.

6. **Trigger scope**
   Pass: README/API/CHANGELOG and skill-review requests do not launch generation;
   an audit with no change requested has an empty write set.
   Fail: unrelated document generation triggered by reviewing this skill.

Artifact tests and decision probes belong to the checked-in evaluation suite.
Mock keyword results are not evidence for any filesystem property.
