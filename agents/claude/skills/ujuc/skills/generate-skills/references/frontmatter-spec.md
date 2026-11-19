---
source_url: https://code.claude.com/docs/en/skills
spec_url: https://agentskills.io/specification
last_upstream_check: 2026-11-18
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
`background`) accept `yes`/`no`/`on`/`off`/`1`/`0` in any case;
write `true`/`false` for portability (`validate-skill` warns on the other forms).

Only `name`, `description`, `license`, `compatibility`, `metadata` and
`allowed-tools` belong to the standard; every other field breaks uploads ([Portability](#portability-outside-claude-code)).

### `name`

| Rule | Origin | Description |
|------|--------|-------------|
| Format | **[SPEC]** | `^[a-z0-9]+(-[a-z0-9]+)*$`, max 64 characters |
| Folder match | **[SPEC]** | Must match the parent directory name |
| Reserved prefixes | **[LOCAL]** | No name starting with `claude` or `anthropic` (no hyphen required); `RESERVED_NAME_PREFIXES` only |
| Refused characters | **[CC]** | Characters such as zero-width, control, private-use, unassigned or direction-changing ones, a blank other than one plain space between words, `<`/`>`. A refused folder name stops the skill loading, except in a plugin's `skills/`, where the characters become hyphens in the command; a refused `name` leaves the skill loaded, but the `/` menu does not show that value and typing it does not invoke the skill (`claude --debug`, search `[names]`) |
| Reserved names | **[CC]** | Outside plugins, `anthropic-skills` and names inside it (`anthropic-skills:*`) do not load, and a folder named `synced` (any case) is skipped (for `synced`, `validate-skill` warns and `init-skill` refuses; `anthropic-skills` fails the reserved-prefix rule above) |

**[CC]** For personal and project skills `name` sets the `/command` unless another
command uses that name, and the directory name also invokes the skill. Under a
plugin's `skills/` subdirectory
`name` replaces the directory name in the command's last segment (`name: fancy`
→ `/my-plugin:fancy`, and bare `/fancy` unless another command uses it); for a plugin-root `SKILL.md` it supplies the whole final
segment, falling back to the plugin directory name.

### `description`

What the skill does and when to use it; the primary trigger-matching field.

| Rule | Origin | Description |
|------|--------|-------------|
| Spec max length | **[SPEC]** | **1,024 characters** for `description` alone; `validate-skill` warns above it |
| Listing cap | **[CC]** | **1,536 characters** for `description` + `when_to_use`, truncated in the listing (`skillListingMaxDescChars`); `validate-skill` fails above it |
| XML tags | **[LOCAL]** | Tag-shaped tokens (`<name ...>`) in `description` or `when_to_use` fail; upstream displays `<`/`>` in `description` and `when_to_use` as `&lt;`/`&gt;`, and escapes them in text that reaches Claude for skills synced from claude.ai (v2.1.228+) |

Two truncations apply:

- The per-skill cap cuts the tail: **front-load the key use case.**
- **[CC]** When all descriptions overflow the listing budget (1% of the context
  window), Claude Code drops **whole** descriptions, least-invoked skills first.
  Front-loading does not help; raise `skillListingBudgetFraction` (e.g. `0.02`)
  or `SLASH_COMMAND_TOOL_CHAR_BUDGET`, or mark low-priority skills `name-only`
  via `skillOverrides`. `skillOverrides` does not affect plugin skills, which
  includes this repository's `ujuc:*` skills; manage those through `/plugin`.

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
Claude Code blocks Claude's call unless the user's message holds `/name` as a
separate word with no punctuation attached: at the start it runs the skill
directly, after plain text it only permits Claude to run it for that message.
Default `false`. Recommended for destructive or high-cost workflows. It also
keeps the skill out of subagent preloads and stops it running when
a session-scoped scheduled task fires with it as the prompt.

### `user-invocable`

`false` hides the skill from the `/` menu and refuses a typed `/name` (default
`true`): for background
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
- Workspace trust does not gate it: a project skill's grant applies even in a
  `-p` run in an untrusted folder. `allowManagedPermissionRulesOnly` (v2.1.282+)
  makes Claude Code ignore it in project and personal skills.
- `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SKILL_DIR}`, and in plugins
  `${CLAUDE_PLUGIN_ROOT}`/`${CLAUDE_PLUGIN_DATA}` substitute in Bash rules, so
  `Bash(${CLAUDE_SKILL_DIR}/scripts/lint.sh *)` matches the body's call and lets
  a bundled script run without a prompt.
- Injected `` !`command` `` lines never prompt; each is checked against the
  permission rules, and one a deny rule matches aborts the invocation. Outside
  auto mode any check result but allow aborts it, so pre-approve here a command
  the rules do not already allow. An ask rule still aborts it, and when the
  closest repository at or above the working directory looks bare (`HEAD`
  beside `refs` or `commondir`) the grant is ignored for an injected Bash
  command that contains `git` or cannot be parsed. In auto mode a command that
  would otherwise need approval does not abort: the skill loads with an
  instruction to run it first, except in a forked skill that sets `agent` or a
  session without the shell tool that runs injected commands, which still abort.

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
- Applies for the rest of the current turn. Overrides the session level but not
  `CLAUDE_CODE_EFFORT_LEVEL`; `maxEffortLevel` or an organization cap still limits
  it. With `context: fork` it sets the forked subagent's effort level instead.
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
(default `true`). Claude Code also
waits at `true` in non-interactive runs (`-p`, Agent SDK), with
`CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`, while a previous invocation of the
same skill runs, when a session-scoped scheduled task fires it, and when a
dynamic-workflow agent invokes it (v2.1.295+). A backgrounded fork gets
the narrower background-subagent tool set and its edits fall outside session
checkpoints (`/rewind` restores only files Claude had already edited in the
conversation; use git for the rest); set `false` when the skill needs the
full tool set.

### `hooks`

Hooks in the settings format. They register when the skill is invoked and keep
running for the rest of the session; `once: true` removes a hook after its first
successful run ([hooks in skills](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents)).
When managed `strictPluginOnlyCustomization` lists `hooks`, a personal or project
skill's hooks do not run and it loses its `allowed-tools` pre-approval, apart from
the skills that keep it.

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
`paths: "src/**/*.ts, tests/**/*.spec.ts"`. Patterns are relative to Claude's
current working directory; files outside it do not match. No effect on `/skill-name`.

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
`argument-hint` or `model` from existing skills. A skill newly meant
for one of those paths uses only the six fields and no Claude Code-only body
features (`` !`command` `` injection, `@` file references,
`${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}`): in a skill synced from
claude.ai, `!` never runs on your machine and the others work only in Cowork or
cloud sessions (v2.1.228+); six-field
frontmatter still loads unchanged in Claude Code.

## Invocation Control Matrix

| Frontmatter | User can invoke | Claude can invoke | Context loading |
|-------------|----------------|-------------------|-----------------|
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | Not on its own | Description NOT in context; full skill loads when invoked |
| `user-invocable: false` | No | Yes | Description always in context; full skill loads when invoked |

## Content Lifecycle

- Invoked content enters the conversation once and stays for the session; the
  file is not re-read, so write standing instructions, not one-time steps.
- Instructions persist; an `allowed-tools` grant does not (it clears on the next message).
- Re-invoking with identical rendered content adds a short "already loaded" note;
  changed arguments or dynamic-context output append the full content again.
- Auto-compaction re-attaches the most recent invocation of each skill (first
  5,000 tokens each, 25,000-token shared budget, most recent first); older skills can drop out.

## String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments. When no placeholder (`$ARGUMENTS`, `$N`, or a named argument) receives them, they are appended as `ARGUMENTS: <value>`; an unfilled `$N` stays literal and does not count, while a named placeholder counts even when empty |
| `$ARGUMENTS[N]` / `$N` | Argument by 0-based index (`$0` is the first) |
| `$name` | Named argument from the `arguments` field |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level (`low`–`max`) |
| `${CLAUDE_SKILL_DIR}` | Directory of this SKILL.md (for plugin skills, the skill's subdirectory, not the plugin root); also in `allowed-tools` Bash rules |
| `${CLAUDE_PROJECT_DIR}` | Project root, the path hooks receive; also in `allowed-tools` Bash rules |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin skills only: plugin install directory, for files bundled anywhere in the plugin |
| `${CLAUDE_PLUGIN_DATA}` | Plugin skills only: persistent data directory that survives plugin updates |

Indexed arguments use shell-style quoting (`/my-skill "hello world" second` →
`$0` = `hello world`). Escape a literal `$` before a digit, `ARGUMENTS` or a
declared name with one backslash: `\$1.00`; a doubled backslash (`\\$1`) keeps
both backslashes and still expands. The escape does not stop a `${CLAUDE_*}`
variable from substituting. An argument value is inserted literally: a `$1` or
`$ARGUMENTS` inside it is not expanded again, though `${CLAUDE_*}` variables are.

## Manual checks

`validate-skill` checks the rest. A wrong value type (it does not type-check
`hooks`, `license`, `argument-hint` or the `agent` value), a non-map `metadata`
and a `compatibility` outside 1–500 characters fail; non-string `metadata` keys
or values, a `metadata` key that reuses a field name, a `description` over
1,024 characters and `background` without `context: fork` only warn, and a
warning does not fail the run. **[LOCAL]** It also fails a `README.md` in a
skill folder (vendored subtree skills in `SUBTREE_SKILLS` excepted), which the
standard allows. Check these by hand:

- [ ] `description` states WHAT; WHEN lives in `description` or `when_to_use`
- [ ] An upload-destined skill uses only the six standard fields
