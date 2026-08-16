---
name: implement-plan
description: "주석이 달린 구현 플랜을 지속적 검증·블로커 감지·디버거 연동과 함께 실행한다. 순차/병렬(worktree) 실행 모드를 지원한다. 구현 시작, 플랜 실행해, implement-plan, 다 구현해, /implement-plan 요청 시 사용한다."
group: build
model: sonnet
argument-hint: "[feature-name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, AskUserQuestion
---

# Implement Plan — Execution Driver

Execute `.plans/plan-{feature}.md` one item at a time, or in isolated worktrees when items are truly independent. Mark an item complete only after its verifier report has no FAIL.

## Composition

1. `deep-read` optionally writes `.research/research-*.md`.
2. `annotate-plan` writes the plan and embeds reusable code under `## Reference Implementations`.
3. `implement-plan` executes the plan and writes `.plans/.verify-*`, `.plans/.blocker-*`, and `.plans/.debug-*` artifacts.

Return scope corrections to `annotate-plan` Phase B instead of redesigning the plan inline.

## 1. Load the Plan

- With `$ARGUMENTS`, open `.plans/plan-{feature}.md` directly.
- Otherwise glob `.plans/plan-*.md`: use one match, ask the user when there are multiple, and stop when there are none.
- Parse every unchecked todo, dependency note, affected path, embedded `Acceptance Criteria`, and `Reference Implementations`. Map each todo to the criteria it advances; never silently drop an active criterion.
- Create `.plans/.implementing`. If an existing flag is older than 24 hours or has no matching active plan, remove it and warn once.

## 2. Select a Mode

Treat items that touch the same file as sequential even when the plan calls them independent.

| Condition | Mode |
|---|---|
| Fewer than two independent items, or any file overlap | **A — sequential** |
| Two or more independent items with disjoint file sets and no pre-existing changes in those paths | **B — parallel worktrees** |
| Mixed graph | Run sequential chains in A, then the disjoint cluster in B |

## 3A. Sequential Execution

For each item in dependency order:

1. Derive a stable unique `{item-slug}` as `{todo-ordinal}-{kebab-summary}` and identify its affected files.
2. Implement only that item in the main context, following `~/.claude/agents/implementer.md` with the active plan, references, allowed files, and blocker path `.plans/.blocker-{item-slug}.md`.
3. If that blocker file appears, go to Section 4 before verification. Otherwise launch `verifier` with the item, affected files, mapped acceptance criteria, requested checks, and output path `.plans/.verify-{item-slug}.md`; wait.
4. Confirm the report contains `build:`, `typecheck:`, `lint:`, `tests:`, and `errors:`.
5. If any check is `FAIL`, go to Section 4. Otherwise mark the item `- [x]` and continue.

Never begin the next item before the current report is complete. This keeps failed edits isolated from later work.

## 3B. Parallel Worktrees

Launch one `implementer` agent per independent item in a single message with `isolation="worktree"` and `run_in_background=true`. Supply:

- the exact item and active plan path;
- its affected files and embedded reference excerpts;
- `{item-slug}` and blocker path `.plans/.blocker-{item-slug}.md`;
- the completion contract from `~/.claude/agents/implementer.md`.

Each successful agent returns `status`, absolute worktree path, branch, commit SHA, changed files, and check summary. For each result:

1. `BLOCKED`: wait for every already-launched sibling to finish, collect all results, copy the blocker into the main checkout, and remove or explicitly retain every sibling worktree before Section 4. Never orphan a live/finished sibling.
2. `COMPLETE`: launch `verifier` against the returned worktree and write the report to the main checkout's `.plans/.verify-{item-slug}.md`; wait. On FAIL, diagnose and fix inside that worktree before any merge.
3. When verification has no FAIL, resolve the worktree's current verified SHA and merge it with `git merge --no-ff <commit-sha>`. A worktree commit shares the repository object store, so no fetch or guessed branch is needed.
4. On a merge conflict, abort the merge and ask the user; never auto-resolve a conflict caused by dependency misclassification.
5. Mark the item `- [x]` only after verification and merge both succeed.

After a merged or abandoned item, remove its worktree and delete its branch. Do not remove a worktree whose result is still needed for blocker recovery.

## 4. Blocker and Failure Handling

### Blocker

If `.plans/.blocker-{item-slug}.md` exists, show its `## Problem`, `## Attempts`, and `## Proposal` sections. Remove `.plans/.implementing`, stop, and direct the user to `annotate-plan` Phase B (`address notes`). Do not run the debugger for an explicit scope blocker.

### Verifier failure

Launch `debugger` with:

- `.plans/.verify-{item-slug}.md`;
- affected files;
- the active plan path;
- output `.plans/.debug-{item-slug}.md`;
- for Mode B, the failed worktree root and verified commit SHA.

Wait, show its four required sections, and ask whether to apply the suggested fix. In Mode B, diagnose and apply any approved fix inside the same worktree, commit the corrected item, and verify that new commit before merge. In Mode A, apply inline and rerun the same verifier before marking complete.

### Scope correction

After repeated failure or plan divergence, do **not** run `git checkout -- {files}`: it can erase user work or earlier items. Show the item diff and ask whether to keep it or revert it. A failed worktree may be dropped safely; main-checkout changes require explicit user direction. Mark `- [ ] (RESET)` only after the chosen rollback, remove `.plans/.implementing`, and hand back to `annotate-plan`.

## 5. Completion

When all items are checked:

1. Launch one final `verifier` for the full build/test suite and every active acceptance criterion, writing `.plans/.verify-final-{feature}.md`, and wait.
2. On FAIL, surface the report and offer debugger or scope correction; do not claim completion.
3. Remove `.plans/.implementing` on every terminal path.
4. Report completed/total items, per-item verification, RESET items, and any retained worktrees.
5. If changes remain uncommitted, suggest `/commit`; pushing remains a separate explicit request.

## Constraints

- Never mark `[x]` without a matching completed verifier artifact.
- Never auto-discard main-checkout changes.
- Never parallelize overlapping files.
- Do not commit `.plans/` transient artifacts unless the project explicitly tracks them.

## Eval Criteria

```
EVAL 1: Plan state integrity
  Pass: Every original todo is exactly one of [x], [ ], or [ ] (RESET).
  Fail: Any todo is lost, duplicated, or has another state.

EVAL 2: Flag lifecycle
  Pass: `.plans/.implementing` is absent on every terminal path.
  Fail: The flag remains after completion, blocker handoff, or cancellation.

EVAL 3: Verification coverage
  Pass: Every [x] item has one completed `.plans/.verify-{slug}.md` with no FAIL.
  Fail: Any completed item lacks a passing report.

EVAL 4: Worktree reconciliation
  Pass: Every Mode B merge uses the returned commit SHA and has no conflict.
  Fail: A branch is guessed, a merge conflicts, or unverified work is marked complete.

EVAL 5: Safe correction
  Pass: Main-checkout changes are never auto-discarded and RESET hands back to annotate-plan.
  Fail: Recovery uses destructive checkout/reset or redesigns the plan inline.
```
