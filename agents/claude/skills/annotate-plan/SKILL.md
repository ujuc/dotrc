---
name: annotate-plan
description: "병렬 에이전트로 구현 계획을 생성하고, 사용자 인라인 주석을 반복 처리하여 플랜을 개선한다. 구현 계획 작성, 플랜 만들어줘, annotate-plan, /annotate-plan, 노트 반영해줘, address notes, 주석 처리해, annotations 요청 시 사용한다."
group: analysis
model: sonnet
argument-hint: "[feature-name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, advisor
---

# Annotate Plan — Annotation Cycle Planning

Create an implementation plan at `.plans/plan-{feature}.md` and support iterative annotation cycles where the user adds inline notes.

## Phase A — Initial Plan Generation

### 1. Gather Context
- Parse `$ARGUMENTS` for feature name; derive `{feature}` as kebab-case slug.
- Load `.research/research-*.md` if present (deep-read output).
- Check for `spec.md`, `.sprint/contract.md` (harness artifacts).
- If no research and no spec exist, surface this to the user before dispatching agents — the plan quality will be weaker.

### 2. Launch 2 Parallel Agents

Spawn BOTH agents in a **single message** with two `Agent` tool calls. Sequential dispatch doubles wall-clock time for no benefit.

| Agent | `subagent_type` | Focus | Output path |
|-------|-----------------|-------|-------------|
| **plan-drafter** | `Plan` (built-in) | Draft implementation plan sections: Goal, Approach, File Changes, Dependencies, Risks, Open Questions | `.plans/.partial/plan.md` |
| **reference-finder** | `reference-finder` | Find reusable patterns/utilities/tests; emit `file:line` citations | `.plans/.partial/references.md` |

Agent prompt template (adapt per role):
```
Feature: {feature name}
Requirements: {from $ARGUMENTS / spec.md, plus every criterion and exclusion from .sprint/contract.md when present}
Research context: {paste or reference .research/research-*.md path}
Focus: {role description}
Output: {partial path}
Required sections: {see table}
```

Reference-finder output format and citation rules live in `~/.claude/agents/reference-finder.md`; do not restate them.

Wait for both agents to finish. Verify each partial exists and is non-empty before merging — if either is missing, re-dispatch that one role rather than merging with a hole.

### 3. Merge and Write Plan

Combine the partials into `.plans/plan-{feature}.md`:

```markdown
# Plan: {feature}

## Goal
(what and why)

## Approach
(high-level strategy)

## Acceptance Criteria
(verbatim criteria and exclusions from the active contract, or `No active contract`)

## Reference Implementations
(from reference-finder — existing code to reuse/adapt, with file:line citations)

## File Changes
(exact paths, what changes in each)

## Code Snippets
(key implementation details only)

## Dependencies & Ordering
(which items depend on others)

## Risk Assessment
(what could go wrong)

## Open Questions
(unresolved decisions)

## Todo
- [ ] Item 1
- [ ] Item 2
```

### 4. Save Baseline and Cleanup
- Copy plan to `.plans/.plan-{feature}.md.prev` (annotation diff baseline).
- Initialize cycle counter: write `0` to `.plans/.plan-{feature}.cycle`.
- Delete `.plans/.partial/` directory.
- Output: ``` `.plans/plan-{feature}.md` has been created. Review it and add inline notes, then say 'address notes' to start an annotation cycle. ```

## Phase B — Annotation Cycle

Triggered when user says: "노트 반영해줘", "address notes", "주석 처리해", "annotations".

### 1. Detect Annotations

- Diff `.plans/.plan-{feature}.md.prev` against the current plan to find user additions/edits.
- Within added or changed diff ranges only, scan for explicit markers: `> ` blockquotes, `NOTE:`, `TODO:`, `FIXME:`, `<!-- ... -->`. Markers already present in `.prev` are not new annotations.
- If `.plans/.blocker-*.md` or `.plans/.debug-*.md` files exist, treat their contents as annotation sources alongside inline diff markers — this lets `implement-plan`'s failure output feed the next annotation cycle. After incorporating, move the consumed files to `.plans/.partial/` so they are not re-read on the next cycle.
- Treat unrelated whitespace-only diffs as noise. If no new annotations or blocker/debug artifacts remain, report that and stop without changing the baseline or counter.

See `references/annotation-guide.md` for the four annotation formats and six feedback-type categories.

### 2. Process Each Annotation

For each detected annotation:
1. Quote the annotation verbatim (with its surrounding section).
2. Classify the feedback type (per annotation-guide.md).
3. State how it will be addressed — which sections change, whether it is a local patch or a structural revision.
4. If an active contract exists and the annotation changes scope, exclusions, or acceptance criteria, stop and require a new archived negotiation workspace; do not alter the contracted plan inline.
5. Otherwise apply the change with `Edit` (preserve unrelated sections; do not rewrite the whole plan). The updated baseline marks the annotation consumed; do not process unchanged markers on later cycles.

### 3. Update Baseline and Counter

- Overwrite `.plans/.plan-{feature}.md.prev` with the current plan.
- Increment the cycle counter in `.plans/.plan-{feature}.cycle`.

### 4. Cycle Limit

After the counter reaches 6, surface: "6 annotation cycles complete. Consider moving to implementation with `/implement-plan`." This is a suggestion, not a hard stop — continue if the user explicitly asks.

## Advisor Escalation

Sonnet is the default. Call `advisor()` (no parameters — the full context forwards automatically) only at these decision points:

- **Phase A pre-merge**: plan-drafter and reference-finder disagree on a load-bearing fact (e.g., chosen library, existing helper availability), or Risk Assessment synthesis is ambiguous.
- **Phase B annotation interpretation**: an annotation is ambiguous, or it is unclear whether the change spans multiple sections versus a localized edit.

Do not call advisor for routine progress updates or for simple Q&A.

## Constraints

- **Do NOT implement code** during this skill. Hand off to `implement-plan` only after the user stops annotating.
- The plan is a **shared mutable document** — Claude writes, the user annotates, Claude incorporates.
- Always wait for user confirmation before proceeding to implementation.
- Create `.plans/` and `.plans/.partial/` if missing. Never commit `.plans/.partial/`.

## Gotchas

1. **`.prev` baseline drift after manual edits.** If the user edits the plan between cycles without triggering `address notes`, the next diff against `.prev` will surface pre-existing edits as new annotations. When you detect a suspiciously large diff, ask the user to confirm what is new versus carry-over.
2. **Cycle counter absent on resume.** When a session is resumed, `.plans/.plan-{feature}.cycle` may be missing if Phase A ran in a different checkout. Recreate with `0` on first `address notes` call instead of erroring.
3. **Annotations inside code blocks.** `NOTE:` / `TODO:` / `FIXME:` markers are valid inside Markdown code blocks too — these are almost never user annotations, they are snippets Claude itself produced. Skip annotations found inside fenced blocks unless the user explicitly points to them.
4. **Plan bloat across cycles.** Every cycle tends to grow the plan. After cycle 3, suggest trimming stale sections (rejected approaches, resolved open questions) to keep the document focused.

## Eval Criteria

```
EVAL 1: Both partials written
  Question: After Phase A Step 2, do `.plans/.partial/plan.md` and
            `.plans/.partial/references.md` both exist and have >0 bytes?
  Pass: Both exist, non-empty.
  Fail: Either missing or zero-byte.

EVAL 2: Plan section completeness
  Question: Does the final `.plans/plan-{feature}.md` contain all nine
            headings in the Phase A Step 3 template (Goal, Approach,
            Acceptance Criteria, Reference Implementations, File Changes,
            Code Snippets, Dependencies & Ordering, Risk Assessment,
            Open Questions, Todo)?
  Pass: All ten headings present.
  Fail: Any heading missing.

EVAL 3: Baseline and counter initialized
  Question: After Phase A Step 4, do `.plans/.plan-{feature}.md.prev`
            and `.plans/.plan-{feature}.cycle` (containing `0`) both
            exist?
  Pass: Both exist with correct contents.
  Fail: Either missing, or cycle file does not contain `0`.

EVAL 4: Annotation round-trip
  Question: After a Phase B cycle, is the counter incremented by exactly 1,
            does `.prev` match the plan, and does an immediate no-diff rerun do nothing?
  Pass: Counter +1, `.prev` byte-matches, no annotation is reprocessed.
  Fail: Counter/baseline mismatch, or an unchanged annotation is processed again.
```
