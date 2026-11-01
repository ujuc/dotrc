---
source_url: https://martinfowler.com/articles/exploring-gen-ai/tdd-in-the-agent-loop.html
last_upstream_check: 2026-11-01
check_interval_days: 90  # a published article, not a living doc page — same long gate as context-engineering-claude5.md
---

# TDD in the Agent Loop — Testing-Instruction Constraint

## Scope and precedence

The cached findings below are model- or study-specific evidence, not universal
rules for every harness. Apply them as local authoring defaults after explicit
user/repository requirements. Preserve confirmed team TDD, nondefault conventions,
concrete test commands and safety boundaries. Prior explicit decisions suffice;
no repeated interview is required. Missing evidence in a blind review never
licenses removing a team policy. Project-doc runs do not modify this cache or
its date; use native fetch equivalents under SKILL.md's Host capabilities.

T1 governs generated project docs, never this skill's own prose: Stage 3 writes
by it, Stage 4 rejects by it, update mode flags existing docs against it.

**Freshness**: re-fetch `source_url` only when `today - last_upstream_check >
check_interval_days` (`ToolSearch` `select:WebFetch` first — deferred tool).
On any fetch failure use this snapshot and say so in one line:
*"tdd-agent-loop 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

## Cached snapshot (last verified 2026-11-01)

Birgitta Böckeler's evaluation (martinfowler.com, *exploring-gen-ai* series)
found that mandating TDD inside an agent's autonomous loop produced no
measurable quality gain — Opus-judged rankings favored non-TDD runs, mutation
scores showed no meaningful difference — at *"at least 3x the tokens"* (small
8.50x, medium 2.96x, large 4.89x; many are cache hits, so *"how many times
exactly is variable"*). A TDD run ranked first only after she *"strengthened the
TDD prompt with a more explicit refactor-and-design-review step"*. She stopped
telling agents to write tests first until evals or other strong arguments
convince her otherwise.

### T1 — Agent-directed TDD process mandates: reject by default, rewrite as outcome verification

TDD's goals do not transfer into a fully-agentic loop:

- **Test-first does not prevent tautology**: agent *"tests checked the
  implementation's output against itself, re-running the same code to produce
  the 'expected' answer."*
- **Red proves nothing unattended**: *"Watching a test go red is only proof
  of anything if someone is checking why it went red."*
- **Design quality favored non-TDD**: TDD runs let design emerge test-by-test
  and rarely revisited it; non-TDD and test-first runs always designed fully
  before any code.

**Applies to**: any candidate line that prescribes a development *process* to
the agent's own loop, such as "develop with TDD", "write a failing test first",
"follow red-green-refactor". Reject by default and rewrite toward the outcome
the team wants verified (the article's own recommendations):

- the concrete test command whose passing is the done criterion;
- a mutation-score bar for regression quality, not a workflow;
- agent access to static code analysis;
- trend metrics (files touched and tokens per change) and regular reviews of
  structure and modularity;
- the Approved Scenarios approach, semi-manual testing with a bespoke test
  runner per application, for confidence building.

The rewrite must not violate W1: never rewrite a TDD mandate into
self-verification scaffolding. A concrete required test gate stays documented;
a hook may be recommended without removing the team requirement.

## Reconciliation — testing lines that survive T1

T1 targets the **fully-agentic** loop. Test: does the line prescribe *how the
agent must sequence its work* (process — reject) or *what must be true of the
result* (outcome — keep)?

| Line shape | Verdict |
| --- | --- |
| **Human-writes-tests split**: "implement against the existing failing tests in `tests/`; never modify test files" | Survives — the human checkpoint the article finds missing is present. |
| **Outcome requirement**: "every change lands with passing tests", "the CI gate is `make test`" | Survives. |
| **Explicit team decision confirmed in the Stage 2 interview** | Survives — record it as a human-written team rule (explicit user policy takes precedence over the study default). An explicit current or prior user decision is sufficient; never infer approval from code or force a repeated interview. If the team's TDD procedure is multi-step, C2 still applies — recommend a skill plus one reference line, not an inline runbook. |
| **Test-quality monitoring bar**: mutation-score threshold, files-per-change trend | Survives. |

## Update mode

U2 in update-mode.md preserves existing team TDD and prior explicit decisions.
When intent is materially unresolved, ask about the proposed change rather than
automatically removing the rule. Rewrite only when the user's authorization
covers it.
