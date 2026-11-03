---
source_urls:
  - https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra
  - https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.6
  - https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6
  - https://developers.openai.com/api/docs/guides/reasoning
  - https://developers.openai.com/codex/models  # Codex availability and version floors
secondary_source_url: https://developers.openai.com/api/docs/models  # catalog; model pages at /models/<API model ID>
last_upstream_check: 2026-11-01  # fetched live 2026-11-01 (rendered pages and .md exports)
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
and each table model's page, use the refreshed values in-session, and compare
the catalog's model list with the table below; a changed value or a flagship or
GPT-5.6/GPT-6 model missing here is drift — report it in one line and route
cache maintenance to `/generate-skills generate-skills 업데이트 openai-models.md`. A dispatch never edits
this file or its date. On any fetch failure, including an
egress-policy block, use this file and say so in one line:
*"OpenAI 모델 가이드 라이브 로드 실패, 캐시 사용 (last check: <date>)."*

**How to fetch**: append `.md` to a page URL for verbatim Markdown
(`/api/docs/models/gpt-6-sol.md`; the guide pages are
`/api/docs/guides/latest-model/<model>.md`) and read it with `curl -sL`. Read
positioning sentences and the catalog's reasoning ratings from the rendered page
(WebFetch or a browser such as ego-browser), because the exports can lag: on
2026-09-23 `/api/docs/models.md` still recommended GPT-5.6 Terra and Luna where
the rendered catalog named GPT-6 Sol and Luna. Per-model `.md` values matched
the rendered pages that day. On 2026-10-02 both named GPT-6.1 Sol and GPT-6 Luna. WebFetch summarizes through a small model, so
quote from `curl` or browser text, not from a WebFetch answer.

---

## Model facts

| Family | API model ID | OpenAI positioning | Reasoning effort |
|--------|--------------|--------------------|------------------|
| GPT-6 | `gpt-6-astra` | *"Highest intelligence"*; *"our most intelligent model yet"* | `low`, `medium`, `high`, `xhigh`, `max`; no `none`: *"use `low` instead"*; default not stated |
| GPT-6 | `gpt-6.1-sol` | *"near-Astra performance at a lower cost"* | `low`, `medium`, `high`, `xhigh`, `max`; *"does not support `none` or `minimal`"*; default `medium` |
| GPT-6 | `gpt-6.1-terra` | *"Fast and efficient"*; *"For visual reasoning, precise computer use, and clear, natural writing."* | `none`, `low`, `medium`, `high`, `xhigh`, `max`; default `medium` |
| GPT-6 | `gpt-6-sol` | *"built for complex coding and agentic workflows"*; superseded: *"See GPT-6.1 Sol for the newer Sol model."* | `none`, `low`, `medium`, `high`, `xhigh`, `max`; default `medium` |
| GPT-6 | `gpt-6-luna` | *"Strong performance for focused, high-volume tasks."* | Same as GPT-6 Sol |
| GPT-5.6 | `gpt-5.6-sol` (alias `gpt-5.6`) | *"the model for flagship capability"* | `none`, `low`, `medium`, `high`, `xhigh`, `max`; default `medium` |
| GPT-5.6 | `gpt-5.6-terra` | *"a balance of intelligence and cost"* | Same as GPT-5.6 Sol |
| GPT-5.6 | `gpt-5.6-luna` | *"efficient, high-volume workloads"* | Same as GPT-5.6 Sol |

Also stated by OpenAI:

- GPT-6 Astra *"is generally better than GPT-5.6 Sol and earlier models at
  staying coherent during long tasks."* In several evaluations,
  *"Astra achieved stronger results using substantially fewer output tokens. Its
  estimated API cost per task was lower than earlier models despite its higher
  per-token pricing."*
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
| `gpt-6-astra` | *"Our most capable model for the most demanding work."* | Highest | Apr 30, 2026 | $10 / $1 / $50 |
| `gpt-6.1-sol` | *"Near-Astra performance for complex work at a lower cost."* | Highest | Apr 30, 2026 | $2 / $0.1 / $10 |
| `gpt-6.1-terra` | *"A fast, efficient model for visual reasoning, precise computer use, and clear, natural writing."* | Highest | Jun 01, 2026 | $1 / $0.05 / $5 |
| `gpt-6-sol` | *"Built to power complex coding and agentic workflows."* | Highest | Apr 20, 2026 | $2 / $0.2 / $10 |
| `gpt-6-luna` | *"Our most efficient model for focused, high-volume tasks."* | High | May 18, 2026 | $0.1 / $0.01 / $0.5 |
| `gpt-5.6-sol` | *"GPT-5.6 flagship model for complex professional work"* | Highest | Feb 16, 2026 | $4 / $0.4 / $20 (promotional) |
| `gpt-5.6-terra` | *"GPT-5.6 model that balances intelligence and cost"* | Higher | Feb 16, 2026 | $2 / $0.2 / $12 |
| `gpt-5.6-luna` | *"GPT-5.6 model optimized for cost-sensitive workloads"* | High | Feb 16, 2026 | $0.2 / $0.02 / $1.2 |

- All eight list *"1,050,000 context window"*, *"Maximum input tokens: 922,000"*,
  and *"128,000 max output tokens"*, with text and image input and text output.
  *"GPT-6.1 Sol uses a default context window of 500K tokens in Codex and ChatGPT
  Work. Usage drawn from your subscription has no long-context surcharge."*
- Long prompts: *"Prompts with more than 272K input tokens are priced at 2x
  input and cache rates and 1.5x output for the full request"* (GPT-6 pages;
  the GPT-5.6 pages say *"2x input and 1.5x output"*). All but GPT-6.1 Terra: *"Cache writes
  are billed at 1.25x the uncached input token rate."* Terra prints the rate in
  dollars: *"Standard cache writes cost $1.25 per million tokens for 30-minute
  retention"*.
- GPT-5.6 Sol: *"GPT-5.6 Sol’s promotional pricing is available at least
  through November 21, 2026."* Re-check its price after that date.
- Defaults: *"GPT-6.1 Sol, GPT-6 Sol, and GPT-6 Luna also default to `medium`
  reasoning effort."*
  No fetched page states GPT-6 Astra's default. Sending `none` to Astra fails:
  *"Setting reasoning.effort (Responses) or reasoning_effort (Chat Completions)
  to none returns HTTP 400."*
- Cybersecurity aliases: `gpt-5.6-cyber` requires *"separate approval and
  provisioning"*. The Daybreak Blue/Red aliases are deprecated: *"This alias is
  deprecated, please use the latest cyber model available to you."* None are
  profile candidates.
- Aliases: *"The `gpt-5.6` alias routes requests to GPT-5.6 Sol."* The catalog
  lists no `gpt-6` alias (checked 2026-09-23): Astra's snapshot list holds only
  `gpt-6-astra`, and `/api/docs/models/gpt-6` returns 404.
- Placement across families is inconsistent upstream, so record it without
  resolving it. The catalog says *"Choose GPT-6.1 Sol to balance intelligence
  and cost, or GPT-6 Luna for cost-sensitive, high-volume workloads"* (checked
  2026-10-02; on 2026-09-23 it named GPT-6 Sol). GPT-6.1 Sol's own page says
  *"Near-Astra performance"*, and the model-selection guide ranks Luna, GPT-6.1
  Sol and Astra, with *"GPT-6.1 Sol · Extra high"* for *"decisions built from
  conflicting evidence"*. The reasoning guide still says *"For lower cost, consider gpt-5.6-terra, or gpt-5.6-luna for
  the lowest cost and latency."* The reasoning rating comes from the rendered
  catalog only, not from the `.md` export.

## Choosing model and effort

- Resolve the workload profile in `model-selection.md` first. Local policy: use
  the newest model for the role, and price is no criterion. Its OpenAI candidates
  are GPT-6 Luna (Lightweight), GPT-6.1 Terra (Standard), GPT-6.1 Sol (Advanced),
  and GPT-6 Astra (Frontier). *"GPT-6.1 Terra requires Codex CLI 0.159.0 or
  later."* GPT-6 Sol and the GPT-5.6 models stay here as catalog facts, not
  candidates.
- GPT-5.6 effort, per OpenAI: *"Use `medium` as a balanced starting point and
  `low` for latency-sensitive workloads."* *"Use `high` or `xhigh` when more
  reasoning produces a measured quality gain."* *"Reserve `max` for the hardest
  quality-first workloads."* *"Before increasing reasoning effort, check whether
  the prompt is missing a success criterion, dependency rule, tool-routing rule,
  or verification loop."*
- GPT-6 Astra and GPT-6.1 Sol: never request `none` (or `minimal` on 6.1 Sol);
  `low` is the floor. GPT-6.1 Terra, GPT-6 Sol, and GPT-6 Luna accept `none`.
  Astra's default effort is unstated, so set one explicitly. GPT-6.1 Sol, GPT-6.1
  Terra, GPT-6 Sol, and Luna default to `medium`. For Terra: *"Start with `medium`
  and increase it if the improvement in quality is worth the added time and
  tokens."*
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
result."* On long runs, name the current stage (GPT-5.6): *"Distinguish
research, design, implementation, review, and external coordination so the
model does not silently move from one layer to another."*

### P2 — Give outcomes and state each rule once

GPT-5.6 *"can better infer the user’s underlying goal and intended level of work
from context, so you often do not need to prescribe every step. Continue to
provide domain context, hard constraints, approval boundaries, and success
criteria. Tell the model when an important ambiguity should trigger a
question."* Also: *"State each instruction once."* *"Repeating instructions such
as “ask first,” “do not mutate,” or “wait for approval” can cause unnecessary
approval requests for safe, expected actions."*

Keep absolute wording for real invariants: *"Use ALWAYS, NEVER, must, and only for
true invariants such as safety rules, required fields, or actions that should
never happen. For judgment calls, such as when to search, ask, use a tool, or
keep iterating, prefer decision rules."*

### P3 — Make instruction precedence explicit

GPT-6 Astra *"can be more sensitive to instructions contained in skills and
other files, such as `AGENTS.md`"*, and *"unclear or conflicting guidance in a
skill file may cause the model to pause and block work early. Make the priority
of user instructions and skills explicit."* The GPT-5.6 prompting guidance
adds: *"GPT-5-class models follow prompt contracts closely, so conflicting rules
can create more instability than missing detail."*

Say that the task instructions win over conflicting skill guidance. If a run
pauses unexpectedly, ask it to name the SKILL.md and quote the instruction that
caused the pause.

### P4 — Specify the report you need back

GPT-6 Astra *"tends to use lists, tables and Markdown to make responses
scannable."* GPT-5.6 is more concise than GPT-5.5, and broad brevity instructions
*"may be unnecessary for some tasks and can sometimes make responses too
brief."*

Name the report's format and contents (changed files, checks run and their
results, open issues) and what a short answer must keep: *"Keep all required facts,
decisions, caveats, and next steps."*

### P5 — Set the delegation bar

GPT-6 Astra *"may delegate less often than desired for your workflow. Specify
when and how much it should use subagents for parallel work."* Say whether
parallel subagents are wanted and for which parts. Ask for legible handoffs too:
*"Messages between agents may contain grammar or spacing errors."*

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
Claude-side cache; `rules/AGENTS.md` stays model-neutral.

## Repo implication

OpenAI: *"We **strongly recommend** auditing skills and other files accessible
to your model for instructions that could influence its behavior."* This repository
no longer supplies rules or skills to Codex; before relying on GPT-6 Astra, audit
the prompt, the target project's files and any `~/.codex` user state for
conflicting or pause-inducing lines.

## Out of scope — do not import

Responses API integration settings: async tool calling, mid-turn steering,
`configuration_update`, Programmatic Tool Calling, the multi-agent beta API,
`prompt_cache_options`, `reasoning.context`, `text.verbosity`,
`safety_identifier`, image detail, data residency, fast mode, Ultrafast mode,
`phase`, reasoning summaries, and `reasoning.mode`. They configure
an API application, not a Codex task prompt or a repository document.
