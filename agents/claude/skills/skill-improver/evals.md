# Eval Criteria

Binary checks for `/autoresearch` reuse. A criterion fails when its expected outcome is violated; missing applicable evidence is UNVERIFIED, never PASS.

| ID | Scenario | Expected outcome |
| --- | --- | --- |
| 1 | `cargo` or validator launcher missing | Stop in Phase 0 with an actionable fix; no Phase 1+ work. |
| 2 | Description auto-fix | Diff preserves every original Korean trigger; only WHAT changes. |
| 3 | Fix introduces a regression | Revert the fix or discard its unapplied draft, reclassify as manual, and restore the prior result. |
| 4 | Three repair iterations exhausted | Stop, report unresolved failures and actual consultation availability. |
| 5 | Missing or invalid `group` | Report as manual and present the eight allowed slugs; never guess. |
| 6 | E-track proposal or a sample without attributable failures | Every proposal cites a session ID and rubric label; no failures means no E-track edit. Keep explicit user-directed authoring separate. |
| 7 | Session evidence collection and reporting | Use the collector, keep audit artifacts under mktemp `REPORT_DIR`, cite IDs plus paraphrases; no direct raw-history reads or digest quotes. |
| 8 | Waza invocation in skill definitions | Only `claude/skills/waza/scripts/waza-run.sh` contains direct Waza subcommands; skills call that launcher. Exclude `waza-install.md` when scanning documentation. |
| 9 | Model recommendation and execution | Recommend a workload profile with supported candidates and escalation conditions; respect user choices and distinguish advice from actual switching. Inheritance is a fallback, not proof of fit. |
| 10 | Waza regression guard | With `- Usable: yes` and a checked-in suite, a target about to receive a model-visible edit has a `--trials 3` baseline JSON before that edit and a `--trials 3 --baseline-json` rerun after it; only a `⚠️ **regression**` line that reproduces on one confirmation rerun reverts all of that iteration's model-visible fixes for the target and reclassifies them as manual. Launcher exit 1, a missing Result JSON, or `⚠️ incomparable` is UNVERIFIED; mock results are reference-only and never revert. Without Waza, a suite, or a model-visible edit, the guard is SKIP and no suite is scaffolded or edited. |
