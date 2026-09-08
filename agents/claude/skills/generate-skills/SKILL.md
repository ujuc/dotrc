---
name: generate-skills
description: "Claude 스킬을 생성하거나 기존 스킬을 최신 spec에 맞게 업데이트한다. 스킬 만들어줘, 새 스킬 추가, 스킬 업데이트, 스킬 수정, generate-skills 요청 시 사용한다."
group: meta
disable-model-invocation: true
argument-hint: "[skill-name]"
---

# Skill creation / update workflow

Read `references/quality-criteria.md` before authoring. It governs authority,
selected write scope, native tool equivalents and evidence levels, including
updates to this skill. Reuse existing user approval and managed-plan decisions.
Claude tool/model names below are host-specific examples; map available
capabilities and report missing independent roles rather than inventing them.

## Model guidance

Use **Standard** for scoped authoring, **Advanced** for conflicting policies or
uncertain evidence, **Frontier** for unresolved cross-workflow decisions and
**Lightweight** for mechanical validation. Apply `references/model-selection.md`
to resolve available models or recommend one when the host cannot switch.

## Mode detection

Inspect `$ARGUMENTS` to choose a mode:

- **Update mode**: `$ARGUMENTS` contains any of `업데이트`, `수정`, `update`
  → Run Step 0 → Steps U1–U3 → Step 5 (validation)
- **Create mode**: anything else
  → Run Step 0 → Steps 1–5

If `$ARGUMENTS` is empty, ask the user via AskUserQuestion which mode and which target skill.

---

## Reference routing

Load references when their condition applies; do not preload the directory.
Paths in this body resolve from this skill directory. Links inside a reference
resolve from that reference's directory.

| When | Reference |
| --- | --- |
| Resolving authority, scope or evidence | [Quality criteria](references/quality-criteria.md) |
| Choosing workload or delegation | [Model selection](references/model-selection.md), [subagent guidelines](references/subagent-guidelines.md) |
| Designing or restructuring | [Design principles](references/design-principles.md), [skill types](references/skill-types.md), [patterns](references/patterns.md) |
| Scaffolding or writing metadata | [Skill structure](references/skill-structure.md), [frontmatter spec](references/frontmatter-spec.md), [description examples](references/description-examples.md) |
| Defining output or injecting context | [Output patterns](references/output-patterns.md), [dynamic context](references/dynamic-context.md) |
| Reviewing an update | [Redundancy audit](references/redundancy-check.md), [review checklist](references/review-checklist.md), [eval guide](references/eval-guide.md) |
| Distributing a completed skill | [Distribution guide](references/distribution-guide.md) |

## Language policy

Apply this to every skill created or updated through this workflow.

- **`description` field → Korean.** This is the only part the user sees. Korean trigger phrases are also matched against `$ARGUMENTS` and the user's natural utterances, so Korean wording is functional, not just stylistic.
- **SKILL.md body, references/, scripts/, init templates → English.** This content is read by the LLM. English is more token-efficient and avoids translation drift in instructional prose.
- **Keep Korean verbatim where it has functional value:** trigger keywords used for `$ARGUMENTS` matching (e.g., `업데이트`, `수정`), Korean usage examples in description-writing guides, Korean Conventional Commits examples, and any text the user is expected to read (e.g., user-facing summary blocks defined inside a skill).
- **Keep target-language corpora and linguistic rulebooks in their analyzed
  language.** Translating a Korean pattern catalog into English destroys the
  data the skill must inspect.
- **When updating a legacy skill** that has Korean prose in the body or references, translate the prose to English while preserving the items above.

---

## Step 0: Spec sanity check (before anything else)

### Shared workflow and Superpowers source

Run `workflow-hooks contract` and require a non-empty
`superpowers.adapted_from.writing_skills` pin. This local skill remains the
authoring controller: it owns the Rust validator, group catalog, and Waza
integration. Adapt the pinned Superpowers pressure-testing principles, but do
not hand control to another skill-generation workflow.

When creating or updating a managed workflow skill, compare every artifact
path and writer claim with the retained contract. Contract changes and their
Rust validation must be approved and updated together.

The official skills doc changes often. Verify it before generating, but only
re-fetch when the local copy is actually stale — `references/frontmatter-spec.md`
carries its own freshness metadata in YAML frontmatter.

### Procedure

1. Read the YAML frontmatter at the top of `references/frontmatter-spec.md`:
   - `source_url` — Claude Code docs URL to fetch
   - `spec_url` — Agent Skills standard URL to fetch (rules marked **[SPEC]**
     are stated only there, never on the Claude Code page)
   - `last_upstream_check` — YYYY-MM-DD of the last verified check
   - `check_interval_days` — cadence threshold (defaults to 14 when missing)
2. Compute `today - last_upstream_check`:
   - **Within interval** → continue with Step 1 in create mode or Step U1 in update mode without fetching.
   - **Beyond interval** → continue to step 3.
3. WebFetch `source_url` and extract the Frontmatter reference section, **and**
   WebFetch `spec_url` for the standard's own field rules. Checking only
   `source_url` leaves every **[SPEC]** rule unverified.
4. Diff against the "Field Reference" section in `references/frontmatter-spec.md`.
5. Use verified guidance in-session and report drift. Update this reference and
   its check date only when cache maintenance is explicitly in the selected
   write scope. Another project's skill task must not change this global cache.
6. Record fetched/cached status; unchanged source content alone does not authorize
   a freshness-date write outside that scope.

### What to compare

- Field additions / removals / behavior changes
- String substitution changes
- Invocation control matrix changes

### Notes

- If WebFetch fails (network error, rate limit, page layout change), keep the
  existing `references/frontmatter-spec.md` **and** `last_upstream_check`
  untouched, then continue with the selected mode's next step and a short notice that the local spec may be stale.
- If the upstream change set is large, summarize it for the user and confirm
  before rewriting the local copy.

---

## Step 1: Capture the use case

Use AskUserQuestion to collect:

1. **Problem / scenario**: what concrete problem does this skill solve?
2. **Target tools**: which tools does it call (built-in tools, MCP servers, external CLIs)?
3. **Expected output**: what does running the skill produce (files, messages, code, ...)?
4. **Trigger phrases**: what does the user actually say when they want this skill?
5. **Catalog group**: choose one of `planning`, `analysis`, `build`, `verify`, `docs`, `writing`, `llm`, or `meta`.

Use the answers to first identify the **domain type** in `references/skill-types.md`, then pick a **structural pattern** from `references/patterns.md`:

| Pattern | Best fit | Freedom |
|---------|----------|---------|
| Linear workflow | Fixed sequence of steps | Low–medium |
| Interview-based | Requirements depend on user context | High |
| Tool orchestration | Combines several tools | Medium |
| Template fill | Produces a fixed-shape artifact | Low |
| Validation / review | Quality-checking existing artifacts | Medium |

Confirm the picked pattern, reason, and group with the user before scaffolding.

### Parallel exploration (optional)

After sending the AskUserQuestion, spawn an Explore subagent to survey existing skills while the user types. Follow `references/subagent-guidelines.md` → "Explore-1".

Skip when `$ARGUMENTS` already contains enough information.

### Behavior baseline

Before drafting, classify the target as discipline, technique, pattern, or
reference. Run the smallest scenario that exposes the current gap without the
new guidance: three pressure scenarios for discipline skills, otherwise one
application or retrieval scenario. For updates, run the unchanged skill as the
baseline. Keep the prompts and observed failure so Step 5 can rerun exactly the
same cases; if Waza is available for an existing skill, persist this baseline
through `waza-runner` before editing. If baseline behavior passes, do not invent a failure. A reproduced instruction
contradiction may justify a scoped consistency correction; otherwise avoid
speculative guidance and retain the evidence level.

---

## Step 2: Scaffold the structure

Follow `references/skill-structure.md`.

### Auto-init (preferred)

Run `scripts/init-skill` (thin bash launcher over the Rust workspace in `tools/`).
Launcher paths are anchored on `$DOTRCDIR` so they resolve from any working
directory — this skill is global, and CWD-relative paths break outside the dotrc
repo. `zshrc` exports `DOTRCDIR`, but only for interactive shells; each snippet
re-derives it so the command also works from cron, CI, or a bare non-interactive
shell.

```bash
DOTRCDIR="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}"
bash "${DOTRCDIR}/agents/claude/skills/generate-skills/scripts/init-skill" <skill-name> --group <slug> --path <target-path>
```

`--group` is required (one of the 8 slugs — see `references/frontmatter-spec.md` → `group`); the validator fails without it, and it must be a deliberate choice, never guessed. By default this creates only `SKILL.md` with the required fields filled in plus commented-out placeholders for every optional frontmatter field (`when_to_use`, `paths`, `shell`, `effort`, `context`, `agent`, etc.). If the skill needs Tier-3 resources, pass `--with-references`, `--with-scripts`, and/or `--with-assets`. Fill in the body in Steps 3–4.

Requires `cargo` (install via <https://rustup.rs>). First invocation compiles the binary (~6–30s); later runs are instant via Cargo's incremental cache.

### Manual scaffold (when cargo / init-skill is unavailable)

This creates a draft only. Completion and registration remain blocked until `cargo` is available for Step 5 validation.

**Required:**

1. Create the skill folder (kebab-case).
2. Create `SKILL.md` (empty — Steps 3–4 will fill it).

**Optional (depending on Step 1 outcome):**

3. `references/` for detailed reference docs.
4. `scripts/` for utility scripts.
5. `assets/` for media.

### Checks

- Folder name is kebab-case.
- No `README.md` was created.
- Folder name does not start with `claude` or `anthropic`.

## Step 3: Write the frontmatter

Use `references/frontmatter-spec.md` together with `references/description-examples.md`.

### Procedure

1. Set non-empty `name`, `description`, and `group`. Match `name` to the folder;
   use the selected catalog group, asking only if placement remains unclear.
2. Write a concise WHAT + WHEN description using the selected trigger phrases.
   Keep workflow details in the body, not discovery metadata.
3. Select optional fields from the frontmatter spec for the intended host and
   distribution path. Use manual invocation for destructive/expensive skills
   and hide background knowledge from the user menu where appropriate.
4. Keep workload guidance in the body. Omit fixed `model` assignments unless the
   user requests a host-supported override; tier labels are not native IDs.

Step 5 owns mechanical validation; review trigger accuracy here.

## Step 4: Write the instructions

Write the SKILL.md body following the pattern picked in Step 1.

### Reference-skill analysis (optional)

If Step 1 surfaced a similar-pattern skill worth studying, spawn an Explore subagent to dissect it in parallel with drafting. Fold the result into the draft. Follow `references/subagent-guidelines.md` → "Explore-2".

### Dynamic context injection (optional)

If the skill's body needs live shell output injected at load time (e.g. current branch, file listing, date), use the `` !`command` `` syntax documented in `references/dynamic-context.md` — Claude Code runs the command before the prompt reaches the model and substitutes its stdout.

### Common rules

- **State model guidance**: use `references/model-selection.md` for default levels,
  escalation triggers and cheaper mechanical phases. Link it when shipped together;
  otherwise adapt its wording locally. Resolve an available model API or recommend
  a model without claiming a session switch.
- **Be specific**: include runnable commands, exact paths, concrete acceptance criteria.
- **Handle errors**: list failure modes and how to recover.
- **Name the tools**: state which tools are used (Read, Write, Bash, AskUserQuestion, ...).
- **Build a Gotchas section**: known failure points are the highest-value content in any skill. See `references/design-principles.md` principle 4.

### Pick an output pattern

When the output shape matters, see `references/output-patterns.md`:

- **Template Pattern**: when the output format must be exact.
- **Examples Pattern**: when input/output pairs convey the quality bar.

### Apply degrees of freedom

Pick instruction specificity per the freedom guide in `references/design-principles.md`.

### Size limits

Keep the body within 500 lines and aim for at most 5,000 words. Move optional
detail into references, keeping execution gates and load conditions inline.

### Post-write checks

- Every `references/` path resolves to a real file.
- Instructions are verifiable (no fuzzy phrasing).
- No filler (no linter-style preaching, no speculation, no over-explaining).
- **Redundancy audit**: the body must not restate rules already enforced by dispatched agent definitions, sibling skills, or standard LLM knowledge. Run the audit in `references/redundancy-check.md` whenever the body references an agent file, overlaps with an existing skill, or exceeds 150 lines.
- **Managed ownership audit**: for workflow skills, verify contract-owned paths,
  writers, archive behavior, and excluded controllers against
  `workflow-hooks contract` rather than peer prose.

## Step U1: Inspect the target skill (update mode)

1. Extract the target skill path / name from `$ARGUMENTS`.
2. Read the target SKILL.md.
3. Parse frontmatter fields (name, description, optional fields).
4. Note whether `references/` and `scripts/` exist.
5. Count SKILL.md body lines.

If the target cannot be identified, ask via AskUserQuestion.

## Step U2: Compare against the latest spec (update mode)

Using the freshly verified `references/frontmatter-spec.md` from Step 0:

1. **Missing required fields**: add non-empty `name` and `description`; update cannot complete without them.
2. **Field compatibility**: distinguish standard, host-specific, and local fields.
   `license` and `metadata` remain standard fields; absence from one host table
   does not mean they were removed.
3. **New fields worth adopting**: suggest `context`, `agent`, `effort`, `allowed-tools` etc. when they would help.
4. **`description` quality**: WHAT + WHEN coverage, trigger phrasing.
5. **Structural health**: SKILL.md line count (500-line ceiling), whether content should be split into `references/`.
6. **Redundancy audit**: detect body content that duplicates dispatched agent definitions, sibling skills, or standard LLM knowledge. Follow `references/redundancy-check.md`. Typical findings: constraints mirrored between skill and agent, prompt templates restating agent rules, generic markdown conventions.
7. **Managed ownership**: when the skill participates in the managed lifecycle,
   compare its paths and sole-writer claims with `workflow-hooks contract`.
8. **Model guidance**: retain task-level defaults and escalation triggers in the
   body; inheritance alone is not a workload recommendation.

Summarize the comparison and reuse any already approved update scope. Resolve
only material unanswered choices or changes beyond that authorization.

## Step U3: Apply updates (update mode)

For the approved scope, use the active harness's patch/edit tool:

1. Add / modify / remove frontmatter fields.
2. Rewrite `description` if needed.
3. Reshape body sections if needed.

Apply already approved changes without per-file reconfirmation. Present new
scope or destructive changes only when existing authorization does not cover
them. When done, proceed to Step 5.

---

## Step 5: Validate

### Automated checks

Before the validator, fail the workflow if `name`, `description`, or `group` is missing/empty; validator warnings do not override these local requirements. If `cargo` is unavailable, stop and report the draft as unvalidated; do not register or claim completion. Otherwise run `scripts/validate-skill` (thin bash launcher over the Rust workspace in `tools/`):

```bash
DOTRCDIR="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}"
bash "${DOTRCDIR}/agents/claude/skills/generate-skills/scripts/validate-skill" <skill-directory>
```

First invocation compiles the validator (~6–30s, debug profile); later runs are instant via Cargo's incremental cache. Requires `cargo` (install via <https://rustup.rs>).

If anything fails, return to the relevant step, fix, and re-run.

### Behavior evaluation

Define binary (yes/no) eval criteria that measure output quality.
Per `references/eval-guide.md`, write 3–6 yes/no checks under an `## Eval Criteria` section in SKILL.md or in a separate `evals.md`.
Rerun the exact Step 1 baseline scenarios with the candidate skill. A
behavior-shaping change needs evidence at the level its claim requires. Record
structure, decision replay, artifact application and live integration separately.
Mock scores never prove behavior. For consistency corrections, show removal of
the reproduced contradiction without inventing a failed baseline. Purely
mechanical corrections may mark behavior N/A with structural evidence. The autoresearch skill can reuse these criteria later.

### Waza measurement (optional automation)

If `waza` is on PATH, persist the Step 5 candidate run alongside the Step 1
baseline for an existing skill. A new skill uses the no-guidance transcript as
its baseline because no runnable skill exists yet. **All waza operations route
through the `waza-runner` agent — this skill never invokes the `waza` CLI
directly.** When Waza is unavailable, use fresh-context subagent scenarios and
report that the evidence was not persisted by Waza.

Use the runner's [agent definition](../../agents/waza-runner.md) for scaffolding,
supported commands, existing-suite preservation and result paths. Refine its
placeholder tasks against actual triggers and outputs before evaluation. Retain
baseline/candidate paths for `skill-improver` and use distinct run labels.

### Independent review (optional)

If the generated skill includes `references/` or `scripts/`, use an available
fresh-context reviewer with the tools needed for a blind review. Select its
workload level using `references/model-selection.md`; uncertain findings may
receive a second independent opinion through a supported delegation/advisor
capability. Follow `references/subagent-guidelines.md`
→ "Reviewer".

Skip for minimal skills (SKILL.md only) or when the user requested a quick build.

### Trigger review (the part automation cannot catch)

Automation only checks form. Trigger accuracy needs a human eye.

- Are the phrases users actually say present in `description`? (avoids under-triggering)
- Does `description` lead with overly generic words ("help", "manage") that would over-trigger? (avoids over-triggering)

When in doubt, follow the trigger-tuning guide in `references/review-checklist.md`.

### Registration

Once validation passes, register only selected user-scope skills when registration
is in scope; project-local skills never enter the global catalog. The map is in `${DOTRCDIR}/agents/claude/skills/README.md`. The `group:` frontmatter is the single source of truth; the README table mirrors it and must stay in sync. Use the `register-skill` launcher — it is idempotent (re-running is a no-op) and errors if the skill is already listed under a different group:

```bash
DOTRCDIR="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}"
bash "${DOTRCDIR}/agents/claude/skills/generate-skills/scripts/register-skill" \
  "${DOTRCDIR}/agents/claude/skills/README.md" \
  --name <skill-name> \
  --group <group-slug>
```

The `--group` value must match the skill's `group:` frontmatter. Manual edit is still valid for layout changes the launcher can't produce (e.g. reordering entries within a row).

If repository policy requires post-edit skill-improver, run one targeted batch
for the changed skills. Re-verification inside that run is sufficient; never
recursively invoke authoring or maintenance after self-edits.

### Distribution (optional)

For team-wide distribution, see `references/distribution-guide.md` — repo check-in vs. plugin marketplace, composing skills, and measuring usage.

---

## Gotchas

- Manual-only skills retain Korean triggers as the discovery record, even though
  Claude Code does not auto-load their descriptions.
- Preserve `../` in bundled sibling reference links. Standalone distribution
  needs a local adaptation; invocation CWD is never the reference base.
- Forked skills must supply required context rather than assume conversation
  history. Check host behavior in the frontmatter spec.
- A failed upstream fetch preserves the cache and check date. Report cached
  evidence as cached, not freshly verified.
- The first Rust launcher call may compile; explain a noticeable startup pause.
- Superpowers is a pinned source. Local validation, catalog and managed
  workflow ownership remain with this repository.

## Eval Criteria

Use these binary checks with the evidence statuses in the eval guide.

| ID | PASS condition |
| --- | --- |
| 1 | `name`, `description`, and `group` are non-empty. |
| 2 | Every concrete reference path in the body and loaded references resolves. |
| 3 | `description` plus optional `when_to_use` covers WHAT and concrete WHEN triggers. |
| 4 | Body is at most 500 lines; a validator size warning still fails this criterion. |
| 5 | The Step 5 validator exits 0 with no error-severity findings. |
| 6 | Matching-input evidence supports the claimed level and preserves the workflow contract; mechanical corrections use structural evidence, and source-conflict repairs do not invent behavioral failures. |
