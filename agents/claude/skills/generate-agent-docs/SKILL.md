---
name: generate-agent-docs
description: "Claude·Codex 공통 AGENTS.md, Claude 전용 CLAUDE.md와 관련 에이전트 문서를 생성·갱신한다. 문서 업데이트, CLAUDE.md 업데이트, AGENTS.md 갱신 요청에 사용한다. (구 명칭 generate-claude-md)"
when_to_use: "문서 생성/갱신 요청일 때. 트리거: '/generate-agent-docs', '문서 업데이트해줘', '문서 갱신해줘', '문서 최신화', 'CLAUDE.md 업데이트', 'AGENTS.md 갱신', 'rules 생성', 'contributing-docs 추가', 'update the docs', 'update CLAUDE.md', 'refresh AGENTS.md'. 파일명이 없는 포괄 요청은 Stage 0-2의 대상 확인을 먼저 거친다. CLAUDE.md·AGENTS.md 등 에이전트 문서의 단일 파일 요청도 지원하며, README·API 문서·CHANGELOG는 이 스킬을 호출하지 않는다. 에이전트 문서 생성이 아닌 이 스킬 자체의 분석·리뷰·개선 계획 요청에는 생성 파이프라인을 실행하지 않는다."
group: docs
allowed-tools: Read Write Edit Glob Grep Agent AskUserQuestion ToolSearch WebFetch TaskOutput advisor Bash(workflow-hooks:*)
---

# Agent Docs Generator — Orchestrator

Generate or refine project documentation — root CLAUDE.md, AGENTS.md,
contributing-docs/, nested CLAUDE.md, `.claude/rules/` — under one governing
rule: **keep necessary shared instructions in AGENTS.md and Claude-specific
additions in CLAUDE.md; prefer non-obvious guidance and preserve explicit policy.**
Role split: **AGENTS.md is the primary cross-harness document** (Codex/Amp
read it natively; Claude Code loads it via the `@AGENTS.md` import), and
**CLAUDE.md is the Claude Code-specific layer** on top of that import. The
current Pi adapter loads shared skills and workflow hooks, not AGENTS.md, so do
not claim Pi receives project instructions unless its host integration does.

## Model guidance

Use Advanced for instruction synthesis and semantic review; Standard suits bounded updates and repository discovery, while Lightweight suits literal inventory only.
Recommend Frontier for unresolved conflicts across many instruction layers after Advanced review.
Apply the [shared selection guide](../generate-skills/references/model-selection.md) to similar work and host-supported model choices.

## Active harness capabilities

The Claude tool/model names below are examples, not prerequisites. Resolve
capabilities against the active harness before dispatching; never invoke a
nonexistent tool or unsupported model alias.

| Capability | Claude example | Equivalent or fallback |
| --- | --- | --- |
| Read/search/edit | Read, Glob, Grep, Edit, Write | Native file tools or shell reads and patch edits |
| Fetch sources | ToolSearch then deferred WebFetch | Available web tool; try equivalent official HTML URL if markdown MIME fails |
| Clarify intent | AskUserQuestion | Native user-input tool or ordinary interactive question |
| Independent roles | Agent + TaskOutput | Fresh-context subagents with supplied inputs; otherwise direct work with independence marked unavailable |
| Advisor | advisor() | Available independent reviewer; if absent, record skipped consultation and unresolved evidence |
| Model selection | Role-based recommendation | Apply Model guidance; resolve actual IDs through the host and retain the session when switching is unavailable or not permitted |

A missing question tool does not imply a headless session. Ask in normal text
when interactive. In headless runs, use confirmed facts and existing
authorization only; leave dependent writes pending if a material choice is
unresolved. Direct self-review never counts as an independent review.

For consultation, supply the relevant evidence and question explicitly; do not
assume automatic context forwarding. A reviewer may use the session model in a
fresh context. Model changes alone do not establish independence.


## Pipeline Map

Execute stages strictly in order. Update mode swaps in U1–U3
(references/update-mode.md) at the marked points but keeps the same order.

| Stage | Purpose | Executed by | Reference |
|-------|---------|-------------|-----------|
| 0 | Live-fetch guidance, route generate/update, pick targets | Orchestrator | this file |
| 1 | Analyze project; classify discoverable vs undiscoverable | 3 Explore agents (complex) or direct reads (simple); update adds U1 audit | references/stage1-analyzer.md |
| 2 | Interview user on unresolved items | Orchestrator via AskUserQuestion; update adds U2 drift report | this file + references/update-mode.md |
| 3 | Write files | 1 general-purpose agent; update mode: U3 surgical edits by orchestrator | references/stage3-generator.md |
| 4 | Verify: evidence checklist → bounded repair → selected blind review → final check | Independent roles when available | references/stage4-verifier.md |

Three reference files cut across Stages 3–4, constraining every documented
instruction while Stage 4 rejects the lines that violate them:
references/model-prompting-guides.md (`[W]` rules — how an instruction is
phrased), references/context-engineering-claude5.md (`C1–C4` — whether the
instruction belongs in a doc at all), and references/tdd-agent-loop.md (`T1`
— whether a testing instruction prescribes process or outcome).

## Stage 0: Bootstrap & Routing

### Managed workflow boundary

Run `workflow-hooks contract` before project analysis. Stop when `.harness/`
exists. If `.plans/.implementing` exists, this skill may analyze and propose
documentation changes but must return them to the active `implement-plan` run
instead of writing files itself. Without an active implementation flag,
standalone user-approved surgical updates remain allowed.

This skill is the **"refine over time"** layer on top of the built-in `/init`
command. `/init` is a user-only slash command — it cannot be invoked
programmatically — so this skill consumes its output (an existing CLAUDE.md)
as the baseline, exactly as the official docs prescribe: *"Run `/init` to
generate a starter CLAUDE.md ... then refine over time."*

### Step 0-1 — Load authoritative guidance (live fetch, loud fallback)

references/claude-code-best-practices.md is the **single authoritative
source** for the ✅ include / ❌ exclude table, the prune test, the upstream per-file size recommendation and separately
labeled local budgets, `@import` semantics, the AGENTS.md import pattern, the
`.claude/rules/` `paths` format, and the over-specified CLAUDE.md failure
pattern. Its upstream changes often, so fetch live on every
run:

1. Use the active harness's fetch capability. In Claude, load deferred WebFetch
   with ToolSearch only when those tools exist; elsewhere use the native
   equivalent. If a markdown URL fails by content type, try its official HTML
   equivalent before cache fallback.
2. Fetch the reference's source_url and secondary_source_url when sizing or
   /init behavior is relevant. Record the effective text and source status.
3. Success → use the fetched text. If it differs materially from the cached
   snapshot, report the drift and route cache maintenance through a separate
   `skill-improver generate-agent-docs` run; a project-doc task must not edit
   this global skill as a side effect.
4. **Any** failure (tool not loaded, offline, rate limit, layout change) →
   use the cached snapshot **and** tell the user in one line:
   *"best-practices 라이브 로드 실패, 캐시 사용 (last check: <date>)."*
   Never fall back silently.

**Staleness-gated sources, different cadence**: four reference files carry
their own `source_url(s)` + `check_interval_days` in frontmatter and re-fetch
only when `today - last_upstream_check > check_interval_days` — fetching them
every run is real cost and they move more slowly than the Claude Code docs.
Same loud-fallback rule on failure.

| Reference | Holds | Interval |
|-----------|-------|----------|
| references/model-prompting-guides.md | Per-model instruction-authoring rules (4 `source_urls`; the secondary URL only for cross-model questions) | 14d |
| references/agents-md-best-practices.md | agents.md standard — fetch only when AGENTS.md is a target | 30d |
| references/context-engineering-claude5.md | Claude 5 context-engineering rules C1–C4 (judgment framing, skill-over-section, no memory lines, four-layer placement) | 90d |
| references/tdd-agent-loop.md | Agent-loop TDD findings T1 (conditional reject of agent-directed TDD process mandates + survivor list) | 90d |

### Step 0-2 — Select targets and resolve dependencies

AGENTS.md is the primary source for shared Claude/Codex instructions. For joint
Claude/Codex setup, select AGENTS.md and CLAUDE.md as the default pair. Create or
update AGENTS.md first; CLAUDE.md starts with `@AGENTS.md` and adds only
Claude-specific content. An import-only CLAUDE.md is valid.

Explicit file restrictions take precedence. AGENTS.md-only updates do not touch
CLAUDE.md when its import is already valid. A CLAUDE.md-only request with no
AGENTS.md requires resolving the missing prerequisite before writing; never
create an unapproved companion, broken import, or standalone alternative.
A previously authorized paired setup already covers the prerequisite: do not
ask again. Include shared supporting documents only when requested or needed
within that authorized scope.

| Request | Selected targets |
| --- | --- |
| Joint Claude/Codex setup | AGENTS.md first, then CLAUDE.md |
| AGENTS.md alone | AGENTS.md only |
| CLAUDE.md alone | CLAUDE.md; inspect AGENTS.md dependency before writing |
| contributing-docs | Selected documents and authorized AGENTS.md index changes |
| rules | Selected .claude/rules/ files |
| Generic 문서 / docs / 문서 업데이트해줘 / update the docs | Clarify whether agent documentation is intended; reuse an already established scope |
| Empty arguments | Ask for targets unless session context already establishes them |

README, API docs, CHANGELOG, and reviewing or improving this skill are not
agent-document generation requests. Hand those tasks back to their owning
workflow without launching this pipeline.

### Step 0-3 — Route by selected file state

Inventory the selected targets before analysis. Existing selected content
always receives update-mode surgical edits (U1–U3); missing selected files use
Stage 3 creation rules. Mixed runs preserve existing content while creating only
authorized additions. Unselected files do not change mode or authorize writes.

Update keywords (업데이트 / 수정 / 갱신 / update / refresh) request refinement.
If all selected files are absent, explain that generation is needed and proceed
when the user's request already authorizes it; ask only if intent remains unclear.

An existing CLAUDE.md is a baseline regardless of how it was produced.
For an empty joint setup, proceed with AGENTS.md first; /init is optional
Claude-specific assistance, never a prerequisite or a new approval gate.
Use a light audit when existing evidence already answers Stage 1 questions;
do not infer how a baseline was created from its style alone.

## Generation Philosophy

AGENTS.md owns shared instructions; CLAUDE.md imports that source and adds only
Claude-specific content. Write shared facts once and preserve their meaning
during migration. Do not use a standalone CLAUDE.md as a missing-dependency
workaround.

Apply the include/prune guidance and policy precedence in
references/claude-code-best-practices.md. Keep non-obvious gotchas and explicit
team requirements; exclude redundant source summaries and standard conventions.
Local optimization defaults never override the user's project rules.

Read references/model-prompting-guides.md for scoped writing rules [W],
references/context-engineering-claude5.md for placement defaults C1–C4, and
references/tdd-agent-loop.md for testing defaults and preserved exceptions.
These model/research findings are not universal requirements across harnesses.

Use references/entry-router-guidelines.md only for relevant governance.
references/SOUL.md is an optional static seed when identity content is requested;
do not copy it automatically or replace it with a live global identity file.
Include orchestration policy only when the project's actual work needs it.

## Stage 1: Project Analysis

**Reference**: references/stage1-analyzer.md (complexity criteria, agent
prompt templates, merge protocol).

Detect package/build/test/lint config, repository structure
(monorepo/submodule), documentation/CI layout, and existing `.claude/rules/`
in the target directory.

- **Complex project** (any of: 3+ config file types, monorepo, submodules) →
  spawn 3 Explore agents in one message: config-explorer,
  structure-explorer, docs-explorer. Explore agents are **read-only** — each
  returns findings as its final message; collect from Agent tool results
  (TaskOutput for background runs).
- **Simple project** → read directly, no subagents.

Merge findings, classify each as discoverable vs undiscoverable, separate
facts from `[ASSUMPTION]`s, and present the summary to the user.

**Independent consultation ①**: monorepo with 5+ packages, 3+ submodules, or an
existing CLAUDE.md with complex structure → validate the analysis strategy.

**Effort note**: do not pin `effort` in frontmatter. Select the recommended
model level by role; adjust supported effort separately when analysis remains
the bottleneck. If switching is unavailable, suggest a suitable session model.

## Stage 2: Interview (orchestrator only — do not delegate)

`AskUserQuestion` runs only in the main orchestrator context (Gotcha 1).
Ask only about items Stage 1 could not resolve:

- **WHY**: project purpose / role
- **WHAT**: monorepo package roles, submodule relationships, external service
  dependencies
- **HOW**: work rules / workflow, recurring agent mistakes, approval for
  nested CLAUDE.md files

Present candidate interpretations for ambiguous items and let the user
choose. Confirm every Stage 1 `[ASSUMPTION]`.

**Deep exploration (optional)**: while AskUserQuestion is pending and the
project is a large monorepo (5+ packages) with unresolved questions, spawn
Explore-Deep in the background. Skip when Stage 1 results
suffice.

**Unavailable question tool**: use a normal interactive question or a native
equivalent. In genuinely headless runs, use only confirmed facts and existing
authorization; keep dependent writes pending when a material choice remains.
Never invent interview answers. Prior explicit user decisions need no repeat.

**Update mode**: run U1 after Stage 1 and U2 during this stage
(references/update-mode.md). Show proposed changes and apply those already
authorized by the user's request or prior selection. Ask only about unresolved
scope, material policy changes, or destructive actions requiring approval.

**Independent consultation ②**: user answers contradict Stage 1 detection, or update
mode surfaces 10+ drift items.

## Stage 3: Generation

**Reference**: references/stage3-generator.md (dispatch prompt template,
per-file rules A–E, common writing rules).

Use one writer via the capability mapping and the reference's dispatch inputs.
Provide effective guidance, confirmed facts, prior decisions, selected targets
and original contents. Use direct writing only when delegation is unavailable,
and report that limitation.

**5 possible targets**: root CLAUDE.md, AGENTS.md, contributing-docs/,
nested CLAUDE.md, `.claude/rules/`. Generate only the applicable ones.

**Update mode**: run U3 instead (references/update-mode.md): preserve original
text outside authorized changes. Write shared supporting documents and AGENTS.md
before the CLAUDE.md that imports it. Do not regenerate existing files.

## Stage 4: Verification

Follow references/stage4-verifier.md as the single owner of the checklist,
bounded repair loop, blind-review inputs and final status rules.

Provide the checklist verifier with originals/diffs, selected scope, confirmed
facts, prior decisions and exceptions, effective guidance, final paths and
ordered writes. Missing required evidence is UNVERIFIED, not PASS.

Run at most three checklist passes. Persistent required FAIL/UNVERIFIED is
incomplete verification. Blind review sees only documents and checks only
document-visible properties; it cannot revoke an unobserved team decision.
Fast-mode or unavailable blind review is disclosed as PARTIAL verification.

Apply grounded blind fixes within authorization once, then check the affected
criteria and final references. Never claim fully verified completion for
unchecked final bytes, skipped independent review or unresolved defects.

## Independent Consultation Summary

Use the active harness's available reviewer or advisor through the capability
mapping above. If unavailable, record the skipped consultation and any
unresolved evidence; preserve Stage 4's verification limits.

| # | When | Trigger |
|---|------|---------|
| ① | After Stage 1 | Monorepo 5+ packages, 3+ submodules, or complex existing CLAUDE.md |
| ② | During Stage 2 | User answer ↔ detection mismatch, or 10+ drift items in update mode |
| ③ | During Stage 4 | Verifier FAIL persists after 2 fix rounds |

**Skip consultation**: simple project generation, 1–2 target files,
verification passes on the first run, or the user gave unambiguous
instructions.

## Red Flags — STOP

| You are about to… | Do instead |
|-------------------|------------|
| Regenerate any existing managed agent-doc target from scratch | Route to update mode and preserve its structure |
| Put project-general content in CLAUDE.md, or Claude-only content in AGENTS.md | Apply the placement test (stage3-generator.md Common Writing Rules) — AGENTS.md is cross-harness, CLAUDE.md is `@AGENTS.md` + Claude-only |
| Assume a Claude tool exists in another host | Use the active capability map before source fetching or role dispatch |
| Use the cached best-practices without saying so | Announce the fallback in one line |
| Give the blind Reviewer anything beyond the generated files | Generated file contents only |
| Expand an update beyond existing authorization | Present the new scope or destructive change; reuse prior approval for unchanged scope (U3) |
| Tell a Stage 1 Explore agent to write a file | Explore is read-only — findings return as final messages |
| Add generic self-check scaffolding | Apply W1; preserve concrete team test gates and recommend automation without erasing policy |
| Emit a TDD or test-first process mandate aimed at the agent's own loop | Rewrite as outcome-based verification (tdd-agent-loop.md T1) — keep it only as one of T1's Reconciliation survivors, e.g. a team decision confirmed in Stage 2 |
| Emit an instruction to show, or to suppress, the agent's reasoning | Never (W2) — risks `reasoning_extraction` refusals one way, internal-tag leakage the other |
| Emit a sometimes-relevant multi-step procedure as a CLAUDE.md / AGENTS.md section | Recommend a skill and emit one reference line (C2) — every-session budget is for always-relevant content |
| Add session logs or treat a Notes heading as grounds for deletion | Apply scoped C3; preserve intentional project policy and do not assume every host has auto-memory |
| Edit project docs while `.plans/.implementing` exists | Return proposed edits to the active `implement-plan` run; do not become a second executor |
| Claim full verification with missing evidence or skipped review | Report FAIL, UNVERIFIED or PARTIAL with the actual checklist, blind-review and final-check results |

## Gotchas

Skill-specific pitfalls automation cannot catch. Update whenever a new edge
case is discovered.

1. **Stage 2 cannot be delegated to a subagent.** `AskUserQuestion` only runs
   in the main orchestrator context. Explore-Deep can overlap with the user's
   typing, but the question flow itself stays in the main agent.
2. **references/SOUL.md is a static seed copy, not the live identity file.**
   The live identity is `~/.config/dotrc/agents/rules/SOUL.md` (last synced
   2026-07-19). The bundled copy keeps generation reproducible across
   environments — do not substitute the live file at runtime; re-sync it
   deliberately during skill updates when the live identity has changed.
3. **Blind Reviewer independence is the whole point.** If Phase 1/2 output or
   Stage 1/2 context leaks into the Reviewer prompt, the review becomes
   confirmation and the FAIL filter loses its value.
4. **Model selection follows role needs and host capabilities.** Apply Model
   guidance; use only supported, permitted choices or disclose the fallback.
   Missing advisor or independent roles must be reported, never fabricated.
   Effort selection is separate from model level.

5. **`disable-model-invocation` is intentionally unset.** The skill is
   invasive (writes/edits several project files); auto-invocation can still
   fire from vague phrasing in `description` and `when_to_use`. If false positives
   become a problem, flip the flag on and rely on `/generate-agent-docs`.
6. **Update mode may misread hand-crafted files as drift.** Unusual
   structures can be intentional. Confirm with the user before removing
   sections that look redundant but may carry project-specific meaning.

## Eval Criteria

references/eval-criteria.md defines 6 checks: target/shared ownership,
authorization/preservation, grounded policy, reference/execution integrity,
verification evidence/status, and managed/trigger boundaries.
skill-improver / autoresearch / waza reuse them when optimizing this skill.
