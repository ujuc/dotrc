---
source_url: https://code.claude.com/docs/en/skills
spec_url: https://agentskills.io/specification
last_upstream_check: 2026-08-14
check_interval_days: 14
---

# YAML Frontmatter Field Specification

> Field rules and validation criteria for YAML frontmatter at the top of SKILL.md.
> Sources: `source_url` (Claude Code behavior) and `spec_url` (the Agent Skills
> open standard Claude Code implements). Both must be re-fetched on a freshness
> check — rules attributed to the standard are not stated on the Claude Code page.
>
> Freshness is tracked by the YAML block above; `generate-skills` Step 0 reads
> `last_upstream_check` and only re-fetches when `today - last_upstream_check >
> check_interval_days`.
>
> Each rule is attributed by origin: **[CC]** Claude Code docs, **[SPEC]** Agent
> Skills standard, **[LOCAL]** this repository's `validate-skill` only.

---

## Delimiter Rules

Frontmatter sits at the very top of the file, wrapped in `---` delimiters:

```yaml
---
name: my-skill
description: What this skill does. When to use it.
---
```

- The first `---` MUST be on **line 1** (no blank lines before it)
- The second `---` closes the frontmatter
- No whitespace before or after delimiters

---

## Field Reference

**[SPEC]** `name` and `description` are **required**. **[CC]** Claude Code itself treats every field as optional — it falls back to the directory name and to the first body paragraph — but a spec-conformant skill declares both.

**[CC]** Boolean fields (`disable-model-invocation`, `user-invocable`, `background`) accept `yes`, `no`, `on`, `off`, `1`, and `0` in any letter case as well as `true`/`false`. Before v2.1.218 only `true`/`false` were recognized, so prefer them for portability.

> **Portability.** Only `name`, `description`, `license`, `compatibility`, `metadata`, and `allowed-tools` belong to the Agent Skills standard. Every other field here — including `when_to_use`, `argument-hint`, `model`, `context`, and this repository's `group` — is Claude Code-only and is a **hard error**, not an ignored key, on claude.ai uploads, the Skills API, and `package_skill.py`. See [Portability outside Claude Code](#portability-outside-claude-code).

> **Local extension (this repository):** every SKILL.md MUST also include a `group` field — one of 8 fixed slugs. `validate-skill` fails when it is missing or invalid, and the catalog table in `skills/README.md` mirrors it. See the [`group`](#group) section below.

### `name`

Display name for the skill. **[CC]** If omitted, uses the directory name.

| Rule | Origin | Description |
|------|--------|-------------|
| Required | **[SPEC]** | Yes — the standard requires it even though Claude Code tolerates its absence |
| Format | **[SPEC]** | Lowercase letters, numbers, and hyphens only (max 64 characters) |
| Pattern | **[SPEC]** | `^[a-z0-9]+(-[a-z0-9]+)*$` |
| Folder match | **[SPEC]** | MUST match the parent directory name. `validate-skill` enforces it only when `name` is present — it does not fail on a missing `name` |
| Reserved prefixes | **[LOCAL]** | Names starting with `claude` or `anthropic` (no hyphen required). Stated by neither upstream source; enforced only by `RESERVED_NAME_PREFIXES` |
| Example | | `generate-skills`, `notion-setup`, `tdd-workflow` |

**[CC]** In personal and project skills, `name` sets only the display label; the `/command` name comes from the **directory**. Plugin skills differ: under a plugin's `skills/` subdirectory `name` replaces the directory name in the command's last segment (`name: fancy` → `/my-plugin:fancy`), and for a plugin-root `SKILL.md` `name` supplies the whole final segment, falling back to the plugin directory name.

### `description`

What the skill does and when to use it. Claude uses this to decide when to apply the skill. If omitted, uses the first paragraph of markdown content.

| Rule | Origin | Description |
|------|--------|-------------|
| Required | **[SPEC]** | Yes, and non-empty |
| Spec max length | **[SPEC]** | **1,024 characters** — a hard cap on `description` alone |
| Listing cap | **[CC]** | **1,536 characters** for `description` + `when_to_use` combined, truncated in the skill listing (the `skillListingMaxDescChars` default). This is what `DESCRIPTION_COMBINED_MAX` enforces — a different limit from the row above, not a restatement |
| Recommended structure | | **WHAT** (what it does) + **WHEN** (when to use it) |
| XML tags | **[LOCAL]** | Tag-shaped tokens (`<name ...>`) forbidden. Claude Code itself escapes angle brackets rather than rejecting them |
| Language | **[LOCAL]** | Per project language policy (Korean or English) |

This is the primary field the system uses for natural language matching. Its quality directly affects trigger accuracy.

Two distinct truncation mechanisms apply, and front-loading only helps with the first:

- The per-skill 1,536-character cap truncates the tail regardless of how many skills exist. **Front-load the key use case.**
- **[CC]** When many skills overflow the listing's total budget (1% of the model's context window), Claude Code drops **whole** descriptions, starting with the least-invoked skills. Front-loading does not help there — raise the budget or mark low-priority skills `name-only` via `skillOverrides`.

### `when_to_use`

Additional context describing when Claude should invoke the skill — trigger phrases, example requests, domain hints. Appended to `description` in the skill listing and shares the 1,536-character cap.

```yaml
when_to_use: "Trigger phrases, example user utterances, when NOT to use this skill."
```

- Use this to separate concise WHAT (in `description`) from noisy trigger keywords.
- Keep Korean trigger phrases verbatim; the matcher compares against raw user input.
- **Claude Code-only.** Not an Agent Skills field — a skill destined for claude.ai upload or the Skills API must fold its WHEN content into `description`.

### `argument-hint`

Hint shown during autocomplete to indicate expected arguments.

```yaml
argument-hint: "[issue-number]"
```

- Example values: `[issue-number]`, `[filename] [format]`
- Appears in the `/` menu autocomplete UI

### `arguments`

Named positional arguments for `$name` substitution in the skill content. Accepts a space-separated string or a YAML list; names map to argument positions in order.

```yaml
arguments: [issue, branch]
```

- With the example above, `$issue` expands to the first argument and `$branch` to the second.

### `disable-model-invocation`

Set to `true` to prevent Claude from automatically loading this skill. Use for workflows you want to trigger manually with `/name`.

```yaml
disable-model-invocation: true
```

- Default: `false` (auto-trigger allowed)
- Recommended for destructive or high-cost operations
- Also prevents the skill from being preloaded into subagents, and (v2.1.196+) from running when a scheduled task fires with the skill as its prompt

### `user-invocable`

Set to `false` to hide from the `/` menu. Use for background knowledge users should not invoke directly.

```yaml
user-invocable: false
```

- Default: `true`
- Use for reference/context skills that Claude should load automatically but users have no reason to call

### `allowed-tools`

Tools Claude can use without asking permission **during the turn that invokes this skill**.

```yaml
# space-separated string
allowed-tools: Read Grep Glob

# or YAML list
allowed-tools:
  - Read
  - Grep
  - Bash(git add *)

# or comma-separated string
allowed-tools: Read, Grep, Bash(git status:*)
```

- Accepts a space- or comma-separated string, or a YAML list — all three officially documented
- **Turn-scoped, not skill-scoped.** The grant clears on the user's next message even though the skill content stays in context; re-invoking the skill re-applies it. For a session-wide grant use permission allow rules instead. (This is the one place where `allowed-tools` and `disallowed-tools` differ — the latter is scoped to the skill being active.)
- Does not restrict which tools are callable, only which skip per-use approval
- Baseline permission settings still apply to tools not listed
- `${CLAUDE_PROJECT_DIR}` substitution applies here too (v2.1.196+), so a rule like `Bash(${CLAUDE_PROJECT_DIR}/scripts/lint.sh *)` resolves to the same path the skill body uses. `${CLAUDE_SKILL_DIR}` (and `${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_PLUGIN_DATA}` in plugin skills) substitute here too — pairing the same variable in the body and in the rule lets a bundled script run without a prompt

### `disallowed-tools`

Tools removed from Claude's available pool while this skill is active. Use for autonomous skills that should never call certain tools.

```yaml
disallowed-tools: AskUserQuestion
```

- Accepts a space- or comma-separated string, or a YAML list
- The restriction clears on the user's next message
- Like deny rules, it cannot remove `EndConversation` while any other tool remains
- For permanent blocks across all skills, use permission deny rules instead

### `model`

Model to use when this skill is active.

```yaml
model: opus
```

- Upstream accepts the same values as `/model`, or `inherit` to keep the active model; if unset, inherits from the current session model
- The override applies for the rest of the current turn only and is not saved to settings — the session model resumes on the next prompt
- A value excluded by the organization's `availableModels` allowlist is silently ignored and the session keeps its current model — no error is raised
- **With `context: fork`, this sets the forked subagent's model instead of the session model**, overriding what the `agent` type would supply
- **[LOCAL]** convention: `opus` for planning/orchestration, `sonnet` for deterministic execution (see `skills/CLAUDE.md`). `validate-skill` accepts only `opus`, `sonnet`, `haiku`, `inherit` — a deliberately stricter subset of what upstream allows

### `effort`

Effort level when this skill is active. Overrides the session effort level.

```yaml
effort: max
```

- Options: `low`, `medium`, `high`, `xhigh`, `max` (availability depends on the model)
- Default: inherits from session

### `context`

Set to `fork` to run in a forked subagent context.

```yaml
context: fork
```

- The skill content becomes the prompt that drives the subagent
- The subagent does NOT have access to conversation history
- Only makes sense for skills with explicit task instructions (not pure guidelines)

### `agent`

Which subagent type to use when `context: fork` is set.

```yaml
context: fork
agent: Explore
```

- Options: built-in agents (`Explore`, `Plan`, `general-purpose`) or custom subagents from `.claude/agents/`
- If omitted, uses `general-purpose`
- Only meaningful when `context: fork` is set

### `background`

Whether a forked subagent runs in the background.

```yaml
context: fork
background: false
```

- Only applies with `context: fork`
- `false` waits for the forked subagent's result in the turn that invoked the skill
- Default: `true` (runs in the background)
- Requires Claude Code v2.1.218 or later; earlier versions always blocked the turn, so the field is a no-op there
- Claude Code waits even at the `true` default in non-interactive runs (`-p` / Agent SDK), when `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, when a previous invocation of the same skill is still running, and when a scheduled task fires the skill
- A backgrounded fork runs with the narrower background-subagent tool set, and its edits land outside session checkpoints (`/rewind` will not undo them). Set `background: false` when the skill body needs the full tool set

### `hooks`

Hooks scoped to this skill's lifecycle. See Claude Code hooks documentation for configuration format.

```yaml
hooks:
  - event: on_skill_start
    command: echo "Skill started"
```

### `paths`

Glob patterns that limit when the skill is auto-activated by Claude. When set, the skill is loaded only when working with files matching the patterns. Uses the same format as path-specific memory rules.

```yaml
# comma-separated string
paths: "src/**/*.ts, tests/**/*.spec.ts"

# or YAML list
paths:
  - "src/**/*.ts"
  - "tests/**/*.spec.ts"
```

- Useful for domain-specific skills (e.g., "only load when touching Terraform files").
- Has no effect on `/skill-name` manual invocation.

### `shell`

Shell used for `` !`<command>` `` inline injections and ` ```! ` fenced blocks inside the skill.

```yaml
shell: powershell
```

- Options: `bash` (default) or `powershell`.
- `powershell` takes effect only when the PowerShell tool is enabled — on by default on Windows without Git Bash, and enabled elsewhere with `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. The env var is one route to enabling the tool, not a universal prerequisite.
- Writing `shell: bash` explicitly is **not** the same as omitting the field: on a machine without bash it aborts the whole skill invocation before any command runs.

### `metadata`

**[SPEC]** Free-form map for your own key-value data (entitlement, catalog fields) read by your own tooling from SKILL.md.

```yaml
metadata:
  version: "1.0"
  owner: platform-team
```

- A flat map of string keys to string values — no nesting; quote non-string scalars (`version: "1.0"`)
- Claude Code does not act on its contents and drops a value that is not a map
- Do not reuse frontmatter field names such as `paths` as keys

### `license`

**[SPEC]** License covering the skill. Claude Code accepts the field but does not act on it.

```yaml
license: Apache-2.0
```

- Free-form short string — a license name, or a pointer to a bundled file (`Proprietary. LICENSE.txt has complete terms`). **Not** restricted to SPDX identifiers

### `compatibility`

**[SPEC]** Environment requirements — intended products, system prerequisites, network access. Claude Code accepts the field but does not act on it.

```yaml
compatibility: Requires ripgrep and network access to api.example.com
```

- Free-form string, 1–500 characters
- Omit unless the skill genuinely has such requirements; most do not

### `group`

> **Local extension** — required by this repository, not the upstream spec.

Group slug used by the catalog table in `skills/README.md`. Every SKILL.md must declare exactly one of the 8 fixed slugs below.

```yaml
group: planning
```

| slug | 한글 라벨 | Used for |
|------|----------|----------|
| `planning` | 🧭 기획·스펙 | Spec writing, sprint contracts |
| `analysis` | 📐 분석·계획 | Codebase reading, plan annotation |
| `build` | 🛠 구현·실행 | Plan execution, multi-agent orchestration |
| `verify` | ✅ 검증·QA | Functional / design QA |
| `docs` | 📝 문서·커밋 | Commits, CLAUDE.md generation |
| `writing` | ✍️ 글쓰기 | Prose humanization, prompt crafting |
| `llm` | 🤖 외부 LLM | Calls to non-Claude models (Gemma, Codex) |
| `meta` | 🧪 메타·관리 | Skill management, session lifecycle |

- `validate-skill` fails when this field is missing or holds a value outside the 8 slugs.
- The slug list is defined in `tools/skill-core/src/rules.rs::ALLOWED_GROUPS`. Any change there must be reflected in this section, in `skills/README.md`, and in `skills/CLAUDE.md`.
- Do NOT auto-fix a missing `group` field — `skill-improver` reports it as manual because guessing from directory name or description risks wrong placement.

---

## Portability outside Claude Code

Claude Code accepts every field above. Other distribution paths do not.

| Distribution path | Accepted frontmatter |
|---|---|
| Claude Code skills at any level, including plugin skills | Every field above |
| claude.ai uploads, the Skills API, `package_skill.py` | `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` |

An unlisted field is a **hard error**, not an ignored key:

```
Unexpected key(s) in SKILL.md frontmatter: argument-hint.
Allowed properties are: allowed-tools, compatibility, description, license, metadata, name
```

This repository's own house style — `when_to_use`, `argument-hint`, `model`, `group` — would therefore fail a claude.ai upload. **No skill here is upload-destined, so this is a constraint to know, not a defect list — do not strip fields from existing skills.** A skill newly intended for one of those paths must be restricted to the six fields. Claude Code-only **body** features (dynamic `` !`command` `` injection, `@` file references) likewise stop working there, while six-field frontmatter still loads unchanged in Claude Code.

---

## Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|-------------|----------------|-------------------|-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description NOT in context; full skill loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

---

## Content Lifecycle

- Invoked skill content enters the conversation once and stays for the session; the file is not re-read on later turns — write standing instructions, not one-time steps.
- **Persistence applies to the skill's instructions, not its permissions** — an `allowed-tools` grant clears on the user's next message while the content stays in context.
- Re-invoking with identical rendered content adds a short "already loaded" note instead of a duplicate copy (v2.1.202+); changed arguments or dynamic-context output append the full content again.
- Auto-compaction re-attaches the most recent invocation of each skill (first 5,000 tokens each, 25,000-token shared budget, most recent first) — older skills can drop out entirely.

---

## String Substitutions

Skills support dynamic value substitution in skill content:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill. If not present in content, arguments are appended as `ARGUMENTS: <value>` |
| `$ARGUMENTS[N]` | Access a specific argument by 0-based index (e.g. `$ARGUMENTS[0]` for first) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0` for first argument) |
| `$name` | Named argument declared in the `arguments` frontmatter list (names map to positions in order) |
| `${CLAUDE_SESSION_ID}` | Current session ID. Useful for logging or session-specific files |
| `${CLAUDE_EFFORT}` | Current effort level (`low`–`max`; ultracode reports as `xhigh`). Use to adapt instructions to the active effort |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill's SKILL.md — for plugin skills, the skill's subdirectory, not the plugin root. Applies to the body and `allowed-tools` |
| `${CLAUDE_PROJECT_DIR}` | Project root directory (v2.1.196+) — same path hooks receive. Applies to the body and `allowed-tools` |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory. Plugin skills only — use for files bundled anywhere in the plugin, including resources shared between its skills |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory, surviving plugin updates. Plugin skills only — installed dependencies, caches, generated files |

Indexed arguments use shell-style quoting (`/my-skill "hello world" second` → `$0` = `hello world`). To include a literal `$` before a digit, `ARGUMENTS`, or a declared name, escape with a single backslash: `\$1.00`.

### Example

```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---

Fix GitHub issue $ARGUMENTS following our coding standards.
```

Running `/fix-issue 123` replaces `$ARGUMENTS` with `123`.

---

## Validation Checklist

After writing frontmatter, verify. Items marked **(manual)** are author-verified —
`validate-skill` does not check them; everything else it enforces.

- [ ] Line 1 is `---`
- [ ] Closing `---` exists
- [ ] `name` and `description` are both present — **(manual)**, required by the Agent Skills spec but not by the validator
- [ ] If `name` is present: matches kebab-case pattern (`^[a-z0-9]+(-[a-z0-9]+)*$`) and is ≤ 64 characters
- [ ] If `name` is present: matches the parent folder name
- [ ] If `name` is present: does not start with `claude` or `anthropic` (local rule)
- [ ] `description` alone ≤ 1,024 characters — **(manual)**, spec cap
- [ ] Combined `description` + `when_to_use` ≤ 1,536 characters (Claude Code listing cap)
- [ ] `description` has no tag-shaped tokens (`<name ...>`)
- [ ] `description` includes WHAT; WHEN lives in `description` or `when_to_use` — **(manual)**
- [ ] If `context` is set: value is `fork`
- [ ] If `agent` is set: `context: fork` is also set
- [ ] If `allowed-tools` / `disallowed-tools` is set: space- or comma-separated string, or YAML list
- [ ] If `paths` is set: glob patterns only apply to auto-activation, not manual `/` invocation
- [ ] If `compatibility` is set: a string of ≤ 500 characters — **(manual)**
- [ ] If `metadata` is set: a flat map of string keys to string values — **(manual)**
- [ ] If the skill is destined for claude.ai / the Skills API: frontmatter is restricted to the six spec fields — **(manual)**
- [ ] `group` field is present and equals one of `planning`, `analysis`, `build`, `verify`, `docs`, `writing`, `llm`, `meta` (local-required)
