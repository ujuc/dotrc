# Workload-Based Model Selection

Local recommendation policy. Profiles describe work, not API model IDs. Check
host availability before selecting a model.

## Starting profiles

| Profile | Choose for | Claude candidate | Move up when |
| --- | --- | --- | --- |
| **Lightweight** | Clear, repeatable extraction, classification, routing, formatting, exact lookups, reporting a deterministic check, or side-task workers that search files, read logs or summarize | Claude Haiku | The task needs interpretation, state-changing decisions, or coordination across files. |
| **Standard** | Bounded tool use, routine commits with known scope, local fixes with clear acceptance criteria, focused exploration, repeated, well-defined agent tasks such as investigation, checklist review or drafting | Claude Sonnet | Requirements conflict, changes cross components, or preserving semantics needs substantial judgment. |
| **Advanced** | Multi-file implementation, difficult debugging, nuanced writing, semantic/security review, synthesis; the default when no row clearly fits (between two named rows, ask per Dispatch routing step 2) | Claude Opus | Long-horizon dependencies, costly ambiguity, or a reproduced reasoning failure exceeds this profile. |
| **Frontier** | Major refactors and migrations, architecture planning, leading many subagents, deep research, long unattended runs, or Advanced at `high` still falls short | Claude Fable | Reassess inputs, tools, scope and stopping conditions; the top profile is not an unlimited retry budget. |

Start with the profile that fits the current step. Apart from the Frontier
row's named triggers, a task's length, number of agents, or the parent's model
alone does not determine its profile. A strong
coordinator can delegate a narrow worker at a lower profile; simple shell
execution does not need the coordinator's full reasoning capacity.

## Selection and escalation

1. Honor task-specific user model choices, privacy/local-only constraints, budget,
   and required tools or input modalities. Keep explicit evaluation targets
   separate from the orchestrating model.
2. Classify ambiguity, dependency breadth, consequences of a wrong decision, and
   how directly the result can be verified. Use each skill's recommendation as a
   starting point, then adjust for the actual input.
3. Resolve the profile to an available Claude model. Use the host's accepted
   identifier, not a profile label in native `model` fields. Local policy: use
   the newest Claude model for the role; a newer model replaces the older one in
   the table after a capability check.
4. Choose reasoning effort separately, only where supported: lower for explicit
   procedures, moderate for bounded reasoning, higher for difficult inference.
   Effort names and defaults vary by host and model, and a level name does not
   mean the same amount of reasoning on a different model; re-check a level
   carried over from another model. Raising effort does not add missing tools,
   context capacity, or permissions.
5. If verification exposes a reasoning gap, first rule out missing inputs,
   unavailable tools and environment errors. Then escalate in this order, keeping
   the same acceptance criteria and the owning workflow's retry limit: give the
   model a way to verify its own work (test, build, script); raise effort one
   level; move to the next profile at a lower effort than the smaller model
   used. Past `high`, test the next profile instead of `xhigh`/`max`. Do not
   spend another model call on an unchanged missing input.
6. Compare cost per successfully completed task, including
   handoff and retry overhead. Neither the cheapest token price nor the highest profile guarantees
   the cheapest successful run. Do not launch a worker for a trivial command
   when dispatch/context-transfer cost dominates. Switch a session's model at a
   natural break: the prompt cache belongs to the model that wrote it.

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

> 이 작업은 변경 범위가 정해진 표준 실행 수준이므로 Sonnet을 권장합니다.
> 변경 분류나 충돌 해결에 복잡한 판단이 필요하면 Opus로 상향을 권장합니다.

When switching is unavailable:

> 이 작업에는 Sonnet 수준을 권장합니다. 현재 세션에서는 모델을
> 전환할 수 없어 기존 모델로 진행하며, 실제 모델이 바뀌었다고 보고하지 않습니다.

## Dispatch routing

A skill that dispatches a worker through the host `Agent` tool resolves the
profile to these call arguments. Never write them into frontmatter.

| Profile | `model` / `effort` | Typical work |
| --- | --- | --- |
| Lightweight | `haiku` / `medium` | Deterministic checks, structured extraction, commits touching ≤2 files and ≤40 changed lines, waza launcher runs |
| Standard | `sonnet` / `medium` | Bounded implementation, multi-file commits, focused exploration, research partial reports |
| Advanced | `opus` / `medium`; `high` for verification, review and brownfield debugging | Component design, implementation, synthesis; semantic review and humanizer strict verifiers at `high` |
| Frontier | `fable` / `medium` (also after an Advanced `high` failure, per step 5); `high` for long unattended runs or a `medium` shortfall; `xhigh` only after a measured gain | Planning and refactors at `medium`, the long unattended part at `high` (the playbook starts at medium; the Fable 5.2 guide starts at `high` and gives `high` to long unattended runs) |

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

## Agent teams

For a lead coordinating several workers ([multi-agent scaling post](https://claude.dev/blog/safely-scaling-multi-agent-teams-with-fable-5-2/),
[model-choice playbook](https://claude.dev/blog/which-claude-model-should-you-build-with/); last checked 2026-11-10):

- Playbook: use an Advanced or Frontier lead with Standard workers only for
  work bigger than one context window; skip it for one chain of dependent steps.
- The lead splits and assigns; workers check with the lead when a task is unclear.
- Workers coordinate, including those questions, through shared state (in the
  post, a database and Git); each writes only to its own branch or workspace,
  and a separate step merges.
- An objective check (tests, build, validator) decides when work counts as done.
- A guard block on the lead stops the team until a person reviews it; a block
  on a worker removes that worker.
- Agents tend to give up early on hard problems; a person re-checks an
  "infeasible" verdict before the work is dropped, since human encouragement
  keeps agents from stopping too early.

Local inference, not from the post: in Claude Code, parallel writers use
`isolation: "worktree"`, least privilege comes from permission rules and the
sandbox, and the auto-mode classifier is the pre-execution guard.

## Source basis

Repository policy inferred from vendor descriptions. Last checked: 2026-11-10.

- [Claude model overview](https://platform.claude.com/docs/en/models/overview)
  and [cost and intelligence guidance](https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence):
  compare cost per completed task; a stronger model may avoid retries. Claude
  Mythos 5.2 is Fable 5.2 for verified organizations, not a separate candidate.
  The overview: *"Use Claude Fable 5.2 for demanding reasoning and long-horizon
  agentic work, or when your evals on Claude Opus 5.5 at higher effort still
  fall short."*
- [Prompting Claude Fable 5.2](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2):
  effort, early stopping, subagents and earlier-model instructions for Fable
  5.2. Fetch it live; read the [2026-11-10 backup](prompting-claude-fable-5-2.md)
  only when the fetch fails, and say so in one line.
- [Which Claude model should you build with](https://claude.dev/blog/which-claude-model-should-you-build-with/):
  start on Opus 5.5 at medium; move down for well-scoped or side tasks; move up
  to Fable 5.2 *"when Opus 5.5 at high still falls short, or for long unattended
  runs"*; adjust effort before switching models.
