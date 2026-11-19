# Create mode: Steps 1–4

Run in the order [Mode detection](../SKILL.md#mode-detection) sets; Step 5 there finishes the skill.

## Step 1: Capture the use case

After the interview in [SKILL.md Step 1](../SKILL.md#step-1-capture-the-use-case-create-mode), name the skill's **domain type**: library/API reference, product
verification, data fetching and analysis, business process automation, code
scaffolding, code quality and review, CI/CD and deployment, runbook, or
infrastructure operations. A skill that straddles several is a candidate to split.

Pick a **structural pattern**:

| Pattern | Best fit | Freedom |
| --- | --- | --- |
| Linear workflow | Fixed sequence of steps | Low–medium |
| Interview-based | Requirements depend on user context | High |
| Tool orchestration | Combines several tools | Medium |
| Template fill | Produces a fixed-shape artifact | Low |
| Validation / review | Quality-checking existing artifacts | Medium |

Combine patterns with an explicit step heading at each boundary (interview then
linear, linear then validation). Keep conditional branches to two or three that
converge on one goal.

Confirm the pattern and the reason with the user before scaffolding.
While the user answers, the [Explore-1 survey](subagent-guidelines.md#explore-1-existing-skill-survey)
may run; skip it when the request already names the skill, purpose and pattern.

## Step 2: Scaffold the structure

Run `init-skill` ([Scripts](../SKILL.md#scripts)). It writes `SKILL.md` with the required
fields and commented placeholders for common optional fields; add
`--with-references`, `--with-scripts` or `--with-assets` only for resources the
skill needs.

Without `cargo`, scaffold by hand (a kebab-case folder with an empty `SKILL.md`,
plus the needed subfolders). That is a draft only: completion stays blocked
until Step 5 validates it.

Structure rules the validator does not cover:

- `SKILL.md` is the only entry point; no `main.md` or `index.md`.
- `references/` holds what only some tasks need, each linked from `SKILL.md`
  with a load condition. Resolve a Markdown link from the file that contains it:
  `references/api-guide.md` in `SKILL.md`, `api-guide.md` from a sibling reference.
  (Local policy: the spec says paths relative to the skill root and references
  one level deep from `SKILL.md`; this repository resolves from the containing
  file because `skill-diet-eval check` validates links that way.)
- Link a sibling skill's shared reference (such as `model-selection.md`) instead of copying it.
- `scripts/`: Rust in a Cargo workspace under `tools/` behind thin, executable
  bash launchers (this skill's layout); Python only via `uv` with PEP 723
  metadata. Show the full invocation of each script the skill uses.
- `assets/`: media referenced from the skill; prefer text when text works.

## Step 3: Write the frontmatter

Use [frontmatter-spec.md](frontmatter-spec.md) and [description-examples.md](description-examples.md).

1. Set non-empty `name` (matching the folder) and `description`. A name that
   matches a bundled skill or built-in command you can see in the session is a
   conflict too: a personal or project skill replaces that command (not its
   aliases; a built-in command only in a local terminal session), and a plugin
   skill keeps `/plugin:name` but loses the bare `/name`.
2. Write a concise WHAT + WHEN `description` from the selected trigger phrases;
   workflow detail belongs in the body.
3. Pick optional fields for the intended host and distribution path. Use manual
   invocation for destructive or expensive skills, and hide background knowledge
   from the user menu where appropriate.
4. Keep workload guidance in the body. Omit `model` unless the user asks for a
   host-supported override; tier labels are not model IDs.

Review trigger accuracy here; Step 5 owns mechanical validation.

## Step 4: Write the instructions

Write the body in the Step 1 pattern. When Step 1 found a similar skill worth
studying, run [Explore-2](subagent-guidelines.md#explore-2-reference-skill-analysis)
while drafting and fold in its result.

- **Model guidance**: a default profile, an escalation trigger, and cheaper
  mechanical phases from [model-selection.md](model-selection.md); link it when
  shipped together, otherwise adapt the wording locally.
- **Be specific**: runnable commands, exact paths, acceptance criteria; each
  verification step names its gate (command, test, file, criterion).
- **Errors**: failure modes and how to recover.
- **Tools**: name the tools used.
- **Gotchas**: known failure points, each with the correct approach ([design principles](design-principles.md#gotchas)).
- **Done**: state completion criteria; add no unrequested "stop for review" step.
- **Freedom**: match specificity to a named fragility ([degrees of freedom](design-principles.md#degrees-of-freedom)).
- **Output shape**: a strict template when the format must be exact, a flexible
  one when only structure matters, input/output examples to convey style.
- **Size**: place each fact by [level](../../../../skill-diet/skills/skill-diet/SKILL.md#levels). A new
  skill has no diet baseline, so draft `SKILL.md` toward 500 words (Superpowers
  recommendation, not a limit); `skill-diet-growth` prints the count. The first
  diet replaces this target with its growth budget.
- **Shape**: state when not to use the skill as a negative trigger in
  `description`, since the body loads too late to decide that. A technique or
  pattern skill gets one before/after example of its core pattern. Common
  mistakes go under Gotchas, and `SKILL.md` ends with `Look up the rest`. Put
  the rules that must outlast compaction near the top
  ([content lifecycle](frontmatter-spec.md#content-lifecycle)).

### Dynamic context

`` !`command` `` in the body runs before the prompt reaches the model and is
replaced by its output (shell set by the `shell` field; `bash` merges stderr into
stdout). It runs on every load, cannot branch, and delays loading when slow: at
the Bash tool's 2-minute timeout it is moved to the background (the skill
renders with a note instead of its output) or killed, which aborts the
invocation. A failing command aborts the whole invocation, so Claude never sees
the skill: with `bash` any non-zero exit fails, except exit 1 from search and
comparison commands, so append `|| true` to another command expected to exit
non-zero. It is permission-checked without a prompt; pre-approve a command your
rules do not already allow in [`allowed-tools`](frontmatter-spec.md#allowed-tools).
It runs in the session's current directory, so reach bundled files through
`${CLAUDE_SKILL_DIR}`. Use it for always-needed, fixed context (git status,
current branch, tool versions), never for user-dependent commands or anything
that prints secrets.

### Post-write checks

- Every `references/` path resolves, and examples or historical paths are labeled.
- No fuzzy phrasing, filler, speculation or over-explaining.
- Run the [redundancy audit](../SKILL.md#redundancy-audit).

For team distribution, choose repo check-in (every checked-in skill costs
context) or a [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
Measure your own usage with `/skill-doctor` (v2.1.252+): it reports each listed
skill's context cost and use and flags never-invoked skills. Across a team or
over time, log Skill calls with a PreToolUse hook.
