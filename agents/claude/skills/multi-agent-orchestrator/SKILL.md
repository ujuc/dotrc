---
name: multi-agent-orchestrator
description: "canonical 스펙·계약·연구·계획·구현 스킬과 선택적 독립 평가를 하나의 장기 실행 파이프라인으로 조율한다."
when_to_use: "멀티에이전트, 파이프라인 실행, multi-agent-orchestrator, 에이전트 오케스트레이션, full harness run, autonomous build session, plan and build this 요청 시 사용한다."
group: build
model: opus
argument-hint: "[1-4 sentence prompt]"
allowed-tools: Read Write Edit Glob Grep Bash Agent AskUserQuestion advisor
---

# Multi-Agent Orchestrator

Coordinate the canonical workflow writers and optional independent evaluators. The orchestrator owns sequencing, evaluator selection, synthesized evaluation, and handoff only. It never writes another skill's artifact or performs managed implementation itself.

## Canonical Pipeline

```text
spec-planner when architectural
  → sprint-contract-negotiator
  → deep-read when repository evidence is needed
  → annotate-plan
  → user plan approval
  → implement-plan(evaluators=[...])
  → optional fresh QA/design evaluators
  → orchestrator synthesis
  → implement-plan(final_report=PASS report)
```

For bounded work, `spec-planner` may approve a short design without `spec.md`; the rest of the managed pipeline remains canonical. Spike work should not enter this orchestrator.

## Preflight and Consent

1. Run `"${WORKFLOW_HOOKS_BIN:-$HOME/.local/bin/workflow-hooks}" contract`.
2. Verify canonical writers, patterns, one-active-workflow policy, and that this skill owns only `evaluation_report` and `handoff`.
3. If the command is unavailable, stop and report:
   ```bash
   cargo install --locked --path "$HOME/.config/dotrc/agents/tools/workflow-hooks" --root "$HOME/.local"
   ```
4. Inspect active canonical artifacts without changing them. If `.harness/` exists, stop and ask the user to preserve, manually translate, or remove that legacy state; never migrate or delete it automatically.
5. If canonical active state exists, offer only resume of that exact workflow or stop. Do not create a second spec, contract, research set, or plan.
6. Select evaluators before implementation:
   - QA when independent runtime functional verification materially reduces risk;
   - design when visual quality and visual usability are acceptance concerns;
   - none when fresh automated checks objectively cover the work.
7. Verify selected evaluator skills and live Chrome access before implementation. A no-evaluator run does not require Chrome.
8. Present a concise execution summary: request class, stages, selected evaluators, canonical active/durable paths, and major user approvals. Require explicit user consent before creating workflow artifacts or launching agents.

Do not choose a technology stack the user or repository did not choose. Do not mutate `.gitignore`, create custom workspaces, estimate unsupported model costs, or promise a duration.

## Stage Ownership

| Stage | Owner | Managed output |
|---|---|---|
| Product classification/design | `spec-planner` | `spec.md` only for architectural work |
| Done negotiation | `sprint-contract-negotiator` | `.sprint/contract.md` plus its audit files |
| Repository research | `deep-read` | `.research/research-*.md` |
| Implementation plan and annotations | `annotate-plan` | `.plans/plan-{feature}.md` plus baseline/cycle |
| Implementation and archive | `implement-plan` | code, verifier/blocker/debug state, durable docs |
| Functional runtime evaluation | `qa-evaluator` | `.plans/.qa-{feature}-r{round}.md` |
| Visual evaluation | `frontend-design-evaluator` | `.plans/.design-{feature}-r{round}.md` |
| Evaluation synthesis | this orchestrator | `.plans/.evaluation-{feature}-r{round}.md` |
| Context handoff | this orchestrator | `.plans/.handoff-{feature}.md` |

The orchestrator invokes owners through the active harness and reads their outputs. It does not restate a role as a new writer.

## Operating References

- [Canonical communication protocol](references/communication-protocol.md) — exact writers, paths, rounds, handoff, and stale-state behavior.
- [Workflow architecture](references/architecture.md) — ownership rationale, evaluator selection, completion, and Superpowers boundary.
- [Workflow tuning guide](references/workflow-tuning-guide.md) — fresh-agent calibration, severity thresholds, and component revalidation.

## Planning Stages

### 1. Product Design

Invoke `spec-planner` with the original request and repository context. Respect its spike/bounded/architectural classification. Stop if it classifies the request as a spike. For architectural work, require the user's design approval and canonical `spec.md` before proceeding.

### 2. Acceptance Contract

Invoke `sprint-contract-negotiator` against canonical `spec.md` or the approved bounded design. Require immutable `.sprint/contract.md` with no unresolved rejection or escalation before proceeding.

### 3. Research

Invoke `deep-read` only when existing repository behavior, data flow, dependencies, or risks materially affect planning. Require the user-review gate on each resulting research artifact. Do not create research for greenfield facts already established by the design and contract.

### 4. Plan and Approval

Invoke `annotate-plan` with exact spec, contract, and material research paths. Require complete `## Workflow Sources`, contract coverage, exact file/test paths, and verification commands. Stop at the plan review gate. Process user edits through annotation cycles until the user explicitly approves implementation.

## Implementation Stage

Invoke `implement-plan` with the exact feature and selected evaluator set.

- With no evaluators, expect fresh full verification followed by immediate archive. The orchestrator does not synthesize a report.
- With evaluators, require exact `AWAITING_EVALUATION`. Any premature archive is a protocol failure.
- On blocker, RESET, or verification failure, let `implement-plan` and `annotate-plan` own recovery. Do not edit code in the orchestrator role.

Repository Git instructions control execution mode. Never impose generic branches, commits, worktrees, merges, or PRs.

## Independent Evaluation

For each evaluation round, create fresh evaluator contexts with no sympathy-producing implementation transcript. Pass only:

- exact feature and round;
- `spec.md` when present;
- `.sprint/contract.md`;
- `.plans/plan-{feature}.md`;
- `.plans/.verify-final-{feature}.md`;
- application URL/test environment and approved state-changing scope;
- previous report paths only when verifying specific unresolved findings.

Run selected QA and design evaluators in parallel when they use the same stable build and do not mutate state. Require their separate contract-configured outputs. QA owns functional acceptance and severity. Design owns aesthetic quality and visual usability, not business-function acceptance.

Always use a fresh evaluator context each round to reduce score inflation. Never edit an evaluator report.

## Synthesized Evaluation

After all selected reports exist, this orchestrator writes exactly `.plans/.evaluation-{feature}-r{round}.md` with:

```markdown
# Evaluation: {feature} — Round {round}

## Sources
- QA: `.plans/.qa-{feature}-r{round}.md` or None
- Design: `.plans/.design-{feature}-r{round}.md` or None
- Final Verifier: `.plans/.verify-final-{feature}.md`

## Acceptance Criteria
| Criterion | Verdict | Evidence source |
|---|---|---|
| exact active criterion | PASS/FAIL | exact report section/evidence |

## Evaluator Verdicts
- QA: PASS/FAIL/Not selected
- Design: PASS/FAIL/Not selected

## Overall
PASS or FAIL

## Required Follow-up
(exact findings and owning stage, or None)
```

Overall PASS requires every active acceptance criterion PASS and every selected evaluator PASS under its own severity rules. Scores cannot override a FAIL, Critical/Major issue, or missing evidence. The synthesis must cite exact source report paths and must not invent observations.

## Feedback Loop and Completion

- **PASS:** re-invoke `implement-plan` with the exact synthesized path as `final_report`. Only that finalization call validates existing evidence and invokes archive.
- **FAIL:** return exact findings to `implement-plan`; remove/invalidate the stale final verifier before implementation changes. Require item fixes, a new full verifier, and a new fresh evaluation round.
- Default maximum is three managed evaluation rounds. If round 2 repeats a root issue from round 1, investigate whether the contract, plan, implementation, or evaluator boundary is wrong before round 3. After round 3 FAIL, write/update handoff and ask the user rather than silently expanding scope.

Completion is valid only after `implement-plan` reports successful archive into contract destinations.

## Handoff

When context must reset, write only `.plans/.handoff-{feature}.md` with active stage, exact canonical paths, selected evaluators, latest round, completed evidence, blockers, service URLs, and next owner/action. A new session cross-checks every path before resuming. Never use handoff as consent, and never duplicate artifact contents into it.

## Optional Superpowers Boundary

Cross-cutting Superpowers disciplines may assist stage owners with TDD, systematic debugging, fresh verification, review, or safe parallel dispatch. They do not write managed workflow state. Within this pipeline, `annotate-plan` replaces `writing-plans`, and `implement-plan` replaces SDD/`executing-plans`; repository Git rules override generic worktree and branch completion workflows.

## Eval Criteria

```text
EVAL 1: One writer per artifact
  Pass: every canonical artifact was written only by its contract owner.
  Fail: the orchestrator creates spec, contract, research, plan, code, or evaluator output.

EVAL 2: Approval gates
  Pass: initial pipeline consent, product approval when needed, and plan approval occur before their dependent stages.
  Fail: implementation begins from unapproved state.

EVAL 3: Evaluation independence
  Pass: fresh selected evaluators write separate reports against one stable build.
  Fail: an evaluator reuses implementation context or reports collide.

EVAL 4: Synthesis integrity
  Pass: every criterion and selected verdict is cited; any FAIL makes Overall FAIL.
  Fail: score, missing evidence, or uncited judgment overrides a failure.

EVAL 5: Completion ownership
  Pass: only implement-plan archives after standalone verification or synthesized PASS.
  Fail: orchestrator or evaluator archives or claims completion early.
```
