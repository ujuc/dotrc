---
name: design-agent
description: "독립 실행 에이전트 프로그램(수동 루프·Tool Runner·Managed Agents·Agent SDK)을 인터뷰로 설계하고 docs/agent-designs/ 아래 설계 문서를 쓴다."
when_to_use: "에이전트 설계해줘, 에이전트 만들고 싶어, 에이전트 만들어줘, 자율 에이전트, 에이전트 루프·아키텍처, 봇 만들어줘, Agent SDK vs Managed Agents, design an agent, build an agent, design-agent, /design-agent 요청 시 사용한다. Claude Code 서브에이전트(.claude/agents)·Agent 툴 디스패치·Workflow 스크립트·AGENTS.md 문서에는 쓰지 않는다. 코드는 claude-api, 구현 계획은 writing-plans, 제품 스펙(spec.md)은 spec-planner, 스킬 워커 role 파일은 generate-skills가 맡는다."
group: planning
argument-hint: "[agent-name or one-line task]"
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
---

# Design Agent

Interview the user about a standalone agent program, decide whether it should
be an agent at all, recommend one build approach, and write an approved design
document at `docs/agent-designs/<agent-name>.md` in the current project.

Done means: the tier and the approach are stated with reasons, the design
document exists at that path with no placeholders, the user approved the
written document, and the handoff to `writing-plans` is reported. This skill
writes no code, no `spec.md`, and no plan.

## Model guidance

Use Standard for the gate and the interview. Use Advanced for the
recommendation when constraints conflict (for example secrets must stay
on-premise but the job needs scheduling) and for drafting the success rubric.
Recommend Frontier only when two approaches stay tied after Advanced analysis.
Apply the [shared selection guide](../generate-skills/references/model-selection.md)
for host-supported model choices.

## Reference routing

Load a reference only at the step that needs it.

| Step | Reference |
| --- | --- |
| Gate, Interview | [questions.md](references/questions.md) |
| Recommend | [approaches.md](references/approaches.md) |
| Write | [design-template.md](references/design-template.md) |

## Preflight

1. Read `$ARGUMENTS`. A kebab-case token is the agent name; anything else is
   the task description.
2. Detect with `Glob` and `Grep` what the project already fixes: language
   (`pyproject.toml`, `package.json`, `go.mod`, ...), an existing Anthropic
   SDK or `claude-agent-sdk` dependency, a scheduler (`.github/workflows/*.yml`
   with `schedule`), and the language of existing docs. Treat each finding as
   an answered question; do not ask what the repository already says.
3. The output path is `docs/agent-designs/<agent-name>.md` relative to the
   current working directory. It is outside the managed workflow contract, so
   do not touch `spec.md`, `.research/`, or `.plans/`.

## Step 1: Describe

Ask one open question: what should the agent do? If `$ARGUMENTS` already
carried a task, restate it and ask for the single most important missing
piece; a second gap waits for the next message. Let the user answer in full
before proposing tools or approaches. Then derive the agent
name when `$ARGUMENTS` had none, and stop and ask if the output path already
exists.

## Step 2: Gate

Apply the four criteria in `references/questions.md` → Gate: complexity,
value, viability, cost of error. Decide the tier: single call, batch,
code-driven workflow, or agent. State the decision in one line with the
failing criterion when the answer is "not an agent".

When the tier is not "agent", say so explicitly even though the user said
"agent", describe the simplest shape in two or three sentences, and ask
whether they still want a design document for that shape. Continue only on a
yes; the template's Tier field covers non-agent shapes.

## Step 3: Interview

Walk the question list in `references/questions.md` in order. Each question
changes the design; skip any that Describe or Preflight already answered.

- One question per message, through `AskUserQuestion` with the listed
  options when the host has it; plain text otherwise.
- Propose, don't interrogate: when the description gives an opening, present
  the inferred answer and ask the user to confirm or correct it.
- Stop asking once the approach can be chosen and every section of the
  design template can be filled.

## Step 4: Recommend

Load `references/approaches.md`.

- Agent tier: place the answers on the two axes (who supplies the loop, who
  supplies deployment), pick one approach, name the runner-up, and name the
  single constraint that would flip the choice. Use the archetype table for
  defaults the interview did not cover.
- Other tiers: name the API surface instead (a single request with
  structured output, the Batches API, or your own sequencing code with tool
  calls) and skip the axes and the runner-up.

Run the viability gate in `references/approaches.md` silently. Present the
recommendation plus only the gaps, then wait for a yes. On a no, ask which
constraint changed, return to Step 3 for that question only, and re-present.

## Step 5: Write

Load `references/design-template.md` and fill every section. Write the
document in the language of the project's existing docs; default to English.
Draft the success rubric yourself as 5–10 independently gradeable criteria
and mark it as a starter to tune. Then self-review:

- no placeholder or template text remains;
- the stop condition and the budget are explicit (a number, or "none" with a
  reason);
- every gated action is listed with who answers and what happens unattended;
- no API field name, beta header, or SDK signature appears; the document
  names mechanisms and the implementer verifies the surface.

Write the file with `Write`, show the path, and ask for approval. On
requested changes, edit the file this run created; the "stop if it exists"
rule in Step 1 applies only to files that existed before this run.

## Step 6: Handoff

Report the tier, the approach, open questions, and the path. Name the next
steps without running them: `writing-plans` with the design document as its
spec; for implementation detail, the `claude-api` skill for the manual loop,
Tool Runner, and Managed Agents (its `managed-agents-onboard` subcommand turns
a Managed Agents design into files), and the `claude-code-guide` agent for
Claude Agent SDK questions. Do not generate code here.

## Gotchas

- Answering everything in one pass with assumptions listed at the end is the
  baseline failure this skill exists to fix. Ask the one question that most
  changes the design first.
- "A good report" is not a rubric. Each criterion must be checkable by a
  second person without the author; prefer "not reverted within 7 days" over
  "confirmed by a maintainer" when nobody is obliged to reply.
- Tool Runner and Claude Agent SDK have the same shape (a harness you host)
  but different scope; check `references/approaches.md` before recommending
  either.
- A scheduled run can overlap a manual rerun of itself. The design states how
  double writes are prevented (a concurrency lock, or re-checking state right
  before each write).

## Eval Criteria

```text
EVAL 1: Gate stated
  Question: Does the reply state in one line whether the task needs an agent
  loop, and which of the four criteria decided it?
  Pass condition: tier named with the deciding criterion before any design.
  Fail condition: design or tool list appears without a tier decision.

EVAL 2: One question at a time
  Question: Did every clarifying question go out in its own message?
  Pass condition: no message carries more than one question.
  Fail condition: a questionnaire or a full design with assumptions appended.

EVAL 3: Approach justified on both axes (agent tier only)
  Question: Does the recommendation name the approach, the loop supplier, the
  deployment supplier, and a runner-up with the constraint that would flip
  the choice?
  Pass condition: all five present; SKIP for non-agent tiers.
  Fail condition: any missing, or the approach is named without the axes.

EVAL 4: Gradeable rubric
  Question: Does the design document hold 5–10 success criteria a second
  person can grade without the author?
  Pass condition: every criterion names an observable artifact or measure.
  Fail condition: fewer than 5, or any criterion is a quality adjective only.

EVAL 5: Document complete at the right path
  Question: Does `docs/agent-designs/<agent-name>.md` exist with every
  template section filled and an explicit stop condition and budget?
  Pass condition: file present, no placeholders, both fields explicit;
  SKIP when the user declined a document in Step 2.
  Fail condition: file missing, placeholder text, or a count cap as budget.
```
