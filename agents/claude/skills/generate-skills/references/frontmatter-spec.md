---
source_url: https://code.claude.com/docs/en/skills
spec_url: https://agentskills.io/specification
last_upstream_check: 2026-09-23
check_interval_days: 14
---

# YAML Frontmatter Field Specification

Rules for SKILL.md frontmatter. Origins: **[CC]** Claude Code docs (`source_url`),
**[SPEC]** the Agent Skills standard (`spec_url`; these rules are not on the
Claude Code page), **[LOCAL]** this repository's `validate-skill` only. Step 0
reads the header above and re-fetches both URLs when
`today - last_upstream_check > check_interval_days`.

## Delimiter Rules

The opening `---` must be on line 1, with a closing `---`. **[CC]** Both failures
are silent: with the opening `---` elsewhere the whole file, markers included,
becomes skill content, and YAML that does not parse loads the skill with no
fields, so it stops matching on `description`. `claude plugin validate
<skills-dir>` (v2.1.233+) lists such files.

## Field Reference

**[SPEC]** `name` and `description` are required. **[CC]** Claude Code treats
every field as optional, falling back to the directory name and the first
non-empty body line. **[LOCAL]** `validate-skill` fails when either is missing.
Field names must match exactly: Claude Code silently ignores an unknown key, so
`disable_model_invocation` does nothing (`validate-skill` warns on unknown keys).

**[CC]** Boolean fields (`disable-model-invocation`, `user-invocable`,
`background`) accept `yes`/`no`/`on`/`off`/`1`/`0` in any case since v2.1.218;
write `true`/`false` for portability.

Only `name`, `description`, `license`, `compatibility`, `metadata` and
`allowed-tools` belong to the standard; every other field, including this
repository's `group`, breaks uploads ([Portability](#portability-outside-claude-code)).

### `name`

| Rule | Origin | Description |
|------|--------|-------------|
| Format | **[SPEC]** | `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 characters |
| Folder match | **[SPEC]** | Must match the parent directory name |
| Reserved prefixes | **[LOCAL]** | No name starting with `claude` or `anthropic` (no hyphen required); `RESERVED_NAME_PREFIXES` only |

**[CC]** For personal and project skills `name` is only the display label; the
`/command` comes from the directory. Under a plugin's `skills/` subdirectory
`name` replaces the directory name in the command's last segment (`name: fancy`
→ `/my-plugin:fancy`); for a plugin-root `SKILL.md` it supplies the whole final
segment, falling back to the plugin directory name.

### `description`

What the skill does and when to use it; the primary trigger-matching field.

| Rule | Origin | Description |
|------|--------|-------------|
| Spec max length | **[SPEC]** | **1,024 characters** for `description` alone |
| Listing cap | **[CC]** | **1,536 characters** for `description` + `when_to_use`, truncated in the listing (`skillListingMaxDescChars`); `DESCRIPTION_COMBINED_MAX` enforces this one, not the 1,024 |
| XML tags | **[LOCAL]** | Tag-shaped tokens (`<name ...>`) fail; upstream only escapes them for skills synced from claude.ai (v2.1.228+) |

Two truncations apply:

- The per-skill cap cuts the tail: **front-load the key use case.**
- **[CC]** When all descriptions overflow the listing budget (1% of the context
  window), Claude Code drops **whole** descriptions, least-invoked skills first.
  Front-loading does not help; raise `skillListingBudgetFraction` (e.g. `0.02`)
  or `SLASH_COMMAND_TOOL_CHAR_BUDGET`, or mark low-priority skills `name-only`
  via `skillOverrides`.

### `when_to_use`

Extra trigger context (phrases, example requests, when not to use), appended to
`description` in the listing and sharing its 1,536-character cap. Use it to keep
noisy trigger keywords out of a concise WHAT; keep Korean phrases verbatim.
Claude Code-only: an upload-destined skill folds it into `description`.

### `argument-hint`

Autocomplete hint in the `/` menu, e.g. `"[issue-number]"`, `"[filename] [format]"`.

### `arguments`

Named positional arguments for `$name` substitution, as a space-separated string
or YAML list mapped to positions in order: `arguments: [issue, branch]` makes
`$issue` the first argument and `$branch` the second.

### `disable-model-invocation`

`true` stops Claude from loading the skill on its own; users run it with `/name`.
Default `false`. Recommended for destructive or high-cost workflows. It also
keeps the skill out of subagent preloads and (v2.1.196+) stops it running when
a scheduled task fires with it as the prompt.

### `user-invocable`

`false` hides the skill from the `/` menu (default `true`): for background
knowledge Claude should load but users have no reason to call.

### `allowed-tools`

Tools that skip per-use approval **during the turn that invokes the skill**.

```yaml
allowed-tools: Read Grep Glob            # or "Read, Grep, Bash(git status:*)", or a YAML list
```

- **[SPEC]** The standard defines only the space-separated string and marks the
  field "Experimental"; use that form in a skill meant for other agents.
- **Turn-scoped.** The grant clears on the user's next message while the skill
  content stays; re-invoking re-applies it. Use permission allow rules for a
  session-wide grant.
- It does not restrict which tools are callable; baseline permissions still
  apply to unlisted tools, and deny and ask rules override it.
- `${CLAUDE_PROJECT_DIR}` (v2.1.196+), `${CLAUDE_SKILL_DIR}`, and in plugins
  `${CLAUDE_PLUGIN_ROOT}`/`${CLAUDE_PLUGIN_DATA}` substitute in Bash rules, so
  `Bash(${CLAUDE_SKILL_DIR}/scripts/lint.sh *)` matches the body's call and lets
  a bundled script run without a prompt.

### `disallowed-tools`

Tools removed while the skill is active (e.g. `AskUserQuestion` for an
autonomous skill); same formats as `allowed-tools`. The restriction clears on
the user's next message and cannot remove `EndConversation` while any other
tool remains. Use permission deny rules for a permanent block.

### `model`

```yaml
model: opus
```

- Takes the same values as `/model`, or `inherit`; unset inherits the session
  model. Aliases (`opus`, `sonnet`, `fable`) move to newer versions; pin a
  measured model by its full name ([model-config](https://code.claude.com/docs/en/model-config)).
- Applies for the rest of the current turn only; the session model resumes on
  the next prompt.
- Silently ignored when the organization's `availableModels` excludes it, and in
  auto mode (or plan mode under the auto-mode classifier) when auto mode does
  not support it. **[LOCAL]** This repository runs auto mode: confirm an
  explicit override took effect.
- With `context: fork` it sets the forked subagent's model instead, overriding
  the `agent` type's; an excluded value then follows the subagent
  model-override rules.
- **[LOCAL]** Omit fixed `model` assignments; state a workload profile and
  escalation condition in the body ([model-selection.md](model-selection.md)).
  Omission inherits the session but does not pick a task-appropriate model. An
  explicit user-requested override uses a verified host identifier, never a
  tier label. `validate-skill` checks only for a non-empty string.

### `effort`

```yaml
effort: high
```

- `low`, `medium`, `high`, `xhigh`, `max`, as the model supports.
- Default: inherits the session; with no level set anywhere each model uses its
  own default, and defaults differ by model ([model-config](https://code.claude.com/docs/en/model-config)).
- Overrides the session level but not `CLAUDE_CODE_EFFORT_LEVEL`; `maxEffortLevel`
  or an organization cap still limits it.
- **[LOCAL]** Pin a level only with measured evidence; see
  [model-selection.md](model-selection.md#selection-and-escalation) step 4 on
  effort names across models.

### `context`

`fork` runs the skill in a forked subagent: the skill content becomes its
prompt and it has **no** conversation history. Only for skills with explicit
task instructions, not pure guidelines.

### `agent`

Subagent type for `context: fork` (`validate-skill` fails `agent` without it): `Explore`, `Plan`,
`general-purpose` (default) or a custom subagent. Local policy: no
`.claude/agents/` definitions; dispatch roles from `references/roles/`.

### `background`

With `context: fork`, `false` makes the invoking turn wait for the fork's result
(default `true`, v2.1.218+; earlier versions always waited). Claude Code also
waits at `true` in non-interactive runs (`-p`, Agent SDK), with
`CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, while a previous invocation of the
same skill runs, and when a scheduled task fires it. A backgrounded fork gets
the narrower background-subagent tool set and its edits fall outside session
checkpoints (`/rewind` cannot undo them); set `false` when the skill needs the
full tool set.

### `hooks`

Hooks in the settings format. They register when the skill is invoked and keep
running for the rest of the session; `once: true` removes a hook after its first
successful run ([hooks in skills](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents)).

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
```

### `paths`

Globs (comma-separated string or YAML list, same format as path-specific memory
rules) that limit **automatic** activation to matching files, e.g.
`paths: "src/**/*.ts, tests/**/*.spec.ts"`. No effect on `/skill-name`.

### `shell`

Shell for `` !`<command>` `` injections and `!` fenced blocks: `bash` (default)
or `powershell`. `powershell` works only when the PowerShell tool is enabled: by
default on Windows without Git Bash, and on Windows with Git Bash for claude.ai
and Console accounts; Bedrock, Google Cloud Agent Platform, Microsoft Foundry,
macOS, Linux and WSL need `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` (`0` turns it
off). An explicit `shell: bash` differs from omitting it: on a machine without
bash it aborts the whole invocation before any command runs.

### `metadata`

**[SPEC]** A flat map of string keys to string values for your own tooling; no
nesting, quote non-string scalars (`version: "1.0"`), and do not reuse field
names such as `paths` as keys. Claude Code ignores its contents and drops a
non-map value.

### `license`

**[SPEC]** Free-form short string, not limited to SPDX: a license name or a
pointer to a bundled file (`Proprietary. LICENSE.txt has complete terms`).
Claude Code ignores it.

### `compatibility`

**[SPEC]** Free-form environment requirements (products, prerequisites, network
access), 1–500 characters. Claude Code ignores it. Omit unless the skill truly
has such requirements.

### `group`

**[LOCAL]** Required here, not upstream: exactly one catalog slug for the
`skills/README.md` table.

| slug | 한글 라벨 | Used for |
|------|----------|----------|
| `planning` | 🧭 기획·스펙 | Spec writing |
| `analysis` | 📐 분석·계획 | Codebase reading |
| `build` | 🛠 구현·실행 | Plan execution |
| `docs` | 📝 문서·커밋 | Commits, CLAUDE.md generation |
| `writing` | ✍️ 글쓰기 | Prose humanization, prompt crafting |
| `llm` | 🤖 외부 LLM | Calls to non-Claude models (Codex) |
| `meta` | 🧪 메타·관리 | Skill management, session lifecycle |

- `validate-skill` fails on a missing or unlisted slug. The list lives in
  `tools/skill-core/src/rules.rs::ALLOWED_GROUPS`; change it there, here and in
  `skills/README.md` together.
- Never auto-fix a missing `group`: `skill-improver` reports it as manual,
  because a guess from the name or description risks wrong placement.

## Portability outside Claude Code

| Distribution path | Accepted frontmatter |
|---|---|
| Claude Code skills at any level, including plugin skills | Every field above |
| claude.ai uploads (including a personal skill enabled for your claude.ai account for Cowork, cloud sessions, or routines), the Skills API, `package_skill.py` | `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools` |

Any other field is a **hard error** there, not an ignored key:

```
Unexpected key(s) in SKILL.md frontmatter: argument-hint.
Allowed properties are: allowed-tools, compatibility, description, license, metadata, name
```

No skill here is upload-destined, so do not strip `when_to_use`,
`argument-hint`, `model` or `group` from existing skills. A skill newly meant
for one of those paths uses only the six fields and no Claude Code-only body
features (`` !`command` `` injection, `@` file references); six-field
frontmatter still loads unchanged in Claude Code.

## Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|-------------|----------------|-------------------|-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description NOT in context; full skill loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

## Content Lifecycle

- Invoked content enters the conversation once and stays for the session; the
  file is not re-read, so write standing instructions, not one-time steps.
- Instructions persist; an `allowed-tools` grant does not (it clears on the next message).
- Re-invoking with identical rendered content adds a short "already loaded" note
  (v2.1.202+); changed arguments or dynamic-context output append the full content again.
- Auto-compaction re-attaches the most recent invocation of each skill (first
  5,000 tokens each, 25,000-token shared budget, most recent first); older skills can drop out.

## String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments. When no placeholder (`$ARGUMENTS`, `$N`, or a named argument) receives them, they are appended as `ARGUMENTS: <value>`; an unfilled `$N` stays literal and does not count, while a named placeholder counts even when empty |
| `$ARGUMENTS[N]` / `$N` | Argument by 0-based index (`$0` is the first) |
| `$name` | Named argument from the `arguments` field |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level (`low`–`max`; ultracode reports as `xhigh`) |
| `${CLAUDE_SKILL_DIR}` | Directory of this SKILL.md (for plugin skills, the skill's subdirectory, not the plugin root); also in `allowed-tools` Bash rules |
| `${CLAUDE_PROJECT_DIR}` | Project root (v2.1.196+), the path hooks receive; also in `allowed-tools` Bash rules |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin skills only: plugin install directory, for files bundled anywhere in the plugin |
| `${CLAUDE_PLUGIN_DATA}` | Plugin skills only: persistent data directory that survives plugin updates |

Indexed arguments use shell-style quoting (`/my-skill "hello world" second` →
`$0` = `hello world`). Escape a literal `$` before a digit, `ARGUMENTS` or a
declared name with one backslash: `\$1.00`.

## Manual checks

`validate-skill` enforces the rest; check these by hand:

- [ ] `description` alone ≤ 1,024 characters
- [ ] `description` states WHAT; WHEN lives in `description` or `when_to_use`
- [ ] `compatibility`, if set, is a string of ≤ 500 characters
- [ ] `metadata`, if set, is a flat map of string keys to string values
- [ ] An upload-destined skill uses only the six standard fields
