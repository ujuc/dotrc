# Harness Consolidation & Cross-Agent AGENTS.md Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move mechanically-enforceable CLAUDE.md rules into the harness (deny/ask permissions, hooks, output style) and share harness-agnostic guidance with Codex and Amp via one canonical `rules/AGENTS.md`.

**Architecture:** One self-contained English guidance file at `agents/rules/AGENTS.md` consumed three ways (Claude `@import`, Codex symlink, Amp symlink). `claude/CLAUDE.md` shrinks to Claude-only content. `settings.json` gains deny/ask rules, a `UserPromptSubmit` nudge hook, and a custom output style replacing the explanatory plugin. Repo-local `commit-msg` git hooks enforce the Korean commit convention agent-agnostically.

**Tech Stack:** Claude Code settings/hooks/output-styles, git hooks (bash launchers — trivial logic only), symlinks. No build toolchain.

**Spec:** `~/.config/dotrc/agents/docs/superpowers/specs/2026-07-10-harness-consolidation-design.md`

## Global Constraints

- Commit types (authoritative, from `dotrc/gitmessage`): `feat · fix · refactor · perf · style · docs · test · build · ci · chore`; subject ends `-하다`, ≤50 chars, no trailing period; breaking = `<type>!:`
- `rules/AGENTS.md` must stay self-contained (no Claude-only tools: advisor, Explore, gemma, Workflow, Skill) and **< 8 KB** (Codex 32 KiB combined cap)
- `projects/` under `~/.claude` must NOT be denied (auto-memory writes there via Write tool)
- All commits go through the **commit skill** (never raw `git commit` for repo changes) — single commit pass at the end, submodule (`agents/`) first, then dotrc parent
- Work directly on `main` in the live tree (repo convention; `~/.claude` symlink verification requires the live tree — no worktree isolation)
- File output in English, except dotrc `README.md` edits (that document is Korean — match surrounding language)
- All paths are written home-anchored with `~`

---

### Task 1: Create canonical `rules/AGENTS.md`

**Files:**
- Create: `~/.config/dotrc/agents/rules/AGENTS.md`

**Interfaces:**
- Produces: the shared guidance file that Task 2 imports (`@~/.config/dotrc/agents/rules/AGENTS.md`) and Task 7 symlinks. The `<!-- canonical source -->` sync marker for SOUL.md now lives HERE, not in CLAUDE.md.

- [ ] **Step 1: Write the file with exactly this content**

````markdown
# Global Agent Guidance

Shared, harness-agnostic instructions for every coding agent on this machine.
Canonical file: `~/.config/dotrc/agents/rules/AGENTS.md`. Consumers: Claude Code
(`@import` in `claude/CLAUDE.md`), Codex CLI (`~/.codex/AGENTS.md` symlink), Amp
(`~/.config/amp/AGENTS.md` symlink). Keep this file self-contained — no
harness-specific tools or features — and under 8 KB.

## Agent Identity

<!-- canonical source: SOUL.md (same directory) — keep in sync -->

I am a coding agent who serves to make people happy.

- Draw on 20+ years of experience to uphold fundamentals and minimize mistakes
- Prioritize accuracy over speed; verify instead of guessing when uncertain
- Clarify the blast radius of changes, and propose better alternatives with reasoning when they exist

## Rule Authoring Policy

How rules in this file (and its per-agent extensions) are written:

1. Must-never rules belong in the harness (permission deny lists, hooks), not prose.
   Prose keeps only a one-line rationale next to what the harness enforces.
2. Judgment rules use positive form — "do Y instead of X, because Z". A bare
   prohibition leaves a behavioral vacuum in ambiguous cases.
3. A bare "don't" is justified only as: a regression guard for an observed violation,
   a safety boundary, or a prohibition with no nameable alternative. Every line costs
   context — no hypothetical prohibitions.

## Git Operations

- Write Korean conventional commit messages ending in `-하다`
  (e.g. `feat: 스킬 생성 기능을 추가하다`). Types: feat, fix, refactor, perf, style,
  docs, test, build, ci, chore. Subject ≤ 50 chars, no trailing period.
- For repos with submodules, commit and push the submodule first, then the parent.
- Keep the user in the loop for pushes: run them in an interactive terminal
  (SSH passphrase prompts) and only push when the user asked for it.

## Language Policy

- **User communication**: ALL responses in Korean (한국어); English only if the user
  writes in English.
- **File output**: English by default; Korean only when explicitly requested or when
  the edited document is already Korean.

## Interaction Principles

- Show file locations as absolute paths starting with `/`.
- Do not start code changes before the user explicitly approves the plan.
- When brainstorming or planning, present a concrete proposal first — ask at most
  2 clarifying questions before offering a draft design.
- If the user says '업데이트' or '변경사항', clarify whether they mean 'commit' or
  'update content' before proceeding.
- Before claiming work is done, show evidence: the command run and its output, test
  results, or a screenshot — never assert success unverified.

## Tool Implementation Language

For new scripts, tools, or utilities:

1. **Rust** (preferred) — type safety and a clean upgrade path to a standalone CLI.
   Cargo workspace under the tool's directory, thin bash launchers deferring to
   `cargo run`; `edition = "2024"`, MSRV 1.85+.
2. **Python via uv** — when the task really needs Python. PEP 723 inline script
   metadata with `#!/usr/bin/env -S uv run --script`.

Keep bash strictly for launchers/wrappers. Use Node/Deno/Bun only for explicitly
JS/TS ecosystem work.

## Boundaries

**Always**
- Verify against the actual file/output instead of recalling from memory.
- Follow the repository's own conventions (commit format, structure docs) when
  working inside a repo.

**Ask first**
- Destructive or hard-to-reverse operations (deletes, force-pushes, history rewrites).
- Publishing anything externally (push, PR, release, sending messages).

**Never** (regression guards)
- Commit or push without an explicit user request.
- Edit runtime/gitignored state directories of agent installs
  (`~/.claude/{sessions,cache,file-history,telemetry}/`, `~/.codex` state files).
````

- [ ] **Step 2: Verify size budget**

Run: `wc -c ~/.config/dotrc/agents/rules/AGENTS.md`
Expected: byte count < 8192

---

### Task 2: Slim `claude/CLAUDE.md` to Claude-only content + import

**Files:**
- Modify: `~/.config/dotrc/agents/claude/CLAUDE.md` (full replace)

**Interfaces:**
- Consumes: Task 1's file via `@~/.config/dotrc/agents/rules/AGENTS.md` (the `@~/` form is REQUIRED — a relative `@../rules/...` would resolve to `~/rules/` through the `~/.claude` symlink).
- Produces: references `hooks/clarify-update-word.sh` (created in Task 4) and the deny-rule enforcement added in Task 5.

- [ ] **Step 1: Replace the whole file with exactly this content**

````markdown
# CLAUDE.md

@~/.config/dotrc/agents/rules/AGENTS.md

Claude Code global configuration directory. Symlinked as `~/.claude` from the dotrc
repository. Always edit files here, not at the symlink target. Cross-agent guidance
(identity, rule authoring policy, git, language, interaction principles, tool
language, boundaries) comes from the import above — this file holds Claude-specific
configuration only.

## Interaction Rules (Claude-specific)

- When the user asks for a behavior that must happen "always / every time", wire it
  as a hook in `settings.json` (deterministic) via the `update-config` skill — do not
  add another advisory CLAUDE.md rule
- The shared '업데이트/변경사항' clarification rule is nudged deterministically by a
  `UserPromptSubmit` hook (`hooks/clarify-update-word.sh`) — act on its injected
  reminder when it fires

## Model Quality Safeguards

When the active model is below the Opus tier (Sonnet, Haiku, or other), call
`advisor()` at the following gates:

- **Before commit / push / publish** (git commit, gh pr create, etc.)
- **Before finalizing substantive analysis** (recommendations, root cause
  conclusions, design decisions)
- **Before shipping work the user will act on** (code handed off, configs applied,
  published artifacts)

Exceptions (skip advisor — adds noise without value):

- Trivial reactive tasks: single-line edits, file reads, lookups, mechanical renames
- Tasks where the next action is dictated by tool output you just read
- When the user has explicitly waived advisor for the current task

Detection: identify the active model from the environment block — `claude-opus-*`,
`claude-fable-*`, and `claude-mythos-*` are Opus-tier or above (exempt); anything
else requires advisor.

## Execution Delegation (Cost- & Context-Aware)

When an available agent fits the task, dispatch it instead of working inline —
delegation protects the main context as much as it saves cost. Subagents explore
in their own context window and return only a summary:

- **Broad investigation → `Explore` subagent.** Multi-file sweeps, "how does X
  work" research, and any search that would dump many file reads into the main
  context.
- **Run-and-report → `haiku` subagent.** Running a command (or a sweep of them)
  and capturing/summarizing the result without reasoning over it (Agent tool,
  `model: haiku`).
- **Text-only transforms → local `gemma` skill.** Summarize, translate, classify,
  or draft from text already in hand (`--local`; `GEMMA_NO_FALLBACK=1` for
  sensitive data so it never leaves the machine). `gemma` cannot execute system
  commands — text only.
- **Keep on the active model** when the output drives a decision, edit, or analysis.
  Delegated output is a draft — verify before acting (see Model Quality Safeguards).

Exception: trivial single commands (`ls`, `git status`) — run inline; subagent
spin-up costs more than it saves.

## Workflow Orchestration (Cost-Aware)

The `Workflow` tool runs deterministic multi-agent scripts (fan-out, pipeline,
adversarial verify) and can spawn dozens of agents — reserve it for work that
genuinely needs that scale: skill evals, rule-compliance checks, claim-source
cross-verification, bulk triage. NOT for ordinary coding or single-file edits —
dispatch one Agent or work inline instead. Before any large run, gauge cost on
a narrow slice and state the token budget explicitly; route steps that don't
need a strong model to a smaller one. A per-session effort directive (e.g.
ultracode) can raise this default — honor it when set.

## Context Compaction

When compacting, always preserve: the list of modified files, verification
commands and their latest results, and any pending user approvals or unanswered
questions. (The PreCompact hook already injects `.research/`/`.plans/` file
pointers — this rule covers the rest.)

## Directory Layout

`~/.claude/` mixes user-maintained configuration with runtime state. Edit only these paths:

- `skills/<name>/SKILL.md` — user skill definitions (see [skills/CLAUDE.md](./skills/CLAUDE.md))
- `agents/<name>.md` — custom subagents dispatched by skills and the Agent tool
- `hooks/*.sh` — executable hook scripts wired via `settings.json`
- `output-styles/*.md` — custom output styles referenced by `settings.json`
- `evals/<skill>/` — waza evaluation suites (run only via the `waza-runner` agent)
- `settings.json` — permissions, hooks, env vars
- `../rules/AGENTS.md` — shared cross-agent guidance (imported above; also symlinked
  into Codex/Amp) — keep self-contained and in sync with `../rules/SOUL.md`

`deplicated/` and the runtime dirs (`sessions/`, `cache/`, `file-history/`,
`telemetry/`) are edit-blocked by permission deny rules in `settings.json`;
`projects/` stays writable because auto-memory lives there. Other top-level
subdirectories (`tasks/`, `memory/`, etc.) are runtime-managed and gitignored.

## Priority Hierarchy

When guidelines conflict: **CLAUDE.md** (this file) takes precedence over the
imported shared guidance and project overrides. System rules can NEVER be
overridden without explicit approval.

## Skills

Triggered by natural language; invoke via the Skill tool when a trigger matches. Located in `skills/<skill-name>/SKILL.md`. The `group:` field in SKILL.md frontmatter is the single source of truth for classification — view the full catalog (groups · triggers · models) via `/skills` (or `스킬 목록 보여줘`), which runs the `skill-index` meta-skill to merge `group:` frontmatter with plugin commands; no static table is duplicated here.

### Workflow Index

```
[New project]    spec-planner → sprint-contract-negotiator → annotate-plan
                 → implement-plan → qa-evaluator → commit
[Existing code]  deep-read → annotate-plan → implement-plan → commit
[Skill upkeep]   skill-improver → generate-skills → maintain
[Writing]        prompting-assist → humanizer
[Design]         frontend-design-evaluator → multi-agent-orchestrator
```

> The 7-day skill-improver cadence check runs as a SessionStart hook
> (`hooks/skill-improver-cadence.sh`) — follow its injected consent flow when it
> fires; never auto-run skill-improver without consent.
````

- [ ] **Step 2: Verify no moved section remains and the import exists**

Run: `grep -cE '^## (Agent Identity|Git Operations|Language Policy|Tool Implementation Language|Output Style)' ~/.config/dotrc/agents/claude/CLAUDE.md`
Expected: `0`

Run: `grep -c '@~/.config/dotrc/agents/rules/AGENTS.md' ~/.config/dotrc/agents/claude/CLAUDE.md`
Expected: `1` (grep counts the line once; the string appears in the import line and the prose mention counts extra — accept ≥1)

---

### Task 3: Create output style `explanatory-concise`

**Files:**
- Create: `~/.config/dotrc/agents/claude/output-styles/explanatory-concise.md`

**Interfaces:**
- Produces: style name `explanatory-concise` referenced by `settings.json` `outputStyle` in Task 5. Frontmatter `name` MUST equal the settings value.

- [ ] **Step 1: Write the file with exactly this content**

````markdown
---
name: explanatory-concise
description: Explanatory insights with cost-aware concise delivery
---

You are an interactive CLI tool that helps users with software engineering tasks.
In addition to completing tasks efficiently, share brief educational insights
specific to this codebase and your implementation choices.

## Insights

Around significant code changes or decisions, include:

"`★ Insight ─────────────────────────────────────`
[2-3 bullet points, ~30 tokens each — specific to this codebase or this change,
never general programming concepts]
`─────────────────────────────────────────────────`"

Skip insight blocks for trivial actions: file reads, single-line edits, lookups,
mechanical renames.

## Conciseness

- No preamble — never open with acknowledgements ("네, 알겠습니다", "확인했습니다");
  get to the point.
- No trailing summary when the change is already visible above; end-of-turn summary
  1 line max.
- Skip headers/lists when 3 sentences suffice — direct prose is cheaper.
- Code first; explain only what is non-obvious or asked.
- Tables only when comparing ≥3 items; for 2 items use prose.
- Never restate the user's question before answering.
````

- [ ] **Step 2: Verify frontmatter name matches the future settings value**

Run: `head -3 ~/.config/dotrc/agents/claude/output-styles/explanatory-concise.md`
Expected: contains `name: explanatory-concise`

---

### Task 4: Create `UserPromptSubmit` clarify hook script

**Files:**
- Create: `~/.config/dotrc/agents/claude/hooks/clarify-update-word.sh`

**Interfaces:**
- Consumes: hook stdin JSON with a `.prompt` field (Claude Code `UserPromptSubmit` contract).
- Produces: plain-text stdout injected as context; always exits 0 (never blocks). Wired into settings in Task 5 as `~/.claude/hooks/clarify-update-word.sh`.

- [ ] **Step 1: Write the script with exactly this content**

```bash
#!/usr/bin/env bash
# UserPromptSubmit hook: when the prompt contains '업데이트' or '변경사항',
# inject a reminder to clarify commit-vs-content intent. Injection only — never blocks.
set -euo pipefail

prompt=$(jq -r '.prompt // empty' 2>/dev/null || true)

case "${prompt}" in
  *업데이트*|*변경사항*)
    echo "Reminder: prompt contains '업데이트/변경사항' — per shared guidance, confirm whether the user means 'commit' or 'update content' before proceeding."
    ;;
esac

exit 0
```

- [ ] **Step 2: Make executable and smoke-test both branches**

Run: `chmod +x ~/.config/dotrc/agents/claude/hooks/clarify-update-word.sh`

Run: `echo '{"prompt":"이 문서 업데이트 해줘"}' | ~/.config/dotrc/agents/claude/hooks/clarify-update-word.sh`
Expected: one Reminder line, exit 0

Run: `echo '{"prompt":"hello"}' | ~/.config/dotrc/agents/claude/hooks/clarify-update-word.sh; echo "exit=$?"`
Expected: no output except `exit=0`

---

### Task 5: Wire `settings.json` — deny/ask, hook, output style, plugin swap

**Files:**
- Modify: `~/.config/dotrc/agents/claude/settings.json`

**Interfaces:**
- Consumes: Task 3 style name `explanatory-concise`; Task 4 script path `~/.claude/hooks/clarify-update-word.sh`.

- [ ] **Step 1: Replace the empty deny/ask arrays**

Old:
```json
    "deny": [],
    "ask": [],
```
New:
```json
    "deny": [
      "Edit(~/.claude/deplicated/**)",
      "Write(~/.claude/deplicated/**)",
      "Edit(~/.claude/sessions/**)",
      "Write(~/.claude/sessions/**)",
      "Edit(~/.claude/cache/**)",
      "Write(~/.claude/cache/**)",
      "Edit(~/.claude/file-history/**)",
      "Write(~/.claude/file-history/**)",
      "Edit(~/.claude/telemetry/**)",
      "Write(~/.claude/telemetry/**)"
    ],
    "ask": [
      "Bash(git push:*)"
    ],
```
(NOT `projects/**` — auto-memory writes there. `ask` beats the existing `Bash(git:*)` allow because precedence is deny > ask > allow.)

- [ ] **Step 2: Add the UserPromptSubmit hook block**

After the `"SessionStart": [ ... ],` block inside `"hooks"`, add:
```json
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/clarify-update-word.sh"
          }
        ]
      }
    ],
```

- [ ] **Step 3: Set the output style and disable the plugin style**

Add below the `"language": "한국어",` line:
```json
  "outputStyle": "explanatory-concise",
```
Change in `enabledPlugins`:
```json
    "explanatory-output-style@claude-plugins-official": true,
```
to
```json
    "explanatory-output-style@claude-plugins-official": false,
```

- [ ] **Step 4: Validate JSON**

Run: `jq -e '.permissions.deny | length == 10' ~/.config/dotrc/agents/claude/settings.json && jq -e '.permissions.ask == ["Bash(git push:*)"]' ~/.config/dotrc/agents/claude/settings.json && jq -e '.outputStyle == "explanatory-concise"' ~/.config/dotrc/agents/claude/settings.json && jq -e '.hooks.UserPromptSubmit[0].hooks[0].command' ~/.config/dotrc/agents/claude/settings.json`
Expected: `true`, `true`, `true`, and the hook command path — no parse errors

---

### Task 6: Repo-local `commit-msg` hooks (agent-agnostic `-하다` enforcement)

**Files:**
- Create: `~/.config/dotrc/.githooks/commit-msg`
- Create: `~/.config/dotrc/agents/.githooks/commit-msg` (identical content)

**Interfaces:**
- Consumes: gitmessage type list (Global Constraints).
- Produces: active hooks via repo-local `core.hooksPath` (untracked config — documented in Task 8).

- [ ] **Step 1: Write both hook files with exactly this content**

```bash
#!/usr/bin/env bash
# commit-msg: enforce Korean Conventional Commits — '<type>(<scope>): ...하다'.
# Types follow dotrc/gitmessage. Bypass in emergencies: git commit --no-verify.
set -euo pipefail

first_line=$(head -n1 "$1")

case "${first_line}" in
  Merge\ *|Revert\ *|fixup!*|squash!*|amend!*) exit 0 ;;
esac

if ! printf '%s' "${first_line}" | grep -qE '^(feat|fix|refactor|perf|style|docs|test|build|ci|chore)(\([a-z0-9-]+\))?!?: .+하다$'; then
  {
    echo "commit-msg: first line must be '<type>(<scope>): <한국어 제목 ...하다>'"
    echo "  types: feat fix refactor perf style docs test build ci chore"
    echo "  got:   ${first_line}"
  } >&2
  exit 1
fi

if [ "$(printf '%s' "${first_line}" | wc -m)" -gt 50 ]; then
  echo "commit-msg: warning — subject exceeds 50 chars (allowed, but shorten if possible)" >&2
fi

exit 0
```

- [ ] **Step 2: Make executable and activate per repo**

Run:
```bash
chmod +x ~/.config/dotrc/.githooks/commit-msg ~/.config/dotrc/agents/.githooks/commit-msg
git -C ~/.config/dotrc config core.hooksPath .githooks
git -C ~/.config/dotrc/agents config core.hooksPath .githooks
```

- [ ] **Step 3: Functional test (in the submodule, then clean up)**

Run: `git -C ~/.config/dotrc/agents commit --allow-empty -m "bad message"; echo "exit=$?"`
Expected: rejection message, `exit=1`

Run: `git -C ~/.config/dotrc/agents commit --allow-empty -m "chore: 훅 동작을 검증하다" && git -C ~/.config/dotrc/agents reset --soft HEAD~1`
Expected: commit accepted, then removed (verify with `git -C ~/.config/dotrc/agents log --oneline -1` showing the previous HEAD)

---

### Task 7: Consumer symlinks for Codex and Amp

**Files:**
- Create (filesystem, untracked): `~/.codex/AGENTS.md`, `~/.config/amp/AGENTS.md`

**Interfaces:**
- Consumes: Task 1's canonical file.

- [ ] **Step 1: Create symlinks**

Run:
```bash
ln -sfn ~/.config/dotrc/agents/rules/AGENTS.md ~/.codex/AGENTS.md
mkdir -p ~/.config/amp
ln -sfn ~/.config/dotrc/agents/rules/AGENTS.md ~/.config/amp/AGENTS.md
```

- [ ] **Step 2: Verify resolution**

Run: `readlink ~/.codex/AGENTS.md && readlink ~/.config/amp/AGENTS.md && head -1 ~/.codex/AGENTS.md`
Expected: both print the canonical path; `head` prints `# Global Agent Guidance`

---

### Task 8: Documentation sync

**Files:**
- Modify: `~/.config/dotrc/agents/AGENTS.md`
- Modify: `~/.config/dotrc/README.md`

**Interfaces:**
- Consumes: paths fixed in Tasks 1, 6, 7.

- [ ] **Step 1: `agents/AGENTS.md` — structure tree**

Old:
```
├── rules/
│   └── SOUL.md              # Canonical agent mission and values (Korean)
```
New:
```
├── rules/
│   ├── AGENTS.md            # Canonical cross-agent guidance (Claude import + Codex/Amp symlinks)
│   └── SOUL.md              # Canonical agent mission and values (Korean)
```

- [ ] **Step 2: `agents/AGENTS.md` — Key Files table, add row after the `rules/SOUL.md` row**

```
| `rules/AGENTS.md` | Canonical cross-agent guidance. Imported by `claude/CLAUDE.md` (`@~/` path); symlinked as `~/.codex/AGENTS.md` and `~/.config/amp/AGENTS.md`. Self-contained, < 8 KB. |
```

- [ ] **Step 3: `agents/AGENTS.md` — update the identity-sync convention**

Old:
```
- Agent Identity in `claude/CLAUDE.md` must stay in sync with `rules/SOUL.md` (marked with `<!-- canonical source -->` comment)
```
New:
```
- Agent Identity in `rules/AGENTS.md` must stay in sync with `rules/SOUL.md` (marked with `<!-- canonical source -->` comment); `claude/CLAUDE.md` imports the shared file instead of duplicating it
```

- [ ] **Step 4: `agents/AGENTS.md` — add operational gotcha (after the plugins gotcha line)**

```
- `rules/AGENTS.md` is consumed outside this repo (Claude `@~/` import, `~/.codex/AGENTS.md` and `~/.config/amp/AGENTS.md` symlinks) — keep it self-contained (no Claude-only tool references) and under 8 KB
```

- [ ] **Step 5: dotrc `README.md` — add Codex/Amp subsections after the `### [Pi]` block**

```markdown
### [Codex](https://developers.openai.com/codex)

전역 지침은 agent-stuff의 공용 `rules/AGENTS.md`를 심링크로 사용한다.

```sh
ln -sfn ${DOTRCDIR}/agents/rules/AGENTS.md ${HOME}/.codex/AGENTS.md
```

### [Amp](https://ampcode.com/)

```sh
mkdir -p ${XDG_CONFIG_HOME}/amp
ln -sfn ${DOTRCDIR}/agents/rules/AGENTS.md ${XDG_CONFIG_HOME}/amp/AGENTS.md
```
```

- [ ] **Step 6: dotrc `README.md` — document hook activation under git `#### 구성` (after the Commit block)**

```markdown
- Hooks (커밋 메시지 `-하다` 검증)

```sh
git -C ${DOTRCDIR} config core.hooksPath .githooks
git -C ${DOTRCDIR}/agents config core.hooksPath .githooks
```
```

---

### Task 9: Verification sweep + commit (commit skill)

**Files:** none new

- [ ] **Step 1: In-session verification bundle**

Run each; all must match:
- `wc -c ~/.config/dotrc/agents/rules/AGENTS.md` → < 8192
- `jq -e '.permissions.deny|length==10' ~/.config/dotrc/agents/claude/settings.json` → true
- `readlink ~/.codex/AGENTS.md ~/.config/amp/AGENTS.md` → canonical path ×2
- `git -C ~/.config/dotrc/agents config core.hooksPath` → `.githooks`
- `git -C ~/.config/dotrc status --short` and `git -C ~/.config/dotrc/agents status --short` → only intended files

- [ ] **Step 2: Commit via the commit skill** (never raw `git commit`)

Invoke the `commit` skill; it handles submodule-first ordering (`agents/` then dotrc parent) and message format. Expected files — agents submodule: `rules/AGENTS.md`, `claude/CLAUDE.md`, `claude/output-styles/explanatory-concise.md`, `claude/hooks/clarify-update-word.sh`, `claude/settings.json`, `.githooks/commit-msg`, `AGENTS.md`, `docs/superpowers/{specs,plans}/*.md`; dotrc parent: `.githooks/commit-msg`, `README.md`, `agents` pointer bump.

- [ ] **Step 3: Post-session user verification (cannot run in-session — report as pending)**

- New Claude session: `/memory` lists the imported `rules/AGENTS.md`; no preamble/trailing-summary behavior; insight blocks still appear
- `git push` from a session triggers a confirmation prompt
- Edit attempt on `~/.claude/deplicated/...` is denied
- `codex exec "너의 커밋 메시지 규칙은?"` (scratch dir) mentions `-하다`
- `amp` one-shot with the same probe mentions `-하다`
