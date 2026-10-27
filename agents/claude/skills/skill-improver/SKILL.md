---
name: skill-improver
description: "스킬 정의를 구조·의미 점검과 최근 세션 기록에서 관찰된 실패로 감사해 안전한 기계적 결함은 자동 수정하고 행동 변경은 근거 있는 제안으로 남긴다. /skill-improver, skill-improver, 스킬 개선해줘, 에이전트 정의 개선, 스킬 최적화, improve skill 요청 시 사용한다. 스킬 테스트·eval 실행·점수 비교는 waza, 반복 변이 루프는 autoresearch가 맡는다."
group: meta
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(bash:*), Bash(git:*), Bash(date:*), Bash(mktemp:*), Bash(diff:*), Agent, advisor
argument-hint: "[skill-name ...]"
---

# Skill Improver

Audit skills and their role files: fix safe mechanical defects, and propose behavioral changes only where recent sessions support them.

## Scope

- **Model guidance:** Lightweight for structural checks, Standard for bounded mechanical fixes, Advanced for semantic and evidence judgments; recommend Frontier only for an unresolved, consequential cross-skill conflict. Follow the [shared model guide](../generate-skills/references/model-selection.md); recommending a model to the user is not switching to it, and inheriting the parent's model is an execution fallback, not proof of fit.
- **One batch:** reuse the selected targets and any approval already given; a post-edit check is one targeted batch, not a full sweep. During self-maintenance, never invoke this skill or the authoring controller recursively.
- **Policy first:** explicit user and repository policy wins over optimization defaults.
- **Review, don't run:** read definitions, scripts and existing evidence. Never execute a target's workflow to fill an evidence gap; report the gap and route an authorized isolated run to the owning authoring or evaluation workflow. The Waza guard (Phases 4–5) is the only measurement.
- **Independent review:** an advisor or a separate reviewer context, handed the inputs, instructions and evidence explicitly; a different model alone is not independent, and neither is your own reasoning. Use it for a complex skill's cross-skill test coverage (Phase 2), an ambiguous mechanical-vs-manual call or a contested E.1 finding (Phase 4), and at most once after three iterations (Phase 5). When none is available, say so and leave unresolved behavioral proposals unapplied.
- **Questions:** without a question tool, ask in ordinary text; never assume an answer. An unanswered material choice blocks only the writes that depend on it.
- **Write scope:** target files, the skills README catalog, `REPORT_DIR`, Waza result JSON under the gitignored `~/.claude/data/waza/results/`, and a commit the user asked for. Never scaffold or edit `claude/evals/`; suite authoring belongs to `generate-skills` through the `waza` skill.

## Phase 0 — Pre-flight

If step 1 or 2 fails, report an actionable fix and stop before Phase 1.

1. **Toolchain:** `cargo` (`validate-skill` is a Rust launcher with no `.sh` suffix, and its first call may compile; fix: https://rustup.rs) and `jq` (needed by `scripts/collect-sessions`).
2. **Repository:** `repo_root=${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents` must hold `AGENTS.md`, `claude/skills/`, and `claude/skills/generate-skills/scripts/validate-skill`. Run every scan and command against `repo_root`; the caller's CWD may be any project and stays untouched.
3. **Spec freshness** (warn only): read `last_upstream_check` and `check_interval_days` (default 14) from the frontmatter of the sibling `generate-skills` skill's `frontmatter-spec.md` reference; warn when today is past the interval. Relay the one line from `bash <repo_root>/claude/skills/generate-skills/scripts/skill-diet-upstream check`.
4. **Waza** (non-blocking):
   ```bash
   waza_run="<repo_root>/claude/skills/waza/scripts/waza-run.sh"
   bash "$waza_run" status
   ```
   Waza is usable only when the output has the line `- Usable: yes`. Otherwise the Waza guard is SKIP with the `- Usable: no (<reason>)` reason, never a Phase 0 failure. Call only this launcher, never the `waza` binary; the [`waza` skill](../waza/SKILL.md) owns every subcommand.

## Phase 1 — Inventory

1. **Targets:** the named skills, or with no arguments every skill in `claude/skills/` and `.claude/skills/`.
2. **Catalog map:** `name` and `group` of each user-scope `claude/skills/` skill, for B.6. Project-scope `.claude/skills/` skills are validated structurally but never join the user catalog.
3. **Per target:** parse the frontmatter (`name`, `description`, `model`, `allowed-tools`, optional fields), the procedure, constraints and prohibitions, referenced paths (`references/`, `scripts/`, role files), and the description's trigger keywords. Summarize its intent in one line.
4. **Session evidence** (once per run):
   ```bash
   REPORT_DIR=$(mktemp -d "${TMPDIR:-/tmp}/skill-improver-XXXXXXXX")
   bash "<repo_root>/claude/skills/skill-improver/scripts/collect-sessions" --out "$REPORT_DIR"
   ```
   Defaults: a 45-day window, the 12 newest qualifying sessions, sidechains excluded; narrow a manual run with `--since YYYY-MM-DD` or `--project PATH`. Start from `$REPORT_DIR/inventory.json`; Dimension E reads the digests in `$REPORT_DIR/transcripts/`. **Never read raw `.jsonl` history.** If collection fails (missing history can fail instead of giving an empty inventory) or samples no sessions, Dimension E is SKIP, never PASS or a structural FAIL, and A–C continue. Audit artifacts stay under `REPORT_DIR`, never in a user project. After touching `condense.jq` or `inventory.jq`, run `bash scripts/test-collect-sessions`.

## Phase 2 — Tests

Each test is a concrete check with a PASS criterion.

### Dimension A — Structural

Run `validate-skill <path>` (frontmatter, naming, size limits, `group` presence and slug), then `bash <repo_root>/claude/skills/generate-skills/scripts/skill-diet-eval check <path>` (links and anchors in every file) and `bash <repo_root>/claude/skills/generate-skills/scripts/skill-diet-growth <path>`. `diet-recommended` is a Manual finding, not a FAIL. Dimension B does not repeat these.

### Dimension B — Semantic

- **B.1 Description-body alignment:** the description's WHAT clause claims nothing the procedure lacks and misses no major capability.
- **B.5 Reference integrity:** every path the body references exists; role files under `references/roles/` are checked like any reference.
- **B.6 Catalog sync:** a valid user-scope skill is listed under its `group` in `<repo_root>/claude/skills/README.md`. `group` owns placement; no parallel trigger or model catalog in `claude/CLAUDE.md`. Project-scope targets: SKIP.
- **B.7 Language policy:** `description` and `when_to_use` are Korean; SKILL.md bodies are English except functional examples and user-visible strings; role files keep their owning skill's language. Trigger keywords are functional identifiers: never paraphrase or translate them. Report drift and ask before translating.
- **B.9 Authority and write scope:** the target reuses existing approval, puts explicit user and repository requirements over optimization defaults, resolves targets and dependencies before writing, names who owns each side effect, and keeps body and references consistent on cache/date writes and approval scope without new per-file approval gates. FAIL examples: asking again for the same exact patch; editing unrelated sibling or global caches; pruning a named team test gate as generic cleanup; an upstream recommendation shown as an unlabeled local hard limit. New scope and destructive actions still need their approval; when one is needed, quote the requirement and why existing authorization falls short.
- **B.10 Evidence contract** (inspect evaluator prompts and checked-in suites; never run the target): each claim names its evidence level (structure/schema, fixed-input decision replay, actual artifact application, live integration) and has the inputs for it. Verifiers of preservation or confirmation get the original contents or diff, facts, decisions, scope and effective guidance, so a blind reviewer neither guesses hidden facts nor drops policy whose approval it cannot see. Baseline and candidate share inputs and channels; a changed suite supports no raw-score regression claim. SKIP and UNVERIFIED stay evidence statuses, never PASS. FAIL examples: mock keyword success shown as behavior; simulated tool calls shown as live runs; preservation PASS without a baseline; unchecked final repairs; skipped evidence or failed criteria hidden by a score. A source contradiction may be repaired without claiming baseline behavior failed.
  - **WARN low-signal suite** (report only; never PASS evidence, never blocks Phase 5): `eval.yaml` has `config.executor: mock` or the launcher's `| Engine |` row shows `mock` (the mock never loads SKILL.md); or every grader in `eval.yaml` and `tasks/*.yaml` is a `type: text` `contains`/`not_contains` check or a `type: behavior` token budget, with no `skill_invocation` grader. `| Skill invocations | 0 / M |` alone is no WARN: with the default `inject_skill_body: true` the body is already in the system prompt.
- **B.11 Host and source integrity:** tool and model names are supported or mapped to the host's capabilities, with unavailable roles disclosed; upstream requirements, recommendations, local policy and model or study findings keep their own scope; reference paths, section names and writer roles are current. FAIL examples: a missing AskUserQuestion treated as headless operation; claiming an unavailable advisor ran; a model-specific default required globally; shared instructions moved into one host's rule files only.

Trigger completeness, trigger overlap and model fitness belong to the skill-engineer role; do not check them here. To run them, dispatch `Agent` with `subagent_type: "Explore"`, Advanced routing, and the prompt "Read `<abs>/references/roles/skill-engineer.md` first and follow it. Target: <target> [--check trigger|overlap|model|all]"; print the returned report.

### Dimension C — Type-specific

- **Scripts:** run each executable in `scripts/` directly (`./script --help`) so its shebang applies (forcing `bash` breaks a `uv run` PEP 723 script) and expect exit 0; when it needs arguments, also run it bare and expect a clear usage error, not a crash. Data files such as `*.jq` are covered by their launcher's self-check.
- **Pipelines:** every skill name the target references exists as a skill directory.

### Dimension E — Evidence

Score once per run, not per target: rate each digest per [`references/evidence-rubric.md`](references/evidence-rubric.md) and attribute findings by its rules. A target's row shows only findings attributed to it; SKIP when there are none, which is common and not a defect.

- **E.1 Observed failure:** a session scored below 0.5 did work this target owns. Cite the session id and a one-line paraphrase; never quote digest lines or name the projects, files, or people in them.
- **E.2 Coverage:** the target fires where its domain appears. A never-firing skill is a trigger finding for skill-engineer.

Record `sessions_sampled`, failed sessions and `skill_coverage` for the report.

## Phase 3 — Run

Run A → B → C per target, then report its share of E. Classify each result PASS, FAIL, WARN (non-critical, such as a missing optional field), SKIP (not applicable, or no evidence attributed to the target), or **UNVERIFIED** (an applicable claim lacks required evidence; never count it as PASS).

Three or more Dimension A errors skip the rest for that target. Show a results table after each target.

## Phase 4 — Fix

- **Mechanical:** fix directly only A/B/C failures in the table below.
- **Behavioral (E-track):** follow [`references/change-bar.md`](references/change-bar.md). Never edit a target file directly from an evidence finding; no proposal is a valid outcome.

| Category | When | Fix |
| --- | --- | --- |
| Frontmatter | Missing field, typo, invalid format other than `group` | Add or correct the field |
| Description WHAT | B.1 fails | Rewrite the WHAT clause from the procedure; never change the WHEN clause (trigger phrases) without user approval |
| Catalog sync | B.6 fails for a valid user-scope skill | Align the README group map; never register a project-scope skill |
| Reference path | B.5 fails | Fix the path when a similarly named file exists nearby; otherwise Manual |

Manual (report, do not attempt):

- Cross-skill dependencies, core logic, workflow changes, structural design, and authority, scope or evidence decisions.
- WHEN-clause changes and translations, unless explicitly approved.
- Missing or invalid `group`: present the eight allowed slugs and take the user's choice; never infer a group from the name or description.
- E.1 proposals: a draft at most, never an unattended procedure rewrite.
- E.2 coverage gaps: suggestions for skill-engineer, which owns triggers.
- `diet-recommended`: hand off to `/generate-skills <name> 다이어트`; this skill never runs a diet eval.

When fixability is ambiguous, ask for independent review; without one, report the classification and leave the change unapplied.

### Waza baseline

When Waza is usable and `<repo_root>/claude/evals/<skill>/eval.yaml` exists, run a baseline before the target's first model-visible fix (frontmatter, description, body, or a reference path), even when that fix comes in a later iteration:

```bash
eval_yaml="<repo_root>/claude/evals/<skill>/eval.yaml"
[ -f "$eval_yaml" ] && bash "$waza_run" eval "$eval_yaml" --label improver-baseline --trials 3
```

Use three trials; one run is noise. Budget about 20 minutes per guard run. Record the `- Result JSON: ...` path the report ends with as `waza_baseline[<skill>]`. Always pass the absolute `eval.yaml` path: a bare skill name scaffolds a new suite, outside this skill's write scope. No suite → guard SKIP; catalog-only fixes → guard SKIP (catalog-only). Launcher exit 1 or no `- Result JSON:` line → no baseline, guard UNVERIFIED.

## Phase 5 — Re-verify (max 3 iterations)

1. Rerun the target's full test matrix on the final bytes, including checks that passed before.
2. **Regression guard:** a fix that causes a new failure is reverted and reclassified as Manual; an unapplied E-track draft is discarded from `$REPORT_DIR/proposed/`.
3. **Waza guard:** when `waza_baseline[<skill>]` exists and this iteration applied model-visible fixes:
   ```bash
   bash "$waza_run" eval "$eval_yaml" --label improver-after --trials 3 \
     --baseline-json "${waza_baseline[<skill>]}"
   ```
   Classify in this order:
   - Launcher exit 1, no `- Result JSON:` line, or `⚠️ incomparable`, on the rerun or its confirmation: `UNVERIFIED`, never SKIP or PASS, and no revert on that alone. This wins over a reference-only note.
   - `⚠️ **regression**` (rounded weighted Δ below −0.1): run one confirmation with `--label improver-confirm` against the same baseline. If it appears again, revert **all** of this iteration's model-visible fixes for the target and reclassify them as Manual (`regression-reverted`); do not bisect, since each run costs 13–20 minutes. If not, record `preserved` with an "unconfirmed drop" note and both JSON paths.
   - `reference-only` (mock engine): record it and never revert.
   - Otherwise `preserved`. That is a fixed-input replay, reported under B.10, never as live behavior.

   Keep every JSON path for the report and any later `/autoresearch` run.
4. All required checks PASS, with inapplicable or missing optional evidence shown as SKIP/UNVERIFIED → Phase 6. Never call an audit end-to-end behavior verification.
5. Failures remain and fewer than three iterations → back to Phase 4. After the third, stop, report what remains, and disclose whether review was available.

## Phase 6 — Report and commit

Report each target's checks, iterations, status and changes, the evidence summary, and the `REPORT_DIR` location:

```
## skill-improver Results

| Target | Tests | Iterations | Status | Changes |
|--------|-------|------------|--------|---------|
| <target> | <PASS/FAIL/SKIP/UNVERIFIED counts> | <n> | <status> | <changes or none> |

Evidence: <sampled> sessions since <date>, <failed> failed, coverage <ratio>
  - <session id> → <target>: <one-line paraphrase and disposition>
Waza: <usable|SKIP reason>
  - <skill>: engine <engine>, trials <n>, weighted <before> → <after> (<Δ>), skill invocations <N/M>, verdict <preserved|regression-reverted|reference-only|UNVERIFIED|SKIP> — baseline <json>, after <json>[, confirm <json>]
Suite signal:
  - <skill>: WARN low-signal suite (<mock engine|text/token-budget graders only>) → author through generate-skills with the waza skill
```

Include empty evidence and no-proposal outcomes, and every target with a Waza baseline, changed or not. Leave the scratch directory in place. Session history stays local and read-only: never upload, commit, or quote raw history or digest lines; cite session IDs with one-line paraphrases.

If fixes were applied, show the full diff. Commit only when the user asked (a still-applicable earlier request counts), following the repository's Korean Conventional Commit rules; otherwise leave the changes uncommitted.

For deeper eval-based optimization, finish this run, then recommend a separate `/autoresearch <target>`; never launch it inside this run's commit.

## Look up the rest

- Scoring digests, attribution, coverage, privacy → [references/evidence-rubric.md](references/evidence-rubric.md)
- E-track proposal → [references/change-bar.md](references/change-bar.md)
- Trigger, overlap and model checks → [references/roles/skill-engineer.md](references/roles/skill-engineer.md), through `Explore`
- Eval criteria for `/autoresearch` → [evals.md](evals.md)
