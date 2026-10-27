# Create mode: Steps 1–4

Run after Step 0 and the behavior baseline in [SKILL.md](../SKILL.md); Step 5 there finishes the skill.

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

Confirm the pattern, the reason, and the group with the user before scaffolding.
While the user answers, the [Explore-1 survey](subagent-guidelines.md#explore-1-existing-skill-survey)
may run; skip it when `$ARGUMENTS` already names the skill, purpose and pattern.

## Step 2: Scaffold the structure

Run `init-skill` ([Scripts](../SKILL.md#scripts)). `--group` is required and is
a deliberate choice, never a guess. It writes `SKILL.md` with the required
fields and commented placeholders for every optional field; add
`--with-references`, `--with-scripts` or `--with-assets` only for resources the
skill needs.

Without `cargo`, scaffold by hand (a kebab-case folder with an empty `SKILL.md`,
plus the needed subfolders). That is a draft only: completion and registration
stay blocked until Step 5 validates it.

Structure rules the validator does not cover:

- `SKILL.md` is the only entry point; no `README.md`, `main.md` or `index.md`.
- `references/` holds what only some tasks need, each linked from `SKILL.md`
  with a load condition. Resolve a Markdown link from the file that contains it:
  `references/api-guide.md` in `SKILL.md`, `api-guide.md` from a sibling reference.
- Link a sibling skill's shared reference (such as `model-selection.md`) instead of copying it.
- `scripts/`: Rust in a Cargo workspace under `tools/` behind thin, executable
  bash launchers (this skill's layout); Python only via `uv` with PEP 723
  metadata. Show the full invocation of each script the skill uses.
- `assets/`: media referenced from the skill; prefer text when text works.

## Step 3: Write the frontmatter

Use [frontmatter-spec.md](frontmatter-spec.md) and [description-examples.md](description-examples.md).

1. Set non-empty `name` (matching the folder), `description` and `group`; ask
   only if placement remains unclear.
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
- **Size**: place each fact by [level](../../skill-diet/SKILL.md#levels).

### Dynamic context

`` !`command` `` in the body runs before the prompt reaches the model and is
replaced by its stdout (shell set by the `shell` field). It runs on every load,
injects error output as-is when it fails, cannot branch, and delays loading when
slow. Use it for always-needed, fixed context (git status, current branch, tool
versions), never for user-dependent commands or anything that prints secrets.

### Post-write checks

- Every `references/` path resolves, and examples or historical paths are labeled.
- No fuzzy phrasing, filler, speculation or over-explaining.
- Run the [redundancy audit](../SKILL.md#redundancy-audit).

For team distribution, choose repo check-in (every checked-in skill costs
context) or a [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).
Measure usage with a PreToolUse hook that logs skill invocations: it shows which
skills are popular, which undertrigger, and trends over time.
