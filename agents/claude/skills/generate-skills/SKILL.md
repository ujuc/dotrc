---
name: generate-skills
description: "Claude 스킬을 생성하거나 기존 스킬을 최신 spec에 맞게 업데이트한다. 스킬 만들어줘, 새 스킬 추가, 스킬 업데이트, 스킬 수정, generate-skills 요청 시 사용한다."
group: meta
model: opus
disable-model-invocation: true
argument-hint: "[skill-name]"
---

# Skill creation / update workflow

## Mode detection

Inspect `$ARGUMENTS` to choose a mode:

- **Update mode**: `$ARGUMENTS` contains any of `업데이트`, `수정`, `update`
  → Run Step 0 → Steps U1–U3 → Step 5 (validation)
- **Create mode**: anything else
  → Run Step 0 → Steps 1–5

If `$ARGUMENTS` is empty, ask the user via AskUserQuestion which mode and which target skill.

---

## Design principles

Principles that guide every step. See `references/design-principles.md` for the full version.

1. **Concise is key — aggressively cut what the model already knows.** The context window is shared, and a skill earns its tokens only by supplying what the model cannot derive from training or from reading the code. Restating model-known conventions, generic best practices, or standard tool behavior is pure overhead — telling the model what it already knows changes nothing. When in doubt, assume it knows and cut it.
2. **Match degrees of freedom to task fragility** (low / medium / high specificity).
3. **Progressive disclosure**: split content across three tiers (metadata → body → bundled resources).
4. **Use subagents** wherever they protect the main context or unlock parallel work. See `references/subagent-guidelines.md` for the decision criteria.

---

## Language policy

Apply this to every skill created or updated through this workflow.

- **`description` field → Korean.** This is the only part the user sees. Korean trigger phrases are also matched against `$ARGUMENTS` and the user's natural utterances, so Korean wording is functional, not just stylistic.
- **SKILL.md body, references/, scripts/, init templates → English.** This content is read by the LLM. English is more token-efficient and avoids translation drift in instructional prose.
- **Keep Korean verbatim where it has functional value:** trigger keywords used for `$ARGUMENTS` matching (e.g., `업데이트`, `수정`), Korean usage examples in description-writing guides, Korean Conventional Commits examples, and any text the user is expected to read (e.g., user-facing summary blocks defined inside a skill).
- **When updating a legacy skill** that has Korean prose in the body or references, translate the prose to English while preserving the items above.

---

## Step 0: Spec sanity check (before anything else)

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
5. **If changes are detected**: update both the field content and
   `last_upstream_check` (set to today's date). Surface the diff to the user
   if the change set is non-trivial before rewriting.
6. **If unchanged**: just bump `last_upstream_check` to today's date.

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

---

## Step 3: Write the frontmatter

Use `references/frontmatter-spec.md` together with `references/description-examples.md`.

### Procedure

1. Set `name` (**required**): same as folder, kebab-case.
2. Write `description` (**required**) using the **WHAT + WHEN** formula:
   - WHAT: what the skill does (from Step 1's problem / scenario).
   - WHEN: when it should trigger (from Step 1's trigger phrases).
   - If omitted, the first paragraph of the markdown body is used.
3. Set `group` (**required** — local extension): one of the 8 slugs in
   `references/frontmatter-spec.md` → `group`. Never guess — confirm with the
   user when the placement is unclear.
4. Decide optional fields by category:

   **Invocation control:**
   - `disable-model-invocation`: `true` for destructive or expensive skills.
   - `user-invocable`: `false` for background-knowledge skills (hides from the `/` menu).

   **Execution environment:**
   - `model`: `opus` for complex workflows; omit otherwise.
   - `effort`: set when a different effort level than the session default is needed (`low`, `medium`, `high`, `max`).
   - `context`: `fork` to run in an isolated subagent context.
   - `agent`: subagent type when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, ...).

   **Tools / permissions:**
   - `allowed-tools`: tools usable without confirmation while the skill is active.
   - `disallowed-tools`: tools removed from the pool while the skill is active (e.g. `AskUserQuestion` for autonomous loops).

   **Other:**
   - `argument-hint`: autocomplete hint (e.g., `[issue-number]`).
   - `arguments`: named positional arguments for `$name` substitution.
   - `hooks`: hooks scoped to the skill's lifecycle.

Mechanical checks (kebab-case, length, reserved prefix, etc.) are handled by `validate-skill` in Step 5. Here, only check semantics: **does `description` contain both WHAT and WHEN?**

---

## Step 4: Write the instructions

Write the SKILL.md body following the pattern picked in Step 1.

### Reference-skill analysis (optional)

If Step 1 surfaced a similar-pattern skill worth studying, spawn an Explore subagent to dissect it in parallel with drafting. Fold the result into the draft. Follow `references/subagent-guidelines.md` → "Explore-2".

### Dynamic context injection (optional)

If the skill's body needs live shell output injected at load time (e.g. current branch, file listing, date), use the `` !`command` `` syntax documented in `references/dynamic-context.md` — Claude Code runs the command before the prompt reaches the model and substitutes its stdout.

### Common rules

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

- SKILL.md body: aim for ≤ 5,000 words.
- Over the limit? Move detail into `references/` and link with relative paths.

### Post-write checks

- Every `references/` path resolves to a real file.
- Instructions are verifiable (no fuzzy phrasing).
- No filler (no linter-style preaching, no speculation, no over-explaining).
- **Redundancy audit**: the body must not restate rules already enforced by dispatched agent definitions, sibling skills, or standard LLM knowledge. Run the audit in `references/redundancy-check.md` whenever the body references an agent file, overlaps with an existing skill, or exceeds 150 lines.

---

## Step U1: Inspect the target skill (update mode)

1. Extract the target skill path / name from `$ARGUMENTS`.
2. Read the target SKILL.md.
3. Parse frontmatter fields (name, description, optional fields).
4. Note whether `references/` and `scripts/` exist.
5. Count SKILL.md body lines.

If the target cannot be identified, ask via AskUserQuestion.

---

## Step U2: Compare against the latest spec (update mode)

Using the freshly verified `references/frontmatter-spec.md` from Step 0:

1. **Missing required fields**: add non-empty `name` and `description`; update cannot complete without them.
2. **Removed fields**: detect fields no longer in the official doc (e.g., `license`, `metadata`).
3. **New fields worth adopting**: suggest `context`, `agent`, `effort`, `allowed-tools` etc. when they would help.
4. **`description` quality**: WHAT + WHEN coverage, trigger phrasing.
5. **Structural health**: SKILL.md line count (500-line ceiling), whether content should be split into `references/`.
6. **Redundancy audit**: detect body content that duplicates dispatched agent definitions, sibling skills, or standard LLM knowledge. Follow `references/redundancy-check.md`. Typical findings: constraints mirrored between skill and agent, prompt templates restating agent rules, generic markdown conventions.

Summarize the comparison for the user and get approval for the update scope.

---

## Step U3: Apply updates (update mode)

For the approved scope, edit with the Edit tool:

1. Add / modify / remove frontmatter fields.
2. Rewrite `description` if needed.
3. Reshape body sections if needed.

Show the change to the user before each edit and confirm.
When done, proceed to Step 5 (validation).

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

### Behavior evaluation (optional)

Define binary (yes/no) eval criteria that measure output quality.
Per `references/eval-guide.md`, write 3–6 yes/no checks under an `## Eval Criteria` section in SKILL.md or in a separate `evals.md`.
The autoresearch skill reuses these criteria when optimizing autonomously.

### waza baseline measurement (optional)

If `waza` is on PATH, record an initial benchmark so `skill-improver` has a before/after reference. **All waza operations route through the `waza-runner` agent — this skill never invokes the `waza` CLI directly.** Skip cleanly when waza is missing — `waza-runner` prints the install guide and exits without error.

1. Scaffold the eval suite via the runner:
   ```
   Agent("waza-runner", "scaffold <skill-name>")
   ```
   The runner writes `agents/claude/evals/<skill-name>/eval.yaml` with positive×2 + negative×1 placeholder tasks. An existing `eval.yaml` is preserved — the runner never overwrites.
2. Refine the auto-generated tasks so triggers and expected outputs match reality. Replace the placeholder prompts and add at least one assertion that exercises the skill's specific behavior. (Human-in-the-loop step.)
3. Dispatch the runner with a `baseline` label:
   ```
   Agent("waza-runner", "eval <skill-name> --label baseline")
   ```
4. The agent prints a Korean summary table and saves JSON to `~/.claude/data/waza/results/<skill-name>-baseline-<ts>.json`. Keep that path in mind — `skill-improver` will compare against it later.

### Independent review (optional)

If the generated skill includes `references/` or `scripts/`, spawn a `general-purpose` agent (`model: sonnet`) to do a blind review; the reviewer consults `advisor()` for an opus cross-model second opinion on uncertain findings. Follow `references/subagent-guidelines.md` → "Reviewer".

Skip for minimal skills (SKILL.md only) or when the user requested a quick build.

### Trigger review (the part automation cannot catch)

Automation only checks form. Trigger accuracy needs a human eye.

- Are the phrases users actually say present in `description`? (avoids under-triggering)
- Does `description` lead with overly generic words ("help", "manage") that would over-trigger? (avoids over-triggering)

When in doubt, follow the trigger-tuning guide in `references/review-checklist.md`.

### Registration

Once validation passes, register the skill in the catalog group map in `${DOTRCDIR}/agents/claude/skills/README.md`. The `group:` frontmatter is the single source of truth; the README table mirrors it and must stay in sync. Use the `register-skill` launcher — it is idempotent (re-running is a no-op) and errors if the skill is already listed under a different group:

```bash
DOTRCDIR="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}"
bash "${DOTRCDIR}/agents/claude/skills/generate-skills/scripts/register-skill" \
  "${DOTRCDIR}/agents/claude/skills/README.md" \
  --name <skill-name> \
  --group <group-slug>
```

The `--group` value must match the skill's `group:` frontmatter. Manual edit is still valid for layout changes the launcher can't produce (e.g. reordering entries within a row).

### Distribution (optional)

For team-wide distribution, see `references/distribution-guide.md` — repo check-in vs. plugin marketplace, composing skills, and measuring usage.

---

## Gotchas

Skill-specific pitfalls that validator automation cannot catch. Update this section whenever a new edge case is discovered.

1. **`disable-model-invocation: true` removes the description from model context.**
   When this flag is set, the skill's `description` is not loaded into context, so its natural-language trigger phrases cannot auto-fire — the skill is effectively `/name`-only (or an explicit user request to run it). It also blocks subagent preloading and scheduled-task prompts (v2.1.196+). Keep trigger phrases in `description` anyway: they document intent and remain the record of when the skill is meant to fire.

2. **Reference paths are relative to SKILL.md, not the invocation cwd.**
   `references/<name>.md` in SKILL.md always resolves relative to the skill directory. Avoid `../` paths — if you need content from outside the skill tree, copy it into `references/` so the skill stays self-contained.

3. **`context: fork` drops conversation history.**
   The forked subagent sees only the SKILL.md body as its prompt — no prior messages, no user context. Any skill using `context: fork` must be self-sufficient (no "as discussed above" assumptions).

4. **Step 0 `WebFetch` is a single point of staleness.**
   When the Claude Code docs page is unreachable (network, rate limit, layout change), the workflow falls back to the local `references/frontmatter-spec.md`. The metadata block at the top of that file (`last_upstream_check`) is the only signal of how stale the spec might be.

5. **Cargo first-build cost is user-visible.**
   The first invocation of `scripts/validate-skill` or `scripts/init-skill` compiles the Rust workspace (~6–30s). Subsequent runs are near-instant. Users unfamiliar with Rust may interpret the initial pause as a hang — surface this in progress messages if the skill is invoked in an unattended context.

---

## Eval Criteria

Five binary checks that should pass for any skill produced (or updated) by this workflow. The `autoresearch` skill can reuse these when optimizing autonomously.

```
EVAL 1: Frontmatter completeness
  Question: Does SKILL.md contain both `name` and `description` fields,
            each non-empty?
  Pass: Both present with content.
  Fail: Either missing or empty string.

EVAL 2: Reference path integrity
  Question: Do all `references/<path>` mentions in SKILL.md resolve
            to files that exist on disk?
  Pass: Every referenced path is an existing file.
  Fail: Any referenced path is broken.

EVAL 3: Description structure
  Question: Does `description` (or `description` + `when_to_use`
            together) contain both WHAT (what the skill does) and
            WHEN (concrete trigger phrases the user might say)?
  Pass: Both elements clearly present, no pure-generic leaders
        like "help" or "manage".
  Fail: Missing WHAT or WHEN, or the phrasing is purely generic.

EVAL 4: Body size budget
  Question: Is the SKILL.md body (everything after the closing `---`)
            at most 500 lines?
  Pass: ≤ 500 lines.
  Fail: > 500 lines — split detail into `references/` files.
        (`validate-skill` reports overage as a warning, not an error;
        this eval still counts it as a failure.)

EVAL 5: Validator pass
  Question: Does the `$DOTRCDIR`-anchored `scripts/validate-skill`
            command from Step 5 exit with status 0 and no `✗` findings?
  Pass: Exit 0, no error-severity lines.
  Fail: Exit non-zero, or any `✗` finding.
```
