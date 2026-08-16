---
name: generate-agent-docs
description: 프로젝트용 CLAUDE.md(Claude 전용 레이어), AGENTS.md(Codex·Amp 겸용 크로스하네스 주 문서), contributing-docs/, .claude/rules/ 파일을 발견 불가능 정보 원칙에 따라 생성하거나 업데이트한다. 파일명을 특정하지 않은 포괄적인 '문서 업데이트' 요청도 대상을 한 줄로 확인한 뒤 여기서 처리한다. (구 명칭 generate-claude-md)
when_to_use: "문서 생성/갱신 요청일 때. 트리거: '/generate-agent-docs', '문서 업데이트해줘', '문서 갱신해줘', '문서 최신화', 'CLAUDE.md 업데이트', 'AGENTS.md 갱신', 'rules 생성', 'contributing-docs 추가', 'update the docs', 'update CLAUDE.md', 'refresh AGENTS.md'. 파일명이 없는 포괄 요청은 Stage 0-3의 대상 확인을 먼저 거친다. CLAUDE.md·AGENTS.md 등 에이전트 문서의 단일 파일 요청도 지원하며, README·API 문서·CHANGELOG는 이 스킬을 호출하지 않는다."
group: docs
model: opus
allowed-tools: Read Write Edit Glob Grep Agent AskUserQuestion ToolSearch WebFetch TaskOutput advisor
---

# Agent Docs Generator — Orchestrator

Generate or refine project documentation — root CLAUDE.md, AGENTS.md,
contributing-docs/, nested CLAUDE.md, `.claude/rules/` — under one governing
rule: **document only what an agent cannot discover by reading the code.**
Role split: **AGENTS.md is the primary cross-harness document** (Codex/Amp
read it natively; Claude Code loads it via the `@AGENTS.md` import), and
**CLAUDE.md is the Claude Code-specific layer** on top of that import.

## Pipeline Map

Execute stages strictly in order. Update mode swaps in U1–U3
(references/update-mode.md) at the marked points but keeps the same order.

| Stage | Purpose | Executed by | Reference |
|-------|---------|-------------|-----------|
| 0 | Live-fetch guidance, route generate/update, pick targets | Orchestrator | this file |
| 1 | Analyze project; classify discoverable vs undiscoverable | 3 Explore agents (complex) or direct reads (simple); update adds U1 audit | references/stage1-analyzer.md |
| 2 | Interview user on unresolved items | Orchestrator via AskUserQuestion; update adds U2 drift report | this file + references/update-mode.md |
| 3 | Write files | 1 general-purpose agent; update mode: U3 surgical edits by orchestrator | references/stage3-generator.md |
| 4 | Verify: checklist → fix loop → blind review | sonnet subagents + advisor | references/stage4-verifier.md |

Three reference files cut across Stages 3–4, constraining every documented
instruction while Stage 4 rejects the lines that violate them:
references/model-prompting-guides.md (`[W]` rules — how an instruction is
phrased), references/context-engineering-claude5.md (`C1–C4` — whether the
instruction belongs in a doc at all), and references/tdd-agent-loop.md (`T1`
— whether a testing instruction prescribes process or outcome).

## Stage 0: Bootstrap & Routing

This skill is the **"refine over time"** layer on top of the built-in `/init`
command. `/init` is a user-only slash command — it cannot be invoked
programmatically — so this skill consumes its output (an existing CLAUDE.md)
as the baseline, exactly as the official docs prescribe: *"Run `/init` to
generate a starter CLAUDE.md ... then refine over time."*

### Step 0-1 — Load authoritative guidance (live fetch, loud fallback)

references/claude-code-best-practices.md is the **single authoritative
source** for the ✅ include / ❌ exclude table, the prune test (*"Would
removing this cause Claude to make mistakes? If not, cut it"*), the 200-line
ceiling, `@import` semantics, the AGENTS.md import pattern, the
`.claude/rules/` `paths` format, and the over-specified CLAUDE.md failure
pattern. Its upstream changes often, so fetch live on every
run:

1. Call `ToolSearch` with query `select:WebFetch`. WebFetch is a **deferred
   tool**: `allowed-tools` only pre-grants permission — until the schema is
   loaded, calling it fails with a validation error that is *not* a network
   error.
2. `WebFetch` the `source_url` in that file's frontmatter (plus
   `secondary_source_url` when CLAUDE.md sizing or `/init` behavior is in
   scope).
3. Success → use the fetched text; if it differs materially from the cached
   snapshot, update the cache and bump `last_upstream_check`.
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

### Step 0-2 — Route generate vs update

Two signals: update keywords and whether any selected target already exists. **Existing selected content always routes to update mode.** Selected targets include root or nested CLAUDE.md, AGENTS.md, contributing-docs/, and `.claude/rules/`.

| Signal | Branch |
|--------|--------|
| `$ARGUMENTS` contains `업데이트` / `수정` / `갱신` / `update` / `refresh` | **Update mode** (U1→U3 refine path) |
| No keyword + any selected target exists | **Update mode** — preserve existing structure; never regenerate it |
| No keyword + none of the selected targets exists | **Generate mode** (full Stage 1→4), after the recommendation below |

- **No-baseline recommendation**: state in one line that no baseline was found
  and that running `/init` first (the official "/init then refine" workflow)
  is preferred, then ask whether to proceed with full generation now or
  re-invoke after `/init`. Render the prompt in the user's language. If the
  user proceeds, run Stage 1→4 as the standalone fallback.
- **Light refine for rich baselines**: if the existing CLAUDE.md came from
  `/init`'s `CLAUDE_CODE_NEW_INIT=1` flow (it already did subagent exploration
  + interview), skip heavy Stage 1 exploration and apply only this skill's
  differentiators: discoverability filter, AGENTS.md, contributing-docs/,
  rules/, blind review.

### Step 0-3 — Identify targets

| Keyword in `$ARGUMENTS` | Target |
|-------------------------|--------|
| `CLAUDE.md` alone | Root CLAUDE.md only |
| `AGENTS.md` alone | AGENTS.md only |
| `contributing-docs` | contributing-docs/ plus an AGENTS.md index update only when needed |
| `rules` | `.claude/rules/` only |
| `업데이트` with no specific file name | All 5 file types |
| Generic `문서` / `docs` with no file named | All 5 file types — after the confirmation below |

Empty `$ARGUMENTS` → ask which of the five managed target types to handle, then apply Step 0-2 to that selected set. Never infer all targets from bare `/generate-agent-docs`.

**Generic-request confirmation.** "문서 업데이트해줘" / "update the docs" does
not say *which* docs, and this skill is expensive to aim at the wrong target.
Before Stage 1, state in one line what it covers — root CLAUDE.md, AGENTS.md,
contributing-docs/, nested CLAUDE.md, and `.claude/rules/` — and ask whether that is the target. If
the user meant README, API docs, a CHANGELOG, or any other project document,
hand the task back rather than generating agent docs they did not ask for.
Skip this confirmation when `$ARGUMENTS` already names a file or target type.

## Generation Philosophy

- **Undiscoverable information only.** AGENTS.md is a diagnostic list of
  problems the code has not yet solved. Research evidence: auto-generated
  context → success rate −2–3%, cost +20%; human-written gotchas → +4%
  (ETH Zurich). Every line must justify its existence. The operative
  include/exclude rule lives in the authoritative source (Step 0-1).
- **Cross-harness role split.** AGENTS.md is the primary project document,
  consumed by every harness (Codex/Amp natively; Claude Code through the
  `@AGENTS.md` import that opens CLAUDE.md) — keep it harness-neutral and
  plain markdown (no frontmatter). CLAUDE.md holds only Claude Code-specific
  content below the import. The operative placement test lives in
  stage3-generator.md Common Writing Rules.
- **Code patterns are discoverable** — style rules are unnecessary; exclude
  them. Write instructions as verifiable success criteria.
- **Governance** (references/entry-router-guidelines.md): when
  autonomous-agent safeguards are required, reflect the Entry Router CORE
  rules in AGENTS.md Boundaries and CLAUDE.md behavioral guidelines.
- **Workflow-usage policy — document conditionally**: when Stage 1/2 reveal
  large-scale parallel/adversarial orchestration (eval harnesses,
  rule-compliance verification, claim-source cross-checking, bulk triage,
  multi-agent pipelines), have Section B emit its short "Workflow
  Orchestration" policy block into AGENTS.md (harness-neutral phrasing).
  Otherwise **omit it** — it fails the prune test and burns the size budget.
- **Instruction-authoring constraints**
  (references/model-prompting-guides.md): a documented instruction is
  system-prompt content, so the per-model prompting guides govern how it may be
  phrased. Its `[W]` rules reject three shapes outright — self-verification
  scaffolding, reasoning-visibility commands, severity filter bars — and
  require every scoped rule to name its scope. Its `[S]` rules govern this
  skill's own upkeep and must never reach a project file.
- **Claude 5 context-engineering rules**
  (references/context-engineering-claude5.md): four additive constraints on
  *what* gets documented — C1 anchor an instruction to an observable signal
  instead of forbidding a behavior outright (its Reconciliation section names
  the prohibitions that still survive under this repo's Rule Authoring
  Policy), C2 turn a sometimes-relevant multi-step procedure into a skill plus
  one reference line, C3 never emit memory-management lines (auto-memory owns
  that now), C4 place a finding across four layers, not two.
- **Testing instructions: outcome over process**
  (references/tdd-agent-loop.md): mandating TDD inside an agent's loop showed
  no quality gain at 3–8.5× token cost (Böckeler, martinfowler.com), so T1
  rejects agent-directed test-first/TDD process lines by default and rewrites
  them as outcome-based verification (named test command, mutation-score bar,
  static analysis). Its Reconciliation lists the four survivors —
  human-writes-tests splits, outcome requirements, an explicit team decision
  confirmed in Stage 2, test-quality monitoring bars.
- **Soul** (references/SOUL.md): the agent-identity seed used when generating
  project files — a static copy, not a pointer to the live identity file.

## Stage 1: Project Analysis

**Reference**: references/stage1-analyzer.md (complexity criteria, agent
prompt templates, merge protocol).

Detect package/build/test/lint config, repository structure
(monorepo/submodule), documentation/CI layout, and existing `.claude/rules/`
in the target directory.

- **Complex project** (any of: 3+ config file types, monorepo, submodules) →
  spawn 3 Explore agents (`model: sonnet`) in one message: config-explorer,
  structure-explorer, docs-explorer. Explore agents are **read-only** — each
  returns findings as its final message; collect from Agent tool results
  (TaskOutput for background runs).
- **Simple project** → read directly, no subagents.

Merge findings, classify each as discoverable vs undiscoverable, separate
facts from `[ASSUMPTION]`s, and present the summary to the user.

**advisor() gate ①**: monorepo with 5+ packages, 3+ submodules, or an
existing CLAUDE.md with complex structure → validate the analysis strategy.

**Effort note**: the orchestrator inherits the session model/effort — do not
pin `effort` in frontmatter. If analysis itself is the bottleneck on a very
large monorepo, suggest the user raise the session effort level and re-run.

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
Explore-Deep (`model: sonnet`) in the background. Skip when Stage 1 results
suffice.

**Non-interactive session**: if AskUserQuestion is unavailable (headless
run), skip the interview, generate from confirmed facts only, and list every
unresolved question in the final report. Never write assumptions into
generated files.

**Update mode**: run U1 (audit) and U2 (drift comparison) in this stage
(references/update-mode.md). Present the U2 comparison report and confirm the
update scope with the user.

**advisor() gate ②**: user answers contradict Stage 1 detection, or update
mode surfaces 10+ drift items.

## Stage 3: Generation

**Reference**: references/stage3-generator.md (dispatch prompt template,
per-file rules A–E, common writing rules).

Spawn one general-purpose agent (`model: sonnet`) using the dispatch prompt
template. The agent Reads the rule files itself; the orchestrator pastes into
the prompt only the live-fetched authoritative constraints, the Stage 1
summary, the Stage 2 answers, and the target list.

**5 possible targets**: root CLAUDE.md, AGENTS.md, contributing-docs/,
nested CLAUDE.md, `.claude/rules/`. Generate only the applicable ones.

**Update mode**: run U3 instead (references/update-mode.md) — the
orchestrator applies surgical Edits, one user-confirmed change at a time.
Never regenerate whole files.

## Stage 4: Verification

**Reference**: references/stage4-verifier.md (verifier dispatch template,
verification checklist, anti-patterns, reviewer prompt). The checklist's
size/staleness items enforce the authoritative prune test and 200-line
ceiling from Step 0-1.

1. **Verifier** (`model: sonnet`): apply the verification checklist line by
   line via the dispatch template.
2. **Fix loop**: the orchestrator fixes FAIL items, then re-verifies.
   Maximum **3 verification runs total** (initial + up to 2 fix rounds).
   If FAILs remain, call advisor once, then report them and proceed.
3. **Blind Reviewer** (`model: sonnet`, consults advisor): spawn when output
   exceeds a single root CLAUDE.md. Pass generated file contents **only** —
   no Stage 1/2 results, no verifier output (Gotcha 3). Apply its grounded
   FAIL fixes once before final output.

Report verification results to the user; for each FAIL, quote the line and
the reason.

**advisor() gate ③**: Verifier FAIL persists after the 2 fix rounds.

## Advisor Escalation Summary

| # | When | Trigger |
|---|------|---------|
| ① | After Stage 1 | Monorepo 5+ packages, 3+ submodules, or complex existing CLAUDE.md |
| ② | During Stage 2 | User answer ↔ detection mismatch, or 10+ drift items in update mode |
| ③ | During Stage 4 | Verifier FAIL persists after 2 fix rounds |

**When not to call advisor()**: simple project generation, 1–2 target files,
verification passes on the first run, or the user gave unambiguous
instructions.

## Red Flags — STOP

| You are about to… | Do instead |
|-------------------|------------|
| Regenerate any existing managed agent-doc target from scratch | Route to update mode and preserve its structure |
| Put project-general content in CLAUDE.md, or Claude-only content in AGENTS.md | Apply the placement test (stage3-generator.md Common Writing Rules) — AGENTS.md is cross-harness, CLAUDE.md is `@AGENTS.md` + Claude-only |
| Call WebFetch before loading its schema | `ToolSearch` `select:WebFetch` first (Step 0-1) |
| Use the cached best-practices without saying so | Announce the fallback in one line |
| Give the blind Reviewer anything beyond the generated files | Generated file contents only |
| Apply an update-mode edit the user has not seen | Show the exact change; get per-file confirmation (U3) |
| Tell a Stage 1 Explore agent to write a file | Explore is read-only — findings return as final messages |
| Write a "double-check your work" line or pre-response checklist into a generated doc | Delete it (model-prompting-guides.md W1) — it causes over-verification; a real must-run gate becomes a hook |
| Emit a TDD or test-first process mandate aimed at the agent's own loop | Rewrite as outcome-based verification (tdd-agent-loop.md T1) — keep it only as one of T1's Reconciliation survivors, e.g. a team decision confirmed in Stage 2 |
| Emit an instruction to show, or to suppress, the agent's reasoning | Never (W2) — risks `reasoning_extraction` refusals one way, internal-tag leakage the other |
| Emit a sometimes-relevant multi-step procedure as a CLAUDE.md / AGENTS.md section | Recommend a skill and emit one reference line (C2) — every-session budget is for always-relevant content |
| Write a Memory / Notes / Session Log / Changelog section into an agent-config file | Delete it (C3) — auto-memory owns that content, and a hand-maintained log fails the prune test as soon as it goes stale |
| Claim completion without Stage 4 output | Report checklist/reviewer results with quoted failures |

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
4. **`model: opus` is an orchestrator hint, not a pipeline default.** Stage
   1/3/4 subagents explicitly request `model: sonnet` for cost; the Stage 4
   Reviewer additionally consults advisor() (opus per `advisorModel`) on
   low-confidence findings. Model aliases (`opus`/`sonnet`) resolve to the
   current generation at runtime — never hardcode version IDs. `effort` is
   inherited from the session, never pinned in frontmatter.
5. **`disable-model-invocation` is intentionally unset.** The skill is
   invasive (writes/edits several project files); auto-invocation can still
   fire from vague phrasing in `description` and `when_to_use`. If false positives
   become a problem, flip the flag on and rely on `/generate-agent-docs`.
6. **Update mode may misread hand-crafted files as drift.** Unusual
   structures can be intentional. Confirm with the user before removing
   sections that look redundant but may carry project-specific meaning.

## Eval Criteria

references/eval-criteria.md defines 6 binary checks — mode routing,
discoverability discipline, size budgets, reference integrity, blind review,
instruction-authoring constraints — for any generation or update run.
skill-improver / autoresearch / waza reuse them when optimizing this skill.
