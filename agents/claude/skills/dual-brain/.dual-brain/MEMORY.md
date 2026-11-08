# Project Memory

## Hot Memory

- [decision][refs:3][last_referenced:2026-11-07][last_verified:2026-11-07] Keep Dual-Brain capability-based: inherit selected models, overlap independent review, and reconcile dependent findings before delivery. Native delegation, local passes, and conversation-only review must reflect actual available tools. Evidence: SKILL.md and references/runtime.md.
- [decision][refs:1][last_referenced:2026-10-13][last_verified:2026-10-13] Right reviews macro design and cross-component behavior; Left checks micro contracts and failure paths. Verify affected final edits and resolve material findings before delivery. Evidence: SKILL.md.
- [constraint][refs:1][last_referenced:2026-11-07][last_verified:2026-11-07] A clean review is successful. No finding quota, speculative edits, or bookkeeping-only memory writes after unchanged repeated reviews; supported in-scope bugs still warrant fixes. Evidence: SKILL.md and benchmarks/VALIDATION.md.

## Warm Memory

- [decision][refs:1][last_referenced:2026-11-07][last_verified:2026-11-07] Generate PORTABLE.md from core/runtime/memory sources for instruction-capable hosts. Document native setup separately from manual import and actual runtime validation; do not assume Muse product identity or paths. Evidence: scripts/export_portable.py and references/platforms.md.
- [constraint][refs:2][last_referenced:2026-10-13][last_verified:2026-10-13] Report correctness, latency, and usage separately. Structural checks and smoke tasks do not establish cross-model performance; historical token totals were withdrawn. Evidence: benchmarks/RESULTS.md and benchmarks/README.md.
- [decision][refs:1][last_referenced:2026-10-13][last_verified:2026-10-13] Benchmark original tests remain intact; transcript wording and skill/test text cannot substitute for implementation evidence. Continuity tasks must not penalize explicit user overrides. Evidence: benchmarks/bench.py, benchmarks/evaluators/evaluate.py, and benchmark regression tests.

## Cold Memory

## Archived Decisions
