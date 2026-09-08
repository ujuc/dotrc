# Workload-Based Model Selection

This is a local recommendation policy for skills and agents. Profiles describe
work, not API model IDs. Models in the same row are candidates for similar roles;
the pairing does not claim equal performance, price, context limits, or tool
support across providers. Check current host availability before selecting one.

## Starting profiles

| Profile | Choose for | OpenAI candidates | Claude candidates | Move up when |
| --- | --- | --- | --- | --- |
| **Lightweight** | Clear, repeatable extraction, classification, formatting, exact lookups, or reporting a deterministic check | GPT-5.6 Luna | Claude Haiku | The task needs interpretation, state-changing decisions, or coordination across files. |
| **Standard** | Bounded tool use, routine commits with known scope, local fixes with clear acceptance criteria, focused exploration | GPT-5.6 Terra | Claude Sonnet | Requirements conflict, changes cross components, or preserving semantics needs substantial judgment. |
| **Advanced** | Multi-file implementation, architecture decisions, difficult debugging, nuanced writing, semantic/security review, synthesis | GPT-5.6 Sol | Claude Opus | Long-horizon dependencies, costly ambiguity, or a reproduced reasoning failure exceeds this profile. |
| **Frontier** | The hardest interconnected work, consequential unresolved tradeoffs, long autonomous reasoning, or demonstrated gaps at Advanced | GPT-6 Astra | Claude Fable | Reassess inputs, tools, scope and stopping conditions; the top profile is not an unlimited retry budget. |

Start with the profile that fits the current step. A task's length, number of
agents, or the parent's model alone does not determine its profile. A strong
coordinator can delegate a narrow worker at a lower profile; simple shell
execution does not need the coordinator's full reasoning capacity.

## Selection and escalation

1. Honor task-specific user model choices, privacy/local-only constraints, budget,
   and required tools or input modalities. Keep explicit evaluation targets and
   specialized backends such as Gemma separate from the orchestrating model.
2. Classify ambiguity, dependency breadth, consequences of a wrong decision, and
   how directly the result can be verified. Use each skill's recommendation as a
   starting point, then adjust for the actual input.
3. Resolve the profile to an available model from the user's chosen provider.
   Use the host's accepted identifier, not a profile label in native `model`
   fields. New models may fill the same role after capability checks; this table
   is not a provider allowlist.
4. Choose reasoning effort separately, only where supported: lower for explicit
   procedures, moderate for bounded reasoning, higher for difficult inference.
   Effort names and defaults vary by host and model. Raising effort does not add
   missing tools, context capacity, or permissions.
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
> 권장합니다. 변경 분류나 충돌 해결에 복잡한 판단이 필요하면 Sol 또는 Opus
> 수준으로 상향을 권장합니다.

When switching is unavailable:

> 이 작업에는 Terra 또는 Sonnet 수준을 권장합니다. 현재 세션에서는 모델을
> 전환할 수 없어 기존 모델로 진행하며, 실제 모델이 바뀌었다고 보고하지 않습니다.

## Examples

| Current step | Recommendation |
| --- | --- |
| Summarize a supplied diff or format a commit message | Lightweight; preserve supplied facts and scope. |
| Inspect known changes, run required checks, stage the accepted scope and commit | Standard; unresolved staging scope requires clarification, not a guessed commit. |
| Untangle mixed changes or reason through a merge conflict | Advanced; model choice does not authorize staging or resolving unapproved scope. |
| Implement an isolated fix with a clear reproducer | Standard; move to Advanced when the cause crosses components. |
| Design a migration spanning APIs, storage and compatibility | Advanced; Frontier for the hardest unresolved interactions or long-horizon constraints. |
| Run an existing test and report its exit status | Lightweight; interpreting a subtle regression can need Standard or Advanced. |
| Audit skill syntax / review workflow semantics / resolve a difficult cross-skill conflict | Lightweight / Advanced / Frontier as the actual work requires. |

## Source basis

Checked 2026-09-09. The role profiles and pairings above are repository policy
inferred from vendor descriptions, not vendor certifications of equivalence.

- [OpenAI model catalog](https://developers.openai.com/api/docs/models): Luna
  emphasizes cost-sensitive volume, Terra balances intelligence and cost, Sol
  handles complex professional work, and Astra targets the hardest work.
- [Claude model overview](https://platform.claude.com/docs/en/models/overview):
  Haiku emphasizes speed, Sonnet balances speed and intelligence, Opus handles
  complex agentic coding, and Fable targets demanding long-horizon reasoning.
- [Claude cost and intelligence guidance](https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence):
  evaluate effort and cost per completed task; a stronger model may avoid retries.
- [Codex subagent model and reasoning controls](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning):
  actual execution settings belong to the host's agent configuration or supported
  invocation parameters.
