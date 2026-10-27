# Workload-Based Model Selection

Local recommendation policy. Profiles describe work, not API model IDs. Models
in one row are candidates for similar roles, not equals in performance, price,
context or tool support. Check host availability before selecting one.

## Starting profiles

| Profile | Choose for | OpenAI candidates | Claude candidates | Move up when |
| --- | --- | --- | --- | --- |
| **Lightweight** | Clear, repeatable extraction, classification, formatting, exact lookups, or reporting a deterministic check | GPT-6 Luna, GPT-5.6 Luna | Claude Haiku | The task needs interpretation, state-changing decisions, or coordination across files. |
| **Standard** | Bounded tool use, routine commits with known scope, local fixes with clear acceptance criteria, focused exploration | GPT-6.1 Sol, GPT-5.6 Terra | Claude Sonnet | Requirements conflict, changes cross components, or preserving semantics needs substantial judgment. |
| **Advanced** | Multi-file implementation, architecture decisions, difficult debugging, nuanced writing, semantic/security review, synthesis | GPT-5.6 Sol | Claude Opus | Long-horizon dependencies, costly ambiguity, or a reproduced reasoning failure exceeds this profile. |
| **Frontier** | The hardest interconnected work, consequential unresolved tradeoffs, long autonomous reasoning, or demonstrated gaps at Advanced | GPT-6 Astra | Claude Fable | Reassess inputs, tools, scope and stopping conditions; the top profile is not an unlimited retry budget. |

Start with the profile that fits the current step. A task's length, number of
agents, or the parent's model alone does not determine its profile. A strong
coordinator can delegate a narrow worker at a lower profile; simple shell
execution does not need the coordinator's full reasoning capacity.

## Selection and escalation

1. Honor task-specific user model choices, privacy/local-only constraints, budget,
   and required tools or input modalities. Keep explicit evaluation targets
   separate from the orchestrating model.
2. Classify ambiguity, dependency breadth, consequences of a wrong decision, and
   how directly the result can be verified. Use each skill's recommendation as a
   starting point, then adjust for the actual input.
3. Resolve the profile to an available model from the user's chosen provider.
   Use the host's accepted identifier, not a profile label in native `model`
   fields. New models may fill the same role after capability checks; this table
   is not a provider allowlist.
4. Choose reasoning effort separately, only where supported: lower for explicit
   procedures, moderate for bounded reasoning, higher for difficult inference.
   Effort names and defaults vary by host and model, and a level name does not
   mean the same amount of reasoning on a different model; re-check a level
   carried over from another model. Raising effort does not add missing tools,
   context capacity, or permissions.
5. If verification exposes a reasoning gap, first rule out missing inputs,
   unavailable tools and environment errors. Then consider higher effort or the
   next profile, retaining the same acceptance criteria and the owning workflow's
   retry limit. Do not spend another model call on an unchanged missing input.
6. Compare cost per successfully completed task, including handoff and retry
   overhead. Neither the cheapest token price nor the highest profile guarantees
   the cheapest successful run. Do not launch a worker for a trivial command
   when dispatch/context-transfer cost dominates.

Independent review needs a separate context with the relevant evidence. It may
use the same model; changing model names alone does not create independence.

## Recommendation versus execution

Every skill/agent should state a starting profile and a concrete escalation
condition. Keep this guidance in the body; do not invent frontmatter keys or
replace a real model ID with `standard`, `advanced`, or another profile name.

Model omission is an execution fallback, not a workload recommendation. When the
host supports a permitted per-agent selection, apply the resolved model through
that native interface. If the current session cannot switch models, give the
recommendation and disclose the effective model or that it is unknown. Continue
within existing capability/permission limits; never claim a recommendation
changed the running model. Do not silently replace an explicitly requested model.

Give a short user-facing recommendation when asked, when choosing a worker, or
when the profile differs materially from the current setup. State it once per
stage, not before every command. For example:

> 이 작업은 변경 범위가 정해진 표준 실행 수준이므로 Terra 또는 Sonnet을
> 권장합니다. 변경 분류나 충돌 해결에 복잡한 판단이 필요하면 GPT-5.6 Sol 또는
> Opus 수준으로 상향을 권장합니다.

When switching is unavailable:

> 이 작업에는 Terra 또는 Sonnet 수준을 권장합니다. 현재 세션에서는 모델을
> 전환할 수 없어 기존 모델로 진행하며, 실제 모델이 바뀌었다고 보고하지 않습니다.

## Dispatch routing

A skill that dispatches a worker through the host `Agent` tool resolves the
profile to these call arguments. Never write them into frontmatter.

| Profile | `model` / `effort` | Typical work |
| --- | --- | --- |
| Lightweight | `haiku` / `medium` | Deterministic checks, structured extraction, commits touching ≤2 files and ≤40 changed lines, waza launcher runs |
| Standard | `sonnet` / `medium` | Bounded implementation, multi-file commits, focused exploration, research partial reports |
| Advanced | `opus` / `high` | Design, semantic review, synthesis, debugging, humanizer strict verifiers |
| Frontier | `fable` / `xhigh` | Interdependent problems unresolved at Advanced |

Procedure:

1. Classify the step with the skill's stated rule and tell the user in one
   line which profile was chosen and why (예: "파일 1개, 12줄이라 Lightweight(haiku)로 초안을 뽑습니다").
2. If the step sits between two rows, ask with `AskUserQuestion`; the options
   are the two rows.
3. Call `advisor` at most once, only when the choice materially changes cost
   or outcome and the evidence does not settle it.
4. Pass `model` and `effort` as `Agent` arguments. An explicit user model
   choice for the session or task wins over the table.

Read-only roles dispatch as `Explore` (no `Edit`/`Write`; `Bash` available) and
return their report as text for the caller to write. Roles that must write
their own files dispatch as `general-purpose`. Role instructions live under the
calling skill's `references/roles/` and the dispatch prompt begins with
"Read `<absolute role path>` first and follow it."

## Source basis

Repository policy inferred from vendor descriptions, not vendor certifications
of equivalence. Last checked: OpenAI 2026-10-02, Claude 2026-10-08.

- [OpenAI model catalog](https://developers.openai.com/api/docs/models) and
  [latest-model guide](https://developers.openai.com/api/docs/guides/latest-model);
  API IDs, effort support and Codex dispatch notes are in [openai-models.md](openai-models.md).
- [Claude model overview](https://platform.claude.com/docs/en/models/overview)
  and [cost and intelligence guidance](https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence):
  compare cost per completed task; a stronger model may avoid retries. Claude
  Mythos 5.1 is the invitation-only Fable 5.1, not a separate candidate.
- [Codex subagent model and reasoning controls](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning):
  execution settings belong to the host's agent configuration or invocation parameters.
