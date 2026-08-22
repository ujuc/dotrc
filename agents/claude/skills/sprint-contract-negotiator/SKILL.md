---
name: sprint-contract-negotiator
description: Generator·Evaluator 역할을 파일 기반 프로토콜로 번갈아 수행해 canonical sprint의 done 기준을 협상한다.
when_to_use: "sprint contract 협상, done 기준 정의, 완료 조건 합의, acceptance criteria 작성, sprint-contract-negotiator 호출 시. 구현 시작 전에 'done이 뭔지 먼저 정하자'·'이 sprint의 합격 기준을 잡아줘'·'평가자가 검증할 기준을 만들어줘' 같은 요청에 적합."
group: planning
model: opus
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Sprint Contract Negotiator

Negotiate externally testable acceptance criteria through alternating Generator and Evaluator passes. The canonical output is the immutable `.sprint/contract.md`; drafts, reviews, and escalation records remain in `.sprint/` for the active workflow.

## Contract Preflight

1. Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`.
2. Verify `artifacts.contract.writer == "sprint-contract-negotiator"` and use its exact configured path.
3. If the command is unavailable, stop and report:
   ```bash
   cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
   ```
4. Stop if `.harness/` exists. Ask the user to preserve, manually translate, or remove it; never migrate it automatically.
5. Use only `.sprint/`. Reject caller-supplied workspaces and never redirect output to an orchestrator-specific directory.
6. If `.sprint/contract.md` exists, stop. The active contract is immutable; the user must finish and archive the active workflow or explicitly abandon it before a new negotiation begins.

## Inputs and Scope

Input is `spec.md` when present, otherwise a user-approved bounded design or story. Read relevant repository context only when it changes observable scope.

The contract defines what must be verified, not code structure, library choices, database schemas, or unit-test implementation.

## Roles

This skill alternates two roles in one orchestrated process and re-reads every turn from disk:

- **Generator** proposes one sprint goal, explicit scope and exclusions, and acceptance criteria.
- **Evaluator** issues exactly one `ACCEPT` or `REJECT` for every criterion. Every rejection names the missing subject, action, observable result, or verification method.

It does not claim to dispatch independent agents. Files are the audit trail and source of truth.

## Canonical File Protocol

```text
.sprint/
  contract-draft-1.md
  contract-review-1.md
  contract-draft-2.md
  contract-review-2.md
  contract-draft-3.md
  contract-review-3.md
  escalation.md          # only when unresolved
  contract.md            # final immutable agreement
```

Formats are defined in [references/file-format.md](references/file-format.md), with examples in [references/negotiation-example.md](references/negotiation-example.md).

## Negotiation

1. Read the approved input and identify the smallest coherent sprint whose criteria can be evaluated together.
2. Write `.sprint/contract-draft-1.md` with goal, in-scope behavior, exclusions, and criteria.
3. Re-read the draft as Evaluator and write `.sprint/contract-review-1.md` with one verdict per criterion.
4. For any rejection, write the next draft addressing every rejection, then the matching review.
5. Stop after review 3. If any rejection remains, write `.sprint/escalation.md`, explain the unresolved decisions, and ask the user; never create round 4.
6. Escalate earlier when the same criterion is rejected twice for the same reason, more than half remain rejected after round 2, or the sprint boundary itself is unclear.
7. On full acceptance, write `.sprint/contract.md` from the accepted draft and append `## Negotiation History`. Do not mutate it later.
8. Report criterion count, rounds used, exclusions, and any escalation.

## Criterion Quality Rule

Every criterion must contain:

> **Subject + Verb + Observable Result + Verification Method**

The verification method must let a reviewer unfamiliar with the implementation decide PASS or FAIL. The recommended criterion count is based on actual sprint complexity, never a fixed minimum.

## Lifecycle Rules

- One checkout has one active managed workflow.
- Existing draft/review files are active state, not disposable scratch files.
- A scope, exclusion, or acceptance change after finalization returns here only after the current contract/workflow is archived or explicitly abandoned by the user.
- The orchestrator may invoke this skill, but only this skill writes contract artifacts.
- This skill never writes research, plans, code, QA/design reports, or synthesized evaluation.

## Eval Criteria

```text
EVAL 1: Canonical ownership
  Pass: all negotiation files are under .sprint/ and contract.md uses the configured path.
  Fail: a caller workspace or .harness path is used.

EVAL 2: Specificity
  Pass: every criterion contains all four quality-rule parts.
  Fail: any criterion is ambiguous or unverifiable.

EVAL 3: Round discipline
  Pass: acceptance occurs within three reviews or escalation.md explains the stop.
  Fail: a fourth round is created or negotiation silently stalls.

EVAL 4: Audit completeness
  Pass: every draft has one matching review and contract.md records the history.
  Fail: any role turn is missing from disk.

EVAL 5: Immutability
  Pass: an existing final contract stops new negotiation until user resolution.
  Fail: active contract state is overwritten, moved, or deleted automatically.
```
