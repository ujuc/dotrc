# Independent authoring-criteria review

Scope: generate-skills and skill-improver, their changed references, and the
exact A–D and self-maintenance inputs in both behavior-cases.md files.
Evidence: fresh-reader decision replay and source inspection; no live maintenance,
target-pipeline invocation, SDK/Waza run, project fixture write, or timestamp write.

## Decisions recorded before baseline inspection

| Case | Actual decision | Result |
| --- | --- | --- |
| A | Apply both already approved file updates without repeating permission. Resolve only genuinely new scope or applicable destructive-action authorization. | PASS |
| B | Record validator evidence as structure PASS and keyword echo as smoke only. Requested behavior remains UNVERIFIED. | PASS |
| C | Leave sibling/global cache, catalog and freshness dates untouched. Use normal interactive text for unresolved choices; dependent writes remain pending. Disclose absent advisor/delegation rather than claiming an independent review. | PASS |
| D | Retain the explicitly mandated project test gate. Model prompting guidance is a scoped default and cannot delete that policy. | PASS |
| Self-maintenance | Audit exactly the two selected skills once. Recheck fixes within the maximum three iterations; invoke neither controller recursively and do not broaden to a periodic sweep. Required failure prevents successful-run timestamp; optional missing integration is disclosed without behavior PASS. | PASS |

These are decisions, not actual file applications or live question delivery.

## Source and structural checks

- PASS: approval reuse agrees across authoring U2/U3, quality-criteria.md,
  improver quality-checks.md and change-bar.md; explicit authoring requests are
  distinguished from session-evidence proposals.
- PASS: authoring Step 0 cache/date scope and Registration agree with the new
  authority reference; project-local skills are excluded from the global catalog.
- PASS: explicit policy precedence, host capability fallback, evidence tiers and
  baseline honesty agree across the changed design/evaluation references.
- PASS: validator for generate-skills exited 0, all 14 reference paths resolve,
  metadata/group valid, body 487 lines (maximum 500).
- PASS: validator for skill-improver exited 0, all 3 reference paths resolve,
  metadata/group valid, body 401 lines (maximum 500).
- PASS: git diff --check exited 0.
- FAIL: skill-improver/SKILL.md, Advisor Escalation item 3 still says that after
  three iterations advisor decides whether to "keep auto-fixing". This contradicts
  the updated Phase 5 item 5, which stops repairs and prohibits another loop.
  Align this remaining cross-reference with the bounded termination rule.

Initial overall source-consistency status: FAIL pending that single correction.
The decision replay passed despite this residual internal conflict; no behavioral
FAIL-to-PASS result is inferred.

## Baseline comparison (read after recording decisions)

The unchanged baseline independently records the same correct A–D decisions.
Candidate text removes the documented per-file approval, incidental cache/date,
unscoped registration and aggressive-pruning tensions, and distinguishes evidence
tiers explicitly. This is a source-consistency improvement, not measured
FAIL-to-PASS behavior. The baseline contains no independent self-maintenance
execution; that case has candidate decision-replay evidence only.

## Focused re-review after correction

- PASS: Advisor Escalation item 3 now explicitly stops repairs and prohibits
  extending the loop, consistent with Phase 5 and the self-maintenance decision.
- PASS: improver EVAL 4 now asks for actual advisor availability and leaves
  unsuccessful runs undated rather than requiring an unavailable consultation.
- PASS: improver EVAL 7 explicitly scopes its question to E-track proposals and
  separates explicit user-directed authoring work, consistent with change-bar.md.
- PASS: authoring EVAL 6 now asks whether exact-input evidence supports the stated
  level, including source consistency, without requiring a fabricated baseline failure.
- PASS: git diff --check after the corrections exited 0.

Final source-consistency status: PASS. The sole reported defect is resolved.
Unaffected decision and structural checks were not repeated. The earlier
validator results remain the recorded structural evidence; final targeted text
changes were inspected directly. Live integration remains untested and is not
claimed as PASS.

## Final executor checks

On 2026-09-05, all three changed skills passed validate-skill on final bytes:
generate-agent-docs (333 body lines, 12 references), generate-skills (487,
14), and skill-improver (402, 3). git diff --check passed. All four argument-taking
script entry points returned help with exit 0 and clear missing-argument errors
with exit 2. The session collector self-check passed all 20 assertions; its
test runner also passed when invoked with --help (it runs tests, not a help UI).

The targeted maintenance batch covered generate-skills and skill-improver only.
Semantic source review and fixed-input decision replay passed after correcting
one contradictory loop-termination sentence. No full live Claude/Codex workflow
or live skill-improver evaluation suite was run. The baseline already produced
correct decisions; this is a source-consistency improvement, not a measured
behavioral FAIL-to-PASS transition. See authoring-criteria-baseline.md for inputs.
