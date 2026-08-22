---
name: implement-plan
description: "canonical 구현 계획을 검증 중심으로 실행하고, 선택된 평가가 끝난 뒤 전체 워크플로 산출물을 안전하게 보관한다."
when_to_use: "구현 시작, 플랜 실행해, implement-plan, 다 구현해, /implement-plan 요청 시 사용한다."
group: build
model: sonnet
argument-hint: "[feature-name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, AskUserQuestion
---

# Implement Plan — Managed Execution Engine

Execute the approved `.plans/plan-{feature}.md`, prove each item and the full workflow, and call the canonical archive operation exactly once. This is the only managed execution engine and completion owner.

## Inputs

The caller may supply:

- `{feature}` or an exact active plan path;
- `evaluators`: the selected independent evaluators, empty for standalone execution;
- `final_report`: an exact synthesized PASS report path, only when finalizing an evaluator-bearing run.

An orchestrator passes these values but does not execute plan items or archive artifacts itself.

## Contract and State Preflight

1. Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`.
2. Verify `workflow.execution_engine == "implement-plan"`, read all artifact/transient/archive definitions, and confirm the selected plan matches `artifacts.plan.pattern`.
3. If the command is unavailable, stop and report:
   ```bash
   cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
   ```
4. Stop if `.harness/` exists. Ask the user to preserve, manually translate, or remove it; never migrate it automatically.
5. Resolve one plan: use the requested feature, accept one glob match, ask when multiple plans exist, and stop when none exists.
6. Parse every unchecked todo, exact affected/test path, `Consumes`/`Produces` dependency, acceptance criterion, exclusion, `## Workflow Sources`, verification command, and reference implementation. Verify every declared source exists at its canonical contract path before editing code.
7. Read all applicable repository instructions, especially Git policy. Repository rules override generic branch, worktree, commit, merge, and PR advice.

## Finalization-Only Entry

When `final_report` is supplied, do not reimplement completed items:

1. Require all todos checked, `.plans/.verify-final-{feature}.md` present with no FAIL, and no implementation change newer than that final verifier.
2. Read the exact report. Require an overall PASS, exact references to selected QA/design source reports, and PASS for every active acceptance criterion. A score cannot override a failing criterion or severity.
3. Confirm the report matches `.plans/.evaluation-{feature}-r{round}.md` and the same selected feature.
4. Call the archive procedure in [Completion and Archive](#completion-and-archive) with `final_report` and return. Do not run evaluator work or create a second synthesis.

If the report is FAIL, do not enter finalization. Return its findings to normal implementation, remove the stale final verifier before changes, and require a fresh full verifier before another evaluation round.

## Execution Mode

After preflight, create the contract-configured implementation flag. Treat an unmatched stale flag as a conflict to inspect, not permission to delete unknown work.

Choose the simplest mode permitted by repository instructions:

| Condition | Mode |
|---|---|
| Direct-main policy, fewer than two independent items, file overlap, or uncertain dependency | **Sequential in the current checkout** |
| Repository permits worktrees and at least two items have disjoint paths and interfaces | **Parallel isolated worktrees** |
| Mixed graph | Sequential dependency chains, then only the proven-disjoint cluster in worktrees |

Never create a branch or worktree merely because a generic workflow recommends it. In this dotfiles repository, execute sequentially on `main`.

## Engineering Disciplines

The contract lists optional Superpowers disciplines. They provide engineering checks, never workflow state or ownership:

- For behavior changes, use `test-driven-development` when available. Otherwise preserve red → green → refactor inline and show the failing test before implementation.
- After a reproducible failure, use `systematic-debugging` when available. Otherwise identify root cause, state one hypothesis, test it, and add a regression test before changing direction.
- Require fresh verification before checking an item and before any completion claim; `verification-before-completion` may enforce this.
- Use requesting/receiving review only for an independent code-review pass. Review feedback returns here for execution.
- Use parallel dispatch only for domains with disjoint files, interfaces, and state.

Inside this managed pipeline, do not invoke Superpowers `writing-plans`, `subagent-driven-development`, `executing-plans`, `using-git-worktrees` when repository policy forbids it, or `finishing-a-development-branch`. `annotate-plan` and this skill own planning and execution state.

## Sequential Execution

For each todo in dependency order:

1. Derive `{item-slug}` as `{ordinal}-{kebab-summary}` and map its exact paths, tests, criteria, inputs, and outputs.
2. For behavior work, run the named test and record the expected failure before implementation.
3. Implement only that item. Follow repository patterns and write `.plans/.blocker-{item-slug}.md` when the plan cannot be executed without a scope decision.
4. Run the named focused checks, then launch an independent verifier writing `.plans/.verify-{item-slug}.md`.
5. Require explicit `build:`, `typecheck:`, `lint:`, `tests:`, and `errors:` results. Any applicable FAIL blocks completion.
6. Mark `[x]` only after fresh PASS and continue. Never begin the next item while the current one is unresolved.

## Parallel Worktrees

Use only when repository policy allows it and independence is proven from the plan interfaces:

1. Launch one implementer per disjoint item in isolated worktrees and require its exact worktree, branch, commit SHA, changed paths, checks, and blocker path.
2. Wait for all already-launched siblings before handling a blocker; never orphan worktrees.
3. Verify each returned SHA independently in its worktree. Fix and reverify there.
4. Integrate only the exact verified SHA using the repository-approved method. On conflict, abort and ask the user; never auto-resolve a dependency-classification failure.
5. Remove merged or explicitly abandoned worktrees and branches only when project instructions permit those actions.

## Blockers and Failures

- **Explicit blocker:** show `Problem`, `Attempts`, and `Proposal`; remove the implementation flag; return to `annotate-plan` Phase B. Do not redesign scope inline.
- **Verifier failure:** create `.plans/.debug-{item-slug}.md` through an independent debugger or the inline systematic-debugging invariant. Apply a fix only after root cause is demonstrated, then rerun the same verifier.
- **Scope divergence:** never run destructive checkout/reset over main-checkout work. Show the diff and ask whether to keep or revert it. Mark `(RESET)` only after the approved rollback, remove the flag, and return to `annotate-plan`.
- **Cancellation or failed final verification:** remove the implementation flag and retain source artifacts. Never archive or claim completion.

## Full Verification and Evaluation Handoff

After all todos are checked:

1. Run one fresh full verifier for the build/test suite and every active acceptance criterion. Write `.plans/.verify-final-{feature}.md`.
2. On FAIL, follow failure handling and do not claim completion.
3. If `evaluators` is empty, proceed directly to archive with no final report.
4. If one or more evaluators were selected, keep the active workflow state and implementation flag, and return exactly:
   ```text
   AWAITING_EVALUATION
   feature: {feature}
   plan: .plans/plan-{feature}.md
   final_verifier: .plans/.verify-final-{feature}.md
   evaluators: [selected evaluator names]
   ```
   Do not archive. The orchestrator runs independent evaluation and writes the synthesis.
5. A PASS synthesis re-invokes this skill with its exact `final_report` for finalization-only entry. A FAIL synthesis returns findings to implementation and invalidates the prior final verifier.

## Completion and Archive

Build JSON containing `cwd`, exact `plan`, all stable `item_slugs`, and `final_report` only when present. Run:

```bash
printf '%s' "$archive_input" | \
  "${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" archive
```

The binary preflights every source and destination, rolls back partial file moves, archives the complete declared workflow, and then removes only feature-owned transient state.

Durable outputs are:

- `docs/specs/spec-{feature}.md` when a product spec was declared;
- `docs/contracts/contract-{feature}.md` when a sprint contract was declared;
- `docs/research/research-*.md` for declared research;
- `docs/plans/plan-{feature}.md` always;
- `docs/reports/report-{feature}.md` only for evaluator-bearing completion.

On archive error, report the exact diagnostic, leave active source state in place, and do not invent a filename or overwrite a destination. Confirm the implementation flag is absent after successful archive. Report item totals, verification evidence, retained worktrees, and exact durable paths. Suggest commit only when changes remain uncommitted; push is always a separate explicit action.

## Eval Criteria

```text
EVAL 1: Ownership
  Pass: implement-plan is the only execution and archive caller.
  Fail: an orchestrator or Superpowers controller owns managed execution state.

EVAL 2: Item integrity
  Pass: every original todo is [x], [ ], or [ ] (RESET), and every [x] has fresh PASS evidence.
  Fail: a todo or criterion is lost, duplicated, or checked without verification.

EVAL 3: Repository policy
  Pass: Git/worktree behavior follows applicable project instructions.
  Fail: generic branch or worktree advice overrides the repository.

EVAL 4: Evaluation boundary
  Pass: selected evaluators cause AWAITING_EVALUATION; only synthesized PASS re-entry archives.
  Fail: execution archives before evaluation or evaluation reimplements work.

EVAL 5: Durable promotion
  Pass: all declared canonical sources and optional final report move atomically to contract destinations.
  Fail: unrelated state moves, a collision is overwritten, or completion is claimed after archive failure.
```
