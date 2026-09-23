---
source_urls:
  - https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra
  - https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.6
  - https://developers.openai.com/api/docs/guides/reasoning
secondary_source_url: https://developers.openai.com/api/docs/models  # catalog; model pages at /models/<API model ID>
last_upstream_check: 2026-09-23  # fetched live 2026-09-23 (rendered pages and .md exports)
check_interval_days: 14
---

# OpenAI Models — Codex Dispatch Reference

## Scope and precedence

This cache holds the OpenAI model facts and prompting notes Claude uses when it
hands work to Codex or another OpenAI-backed agent: choosing the model and
reasoning effort, and writing the task prompt. It is the OpenAI counterpart of
[`model-prompting-guides.md`](../../generate-agent-docs/references/model-prompting-guides.md),
with a different consumer: a dispatch prompt is system-prompt content, so vendor
prompt guidance is in scope here, while API integration settings are not (see
"Out of scope").

Profiles stay in [`model-selection.md`](model-selection.md); this file resolves
an OpenAI candidate to an API model ID and an effort. Explicit user choices,
repository rules, and the Codex host's own configuration come first. Set the
model and effort through the host's controls ([Codex subagent model and
reasoning controls](https://learn.chatgpt.com/docs/agent-configuration/subagents#choosing-models-and-reasoning));
the parameter names quoted below are Responses API facts, not Codex config keys.

The notes are model-specific evidence. OpenAI says its GPT-6 prompts *"address
behavior observed with GPT-6 Astra; evaluate them with your chosen model and
workload."* For GPT-5.6 and GPT-6 targets, they supersede prompting guidance
written for earlier GPT models.

**Freshness**: re-fetch `source_urls` only when `today - last_upstream_check >
check_interval_days`. When that gate fires, also fetch `secondary_source_url`
and each table model's page, refresh "Catalog facts", and compare the catalog's
model list with the table below; a flagship or GPT-5.6/GPT-6 model missing here
is drift — report it in one line and route cache maintenance to
`skill-improver generate-skills`. On any fetch failure, including an
egress-policy block, use this file and say so in one line:
*"OpenAI 모델 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

**How to fetch**: append `.md` to a page URL for verbatim Markdown
(`/api/docs/models/gpt-6-sol.md`; the guide pages are
`/api/docs/guides/latest-model/<model>.md`) and read it with `curl -sL`. Read
positioning sentences and the catalog's reasoning ratings from the rendered page
(WebFetch or a browser such as ego-browser), because the exports can lag: on
2026-09-23 `/api/docs/models.md` still recommended GPT-5.6 Terra and Luna where
the rendered catalog named GPT-6 Sol and Luna. Per-model `.md` values matched
the rendered pages that day. WebFetch summarizes through a small model, so
quote from `curl` or browser text, not from a WebFetch answer.

---

## Model facts

| Family | API model ID | OpenAI positioning | Reasoning effort |
|--------|--------------|--------------------|------------------|
| GPT-6 | `gpt-6-astra` | *"our highest level of capability"*; *"our most intelligent model yet"* | `low`, `medium`, `high`, `xhigh`, `max`; no `none`: *"use `low` instead"*; default not stated |
| GPT-6 | `gpt-6-sol` | *"strong reasoning on demanding tasks"* | `none`, `low`, `medium`, `high`, `xhigh`, `max`; default `medium` |
| GPT-6 | `gpt-6-luna` | *"efficient, repeatable work at scale"* | Same as GPT-6 Sol |
| GPT-5.6 | `gpt-5.6-sol` (alias `gpt-5.6`) | *"the model for flagship capability"* | `none`, `low`, `medium`, `high`, `xhigh`, `max`; default `medium` |
| GPT-5.6 | `gpt-5.6-terra` | *"a balance of intelligence and cost"* | Same as GPT-5.6 Sol |
| GPT-5.6 | `gpt-5.6-luna` | *"efficient, high-volume workloads"* | Same as GPT-5.6 Sol |

Also stated by OpenAI:

- GPT-6 Astra *"is generally better than GPT-5.6 Sol and earlier models at
  staying coherent during long tasks."* It *"achieves stronger results while
  using substantially fewer output tokens—delivering a lower estimated API cost
  per task than earlier models despite its higher per-token pricing."*
- GPT-6: *"If your existing request uses `minimal`, start with `low` and compare
  results on representative tasks."*
- GPT-5.6 *"is especially token-efficient"* and *"tends to be more concise by
  default than GPT-5.5."*
- Pro mode is not a separate model: *"keep your selected GPT-5.6 model and set
  `reasoning.mode` to `pro`"*. GPT-6 lists pro mode among the capabilities it
  keeps from GPT-5.6.
- GPT-5.6 runs *"real-time cyber and biology misuse classifiers"* that *"may
  occasionally intervene on legitimate work, particularly in dual-use areas"*.
  GPT-6 Astra adds asynchronous misalignment monitoring.

## Catalog facts

Values are copied as printed on each model's page
(`https://developers.openai.com/api/docs/models/<API model ID>`); prices are
Standard text-token rates in USD per 1M tokens.

| API model ID | Catalog tagline | Reasoning rating | Knowledge cutoff | Input / cached input / output |
|--------------|-----------------|------------------|------------------|-------------------------------|
| `gpt-6-astra` | *"Our most capable model, built for the hardest end-to-end work"* | Highest | Apr 30, 2026 | $10 / $1 / $50 |
| `gpt-6-sol` | *"Built to power complex coding and agentic workflows."* | Highest | Apr 20, 2026 | $2 / $0.2 / $10 |
| `gpt-6-luna` | *"Our most efficient model for focused, high-volume tasks."* | High | May 18, 2026 | $0.1 / $0.01 / $0.5 |
| `gpt-5.6-sol` | *"Flagship model for complex professional work"* | Highest | Feb 16, 2026 | $4 / $0.4 / $20 (promotional) |
| `gpt-5.6-terra` | *"GPT-5.6 model that balances intelligence and cost"* | Higher | Feb 16, 2026 | $2 / $0.2 / $12 |
| `gpt-5.6-luna` | *"GPT-5.6 model optimized for cost-sensitive workloads"* | High | Feb 16, 2026 | $0.2 / $0.02 / $1.2 |

- All six list *"1,050,000 context window"*, *"Maximum input tokens: 922,000"*,
  and *"128,000 max output tokens"*, with text and image input and text output.
- Long prompts: *"Prompts with more than 272K input tokens are priced at 2x
  input and cache rates and 1.5x output for the full request"* (GPT-6 pages;
  the GPT-5.6 pages say *"2x input and 1.5x output"*). All six: *"Cache writes
  are billed at 1.25x the uncached input token rate."*
- GPT-5.6 Sol: *"GPT-5.6 Sol’s promotional pricing is available at least
  through November 21, 2026."* Re-check its price after that date.
- Defaults: *"GPT-6 Sol and Luna also default to `medium` reasoning effort."*
  No fetched page states GPT-6 Astra's default. Sending `none` to Astra fails:
  *"Setting reasoning.effort (Responses) or reasoning_effort (Chat Completions)
  to none returns HTTP 400."*
- Aliases: *"The `gpt-5.6` alias routes requests to GPT-5.6 Sol."* The catalog
  lists no `gpt-6` alias (checked 2026-09-23): Astra's snapshot list holds only
  `gpt-6-astra`, and `/api/docs/models/gpt-6` returns 404.
- Placement across families is inconsistent upstream, so record it without
  resolving it. The catalog says *"Choose GPT-6 Sol to balance intelligence and
  cost, or GPT-6 Luna for cost-sensitive, high-volume workloads."* The reasoning
  guide still says *"For lower cost, consider gpt-5.6-terra, or gpt-5.6-luna for
  the lowest cost and latency."* The reasoning rating comes from the rendered
  catalog only, not from the `.md` export.

## Choosing model and effort

- Resolve the workload profile in `model-selection.md` first. Its OpenAI
  candidates are GPT-6 Luna or GPT-5.6 Luna (Lightweight), GPT-6 Sol or GPT-5.6
  Terra (Standard), GPT-5.6 Sol (Advanced), and GPT-6 Astra (Frontier). GPT-6
  Sol is placed by the catalog's "balance intelligence and cost" line even
  though its catalog reasoning rating equals GPT-5.6 Sol's (see "Catalog
  facts").
- GPT-5.6 effort, per OpenAI: *"Use `medium` as a balanced starting point and
  `low` for latency-sensitive workloads."* *"Use `high` or `xhigh` when more
  reasoning produces a measured quality gain."* *"Reserve `max` for the hardest
  quality-first workloads."*
- GPT-6 Astra: never request `none`; `low` is the floor. Its default effort is
  unstated, so set one explicitly. GPT-6 Sol and Luna default to `medium`.
- Thinking amount is an effort or mode setting, not prompt text: for pro mode,
  *"You do not need to ask the model to “use pro mode,” “think harder,” or
  generate several candidate answers."*

## Dispatch-prompt guidance

Each item names the model, the vendor evidence, and what the Codex task prompt
should carry. The source pages hold ready-made prompt text for each; adapt it
rather than pasting it whole.

### P1 — Authorize the scope and name the stops

GPT-6 Astra is *"more likely to ask the user a question when additional input
could materially change the result. This can cause it to stop when the user may
expect it to make reasonable assumptions and persist."* GPT-5.6: *"Define what
level of action each request authorizes so the model can continue safe, in-scope
work without unnecessary pauses while stopping before external, destructive,
costly, or scope-expanding actions."*

State the authorized scope, the safe local actions (read files, edit in-scope
code, run tests), and the actions that need confirmation. Ask for approval only
after a concrete result: *"The user should be approving a concrete, reviewable
result."*

### P2 — Give outcomes and state each rule once

GPT-5.6 *"can better infer the user’s underlying goal and intended level of work
from context, so you often do not need to prescribe every step. Continue to
provide domain context, hard constraints, approval boundaries, and success
criteria. Tell the model when an important ambiguity should trigger a
question."* Also: *"State each instruction once."* *"Repeating instructions such
as “ask first,” “do not mutate,” or “wait for approval” can cause unnecessary
approval requests for safe, expected actions."*

### P3 — Make instruction precedence explicit

GPT-6 Astra *"can be more sensitive to instructions contained in skills and
other files, such as `AGENTS.md`"*, and *"unclear or conflicting guidance in a
skill file may cause the model to pause and block work early. Make the priority
of user instructions and skills explicit."*

Say that the task instructions win over conflicting skill guidance. If a run
pauses unexpectedly, ask it to name the SKILL.md and quote the instruction that
caused the pause.

### P4 — Specify the report you need back

GPT-6 Astra *"tends to use lists, tables and Markdown to make responses
scannable."* GPT-5.6 is more concise than GPT-5.5, and broad brevity instructions
*"may be unnecessary for some tasks and can sometimes make responses too
brief."*

Name the report's contents (changed files, checks run and their results, open
issues) and what a short answer must keep: *"Keep all required facts,
decisions, caveats, and next steps."*

### P5 — Set the delegation bar

GPT-6 Astra *"may delegate less often than desired for your workflow. Specify
when and how much it should use subagents for parallel work."* Say whether
parallel subagents are wanted and for which parts.

### P6 — Calibrate testing

GPT-6 Astra *"tends to be thorough in testing before considering a task
complete. For smaller tasks, this can result in broader tests than the task
requires."* Name the required checks and whether new tests are wanted. Vendor
text: *"Do not write tests for reversible, low-impact changes that mirror the
implementation."*

## Divergences from the Claude guides — recorded, not resolved

| Topic | Claude side | OpenAI side | In a Codex prompt |
|-------|-------------|-------------|-------------------|
| Formatting | Fable 5.1 *"uses bold less and is less likely to reach for headers, lists, or quotation marks"*; anti-formatting lines are removed | Astra *"tends to use lists, tables and Markdown"* | State the format (P4); do not copy the Claude-side removal |
| Delegation | Opus 5 and Fable 5 delegate readily (W6) | Astra *"may delegate less often than desired"* | Opposite direction: say when to delegate (P5) |
| Verification | Opus 5 over-verifies (W1) | Astra runs *"broader tests than the task requires"* | Same direction: name the required checks (P6) |
| Asking | Fable 5.1 may ask *"permission for work you already requested"* | Astra is *"more likely to ask the user a question"* | Same direction: authorize the scope (P1) |

W1 and W6 refer to `model-prompting-guides.md`. Keep these divergences in this
Claude-side cache; shared rules stay model-neutral.

## Repo implication

OpenAI: *"We **strongly recommend** auditing skills and other files accessible
to your model for instructions that could influence its behavior."* Codex loads
the shared `rules/AGENTS.md` and this skill tree through `~/.codex/AGENTS.md` and
`~/.codex/skills`. Before relying on GPT-6 Astra for Codex runs, audit them for
conflicting or pause-inducing lines.

## Out of scope — do not import

Responses API integration settings: async tool calling, mid-turn steering,
`configuration_update`, Programmatic Tool Calling, the multi-agent beta API,
`prompt_cache_options`, `reasoning.context`, `text.verbosity`,
`safety_identifier`, image detail, data residency, and fast mode. They configure
an API application, not a Codex task prompt or a repository document.
