---
name: multi-agent-orchestrator
description: "Planner→Contract→Generator 파이프라인과 필요 시 독립 Evaluator를 연결해 장시간 자율 코딩 세션을 오케스트레이션한다."
when_to_use: "멀티에이전트, 파이프라인 실행, multi-agent-orchestrator, 에이전트 오케스트레이션, full harness run, autonomous build session, plan and build this 요청 시 사용한다. 4개 컴포넌트 스킬(spec-planner, sprint-contract-negotiator, qa-evaluator, frontend-design-evaluator)을 capstone 플로우로 엮어야 할 때 호출된다."
group: build
model: opus
argument-hint: "[1-4 sentence prompt]"
allowed-tools: Read Write Edit Glob Grep Bash Agent AskUserQuestion advisor
---

# Multi-Agent Orchestrator

Orchestrate long-running autonomous coding sessions through Planner, Contract, and Generator stages, adding independent QA/design evaluation only when the risk warrants it.

## Pipeline Overview

```
[User Prompt 1-4 sentences]
    │
    ▼
[Planner] ── spec-planner skill
    │ Output: product-spec.md
    ▼
[Contract] ── sprint-contract-negotiator skill
    │ Output: contract.md (per sprint or overall)
    ▼
[Generator] ── Implementation (React+Vite+FastAPI+SQLite or user-specified stack)
    │ Output: Running app + git commits
    ▼
[Evaluator, when deployed] ── qa-evaluator skill (+ frontend-design-evaluator for UI)
    │ Output: evaluation-report.md (PASS/FAIL + feedback)
    │
    ├── PASS → Complete or next sprint
    └── FAIL → Feedback to Generator → Re-implement → Re-evaluate
```

## Pre-flight Check

Before invoking Stage 1, verify the environment is ready. Halt and report to the user if any check fails.

1. **Core skills exist.** Confirm `spec-planner` and `sprint-contract-negotiator` are installed. Defer checks for `qa-evaluator` and `frontend-design-evaluator` until Stage 0 selects those optional evaluators; a no-Evaluator run must not require them.

2. **Inspect repository state without changing it.** Read `.gitignore` and note whether `.harness/` must be added after consent.

3. **Inspect prior artifacts without creating anything.** If `.harness/` exists, classify stale files per [communication-protocol.md](references/communication-protocol.md). Do not create, delete, or overwrite files during pre-flight.

4. **Chrome integration (only when the task will reach Stage 4).** Check that `mcp__claude-in-chrome__*` tools are available. If evaluation is required and Chrome is not active, stop and ask the user to enable it (e.g., `--chrome` flag or `/chrome`) before proceeding. Do not start Stage 1 on a Chrome-bearing task without this gate.

## Stage 0: Plan & Confirm

After Pre-flight passes, present the execution plan to the user and require explicit go-ahead before invoking the Planner. The pipeline writes multiple files, spawns several subagents, and may run for hours — the user must opt in to that scope each time, regardless of whether invocation came from a slash command or from a natural-language trigger.

### Procedure

1. Parse the user prompt (1-4 sentences) and derive:
   - **Tech stack**: whatever the user specified, otherwise note `default: React+Vite+FastAPI+SQLite`.
   - **Scope estimate**: small / medium / large per the cost reference table in this file.
   - **Evaluator deployment**: yes / no per the criteria in "Evaluator Deployment Decision".
   - For each selected evaluator, confirm its skill is installed and Chrome integration is active; otherwise stop before consent and name the missing dependency.

2. Render a Korean summary block (single message, this exact shape):

   ```
   ▣ multi-agent-orchestrator 실행 계획

   - Prompt 요약: <one-line restatement>
   - 실행 단계: Planner → Contract → Generator[ → Evaluator]
   - Tech stack: <stack or "default: React+Vite+FastAPI+SQLite">
   - 예상 시간·비용: <matching evaluator configuration from the cost table>
   - 작업물 위치: .harness/ (gitignored)
   ```

3. Call `AskUserQuestion` with three options:
   - `진행` — start Stage 1 immediately.
   - `tech stack 변경` — collect the desired stack via a follow-up question, regenerate the summary, re-confirm.
   - `중단` — exit without writing to `.harness/`.

   Block until the user responds. Never silently proceed to Stage 1.

4. Branch on the response:
   - `진행` → add `.harness/` to `.gitignore` when needed, create `.harness/`, apply the stale-file rules, then continue to Stage 1.
   - `tech stack 변경` → ask once for the new stack, update the summary, loop back to step 3.
   - `중단` → stop. Do not create `.harness/` files. Acknowledge the cancellation in one line.

### Skip rule

Skip Stage 0 only when the user explicitly requests resume, the handoff is `phase: building` or later, it is fresh/current under the communication protocol, and the user confirms reuse after the stale-file check. A handoff alone is never consent. Otherwise run Stage 0.

## Pipeline Execution

### Stage 1: Planning

Invoke the **spec-planner** skill via Agent subagent.

1. Pass the user's prompt (1-4 sentences) to the Planner agent.
2. The Planner expands it into a detailed product spec.
3. Output: `.harness/product-spec.md` with standard header.
4. Review the spec for completeness before proceeding.

```
Agent instruction: "Use the spec-planner skill to expand the following prompt into a product spec. Write the output to .harness/product-spec.md with the standard YAML header (agent, timestamp, phase: planning, round: 1) per references/communication-protocol.md."
```

### Stage 2: Contract Negotiation

Invoke the **sprint-contract-negotiator** skill via Agent subagent.

1. Pass `.harness/product-spec.md` to the Contract agent.
2. The agent produces a negotiated definition of done.
3. **Default: single contract** for the whole task. Use workspace `.harness/`, producing `.harness/contract.md`.
4. For user-requested phased delivery or tasks over ~6 hours, use a fresh `.harness/sprint-N/` workspace per sprint. After acceptance, copy its immutable `contract.md` to `.harness/contract-sprint-N.md`; never reuse a workspace that already has a contract.

```
Agent instruction: "Use sprint-contract-negotiator with workspace .harness/ (or .harness/sprint-N/ for phased delivery). Read .harness/product-spec.md, negotiate the contract, and add the standard YAML header per references/communication-protocol.md."
```

### Stage 3: Implementation (Generator)

The Generator is the orchestrator itself (or a delegated Agent subagent for isolation).

1. Read the active contract (`.harness/contract.md` or `.harness/contract-sprint-N.md`) for acceptance criteria.
2. Implement the application according to the spec and contract.
3. Use the tech stack specified by the user, or default to React+Vite+FastAPI+SQLite.
4. Commit working increments with descriptive messages.
5. Ensure the application is running and accessible before proceeding to evaluation.
6. If Stage 0 selected no Evaluator, run the project's objective build/tests, report their results, and finish here. Do not enter Stages 4–5.

### Stage 4: Evaluation

Run only when Stage 0 selected an Evaluator. Invoke the **qa-evaluator** skill (and optionally **frontend-design-evaluator**) via a fresh Agent subagent.

1. Pass the active overall or sprint contract and the running application URL to the Evaluator agent.
2. The Evaluator browses the app via Chrome integration and produces a report.
3. Output: `.harness/evaluation-report.md` with PASS/FAIL verdict and specific feedback.
4. If the task has significant UI: also invoke frontend-design-evaluator for design scoring.

```
Agent instruction: "Use the qa-evaluator skill. Read [active contract path] for acceptance criteria. The app is running at [URL]. Write .harness/evaluation-report.md with the standard YAML header (agent, timestamp, phase: evaluating, round: N) per references/communication-protocol.md."
```

**Always spawn a fresh Agent subagent per round.** Reusing the same agent across rounds accumulates context and leads to score inflation — see [harness-tuning-guide.md](references/harness-tuning-guide.md) §4.

### Stage 5: Feedback Loop

If the Evaluator returns FAIL:

1. Read `.harness/evaluation-report.md` for specific feedback items.
2. Address each feedback item in the implementation.
3. Commit fixes.
4. Re-invoke the Evaluator with a **fresh** Agent subagent (increment Round number).
5. Repeat until PASS or maximum iteration count reached (default: 3).

**Advisor escalation after Round 2.** If Round 2 fails with issues overlapping Round 1's feedback (Generator could not address prior items), call `advisor()` before spending Round 3. The advisor sees the full transcript and can diagnose whether the contract is too ambitious, the Generator is missing context, or the Evaluator is asking beyond scope — often saving a wasted round and the escalation described in Gotcha #7.

If the Evaluator returns PASS:

1. Confirm completion to the user.
2. Summarize what was built, tested, and passed.
3. If sprints remain, increment N and negotiate in a new `.harness/sprint-N/` workspace, then publish `.harness/contract-sprint-N.md`.

## Inter-Agent Communication

All communication between agents is **file-based**. One agent writes a file, the next agent reads it. No direct message passing.

See [communication-protocol.md](references/communication-protocol.md) for the full specification.

### File Exchange Summary

| File | Writer | Reader | Purpose |
|------|--------|--------|---------|
| `.harness/product-spec.md` | Planner | Generator, Contract | Product requirements |
| `.harness/contract.md` | Contract | Generator, Evaluator | Acceptance criteria |
| `.harness/evaluation-report.md` | Evaluator | Generator | PASS/FAIL + feedback |
| `.harness/handoff.md` | Any agent | Next agent | Context reset state |

### Standard File Header

Every pipeline artifact must include a YAML frontmatter block at the top. The format is defined authoritatively in [communication-protocol.md](references/communication-protocol.md); keep writers aligned to:

```yaml
---
agent: [authoring agent/skill name]
timestamp: [ISO 8601, e.g., 2026-04-18T14:30:00Z]
phase: [planning|contracting|building|evaluating]
round: [integer, starting at 1]
---
```

## Context Management Strategy

### Opus-class (large context)

With an Opus-class large context window, **compaction is sufficient**. Sprint splitting for context management purposes is unnecessary. The full pipeline state fits comfortably within context.

- Let natural compaction handle context pressure.
- No need for explicit context resets between stages.
- The `.harness/` files serve as durable state regardless.

### Sonnet/Haiku-class (limited context)

Context anxiety is a real concern with smaller context windows. Sprint splitting and explicit context resets are recommended.

- Split large tasks into sprints at the Contract stage.
- After each sprint, perform a context reset.
- On reset: write `.harness/handoff.md` with sufficient state for the next session.
- The handoff file must include: completed work summary, remaining sprints, current contract state, known issues, and file paths for all artifacts.

### Handoff Protocol

When a context reset is needed:

1. Write `.harness/handoff.md` with full pipeline state.
2. Include all file paths, current phase, round number, and pending work.
3. The next session reads the handoff file first to restore context.
4. Verify state restoration by cross-referencing with existing `.harness/` files.

## Evaluator Deployment Decision

Not every task needs an Evaluator. Adding evaluation overhead to a simple task wastes time and money.

### Decision Criteria

**Evaluator required** when:
- Task is at the model's baseline capability boundary (the model might get it wrong).
- Task involves subjective quality requirements (design, UX, copy).
- Expected duration exceeds 30 minutes of autonomous work.
- The task has complex acceptance criteria that benefit from independent verification.

**Evaluator unnecessary** when:
- Task is well within the model's reliable range (simple CRUD, boilerplate, config).
- Objective correctness can be verified by tests alone.
- The overhead of evaluation exceeds the risk of shipping a defect.
- Quick iteration with user feedback is faster than formal evaluation.

### Cost/Time Reference

See [architecture.md](references/architecture.md) for detailed benchmarks.

| Evaluator configuration | Time | Cost | When |
|---|---|---|---|
| None | not separately benchmarked | not separately benchmarked | Objective build/tests are sufficient |
| QA | ~3-6 hr | ~$150 | Independent functional verification is needed |
| QA + design | ~4-6 hr | ~$200 | Significant UI/design quality is in scope |

## Harness Component Re-validation

The harness is not static. As models improve, components may become unnecessary or new capabilities may emerge.

### Re-validation Rules

On new model release:

1. Check if each component is still load-bearing (addressing a real limitation).
2. Remove components that became unnecessary — **simplification first**.
3. Add new capabilities made possible by model improvements.
4. Update prompts to leverage improved model behaviors.

See [harness-tuning-guide.md](references/harness-tuning-guide.md) for the full re-validation checklist and tuning loop.

### Current Component Assessment

| Component | Addresses | Still Needed? |
|-----------|-----------|---------------|
| Planner (spec-planner) | Scope drift, underspecification | Evaluate per model |
| Contract (sprint-contract-negotiator) | Vague done criteria | Evaluate per model |
| QA Evaluator (qa-evaluator) | Self-evaluation blindness | Likely persistent |
| Design Evaluator (frontend-design-evaluator) | Visual quality assessment | Likely persistent |

## Gotchas

2. **File-based communication is the only protocol.** Do not attempt to pass state between agents via in-memory variables, function returns, or prompt injection. Write to `.harness/` files.

3. **Evaluator leniency drift is real.** See [harness-tuning-guide.md](references/harness-tuning-guide.md) §4 "Score Inflation Over Rounds" for the diagnostic and fix. Primary mitigation: always spawn a fresh Agent subagent per evaluation round (no shared context across rounds).

4. **Context reset requires a handoff file.** Never reset context without first writing `.harness/handoff.md`. A reset without a handoff loses all pipeline state.

5. **Do not skip the Contract stage.** Even for simple tasks using the full pipeline, the contract provides the evaluation criteria. Without it, the Evaluator has no objective standard to judge against.

6. **Generator and Evaluator must be separate agents.** The same agent cannot both build and evaluate. This is the core principle of the GAN-inspired pattern — the adversarial relationship drives quality.

7. **Iteration limit exists for a reason.** Default maximum evaluation rounds is 3. If the Generator cannot satisfy the Evaluator in 3 rounds, the issue is likely in the contract (too ambitious or too vague), not in the implementation. Escalate to the user.

9. **Default tech stack is a suggestion, not a mandate.** React+Vite+FastAPI+SQLite is the default only when the user does not specify. Always respect user-specified stacks.

10. **Opus handles the full pipeline in one session; Sonnet/Haiku do not.** Opus-class (large context) models can complete a full pipeline in one session. Sonnet/Haiku-class (smaller context) models require sprint splitting and explicit context resets via `.harness/handoff.md` — running the full pipeline in one go on those models will degrade silently as context pressure mounts.

11. **Stage 0 confirmation gate is non-negotiable.** Whether the skill was auto-invoked from a natural-language trigger or explicitly run via slash command, Stage 0 always fires (unless the handoff skip rule applies). Do not bypass it for "obvious" prompts — the gate is also the user's last chance to correct the default tech stack and scope estimate before the pipeline writes anything to `.harness/`.
