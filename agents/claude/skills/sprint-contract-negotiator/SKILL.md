---
name: sprint-contract-negotiator
description: Generator·Evaluator 역할을 파일 기반 프로토콜로 번갈아 수행해 done 기준을 협상하고 sprint contract를 만드는 스킬.
when_to_use: "sprint contract 협상, done 기준 정의, 완료 조건 합의, acceptance criteria 작성, sprint-contract-negotiator 호출 시. 구현 시작 전에 'done이 뭔지 먼저 정하자'·'이 sprint의 합격 기준을 잡아줘'·'평가자가 검증할 기준을 만들어줘' 같은 요청에 적합."
group: planning
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Sprint Contract Negotiator

Negotiate a definition of done between Generator and Evaluator agents through a file-based protocol. Inspired by Anthropic's harness-design pattern in which the Evaluator's specificity drives final quality.

## Purpose

Before any implementation begins, both agents must agree on what "done" looks like. This skill produces a `contract.md` that both sides reference for the rest of the sprint, and an audit trail of every accept/reject round. The contract prevents scope drift and forces every criterion to be externally testable.

## Inputs and Scope

**Input**: a high-level spec or user story. NOT a technical implementation plan.

**Out of scope**: unit-test design, code structure, library choices. The contract describes WHAT to verify, not HOW to build.

Example inputs:
- "Build a tile-based map editor with rectangle fill, entity placement, and animation preview"
- "Add user authentication with OAuth2 and role-based access control"

## Roles

This skill alternates the Generator and Evaluator roles in one orchestrator, writing and re-reading each turn from disk. It does not claim to dispatch two agents. The latest role file is the only source of truth.

**Generator** writes drafts. Each draft proposes:
- Sprint goal (one sentence)
- Implementation scope (feature list)
- Verification criteria table (testable from the outside)

**Evaluator** writes reviews. For every criterion in the latest draft it issues exactly one of:
- `ACCEPT` — the criterion is specific, observable, and unambiguous
- `REJECT` — with a concrete reason that names the missing element (subject, action, observable result, or verification method)

## Negotiation Protocol

### File exchange

All files live under a caller-supplied `{workspace}`; default to `.sprint/` at the project root. The multi-agent orchestrator supplies `.harness/` instead.

```
{workspace}/
  contract-draft-1.md
  contract-review-1.md
  contract-draft-2.md
  contract-review-2.md
  ...
  contract.md          # final agreed contract
```

File formats are defined in [references/file-format.md](references/file-format.md). A worked end-to-end round-trip is in [references/negotiation-example.md](references/negotiation-example.md).

### Iteration rules

1. Generator writes `contract-draft-{n}.md`.
2. Evaluator reads the draft, writes `contract-review-{n}.md` with one verdict per criterion.
3. If any criterion is `REJECT`, Generator writes `contract-draft-{n+1}.md` addressing every rejection.
4. Loop until Evaluator returns all `ACCEPT`, or until review 3 completes.
5. If review 3 still has any `REJECT`, write `{workspace}/escalation.md` and stop; never create draft 4.
6. On full acceptance: copy the agreed criteria into `contract.md` and append a `## Negotiation History` section.

### Round-trip cap

- **Hard cap: 3 round-trips** (draft 1–3 plus reviews).
- **Early escalation triggers** — escalate to the user before round 3 when ANY of these is true:
  - Same criterion is `REJECT`-ed twice for the same reason → input ambiguity, not a wording problem.
  - Round 2 review still rejects more than 50% of criteria → the spec is too vague to negotiate from.
  - Generator cannot produce ≥ 8 criteria → scope is unclear or trivial.

When escalating, write `{workspace}/escalation.md` with the unresolved criteria and the reason, then ask the user.

## Procedure

1. Read the input spec or user story.
2. Use `Glob` and `Grep` only if relevant existing code informs scope (skip for greenfield).
3. Resolve `{workspace}` (caller-supplied or `.sprint/`) and create it if missing. If `{workspace}/contract.md` exists, stop: the contract is immutable. Ask the user to preserve or archive the existing workspace before starting a new sprint; never overwrite it in place.
4. **Round 1 — Generator**: write `{workspace}/contract-draft-1.md` per [references/file-format.md](references/file-format.md). Aim for the criteria count appropriate to sprint size (see template).
5. **Round 1 — Evaluator**: read draft 1, write `{workspace}/contract-review-1.md`. For every `REJECT`, name the missing element from the four-part rule (subject / verb / observable result / verification method).
6. Repeat with rounds 2 and 3 as needed. Honor early escalation triggers.
7. On full acceptance, write `{workspace}/contract.md` with the agreed criteria plus `## Negotiation History`.
8. Report to the user: criteria count, rounds used, any escalations.

## Criterion Quality Rule

Every criterion MUST follow:

> **Subject + Verb + Observable Result + Verification Method**

Bad → Good comparisons and the full template are in [references/contract-template.md](references/contract-template.md).

The Evaluator's REJECT reasons MUST cite which of the four parts is missing or unverifiable. Generic reasons like "too vague" are themselves rejected and the Evaluator must rewrite the review.

## Gotchas

- **Implementation details belong to the Generator's later work, not the contract.** "Uses PostgreSQL with btree index" is a HOW, not a WHAT. Strip it.
- **Existing contract is immutable.** A different sprint name does not change the fixed contract path. Preserve or archive the whole workspace before starting another negotiation.
- **File-based protocol is non-negotiable.** Both roles MUST read from disk between turns. Conversational state ("as I said in the previous draft") breaks the audit trail and undermines the whole point of the protocol.
- **Do not conflate this with a test plan.** The contract is product-level acceptance criteria. Per-function unit tests are the Generator's domain during implementation.

## Eval Criteria

Five binary checks for any contract produced by this skill. The `autoresearch` skill can reuse these for autonomous optimization.

```
EVAL 1: Specificity
  Question: Does every criterion have all four parts (subject, verb,
            observable result, verification method)?
  Pass: 100% of criteria pass.
  Fail: Any criterion missing one or more parts.

EVAL 2: External testability
  Question: Could a reviewer who has not read the source code verify
            every criterion using only the stated verification method?
  Pass: All criteria verifiable from the outside.
  Fail: Any criterion requires source-code inspection.

EVAL 3: Round-trip discipline
  Question: Did the negotiation finish in ≤ 3 rounds OR escalate
            via `{workspace}/escalation.md`?
  Pass: ≤ 3 rounds, or escalation file exists with reason.
  Fail: 4+ rounds, or stalled without escalation.

EVAL 4: Audit trail completeness
  Question: Do `{workspace}/` files exist for every round, with one
            review per draft?
  Pass: For each `contract-draft-{n}.md`, a matching
        `contract-review-{n}.md` exists.
  Fail: Any round missing its review or draft pair.

EVAL 5: Criteria count fit
  Question: Is the criteria count in the template's recommended range
            for the sprint size?
  Pass: Within range (8–12 small, 15–25 medium, 25–40 large).
  Fail: Outside the range without a documented reason.
```
