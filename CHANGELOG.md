# Changelog

## v1.7.0 — Portable Review Without Forced Changes (2026-11-07)

- Adds an evidence-before-changes contract: clean reviews are successful, no finding quota, no speculative refactors, bounded investigation, and explicit stopping conditions.
- Separates defects from hypotheses/preferences and preserves requested redesign or optimization work within its acceptance criteria.
- Prevents reference-count-only writes and automatic housekeeping after unchanged repeated reviews.
- Adds documented setup routes for Codex, Claude Code, Grok, xAI Grok Bot, and generic Muse prompt use, with unverified native capabilities clearly distinguished.
- Adds a generated self-contained `PORTABLE.md` and stdlib exporter with a freshness check; native skills keep conditional reference loading.
- Makes missing tools/files/persistence explicit and removes the dated provider-specific model catalog from shared runtime guidance.
- Updates English and Korean documentation. Validation distinguishes portable behavior in the available harness from untested external product integrations.

## v1.6.0 — Macro/Micro Review and Final-State Verification (2026-10-13)

- Makes Right Brain's macro review of end-to-end goals, system boundaries, and architecture explicit; Left Brain checks concrete contracts, failure paths, and compatibility with evidence.
- Rechecks affected final changes and closes material findings as fixed, rejected with evidence, or unresolved. Earlier reviews do not certify later edits.
- Coordinates superseded writers before takeover and ties memory verification dates to the final saved claim.
- Bounds subprocess execution for partial output and closed streams, retains timeout logs, and cleans up POSIX process groups.
- Rejects failed/incomplete protocol output even with exit code zero, protects original fixture tests, and captures staged/new files in diffs.
- Excludes test and skill-resource text from implementation evidence; transcript keywords become diagnostic only.
- Corrects continuity scenarios that previously penalized explicit user overrides, and documents the resulting limits on historical scores.
- Adds regression coverage and a native two-reviewer behavioral validation; see benchmarks/VALIDATION.md for observations and limits.

## v1.5.0 — Adaptive Codex Workflow (2026-10-11)

- Replaces mandatory long personas and fixed sequencing with concise role briefs and dependency-aware review.
- Uses current runtime tool schemas, safe agent reuse, inherited model/effort, and an honest single-agent fallback.
- Splits optional runtime/model and memory guidance into references; preserves the tiered memory format.
- Respects read-only scope and explicit user overrides; bounds reference increments and removes mandatory post-save questions.
- Updates current Codex installation guidance and documents model-selection starting points without hardcoded routing.
- Adds an equal-memory benchmark control, exact skill snapshots, effort settings, and regression tests.
- Fixes token subset double-counting, missing-usage reporting, latency labels, and false passes after CLI failure. Withdraws historical token totals.
- Reports validation separately from unmeasured cross-model performance.

## v1.4.0 — Reusable Brain Agents

Dual-Brain now reuses active Right Brain and Left Brain sub-agents when the runtime exposes reusable agent handles, instead of blindly spawning fresh brains on every skill invocation.

- Adds **Step 0C — Sub-Agent Reuse Check** before the Right Brain pass.
- Reuses active Right/Left Brain agents inside the current conversation/runtime when available.
- Resumes closed-but-resumable brain agents when the platform supports it.
- Spawns fresh brain agents only when no usable handle exists or the platform does not expose reusable handles.
- Prevents unbounded nested Right/Left Brain sub-agent trees; only the orchestrator manages brain agents.
- Keeps runtime agent IDs, handles, and thread IDs out of `.dual-brain/MEMORY.md`; cross-session continuity still comes from project memory.

## v1.3.0 — Memory Tiering & Weighted Recall

Dual-Brain memory now uses weighted recall so old decisions do not consume the same attention as active project context.

- Adds Hot / Warm / Cold / Archived tiers for `.dual-brain/MEMORY.md`.
- Adds lightweight metadata: `refs`, `last_referenced`, and `last_verified`.
- Increments `refs` only when a memory item materially influences questioning, verification, synthesis, or implementation.
- Reads Hot memory first, Warm memory when request-relevant, and Cold/Archived memory only by targeted lookup.
- Auto-compacts memory by promoting active items, demoting stale low-reference items, archiving superseded decisions, and merging noisy duplicates.
- Migrates older untiered memory files into the tiered structure during the next memory auto-save.
- Updates benchmark fixtures and prompts to exercise the tiered memory contract.

## v1.2.0 — Persistent Project Memory

- Adds project-local memory intake from `.dual-brain/MEMORY.md`.
- Adds memory auto-save and auto-compaction for durable non-sensitive project context.
- Keeps sensitive content out of memory and reports only removed/redacted categories.
- Adds SkillsGate installation guidance for multi-agent and multi-project setups.
- Adds the benchmark harness and an early results snapshot.
