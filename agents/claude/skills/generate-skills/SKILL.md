---
name: generate-skills
description: "Claude 스킬을 생성하거나 기존 스킬의 구조·frontmatter를 최신 spec에 맞게 업데이트하며, skill-diet 기준의 다이어트를 실행한다. 스킬 만들어줘, 새 스킬 추가, 스킬 업데이트, 스킬 수정, 스킬 갱신, create a skill, update skill, generate-skills, /generate-skills 요청 시 사용한다. 세션 실패 근거의 자동 개선은 skill-improver, eval 실행은 waza가 맡는다."
group: meta
disable-model-invocation: true
argument-hint: "[skill-name]"
---

# Skill creation / update workflow

Tool and model names below are Claude Code examples. Use the active host's file,
patch, fetch, question and fresh-context delegation equivalents, and report a
missing independent role instead of inventing one. These rules also govern
edits to this skill. Paths in this body resolve from this skill directory.

## Model guidance

Use **Standard** for scoped authoring, **Advanced** for conflicting policies or
uncertain evidence, **Frontier** for unresolved cross-workflow decisions and
**Lightweight** for mechanical validation. Resolve a profile to an available
model with [model selection](references/model-selection.md); when the host
cannot switch, recommend one without claiming a switch.

## Mode detection

Inspect `$ARGUMENTS` to choose a mode:

- **Update mode**: `$ARGUMENTS` contains any of `업데이트`, `수정`, `갱신`, `최신화`, `update`, `refresh`
  → Run Step 0 → Steps U1–U3 → Step 5 (validation)
- **Diet mode**: `$ARGUMENTS` contains `다이어트` or `diet`
  → Run Step 0 → [full diet](../skill-diet/references/diet.md) → Step 5. Eval via
  `scripts/skill-diet-eval` in `~/.claude/data/skill-diet/<skill>-<YYYYMMDD>/` with
  `scripts/diet-adapter-claude` symlinked as `adapter`, `--parallel 2`, a pinned
  `--model`. The shipping commit carries `Skill-Diet: <skill-name>`.
- **Create mode**: anything else
  → Run Step 0 → Step 1 below → Steps 2–4 in [create mode](references/create-mode.md) → Step 5

If `$ARGUMENTS` is empty, ask which mode and which target skill.

## Scripts

Launch them by absolute path: this skill is global, so CWD-relative paths break
outside the dotrc repo. The Rust launchers need `cargo`; the first run compiles.

```bash
DOTRCDIR="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}"  # zshrc exports it only in interactive shells
GS="${DOTRCDIR}/agents/claude/skills/generate-skills/scripts"
bash "$GS/init-skill" <skill-name> --group <slug> --path <parent-dir> [--with-references] [--with-scripts] [--with-assets]
bash "$GS/validate-skill" <skill-dir>
bash "$GS/skill-diet-eval" check <skill-dir>   # SKILL.md bytes for the commit message; fails on a broken link or anchor
bash "$GS/skill-diet-growth" <skill-dir>       # one line: within budget | diet-recommended | no diet baseline
bash "$GS/skill-diet-upstream" check           # one advisory line; `pull <tag>` only when the user asks
bash "$GS/register-skill" "${DOTRCDIR}/agents/claude/skills/README.md" --name <skill-name> --group <slug>
```

## Authority and scope

- Explicit user decisions and repository rules beat optimization defaults. Keep
  concrete test gates, nondefault conventions and safety boundaries; a model
  prompting guide does not override them.
- Reuse approved plans and patches without asking again per file. Ask only for a
  material open choice, new scope, a destructive action, or a rule that demands
  fresh approval, and name that reason.
- A missing companion file is a scope decision, not permission to create it.
- Fetch sources read-only. Unless cache maintenance is the selected task, report
  drift and leave sibling or global caches, settings, catalogs and check dates alone.
- With no question tool, ask in plain text when interactive; when headless, keep
  writes that depend on an unanswered material choice pending.
- Label each guidance claim as upstream requirement, upstream recommendation,
  local policy, or model-specific finding, keeping its scope: a per-file size
  recommendation is not a combined hard limit.
- After renaming a section or role, audit the prose that cites it, not only file existence.

## Evidence levels

| Level | Proves | Does not prove |
| --- | --- | --- |
| Structure/schema | Metadata, paths, parsing, size | Skill decisions or file changes |
| Decision replay | Interpretation of fixed inputs in a fresh context | Real tool runs, delivered questions, a finished pipeline |
| Artifact application | Actual output bytes, write order, preservation | Untested hosts or branches |
| Live integration | The exercised host/tool flow | Other hosts, versions or cases |

- Record PASS, FAIL, SKIP (not applicable) or UNVERIFIED (required evidence
  missing) per check. Neither SKIP nor UNVERIFIED passes; missing required
  evidence blocks the completion claim.
- Mock or keyword-echo scores are plumbing smoke, never behavior PASS. Do not
  compare raw scores across a changed suite, executor or input set.
- Keep exact baseline inputs, fixture bytes and outputs, and rerun the same cases
  on the candidate. If an explicit instruction already makes the baseline pass,
  report the removed contradiction, not an invented FAIL→PASS.
- Give a verifier originals or diffs, scope, facts and user decisions. A blind
  reviewer judges only what its inputs show; missing approval evidence is no
  ground for deleting a team rule. Recheck only the criteria a final repair touched.

## Language policy

- `description` → Korean: its trigger phrases are matched against `$ARGUMENTS` and user wording.
- SKILL.md body, `references/`, `scripts/`, init templates → English.
- Keep Korean verbatim where it is functional: `$ARGUMENTS` trigger keywords,
  Korean examples in description guides, Korean Conventional Commits examples,
  user-facing output text, and target-language corpora or rulebooks.
- Updating a legacy skill: translate Korean body prose to English, keeping the above.

## Step 0: Spec freshness

This skill stays the authoring controller (Rust validator, group catalog, Waza
integration). Borrow Superpowers pressure-testing ideas, but never hand control
to another skill-generation workflow.

1. Lines 1–6 of [frontmatter-spec.md](references/frontmatter-spec.md) hold
   `source_url`, `spec_url`, `last_upstream_check` and `check_interval_days`
   (default 14). Within the interval, go to the mode's first step without fetching.
2. Otherwise WebFetch both URLs (**[SPEC]** rules exist only at `spec_url`; try
   the HTML page when a Markdown response fails). Diff fields, string
   substitutions and the invocation-control matrix against the spec's
   Field Reference; use verified guidance in-session and report drift.
3. Rewrite the spec or its date only when cache maintenance is in the selected
   write scope, confirming a large change set with the user first. Unchanged
   upstream content alone does not authorize a date write. When fetching fails
   or is not permitted, leave both untouched and continue with a one-line notice
   that the spec is cached as of `last_upstream_check`. Report fetched or cached either way.
4. Relay the one line from `skill-diet-upstream check`; pull a tag only when the user asks.

## Step 1: Capture the use case (create mode)

Ask (AskUserQuestion or plain text) for the problem or scenario, target tools
(built-ins, MCP servers, external CLIs), expected output, trigger phrases users
actually say, and the catalog group: one of `planning`, `analysis`, `build`,
`docs`, `writing`, `llm`, `meta`. Then pick the domain type and structural
pattern in [create mode](references/create-mode.md#step-1-capture-the-use-case)
and confirm the pattern and group before scaffolding.

## Behavior baseline

Before editing or drafting, classify the target as discipline, technique,
pattern or reference, and run the smallest scenario that exposes the gap
without the new guidance: three pressure scenarios for a discipline skill,
otherwise one application or retrieval scenario. For an update the unchanged
skill is the baseline. Keep the prompts and observed result for Step 5. With
Waza usable on an existing skill, freeze the suite's tasks, then persist this
baseline with `--trials 3` ([Waza suites](references/eval-guide.md#waza-suites)).
If the baseline passes, do not invent a failure; a reproduced contradiction
justifies only its scoped correction.

## Step U1: Inspect the target skill (update mode)

Resolve the target from `$ARGUMENTS` (ask if unclear), read its SKILL.md and
frontmatter, note `references/` and `scripts/`, and run
`skill-diet-eval check <skill-dir>` for size and links.

## Step U2: Compare against the latest spec (update mode)

1. **Required fields**: add non-empty `name` and `description`; the update cannot complete without them.
2. **Field compatibility**: separate standard, host-specific and local fields.
   `license` and `metadata` stay standard even when one host table omits them.
3. **New fields**: suggest `context`, `agent`, `allowed-tools` and the like where
   they help; `effort` only with measured evidence, re-checking a level carried
   over from another model ([model selection](references/model-selection.md#selection-and-escalation) step 4).
4. **`description`**: WHAT + WHEN coverage and trigger phrasing.
5. **Structural health**: `skill-diet-growth <skill-dir>`;
   `diet-recommended`, or one idea stated twice, → offer Diet mode.
6. **Redundancy**: run the audit below.
7. **Model guidance**: keep a default profile and escalation trigger in the
   body; inheritance alone is not a recommendation.

Summarize the comparison, reuse any approved scope, and ask only about material open choices.

## Step U3: Apply updates (update mode)

Put each change through [Editing a skill](../skill-diet/SKILL.md#editing-a-skill),
then edit frontmatter, `description` and body within the approved scope, and go to Step 5.

## Redundancy audit

Run it in Step U2 and after writing a new skill. Cut a line that restates:

- a dispatched worker's role file: keep the rule in the role file, since
  workers load no CLAUDE.md; task inputs, dispatch conditions and inline safety
  gates stay at the call site;
- a sibling skill's procedure: name the skill instead;
- standard LLM or tool knowledge: name the tool and trust its docs.

Keep a duplicate only for an inline safety gate, an unversioned source, or a hot
path. Prefer delete-and-link over rephrasing.

## Step 5: Validate

Fail the workflow if `name`, `description` or `group` is missing or empty;
validator warnings do not override this. If `cargo` is missing, stop and report
the draft as unvalidated: no registration, no completion claim. Otherwise run
`validate-skill` and `skill-diet-eval check` on the skill; fix and rerun until both pass.

**Size limits**: place each fact by [level](../skill-diet/SKILL.md#levels);
skill-diet's budget decides when to slim, and the validator's 500-line warning
is the backstop.

**Behavior evaluation**: write 3–6 binary checks under `## Eval Criteria` or in
`evals.md` ([eval guide](references/eval-guide.md)). Rerun the exact baseline
scenarios and any tests that assert the skill's text on the candidate, recording
each evidence level separately. Purely mechanical corrections may mark behavior
N/A with structural evidence.

**Waza**: when usable, run the candidate beside the baseline. All Waza operations
go through the [`waza` skill](../waza/SKILL.md) launcher `../waza/scripts/waza-run.sh`;
never call the `waza` CLI directly. Follow [Waza suites](references/eval-guide.md#waza-suites)
and keep the baseline/candidate JSON paths for `skill-improver`. Without Waza,
use fresh-context subagent scenarios and report that Waza did not persist the evidence.

**Independent review**: when the skill ships `references/` or `scripts/` and the
user did not ask for a quick build, dispatch the blind reviewer in
[subagent guidelines](references/subagent-guidelines.md#reviewer).

**Trigger review**: automation checks form only. Confirm the phrases users say
are in `description` and that it does not lead with generic words ("help",
"manage"); use [trigger tuning](references/description-examples.md#trigger-tuning) when unsure.

**Registration**: register only user-scope skills, and only when registration is
in scope; project-local skills never enter the global catalog. The README table
mirrors the `group:` frontmatter, so `register-skill --group` must equal it. The
launcher is idempotent and errors if the skill sits under another group; edit by
hand only for layouts it cannot produce.

**Maintenance**: if repository policy requires skill-improver after edits, run
one targeted batch for the changed skills. Its re-verification is enough: never
recursively invoke authoring or maintenance after self-edits, and a targeted
check is not consent to a full sweep, commit or unrelated cleanup.

## Gotchas

- Manual-only skills retain Korean triggers as the discovery record, even though
  Claude Code does not auto-load their descriptions.
- Preserve `../` in bundled sibling reference links. Standalone distribution
  needs a local adaptation; invocation CWD is never the reference base.
- Forked skills must supply required context rather than assume conversation
  history. Check host behavior in the frontmatter spec.

## Eval Criteria

Use these binary checks with the evidence statuses above.

| ID | PASS condition |
| --- | --- |
| 1 | `name`, `description`, and `group` are non-empty. |
| 2 | Every concrete reference path in the body and loaded references resolves. |
| 3 | `description` plus optional `when_to_use` covers WHAT and concrete WHEN triggers. |
| 4 | Body is at most 500 lines; a validator size warning still fails this criterion. |
| 5 | The Step 5 validator exits 0 with no error-severity findings. |
| 6 | Matching-input evidence supports the claimed level and preserves the workflow contract; mechanical corrections use structural evidence, and source-conflict repairs do not invent behavioral failures. |

## Look up the rest

- Create mode Steps 1–4, scaffolding, structure, output and dynamic context → [create-mode.md](references/create-mode.md)
- Field rules, portability, invocation control, substitutions → [frontmatter-spec.md](references/frontmatter-spec.md)
- Writing or tuning `description` → [description-examples.md](references/description-examples.md)
- Degrees of freedom, gotchas, config, hooks, completion criteria → [design-principles.md](references/design-principles.md)
- Workload profile, worker `model`/`effort` → [model-selection.md](references/model-selection.md)
- Explore or reviewer subagents → [subagent-guidelines.md](references/subagent-guidelines.md)
- Eval criteria and Waza suites → [eval-guide.md](references/eval-guide.md)
- Editing an existing skill, sizing it, or teaching a tool → [skill-diet](../skill-diet/SKILL.md), [tool skills](../skill-diet/references/tool-skills.md)
