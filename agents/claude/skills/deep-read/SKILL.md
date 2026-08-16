---
name: deep-read
description: "코드베이스 영역을 깊이 분석하여 구조화된 리서치 문서를 생성한다. 구조, 데이터 흐름, 리스크 분석을 위해 3개 병렬 researcher 에이전트를 디스패치한다. 코드 분석해줘, 깊이 읽어봐, deep-read, /deep-read 요청 시 사용한다."
group: analysis
model: sonnet
argument-hint: "[target-path]"
allowed-tools: Read, Glob, Grep, Bash, Agent, advisor
---

# Deep Read — Codebase Research

Deeply analyze a code area and produce a structured research document at `.research/research-{topic}.md`.

## Workflow

### 1. Determine Target and Topic Slug
- Parse `$ARGUMENTS` for the target (directory, module, or feature area).
- If no target is given, ask the user what to analyze.
- Derive `{topic}` deterministically: make the target repository-relative, drop a leading container component (`src`, `packages`, `apps`, or `libs`), join the remaining path components with hyphens, then kebab-case the result (for example, `src/auth` → `auth`, `packages/api/routes` → `api-routes`). If the user supplied a natural-language topic, slugify that instead.

### 2. Launch 3 Parallel Researcher Agents

Spawn 3 agents in a single message using `Agent` with `subagent_type: "researcher"` and `run_in_background: true`. Agent system rules (citations, exploration depth, no modification) live in `~/.claude/agents/researcher.md` and are not restated here.

| Agent | Focus | Output | Required sections |
|-------|-------|--------|-------------------|
| **structure-explorer** | File structure, entry points, type/interface mapping | `.research/.partial/structure.md` | `# Architecture Overview`, `# Key Files & Responsibilities` |
| **flow-explorer** | Data flow, function call chains, state changes | `.research/.partial/dataflow.md` | `# Data Flow`, `# Call Chains` |
| **risk-explorer** | External/internal dependencies, vulnerabilities, implicit contracts, tech debt | `.research/.partial/risks.md` | `# Dependencies`, `# Gotchas & Risks` (each risk tagged `[Low|Medium|High|Critical]`) |

Agent prompt template:
```
Focus: {role description}.
Target: {target path}.
Output: {output path}.
Required top-level sections: {from table}.
```

Wait for all 3 agents to finish before Step 3 — `run_in_background` agents auto-notify on completion. Do not start merging on partial completion.

### 3. Merge Results

After all 3 agents complete, read `.partial/` files and merge into `.research/research-{topic}.md`.

**PARTIAL markers.** If any partial file contains `<!-- PARTIAL: {reason} -->` (written by `researcher` per its Failure Policy), preserve the marker as a `> PARTIAL: {reason}` blockquote at the top of the corresponding section in the merged document. Also append one line to the `## Gotchas & Risks` section: `> PARTIAL research — {role} could not finish ("{reason}"); rerun that role before planning.` Never silently drop the marker — it is the user's signal that the research is incomplete.

Merge into `.research/research-{topic}.md`:

```markdown
# Research: {topic}

## Architecture Overview
(from structure-explorer)

## Key Files & Responsibilities
(from structure-explorer)

## Data Flow
(from flow-explorer)

## Call Chains
(from flow-explorer)

## Dependencies
(from risk-explorer)

## Patterns & Conventions
(cross-reference: structure + flow)

## Gotchas & Risks
(from risk-explorer)

## Integration Points
(cross-reference: flow + risk)
```

### 4. Cleanup
- Delete `.research/.partial/` directory
- Output: "`.research/research-{topic}.md` has been created. Please review it for accuracy before proceeding to planning."

## Advisor Escalation

Sonnet is the default. Call `advisor()` (no parameters — the full context forwards automatically) only at these decision points:

- **Pre-merge contradiction**: structure / dataflow / risk partials disagree on the same fact, or the Architecture Overview synthesis is ambiguous.
- **Critical-severity risk**: risk-explorer flags `[Critical]` and you need a sanity check on how firmly to state it.

Do not call advisor for routine Q&A or progress updates.

## Constraints
- Observation and documentation only. No code modifications during merge. Per-agent rules are enforced by `~/.claude/agents/researcher.md`.
- Create `.research/` if missing. Never commit `.research/.partial/`.

## Gotchas

1. **Background agents can silently fail.** `run_in_background: true` returns before the subagent writes its output. Always verify each `.partial/*.md` exists and is non-empty before merging — if any is missing, re-dispatch that single role rather than merging with a hole.
2. **Topic slug collisions overwrite prior research.** Re-running `deep-read src/auth` twice overwrites `.research/research-auth.md`. If the user intends an update-over-time workflow, append a date suffix (`research-auth-2026-04-18.md`) or confirm overwrite.
3. **Large targets hit subagent context limits.** For directories over ~50 files, instruct each researcher to stream findings to its output file as it goes, not accumulate in memory. Consider narrowing `Target:` to a subfolder per role if an agent reports truncation.
4. **Merge drift when partials use different heading levels.** The Required sections in the Step 2 table are enforced — if a partial omits `# Architecture Overview`, the merge mapping breaks silently. Grep each partial for the required headings before merging; if any is missing, re-prompt that one agent with stricter instructions.

## Eval Criteria

```
EVAL 1: All three partials written
  Question: After Step 2, do `.research/.partial/structure.md`,
            `.research/.partial/dataflow.md`, and
            `.research/.partial/risks.md` all exist and have >0 bytes?
  Pass: All three exist, non-empty.
  Fail: Any missing or zero-byte.

EVAL 2: Merge completeness
  Question: Does the final `.research/research-{topic}.md` contain all
            eight sections listed in the Step 3 template (Architecture
            Overview, Key Files & Responsibilities, Data Flow, Call Chains,
            Dependencies, Patterns & Conventions, Gotchas & Risks,
            Integration Points)?
  Pass: All eight headings present.
  Fail: Any heading missing.

EVAL 3: Citation density
  Question: Do >=80% of factual claims in the merged document cite a
            `path:line` reference (per researcher.md rules)?
  Pass: Citation ratio >= 0.8 on a sample of 20 claims.
  Fail: Ratio below threshold — re-run failing role(s).

EVAL 4: Cleanup
  Question: Is `.research/.partial/` deleted at the end of Step 4?
  Pass: Directory does not exist after skill completes.
  Fail: Directory still present.
```
