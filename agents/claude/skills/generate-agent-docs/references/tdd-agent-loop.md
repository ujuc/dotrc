---
source_url: https://martinfowler.com/articles/exploring-gen-ai/tdd-in-the-agent-loop.html
last_upstream_check: 2026-08-14
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
its date; use native fetch equivalents under SKILL.md's capability mapping.

Birgitta Böckeler's evaluation (martinfowler.com, *exploring-gen-ai* series)
found that mandating TDD inside an agent's autonomous loop produced no
measurable quality gain — Opus-judged rankings favored non-TDD runs, mutation
scores showed no meaningful difference — at *"at least 3x the tokens"*
(*"Small: 8.50x, Medium: 2.96x, Large: 4.89x"*). Her conclusion: *"I
personally have stopped telling my coding agents to write tests first, let
alone do TDD."* This file carries the one rule that changes what the skill
emits: **T1**.

Consumers: stage3-generator.md (writing), stage4-verifier.md (rejecting),
update-mode.md (flagging existing docs). T1 behaves like
model-prompting-guides.md's `[W]` rules and context-engineering-claude5.md's
`C` rules — it governs generated project docs, never this skill's own prose.

**Freshness**: re-fetch `source_url` only when `today - last_upstream_check >
check_interval_days` (`ToolSearch` `select:WebFetch` first — deferred tool).
On any fetch failure use this snapshot and say so in one line:
*"tdd-agent-loop 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

---

## Cached snapshot (last verified 2026-08-14)

### T1 — Agent-directed TDD process mandates: reject by default, rewrite as outcome verification

Why the TDD goals do not transfer into a fully-agentic loop:

- **Test-first does not prevent tautology**: even writing tests first, agent
  *"tests checked the implementation's output against itself, re-running the
  same code to produce the 'expected' answer."*
- **Red proves nothing unattended**: *"Watching a test go red is only proof
  of anything if someone is checking why it went red."* And without that:
  *"Without a human checkpoint between the two, is there really any purpose
  left to writing the test first?"*
- **Design quality favored non-TDD**: *"the non-TDD and test-first runs
  always created the full design (architecture, data types, edge cases,
  contracts) before writing any code"* — TDD runs let design emerge
  test-by-test and rarely revisited it.

**Applies to**: any candidate line that prescribes a development *process* to
the agent's own loop — "develop with TDD", "write a failing test first",
"follow red-green-refactor", "always test-first". Reject by default and
rewrite toward the outcome the team actually wants verified.

**Rewrite targets** (the article's own recommendations):

- Name the concrete test command whose passing is the done criterion
  (Build & Test Gotchas material)
- *"monitor and improve regression quality with the help of mutation
  testing"* — a mutation-score bar, not a workflow
- *"Give the agent access to static code analysis"*
- Trend metrics: *"keep an eye on the trend of number of files touched per
  change"*
- The *"Approved Scenarios approach ... a form of semi-manual testing
  supported by a bespoke test runner"* for confidence building

The rewrite must not itself violate W1: never rewrite a TDD mandate into
self-verification scaffolding ("add a final verification step", "use a
subagent to verify"). A concrete required test gate stays documented; a hook
may be recommended without removing the team requirement.

---

## Reconciliation — testing lines that survive T1

The evidence above targets the **fully-agentic** loop. Four line shapes fall
outside it and survive:

| Line shape | Verdict |
| --- | --- |
| **Human-writes-tests split**: "implement against the existing failing tests in `tests/`; never modify test files" | Survives — the human checkpoint the article finds missing is present here; the failure evidence does not reach this mode. |
| **Outcome requirement**: "every change lands with passing tests", "the CI gate is `make test`" | Survives — states what must be true of the result, not how the agent sequences its work. |
| **Explicit team decision confirmed in the Stage 2 interview** | Survives — record it as a human-written team rule (explicit user policy takes precedence over the study default). An explicit current or prior user decision is sufficient; never infer approval from code or force a repeated interview. If the team's TDD procedure is multi-step, C2 still applies — recommend a skill plus one reference line, not an inline runbook. |
| **Test-quality monitoring bar**: mutation-score threshold, files-per-change trend | Survives — this is the article's own recommendation. |

Test to apply: does the line prescribe *how the agent must sequence its work*
(process — reject) or *what must be true of the result* (outcome — keep)?

---

## Update mode

U2 in update-mode.md preserves existing team TDD and prior explicit decisions.
When intent is materially unresolved, ask about the proposed change rather than
automatically removing the rule. Rewrite only when the user's authorization
covers it. Missing interview evidence in a blind review is not a rejection of
the team's policy.

---

## Already owned elsewhere — do not duplicate

| Article point | Owner in this skill |
| --- | --- |
| Preserve team gates; recommend automation | claude-code-best-practices.md / stage3-generator.md Common Writing Rules |
| No self-verification scaffolding in docs | model-prompting-guides.md W1 |
| Multi-step procedure becomes a skill + one reference line | context-engineering-claude5.md C2 |
