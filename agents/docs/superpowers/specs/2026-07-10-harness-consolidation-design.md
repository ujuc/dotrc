# Harness Consolidation & Cross-Agent AGENTS.md — Design

Date: 2026-07-10
Status: Approved direction (deny/ask-first enforcement; share with Codex + Amp)

## 1. Context & Goals

`claude/CLAUDE.md` (149 lines) carries rules that fall into three distinct classes,
all currently enforced the same way — as advisory prose that the model must remember:

1. Rules the harness can enforce deterministically (permissions, hooks, output style)
2. Harness-agnostic principles that other agents (Codex, Amp) should also follow
3. Claude-specific guidance (skills, delegation targets, advisor gates)

Goals:

- **G1 — Maximize harness enforcement.** Move mechanically-checkable rules from
  prose into `settings.json` (deny/ask permissions, hooks) and an output style file.
- **G2 — Codify the do/don't authoring policy.** Three-tier model (see §4).
- **G3 — Share global guidance with Codex and Amp** via a single canonical
  `rules/AGENTS.md`, without duplicating content.

## 2. Non-Goals

- Blocking `PreToolUse` hooks (deferred; add only for rules with observed violations)
- Gemini CLI (`contextFileName`) and pi wiring (structure stays extensible; not wired now)
- Tracking `~/.codex/config.toml` or Amp settings in the repo
- Rewriting SOUL.md or the identity content itself

## 3. Architecture

### 3.1 Canonical shared file: `rules/AGENTS.md` (new)

Self-contained English file next to `rules/SOUL.md`. No Claude-only tool references
(no advisor, Explore, gemma, Workflow, Skill tool). Contents moved from CLAUDE.md:

- **Agent Identity** — English block; the `<!-- canonical source: SOUL.md -->` sync
  marker moves here (CLAUDE.md no longer duplicates identity)
- **Git Operations** — submodule-first commit/push order; user-in-the-loop pushes;
  Korean Conventional Commits ending in `-하다`
- **Language Policy** — Korean for user communication (English only when the user
  writes in English); English for file output unless explicitly requested
- **Interaction Principles** — absolute paths in user-facing references; proposal-first
  with ≤2 clarifying questions; clarify '업데이트/변경사항' (commit vs. content) before
  acting; evidence before claiming done
- **Tool Implementation Language** — Rust preferred, Python-via-uv fallback, bash as
  launchers only
- **Boundaries (Always / Ask First / Never)** — global 3-bucket list (destructive ops
  ask-first; never publish/push without explicit request; never edit runtime state)

Size budget: keep well under 8 KB (Codex concatenates global + project docs with a
32 KiB default cap).

### 3.2 Consumers

| Agent | Mechanism | Path |
| ----- | --------- | ---- |
| Claude Code | `@import` (supports `~/` paths) | `claude/CLAUDE.md` line 1: `@~/.config/dotrc/agents/rules/AGENTS.md` |
| Codex CLI | file symlink (no import syntax; global file read first, then repo AGENTS.md) | `~/.codex/AGENTS.md → ~/.config/dotrc/agents/rules/AGENTS.md` |
| Amp | file symlink (`~/.config/amp/AGENTS.md` always included if present) | `~/.config/amp/AGENTS.md → ~/.config/dotrc/agents/rules/AGENTS.md` (mkdir -p first) |

Notes:

- The `@~/...` absolute-home import avoids the "no relative paths escaping the
  symlinked tree" gotcha (`~/.claude/CLAUDE.md`'s parent resolves to `~`, not the repo).
- Codex/Amp running inside this repo additionally read the repo-level `AGENTS.md`
  (contributor guide) — complementary, no conflict.
- No installer script exists in dotrc; symlinks are created manually during
  implementation and documented in `agents/AGENTS.md` (structure + deployment notes).

### 3.3 `claude/CLAUDE.md` slimming

| Section | Disposition |
| ------- | ----------- |
| Agent Identity | Move → `rules/AGENTS.md` (import replaces it) |
| Git Operations | Move → `rules/AGENTS.md`; enforcement via ask-permission + commit-msg hook (§3.4, §3.7) |
| Language Policy | Move → `rules/AGENTS.md` (settings `language` already enforces Korean UI) |
| Interaction Rules | Generic principles move; Claude-specific rules stay (hook-first via `update-config`, plan-approval gate) |
| Model Quality Safeguards | Stay (Claude-only; model detection unavailable to hooks) |
| Output Style — Concise | **Delete** — replaced by output style file (§3.5) |
| Tool Implementation Language | Move → `rules/AGENTS.md` |
| Execution Delegation / Workflow Orchestration / Context Compaction | Stay |
| Directory Layout | Stay; add pointer that deny rules enforce the "never edit" paths |
| Priority Hierarchy | Stay (Claude precedence semantics), reference shared file |
| Skills / Workflow Index | Stay |

Expected result: ~80 lines of Claude-only content + one import line.

### 3.4 `settings.json` — deny/ask wiring

```jsonc
"permissions": {
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
  ]
}
```

- Precedence deny > ask > allow, so `ask: Bash(git push:*)` beats the existing
  `allow: Bash(git:*)` — every push requires user confirmation (also satisfies the
  SSH-passphrase "interactive push" intent).
- **`projects/` is deliberately NOT denied**: auto-memory writes to
  `~/.claude/projects/<slug>/memory/` via the Write tool; a deny there would break it.
- `deplicated/` cleanup, if ever wanted, needs a temporary rule removal — acceptable.

### 3.5 Output style consolidation

Current state: the `explanatory-output-style` plugin and CLAUDE.md's "Output Style —
Concise" section fight each other every turn.

- New file `claude/output-styles/explanatory-concise.md`: explanatory persona
  (insight blocks kept, capped at 2–3 bullets ≈30 tokens each) merged with the
  concise rules (no preamble, no trailing summary, code-first, tables only for ≥3 items)
- `settings.json`: set `"outputStyle": "explanatory-concise"`, remove
  `explanatory-output-style@claude-plugins-official` from `enabledPlugins`
- Delete the CLAUDE.md section — system-prompt-level enforcement replaces advisory prose

### 3.6 UserPromptSubmit clarify hook (non-blocking)

`claude/hooks/clarify-update-word.sh`, wired as `UserPromptSubmit`: when the prompt
contains `업데이트` or `변경사항`, inject a one-line reminder to clarify commit vs.
content-update before acting. Injection only — never blocks. (Bash is acceptable
here: trivial launcher-grade logic.)

### 3.7 commit-msg git hook (agent-agnostic)

`dotrc/.githooks/commit-msg` + the same for the agent-stuff submodule, activated via
`git config core.hooksPath .githooks` in each repo (documented, since local git
config is untracked). Lenient validation of the first line:

```
^(feat|fix|docs|style|refactor|test|chore)(\([a-z0-9-]+\))?: .+하다$
```

Merge/fixup/revert commits pass through. This enforces the Korean commit convention
for Claude, Codex, Amp, and manual commits alike. (Repo-local hooks only — a global
`core.hooksPath` would leak the convention into unrelated/work repos.)

### 3.8 Documentation sync

- `agents/AGENTS.md`: add `rules/AGENTS.md` to structure/key-files; note the two
  consumer symlinks; update the SOUL.md sync convention (target is now `rules/AGENTS.md`)
- `claude/CLAUDE.md` Directory Layout: mention deny-rule enforcement
- dotrc root `AGENTS.md`/README deployment notes: document the manual symlinks

## 4. Do/Don't Authoring Policy (G2 — becomes part of rules/AGENTS.md preamble)

1. **Must-never → harness, not prose.** Deny permissions / hooks are deterministic;
   prose "never" lines survive only as short rationale next to the enforcement.
2. **Judgment rules → positive form**: "do Y instead of X, because Z". A bare
   prohibition leaves a behavioral vacuum in ambiguous cases.
3. **A bare don't is justified only for**: regression guards for observed violations,
   safety boundaries, or prohibitions with no alternative to name. Every line costs
   context — no hypothetical prohibitions.
4. Keep the Always / Ask First / Never 3-bucket structure (already proven in
   `agents/AGENTS.md`); machine-checkable Never items get dual-wired to the harness.

## 5. Risks & Mitigations

| Risk | Mitigation |
| ---- | ---------- |
| `@import` fails to resolve through the `~/.claude` symlink | Verify with `/memory` (import list) after edit; fall back to a fully expanded absolute path |
| Codex 32 KiB project-doc cap | Shared file budgeted < 8 KB |
| Output style swap changes session feel | Insight blocks preserved in the custom style; plugin can be re-enabled to roll back |
| `ask` on push adds friction | Intended — matches existing "user in the loop for push" rule |
| Deny rules block a legitimate future edit (e.g. deplicated cleanup) | Temporary settings edit; documented in CLAUDE.md Directory Layout |
| commit-msg hook rejects legitimate messages | Lenient regex; merge/fixup/revert exempted; hook bypassable with `--no-verify` in emergencies |

## 6. Verification Plan

1. `claude` session: `/memory` shows the imported `rules/AGENTS.md`; identity/git/language
   guidance active without the old CLAUDE.md sections
2. Permission deny: attempt `Edit` on `~/.claude/deplicated/README.md` → denied
3. Permission ask: `git push` from a session → confirmation prompt appears
4. `codex exec` in a scratch dir: verify global guidance appears (e.g. ask it to
   state its commit-message convention)
5. `amp` one-shot: same probe
6. commit-msg hook: `git commit --allow-empty -m "bad message"` rejected;
   `git commit --allow-empty -m "chore: 훅 동작을 검증하다"` accepted (then reset)
7. Output style: new session shows insight blocks + no preamble/trailing summary

## 7. Rollout Order

1. Create `rules/AGENTS.md`; slim `claude/CLAUDE.md` (+ import line)
2. `settings.json` deny/ask + output style file + plugin swap
3. Hooks: `clarify-update-word.sh` (UserPromptSubmit), `.githooks/commit-msg` (both repos)
4. Symlinks: `~/.codex/AGENTS.md`, `~/.config/amp/AGENTS.md`
5. Documentation sync (§3.8)
6. Verification (§6), then commit via the commit skill (submodule first, then dotrc)
