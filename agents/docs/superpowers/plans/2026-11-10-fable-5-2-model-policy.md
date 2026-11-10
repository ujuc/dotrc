# Fable 5.2 Model Policy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Claude Fable 5.2 the Frontier candidate, add the multi-agent team
practices from the Fable 5.2 scaling post, and re-anchor the model-selection
policy on the "which Claude model" playbook.

**Architecture:** All dispatch policy flows from one shared reference,
`generate-skills/references/model-selection.md`, which every skill links by
profile name (Lightweight/Standard/Advanced/Frontier). Edit that file, sync the
two copies of its tables, refresh the prompting-guide cache that
`generate-agent-docs` reads, and update the `settings.json` bootstrap block.
No skill body names a model ID, so no skill body changes.

**Tech Stack:** Markdown references, Rust `skill-core` validator
(`validate-skill`), Claude Code `settings.json`.

**Spec:** No spec doc. The requirements are the user's three requests
(2026-11-10) and these sources, all fetched 2026-11-10:
- Launch: https://www.anthropic.com/claude-fable-and-mythos-5-2
- Multi-agent: https://claude.dev/blog/safely-scaling-multi-agent-teams-with-fable-5-2/
- Model choice: https://claude.dev/blog/which-claude-model-should-you-build-with/
- Cross-checked against https://platform.claude.com/docs/en/models/overview,
  https://code.claude.com/docs/en/model-config, https://code.claude.com/docs/en/advisor,
  https://code.claude.com/docs/en/sub-agents and
  https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2.md

## Status (2026-11-10)

Executed inline; not committed.
- D1: Frontier `fable`/`medium` (also after an Advanced `high` failure); `high` for long unattended runs or a `medium` shortfall; `xhigh` only after a measured gain.
- D2: Advanced `opus`/`medium`, `high` for verification, review and brownfield debugging.
- D3: README and live `settings.json` both updated. The bootstrap `claude-opus-5-5` was aligned to the live `high` + `autoCompactWindow: 400000`.
- D4: dropped. `agents/claude/skills/CLAUDE.md` forbids `~/.claude/agents/` definitions.
- D5: policy text only.
- `last_upstream_check` in `model-prompting-guides.md` stays 2026-11-01, because only the Fable 5.2 guide and the best-practices page were re-fetched.
- Added: a verbatim English backup of the Fable 5.2 prompting guide at `generate-skills/references/prompting-claude-fable-5-2.md`, linked as the fetch-failure fallback.
- Final review: 1 source-fidelity reviewer and 2 report-only skill-improver runs. All Important findings were fixed in one pass.

## Global Constraints

- Model ID `claude-fable-5-2`; alias `fable` resolves to it from Claude Code v2.1.321 (installed: 2.1.322).
- Mythos 5.2 (`claude-mythos-5-2`) requires a verification program: record it as "Fable 5.2 for verified organizations, not a separate candidate", never as a profile.
- Fable 5.1 is legacy, not retired: drop it from candidate tables, keep measured 5.1 evidence (`guidance-testing.md:114`, `design-principles.md:18-19,67`, 5.1-attributed quotes) unchanged.
- Never write a profile label into a `model` field; dispatch tables keep aliases (`haiku`/`sonnet`/`opus`/`fable`).
- Claude Code default effort is `medium` for Fable 5.2, Opus 5.5, Sonnet 5.5 and Haiku 5.5; the API default for Fable 5.2 is `high`. `modelSettings.<id>.effortLevel` accepts `low|medium|high|xhigh` (not `max`).
- A user-level top-level `effortLevel` does not apply to Fable 5.2; only `modelSettings`, `/effort`, `--effort` or `CLAUDE_CODE_EFFORT_LEVEL` do.
- The multi-agent post names no Claude Code key: any mapping onto worktrees, sandbox or permissions is labeled "local inference".
- Files are written in English; `agents/claude/skills/README.md` stays Korean.
- `agents/claude/settings.json` is ask-first and never `git add`ed.
- No commit or push unless the user asks.

## Decisions (user answers before Task 2/4)

| ID | Question | Recommended | Alternative |
| --- | --- | --- | --- |
| D1 | Frontier dispatch, now `fable`/`xhigh` | `fable`/`medium`, raise to `high` | `fable`/`high` (Fable 5.2 guide: "Start at `high`") |
| D2 | Advanced dispatch, now `opus`/`high` | `opus`/`medium`; `high` for verification, review and brownfield debugging (matches `agents/claude/CLAUDE.md:33`) | keep `opus`/`high` |
| D3 | Bootstrap `modelSettings` | add `claude-fable-5-2: high`, drop `claude-fable-5-1` and `claude-opus-5`; keep `claude-opus-5-5` as the live `high` | also apply to live `settings.json` (ask-first) |
| D4 | Custom `Explore` agent with `model: haiku` | defer to follow-up (needs a new install link) | do it now |
| D5 | Scope of request 2 | policy text only | also a Fable-lead profile in `/ultra-config` |

Rationale for D1: the playbook says "Move to the next model up, starting at a
lower effort level than you used on the smaller one" and lists Fable 5.2 at
"medium, then high"; the Fable 5.2 guide reserves `xhigh` for measured gains.

## Review Focus

1. A reader asks "which model when unsure?" — the policy must answer Advanced (Opus 5.5, medium), not Standard. Checked in Task 2 Step 4.
2. A skill dispatches Frontier for a long unattended run — the routing row must give an effort that `Agent` accepts and the escalation order must not jump to `xhigh`. Checked in Task 2 Step 4.
3. Main model is Fable 5.2 with `advisorModel: fable` — still a valid pairing; an `opus` advisor would be silently dropped. Checked in Task 4 Step 3.
4. `generate-agent-docs` writes a CLAUDE.md for a Fable 5.2 project — a Fable 5.1 finding must not be attributed to 5.2 unless the 5.2 guide restates it. Checked in Task 1 Step 4.
5. A stale `fable-5-1` / `Mythos 5.1` mention survives in a candidate or routing context. Checked in Task 5 Step 1.

---

### Task 1: Prompting-guide cache for Fable 5.2

**Files:**
- Modify: `agents/claude/skills/ujuc/skills/generate-agent-docs/references/model-prompting-guides.md:1-55` (frontmatter, Inheritance, Freshness), `:116-124` (W6), `:193-207` (D2)

**Interfaces:**
- Produces: `source_urls` entry `prompting-claude-fable-5-2.md`; `last_upstream_check: 2026-11-10`.

- [ ] **Step 1:** Invoke `skill-diet:skill-diet` for `generate-agent-docs` before editing.
- [ ] **Step 2:** Add the Fable 5.2 guide URL to `source_urls` above the 5.1 entry; bump `last_upstream_check` to `2026-11-10`; fetch `secondary_source_url` and add any other guide listed there but missing here (Freshness rule).
- [ ] **Step 3:** Rewrite the Inheritance paragraph: Fable 5.2 has its own guide, which does not say earlier prompts carry over unchanged and instead lists earlier-model instructions to review, so Fable 5.1/5 findings apply to 5.2 only where the 5.2 guide restates them. Mythos 5.2 maps onto the Fable 5.2 guide.
- [ ] **Step 4:** Add Fable 5.2 quotes only where a rule already covers the topic: W6 (delegation: "If your system prompt, skills, or agent files tell the model to delegate, review those lines first"), W2 (think-less lines: "such a line didn't stop Claude Fable 5.2 from thinking at `medium` and above"), D2 (Fable 5.2 API default `high`, Claude Code default `medium`). Quote verbatim from the fetched guide.
- [ ] **Step 5:** Run `bash agents/claude/skills/ujuc/skills/generate-skills/scripts/validate-skill agents/claude/skills/ujuc/skills/generate-agent-docs` — Expected: no ERROR findings.

### Task 2: Model-selection policy (requests 1 and 3)

**Files:**
- Modify: `agents/claude/skills/ujuc/skills/generate-skills/references/model-selection.md:8-13` (profiles), `:22-45` (selection steps), `:80-85` (dispatch routing), `:104-115` (source basis)
- Modify: `agents/claude/skills/README.md:24-29` (Korean table copy)
- Check only: `agents/claude/skills/ujuc/skills/generate-skills/tools/init-skill/src/main.rs:42-43` (changes only if profile names change; they do not)

**Interfaces:**
- Consumes: D1, D2.
- Produces: profile names unchanged; routing rows `haiku`/`medium`, `sonnet`/`medium`, Advanced per D2, Frontier per D1.

- [ ] **Step 1:** Invoke `skill-diet:skill-diet` for `generate-skills` before editing.
- [ ] **Step 2:** Profiles table: Advanced "Choose for" gains "the default when the fit is unclear"; Frontier gains "major refactors and migrations, architecture planning, leading many subagents, deep research, long unattended runs, or Opus at `high` still falls short". Standard gains "repeated agent tasks such as investigation, review or drafting". Lightweight gains "subagents that search files, read logs or summarize".
- [ ] **Step 3:** Selection step 5: escalation order is (a) give the model a way to verify its own work (test, build, script), (b) raise effort one level, (c) move to the next profile at a lower effort; past `high`, test the next profile instead of `xhigh`/`max`. Step 6: switch models at a natural break, because the prompt cache belongs to the model that wrote it.
- [ ] **Step 4:** Dispatch routing rows per D1/D2. Read the table back and confirm Review Focus 1–2.
- [ ] **Step 5:** Source basis: `Last checked: 2026-11-10`; Mythos line becomes "Claude Mythos 5.2 is Fable 5.2 for verified organizations, not a separate candidate"; add the playbook URL and the models-overview line "Use Claude Fable 5.2 … when your evals on Claude Opus 5.5 at higher effort still fall short."
- [ ] **Step 6:** Sync the 고급/최상위 rows in `skills/README.md` with Step 2 wording.
- [ ] **Step 7:** Run `validate-skill agents/claude/skills/ujuc/skills/generate-skills` — Expected: no ERROR findings.

### Task 3: Multi-agent team practices (request 2)

**Files:**
- Modify: `agents/claude/skills/ujuc/skills/generate-skills/references/model-selection.md` (new `## Agent teams` section after Dispatch routing)

Placed in `model-selection.md`, not `subagent-guidelines.md`, because every
dispatching skill links the former; the latter is scoped to skill generation.

**Interfaces:**
- Consumes: Task 2 file state.

- [ ] **Step 1:** Add ≤12 lines, each traceable to a quote in the post: one lead splits and assigns, workers escalate when unclear; workers coordinate through shared state (files, Git), not chat; each worker writes only its own branch/workspace and a separate step merges; an objective checker (tests, build) decides done; a block on a worker drops that worker, a block on the lead stops the run for human review; push back on early "infeasible" verdicts. Lead/worker model split from the playbook: Opus or Fable lead with Sonnet workers only for work bigger than one context window; skip it for dependent chains.
- [ ] **Step 2:** One line labeled "Local inference": in Claude Code these map onto `isolation: "worktree"` for parallel writers, sandbox/permission deny rules, and the auto-mode classifier. Cite the post URL and `Last checked: 2026-11-10`.
- [ ] **Step 3:** Re-run `validate-skill` for `generate-skills`.

### Task 4: settings.json bootstrap (request 1)

**Files:**
- Modify: `README.md:317-331` (bootstrap `modelSettings`)
- Modify (only if D3 approves): `agents/claude/settings.json` (untracked)

- [ ] **Step 1:** Apply D3 to the README block. The `claude-fable-5-2` key is inferred from the documented canonical-name rule, not shown in a doc example; note this nowhere in the README, only in the report.
- [ ] **Step 2:** If approved, apply the same keys to the live file with `jq … >| tmp && [ -s tmp ] && mv` (noclobber guard).
- [ ] **Step 3:** Confirm `advisorModel: "fable"` stays valid for Opus 5.5 and Fable 5.2 main models (advisor pairing table).

### Task 5: Verification

- [ ] **Step 1:** `git grep -nE 'fable-5-1|Fable 5\.1|Mythos 5\.1'` — classify each hit as measured evidence, historical doc, or stale candidate; only stale candidates are fixed.
- [ ] **Step 2:** Run `skill-improver` on `generate-skills` and `generate-agent-docs` (required by `agents/CLAUDE.md` after a skill change).
- [ ] **Step 3:** One independent reviewer (separate context, budget ≈150k tokens) checks every changed sentence against the source quotes saved under the session scratchpad and reports unsupported claims.
- [ ] **Step 4:** Report checks and outcomes; offer a commit (`skills` scope for Tasks 1–3, `docs` for README) without running it.

## Follow-ups (not in this change)

| Drift | Purpose | Method | Check |
| --- | --- | --- | --- |
| README says `claude-opus-5-5` medium, live is `high` + `autoCompactWindow` | one bootstrap truth | settle in D3 | diff README block vs live |
| README:374 claims `/ultra-config apply baseline` re-applies `advisorModel` | accurate docs | fix wording or add it to `profiles.ts` baseline | ultra-config tests |
| `teammateMode` `auto` (settings) vs `tmux` (`~/.claude.json`) | predictable teams | pick one | `/config` |
| Explore runs on the session model (Opus under Fable) | cheaper discovery | D4: user `Explore` agent with `model: haiku` + install link | sub-agent list |
| Advisor shows little measured gain (playbook) | cost | measure consult rate before keeping `advisorModel` | session cost per task |
| Fable 5.2 guide: cautious instructions build up in memory/CLAUDE.md | fewer needless approvals | audit `agents/claude/CLAUDE.md` and memory with `generate-agent-docs` | run on Fable 5.2 |
