---
name: spec-planner
description: "요청의 복잡도를 분류하고, 아키텍처 수준 작업에만 승인된 제품 스펙을 spec.md로 작성한다."
when_to_use: "스펙 작성, 요구사항 확장, spec-planner, 기획서 만들어줘, 제품 기획 시작, plan this app, expand this idea, create a product spec"
group: planning
model: opus
allowed-tools: Read, Write, Glob, Grep, Bash
---

# Spec Planner

Classify a product request, clarify its intent, and write the canonical `spec.md` only when the work needs an architectural product specification. Define what to build and why; leave implementation choices to planning and execution stages.

The design discipline here is adapted from Superpowers `brainstorming` at the version pinned in `workflow-hooks contract`. This skill does not invoke that workflow or create `docs/superpowers/specs/` state.

## Contract Preflight

Before creating an artifact:

1. Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`.
2. Verify `artifacts.spec.writer == "spec-planner"` and read the configured path. Do not substitute a caller-provided path.
3. If the command is unavailable, stop and report:
   ```bash
   cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
   ```
4. Stop if `.harness/` exists. Ask the user to preserve, manually translate, or remove it; never migrate it automatically.
5. Stop if the configured spec already exists, or if another active plan indicates a conflicting workflow. Never overwrite or delete active state.

## Classify the Request

Choose one path before drafting:

| Class | Use when | Managed output |
|---|---|---|
| **Spike** | The user needs investigation or a recommendation, not a committed product direction | None; recommend `deep-read` or answer directly |
| **Bounded** | The change has a narrow goal, known boundary, and no product-level decomposition | None; present a short design in conversation and obtain approval |
| **Architectural** | The work spans product capabilities, multiple dependent stages, or durable acceptance decisions | Canonical `spec.md` after one approval gate |

Do not inflate spike or bounded work merely to create an artifact.

## Architectural Workflow

1. Read the request and inspect relevant existing product context with `Glob`, `Grep`, and `Read`.
2. Ask one focused question at a time only where the answer changes scope or product behavior.
3. Present 2-3 viable approaches when a meaningful tradeoff exists. Lead with a recommendation and explain the tradeoff briefly.
4. Present the proposed design in sections appropriate to its complexity: target users, value, capabilities, user-visible behavior, constraints, conceptual data, design direction, exclusions, and dependency ordering.
5. Obtain one explicit approval for the complete design before writing `spec.md`.
6. Write only the contract-configured path using [references/spec-template.md](references/spec-template.md) as structure, trimming irrelevant sections rather than filling them with boilerplate.
7. Self-review before delivery:
   - no placeholders or unresolved template text;
   - no contradictory behavior or exclusions;
   - scope is decomposed enough for contract negotiation;
   - ambiguous product decisions are resolved or listed explicitly;
   - implementation details do not constrain the later planner without a product reason.
8. Report the selected class, key decisions, unresolved questions, and the canonical output path.

## Product-Spec Rules

- Describe user capabilities and observable outcomes, not database schemas, API routes, component trees, or library choices.
- Make scope as broad as the approved product direction requires, not to satisfy a fixed feature or sprint count.
- Give every capability a user-value rationale.
- Consider AI only where it provides specific user value; an explicit non-applicability rationale is valid.
- Use conceptual entities and relationships only when they clarify product behavior.
- Express ordering as dependency and value flow, never time estimates or story points.
- Treat repository instructions and the active workflow contract as higher priority than generic planning conventions.

## Handoff

An approved architectural `spec.md` feeds `sprint-contract-negotiator`. This skill does not write a sprint contract, research file, implementation plan, evaluator report, or code.

## Eval Criteria

```text
EVAL 1: Classification fit
  Pass: spike and bounded requests create no managed spec; architectural work does.
  Fail: an artifact is created merely because the skill was invoked.

EVAL 2: Approval gate
  Pass: the complete architectural design was explicitly approved before write.
  Fail: spec.md was written while product direction remained unapproved.

EVAL 3: Contract ownership
  Pass: the embedded contract names this writer and its exact output path is used.
  Fail: a fallback or caller-selected path is used.

EVAL 4: Product clarity and freedom
  Pass: observable product behavior is clear and implementation choices remain open.
  Fail: scope is ambiguous or technical prescriptions leak without product need.

EVAL 5: Self-review
  Pass: no placeholders, contradictions, unresolved scope gaps, or silent assumptions remain.
  Fail: any review category is skipped.
```
