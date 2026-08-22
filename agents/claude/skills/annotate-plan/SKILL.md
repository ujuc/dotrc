---
name: annotate-plan
description: "병렬 분석으로 canonical 구현 계획을 만들고 사용자의 직접 편집과 인라인 주석을 반복 반영한다."
when_to_use: "구현 계획 작성, 플랜 만들어줘, annotate-plan, /annotate-plan, 노트 반영해줘, address notes, 주석 처리해, annotations 요청 시 사용한다."
group: analysis
model: sonnet
argument-hint: "[feature-name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, advisor
---

# Annotate Plan — Canonical Plan Writer

Create and iteratively refine `.plans/plan-{feature}.md`. This is the only managed plan writer; orchestrators and optional Superpowers skills may provide context or discipline but must not create a competing plan.

The planning quality rules are adapted from Superpowers `writing-plans` at the version pinned in `workflow-hooks contract`. This skill does not invoke that workflow or create `docs/superpowers/plans/` state.

## Contract Preflight

Before either phase:

1. Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`.
2. Verify `workflow.plan_writer == "annotate-plan"`, `artifacts.plan.writer == "annotate-plan"`, and use the configured plan pattern.
3. If the command is unavailable, stop and report:
   ```bash
   cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
   ```
4. Stop if `.harness/` exists. Ask the user to preserve, manually translate, or remove it; never migrate it automatically.
5. One checkout has one active workflow. On initial creation, stop if another `.plans/plan-*.md` exists or if the target plan already exists. Never overwrite, rename, or delete active state.

## Phase A — Initial Plan

### 1. Gather Canonical Context

- Derive `{feature}` as a stable kebab-case slug from `$ARGUMENTS`.
- Read `spec.md` and `.sprint/contract.md` when present.
- Read only `.research/research-*.md` files that materially inform this feature and record their exact paths.
- If neither approved product/design context nor research exists, warn the user that plan confidence is lower before dispatch.
- Treat every active contract criterion and exclusion as mandatory plan input; never silently drop one.

### 2. Produce Independent Inputs

Launch both roles in one parallel dispatch and wait for both:

| Role | Agent | Output | Responsibility |
|---|---|---|---|
| plan-drafter | `Plan` | `.plans/.partial/plan.md` | Goal, approach, exact changes/tests, dependencies, risks, questions, todos |
| reference-finder | `reference-finder` | `.plans/.partial/references.md` | Reusable code, APIs, conventions, and tests with `file:line` citations |

Prompts must include the exact spec/contract/research paths, all criteria and exclusions, and the partial output path. If either output is missing or empty, re-dispatch only that role; never merge an incomplete pair.

### 3. Write the Managed Plan

Merge into the contract-configured path with these headings:

```markdown
# Plan: {feature}

## Goal

## Approach

## Acceptance Criteria
(verbatim criteria and exclusions, or `No active contract`)

## Workflow Sources
- Product Spec: `spec.md` or None
- Sprint Contract: `.sprint/contract.md` or None
- Research: None
  OR
- Research:
  - `.research/research-example.md`

## Reference Implementations
(existing code and tests with file:line citations)

## File Changes
(exact affected paths and exact test paths)

## Code Snippets
(load-bearing signatures or examples only)

## Dependencies & Ordering
(per item: Consumes, Produces, predecessors, and parallel-safety)

## Risk Assessment

## Open Questions

## Todo
- [ ] Item 1 — exact implementation paths; exact test paths; verification command
```

`## Workflow Sources` is machine-readable. Use exact canonical backticked paths or `None`; never add prose to those values.

Every behavior-changing todo must name the test that proves it and the fresh verification command. Every todo must identify exact affected and test paths. Do not leave placeholders such as "add tests", "update as needed", or guessed signatures.

### 4. Phase A Self-Review

Before user delivery, verify and revise:

- every spec requirement and contract criterion/exclusion maps to at least one todo and verification;
- no placeholders, unresolved template text, or unsupported assumptions remain;
- file paths, symbols, types, and signatures agree across sections and with inspected code;
- `Consumes`/`Produces` interfaces make ordering and parallel safety explicit;
- all behavior changes have named tests and runnable verification commands;
- Workflow Sources lists only material active sources.

Call `advisor()` only for a load-bearing contradiction between the two partials or an unresolved high-impact planning decision.

### 5. Baseline and Review Gate

- Copy the plan to `.plans/.plan-{feature}.md.prev`.
- Write `0` to `.plans/.plan-{feature}.cycle`.
- Remove `.plans/.partial/`.
- Ask the user to review and directly edit or annotate the plan. Do not proceed to implementation until the user explicitly confirms.

## Phase B — Annotation Cycle

Trigger on requests such as "address notes", "annotations", "노트 반영해줘", or "주석 처리해".

### 1. Detect Feedback

Diff `.plans/.plan-{feature}.md.prev` against the current plan. Every substantive user-added, deleted, or changed diff range is feedback, even when it contains no `NOTE:`, blockquote, TODO, FIXME, or HTML-comment marker. Markers help interpretation; they are not required.

Ignore only whitespace-only changes and generated text unchanged from the baseline. Also consume matching `.plans/.blocker-*.md` and `.plans/.debug-*.md` as feedback sources, then move consumed files to `.plans/.partial/` until the cycle completes.

If there is no substantive diff or failure artifact, stop without changing baseline or counter.

### 2. Apply Each Annotation

For each changed range:

1. Quote the changed text and surrounding heading.
2. Classify it using [references/annotation-guide.md](references/annotation-guide.md).
3. State whether it is a local correction or structural revision and name affected sections.
4. If it changes scope, exclusions, or acceptance criteria under an active contract, stop. Return to the canonical `.sprint/` negotiation lifecycle after the user archives or explicitly abandons the active contract; never create an arbitrary workspace.
5. Otherwise edit only affected sections and re-run the Phase A self-review.

### 3. Finish the Cycle

- Replace `.plans/.plan-{feature}.md.prev` with the accepted current plan.
- Increment `.plans/.plan-{feature}.cycle` by exactly one.
- Remove consumed feedback from `.plans/.partial/`.
- After cycle 6, suggest implementation; continue only when the user explicitly requests another cycle.

## Constraints

- Do not implement code.
- Do not invoke Superpowers `writing-plans`, SDD, or `executing-plans` inside this managed pipeline.
- Preserve unrelated plan sections during annotations.
- Never commit `.plans/.partial/` or choose alternate filenames after a collision.
- Hand off to `implement-plan` only after explicit user approval.

## Eval Criteria

```text
EVAL 1: Contract ownership
  Pass: the configured plan path is written only by annotate-plan.
  Fail: a fallback, Superpowers, or orchestrator plan becomes managed state.

EVAL 2: Provenance and coverage
  Pass: Workflow Sources is exact and every active requirement maps to work and verification.
  Fail: sources are ambiguous or any criterion/exclusion is dropped.

EVAL 3: Executability
  Pass: every todo has exact implementation/test paths, interfaces, dependencies, and commands.
  Fail: placeholders or guessed signatures remain.

EVAL 4: Annotation round-trip
  Pass: marker-free substantive edits are processed, counter increments once, and baseline byte-matches.
  Fail: direct edits are missed or unchanged feedback is processed again.

EVAL 5: Scope integrity
  Pass: contract-changing feedback returns to canonical .sprint negotiation.
  Fail: acceptance scope is edited inline or a second workspace is created.
```
