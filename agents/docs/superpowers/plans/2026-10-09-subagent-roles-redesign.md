# Subagent Roles Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove `agents/claude/agents/`, move every worker role under its owning skill as `references/roles/<role>.md`, dispatch only built-in `Explore`/`general-purpose` with per-call `model`/`effort` from one routing table, and merge verifier+debugger and detector+naturalness-reviewer.

**Architecture:** Role files are the old agent bodies minus frontmatter and the pasted model paragraph. Callers dispatch with "Read `<abs role path>` first and follow it" plus inputs. Read-only roles run on `Explore` and return text that the caller writes to the artifact; writing roles run on `general-purpose`. `model-selection.md` gains the routing table every dispatch cites.

**Tech Stack:** Markdown skills and references, one Python (`uv`) consistency script, `validate-skill` (Rust launcher), waza eval suites, git.

**Spec:** `/Users/ujuc/.config/dotrc/agents/docs/superpowers/specs/2026-10-09-subagent-roles-redesign-design.md`

## Global Constraints

- Commit directly to `main`, sequentially; no branches or worktrees. Every commit goes through the `commit` skill (Korean Conventional Commit, scope `skills` for `claude/skills/` and `claude/evals/`, `agents` otherwise).
- `workflow-contract.json`, artifact paths, and archive behavior do not change.
- Never write `model:` or `effort:` into any frontmatter. Pass them only as `Agent` call arguments.
- Routing table (verbatim from the spec): Lightweight = `haiku`/`medium`; Standard = `sonnet`/`medium`; Advanced = `opus`/`high`; Frontier = `fable`/`xhigh`.
- Read-only roles (verifier, researcher, skill-engineer, commit drafter) dispatch as `Explore`; writing roles (implementer, monolith, scanner, rewriter, fidelity-auditor) dispatch as `general-purpose`.
- Role files carry every rule the worker needs: `Explore` does not load CLAUDE.md.
- Humanizer fast-mode wording `track=monolith` must survive (eval `positive-trigger-3.yaml` greps it). Strict wording changes from "4인 파이프라인" / "4-agent" to "3인 파이프라인" / "3-agent".
- After changing any `agents/claude/skills/<name>/`, run `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/<name>` from the repository root.
- Work from the repository root `/Users/ujuc/.config/dotrc`. `agents/claude/` is symlinked to `~/.claude`, so paths under it are live immediately.

## Review Focus

1. A role file still says "Write to the supplied output path" while its caller dispatches `Explore`, which has no `Write`: the worker fails or silently returns nothing. Task 2 Step 5 and Task 3 Step 4 grep each `Explore` role file for `Write` and require "return as text".
2. The humanizer scanner is called in `review` mode without the round number and falls back to guessing from `_vN`: Task 5 Step 7 makes `round` a required input and the SKILL.md verdict table passes it.
3. `check-consistency` keeps old agent paths and exits 2 ("MISSING FILE") after the move: Task 5 Step 2 updates paths first so the script fails for the right reason (count 3 vs 4) and then passes.
4. The commit drafter returns a subject over 50 characters or a body over 72 columns: Task 7 Step 4 keeps the skill-side `printf | wc -m` check and adds a `fold` width check before committing.
5. `skill-improver` still sweeps `claude/agents/` and reports every target as missing: Task 4 Step 3 removes the sweep and its eval criterion 9 mention of `waza-runner.md`.

---

### Task 1: Routing table in model-selection.md

**Files:**
- Modify: `agents/claude/skills/generate-skills/references/model-selection.md:66-78` (between "## Recommendation versus execution" and "## Examples")

**Interfaces:**
- Produces: a `## Dispatch routing` section with the anchor `#dispatch-routing`; every later task links `../generate-skills/references/model-selection.md#dispatch-routing` (or `../../generate-skills/...` from a `references/roles/` file).

- [ ] **Step 1: Insert the section**

Insert before `## Examples`:

```markdown
## Dispatch routing

A skill that dispatches a worker through the host `Agent` tool resolves the
profile to these call arguments. Never write them into frontmatter.

| Profile | `model` / `effort` | Typical work |
| --- | --- | --- |
| Lightweight | `haiku` / `medium` | Deterministic checks, structured extraction, commits touching ≤2 files and ≤40 changed lines, waza launcher runs |
| Standard | `sonnet` / `medium` | Bounded implementation, multi-file commits, focused exploration, research partial reports |
| Advanced | `opus` / `high` | Design, semantic review, synthesis, debugging, humanizer strict verifiers |
| Frontier | `fable` / `xhigh` | Interdependent problems unresolved at Advanced |

Procedure:

1. Classify the step with the skill's stated rule and tell the user in one
   line which profile was chosen and why (예: "파일 1개, 12줄이라 Lightweight(haiku)로 초안을 뽑습니다").
2. If the step sits between two rows, ask with `AskUserQuestion`; the options
   are the two rows.
3. Call `advisor` at most once, only when the choice materially changes cost
   or outcome and the evidence does not settle it.
4. Pass `model` and `effort` as `Agent` arguments. An explicit user model
   choice for the session or task wins over the table.

Read-only roles dispatch as `Explore` (no `Edit`/`Write`; `Bash` available) and
return their report as text for the caller to write. Roles that must write
their own files dispatch as `general-purpose`. Role instructions live under the
calling skill's `references/roles/` and the dispatch prompt begins with
"Read `<absolute role path>` first and follow it."
```

- [ ] **Step 2: Verify the anchor resolves**

Run: `grep -n '^## Dispatch routing' agents/claude/skills/generate-skills/references/model-selection.md`
Expected: one line.

- [ ] **Step 3: Validate and commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/generate-skills`
Expected: `All checks passed.`
Commit via the `commit` skill: `docs(skills): 워커 디스패치 라우팅 표를 더하다` (body: Why — per-call model/effort replaces pinned agent models).

---

### Task 2: implement-plan roles (verifier absorbs debugger, implementer moves)

**Files:**
- Create: `agents/claude/skills/implement-plan/references/roles/verifier.md` (from `agents/claude/agents/verifier.md` + `agents/claude/agents/debugger.md`)
- Create: `agents/claude/skills/implement-plan/references/roles/implementer.md` (from `agents/claude/agents/implementer.md`)
- Delete: `agents/claude/agents/verifier.md`, `agents/claude/agents/debugger.md`, `agents/claude/agents/implementer.md`
- Modify: `agents/claude/skills/implement-plan/SKILL.md:88`, `:96`, `:107`, `:115`

**Interfaces:**
- Consumes: `model-selection.md#dispatch-routing` (Task 1).
- Produces: verifier report text with the five mandatory lines plus optional `## Diagnosis`; `implement-plan` writes it to `.plans/.verify-{item-slug}.md` / `.plans/.verify-final-{feature}.md`.

- [ ] **Step 1: Move the files**

```bash
mkdir -p agents/claude/skills/implement-plan/references/roles
git mv agents/claude/agents/verifier.md agents/claude/skills/implement-plan/references/roles/verifier.md
git mv agents/claude/agents/implementer.md agents/claude/skills/implement-plan/references/roles/implementer.md
```

- [ ] **Step 2: Rewrite `roles/verifier.md`**

Replace the whole file with:

```markdown
# Verifier role

You run project checks and report their results without fixing code. On a
failure you also diagnose it. You run as a read-only worker: return the report
as your final text; the caller writes it to the artifact path.

Model guidance: see [dispatch routing](../../../generate-skills/references/model-selection.md#dispatch-routing). The caller sends per-item runs at Lightweight and the final run at Standard; a FAIL that needs diagnosis is rerun at Advanced.

## Checks

1. Build, when the caller requests full verification and a build command exists.
2. Typecheck, when configured.
3. Lint, when configured.
4. Tests related to the changed files, or the full suite when requested.
5. On the final run only: every active acceptance criterion the caller lists, one line each.

Use a 60-second timeout per check unless the caller supplies another limit.

## Output

Return exactly this text:

```markdown
## Verification: [item]
- build: PASS/FAIL/SKIP
- typecheck: PASS/FAIL/SKIP
- lint: PASS/FAIL/SKIP
- tests: PASS/FAIL/SKIP ([passed] passed, [failed] failed)
- errors: []
- criteria: (final run only) one `- [criterion]: PASS/FAIL — evidence` line each
```

The first five lines are mandatory. For each failure, include the command,
exit status, and the first relevant stderr excerpt with `file:line` when
available. Use `errors: []` only when no check failed. Mark unavailable or
unconfigured checks as `SKIP` instead of omitting them.

When any line is FAIL, append:

```markdown
## Diagnosis
### Symptom
[Observed failure with the command, exit status, and file:line evidence.]
### Hypotheses
1. [Hypothesis — evidence at file:lines.]
### Reproduction
[Minimal commands or inputs.]
### Suggested Fix
[Smallest plausible edit; proposal only.]
```

When no grounded hypothesis is possible, keep `### Hypotheses` and write
`Insufficient evidence — [what information you need]` below it. Cite every
hypothesis with `file:line` and rank likely causes first. Do not pad the list.

## Rules

- Never modify source files. You have no `Write`/`Edit`; do not try to create files.
- Use `Bash` only for the checks above and for reproduction.
- When the caller supplies a worktree root and commit SHA, run inside that
  worktree and confirm `HEAD` matches the SHA; never inspect the main checkout instead.
- The caller owns sequencing and unique item slugs.

## Advisor

Default to no advisor call. At most once, call `advisor()` only when an
unfamiliar tool output cannot be classified as PASS, FAIL, or SKIP, or to rank
three or more grounded hypotheses. Prefer a grounded `SKIP` note when possible.
If `advisor` is not available in this context, continue without it.
```

- [ ] **Step 3: Trim `roles/implementer.md`**

Delete lines 1–5 (frontmatter) and the `## Model guidance` block (lines 9–13 of the original). Replace the deleted block with one line after the role sentence:

```markdown
Model guidance: see [dispatch routing](../../../generate-skills/references/model-selection.md#dispatch-routing). The caller dispatches at Standard; it moves to Advanced when the item spans interacting components.
```

Prepend `# Implementer role` as the first line. Leave every other section unchanged.

- [ ] **Step 4: Delete debugger.md**

```bash
git rm agents/claude/agents/debugger.md
```

- [ ] **Step 5: Guard the Explore role file**

Run: `grep -n -E '\bWrite\b' agents/claude/skills/implement-plan/references/roles/verifier.md`
Expected: only the line "You have no `Write`/`Edit`".

- [ ] **Step 6: Update implement-plan/SKILL.md dispatches**

Line 88 (Sequential Execution step 4), replace:

`Run the named focused checks, then launch an independent verifier writing `.plans/.verify-{item-slug}.md`.`

with:

`Run the named focused checks, then dispatch the verifier: `Agent` with `subagent_type: "Explore"`, `model`/`effort` from [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing) (Lightweight for a per-item run), and the prompt "Read `<abs>/references/roles/verifier.md` first and follow it. Item: {item-slug}. Changed files: {paths}. Named tests: {commands}." Write the returned text verbatim to `.plans/.verify-{item-slug}.md`.`

Line 96 (Parallel Worktrees step 1), replace `Launch one implementer per disjoint item in isolated worktrees` with `Dispatch one implementer per disjoint item (`Agent` with `subagent_type: "general-purpose"`, `isolation: "worktree"`, Standard routing, prompt "Read `<abs>/references/roles/implementer.md` first and follow it." plus the required inputs it lists)`. Keep the rest of the sentence.

Line 107 (Verifier failure), replace:

`create `.plans/.debug-{item-slug}.md` through an independent debugger or the inline systematic-debugging invariant. Apply a fix only after root cause is demonstrated, then rerun the same verifier.`

with:

`rerun the verifier at Advanced routing so its report carries `## Diagnosis`, or apply the inline systematic-debugging invariant. Apply a fix only after root cause is demonstrated, then rerun the verifier at the item's normal routing.`

Line 115 (Full Verification step 1), replace `Run one fresh full verifier for the build/test suite and every active acceptance criterion. Write `.plans/.verify-final-{feature}.md`.` with `Dispatch one fresh verifier at Standard routing with "full verification" and the list of active acceptance criteria; write the returned text to `.plans/.verify-final-{feature}.md`.`

Confirm no other `debugger` or `.debug-` mention remains:

Run: `grep -n -i 'debugger\|\.debug-' agents/claude/skills/implement-plan/SKILL.md`
Expected: no output.

- [ ] **Step 7: Validate and commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/implement-plan`
Expected: `All checks passed.`
Run: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/implement-plan/eval.yaml --label roles-after --trials 3` (record the Result JSON path for the final report; baseline is the suite's last recorded result under `~/.claude/data/waza/results/`).
Commit: `refactor(skills): implement-plan 워커를 역할 파일로 옮기다` (body: verifier absorbs debugger; Explore dispatch; caller writes artifacts).

---

### Task 3: deep-read researcher role

**Files:**
- Create: `agents/claude/skills/deep-read/references/roles/researcher.md` (from `agents/claude/agents/researcher.md`)
- Delete: `agents/claude/agents/researcher.md`
- Modify: `agents/claude/skills/deep-read/SKILL.md:42`, `:50-56`, `:64`, `:115`, `:121`, `:147`

**Interfaces:**
- Produces: researcher returns the partial report as text; `deep-read` writes `.research/.partial/{structure,dataflow,risks}.md`.

- [ ] **Step 1: Move and trim**

```bash
mkdir -p agents/claude/skills/deep-read/references/roles
git mv agents/claude/agents/researcher.md agents/claude/skills/deep-read/references/roles/researcher.md
```

Delete lines 1–5 and the `## Model guidance` block (original lines 9–13). Prepend `# Researcher role`. After the role sentence add:

```markdown
Model guidance: see [dispatch routing](../../../generate-skills/references/model-selection.md#dispatch-routing). The caller dispatches at Standard.

You run as a read-only worker without `Write`: return the complete partial
report as your final text. The caller writes it to the output path.
```

- [ ] **Step 2: Rewrite the Output Rules and Failure sections**

In `## Output Rules`, replace `- Write only to the output path supplied in the task.` with `- Return only the sections owned by your role; the caller writes them to the output path named in the task.` Replace `The task must supply the output path.` with `The task names the output path so you can label the report; you do not write it.`

In `## Failure`, replace `write the partial evidence available and add `<!-- PARTIAL: [reason] -->` at the top. Never leave the output file empty.` with `return the partial evidence available with `<!-- PARTIAL: [reason] -->` as the first line. Never return an empty result.`

In `## Boundaries`, replace `modify anything except the designated report` with `modify any file`.

- [ ] **Step 3: Update deep-read/SKILL.md**

Line 42, replace the paragraph with:

`Spawn 3 agents in a single message using `Agent` with `subagent_type: "Explore"`, `run_in_background: true`, and Standard `model`/`effort` from [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing). Each prompt starts with "Read `<abs>/references/roles/researcher.md` first and follow it." Role rules (citations, exploration depth, no modification) live in that file and are not restated here.`

Lines 50–56 prompt template, replace with:

```
Read <abs>/references/roles/researcher.md first and follow it.
Role: {structure|dataflow|risks}.
Target: {target path}.
Output label: {output path}.
Required top-level sections: {from table}.
Return the report as your final text.
```

After the "Wait for all 3 agents" paragraph add: `Write each returned text verbatim to its `.research/.partial/{role}.md` before merging.`

Line 64, replace `(written by `researcher` per its `## Failure` section)` with `(the researcher role returns it as its first line)`.

Line 115, replace `Per-agent rules are enforced by `~/.claude/agents/researcher.md`.` with `Per-worker rules are in `references/roles/researcher.md`.`

Line 121 Gotcha 1, replace `returns before the subagent writes its output. Always verify each `.partial/*.md` exists and is non-empty before merging` with `returns before the subagent finishes. Verify each returned text is non-empty and write it to `.partial/*.md` before merging`.

Line 147, replace `(per researcher.md rules)` with `(per the researcher role rules)`.

- [ ] **Step 4: Guard the Explore role file**

Run: `grep -n -E '\bWrite\b' agents/claude/skills/deep-read/references/roles/researcher.md`
Expected: only the "without `Write`" sentence.

- [ ] **Step 5: Validate, eval, commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/deep-read` → `All checks passed.`
Run: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/deep-read/eval.yaml --label roles-after --trials 3` and confirm `positive-trigger-2` still passes (it greps `structure.md`/`dataflow.md`/`risks.md`).
Commit: `refactor(skills): deep-read 연구자를 Explore 역할로 바꾸다`.

---

### Task 4: skill-improver skill-engineer role and agent-mode removal

**Files:**
- Create: `agents/claude/skills/skill-improver/references/roles/skill-engineer.md` (from `agents/claude/agents/skill-engineer.md`)
- Delete: `agents/claude/agents/skill-engineer.md`
- Modify: `agents/claude/skills/skill-improver/SKILL.md:3` (description), `:11`, `:48-52`, `:87-88`, `:93`, `:115`, `:119`, `:126`, `:128`, `:134`, `:141-144`, `:168-182`, `:235`, `:395`

**Interfaces:**
- Produces: skill-engineer report text (Korean sections) printed by `skill-improver`.

- [ ] **Step 1: Move and trim**

```bash
mkdir -p agents/claude/skills/skill-improver/references/roles
git mv agents/claude/agents/skill-engineer.md agents/claude/skills/skill-improver/references/roles/skill-engineer.md
```

Delete lines 1–5 and the `## Model guidance` block (original lines 9–13). Prepend `# Skill-engineer role`. After the role sentence add: `Model guidance: see [dispatch routing](../../../generate-skills/references/model-selection.md#dispatch-routing). The caller dispatches at Advanced. You run read-only on `Explore`; return the report as your final text.` Fix the `effort` link at the old line 89–90 to `../../../generate-skills/references/frontmatter-spec.md#effort` and the model guide link in the Model Fitness section likewise (`../../../generate-skills/references/model-selection.md`).

- [ ] **Step 2: Remove agent mode from SKILL.md**

- Line 3 description: change `스킬/에이전트 정의를` to `스킬 정의를`; keep every trigger phrase, including `에이전트 정의 개선` (it now routes to the role files under `references/roles/`).
- Line 11: `Audit skills and agent definitions` → `Audit skills and their worker role files`.
- Lines 48–52 Language Policy: delete the `- **Agents:**` bullet; change the sentence `Record a target-type policy mismatch as **B.7**` to apply to role files (`Role files under references/roles/ keep the language of the skill that owns them.`).
- Line 87: delete `, plus agent definitions in `claude/agents/` and `.claude/agents/` (and actual equivalents for other hosts)`.
- Line 88: delete the Mode classification step entirely and renumber steps 3–6 to 2–5.
- Line 93: `agent paths` → `role files`.
- Line 115: `three skill dimensions, a mode-specific dimension D for agents, and dimension E` → `three skill dimensions and dimension E`.
- Line 119: delete `**Skip for agent mode** — no equivalent validator exists yet; rely on Dimension D.`
- Line 126 B.5: delete `**Skip for agent files** unless body explicitly mentions external paths`; add `Role files under `references/roles/` are checked like any reference.`
- Line 128 B.7: `agent language is preserved;` → delete.
- Line 134 Scope boundary: replace `belong to the `skill-engineer` agent. ... dispatch `Agent("skill-engineer", "<target> [--check trigger|overlap|model|all]")`` with `belong to the skill-engineer role. To run those checks, dispatch `Agent` with `subagent_type: "Explore"`, Advanced routing, and the prompt "Read `<abs>/references/roles/skill-engineer.md` first and follow it. Target: <target> [--check trigger|overlap|model|all]"; print the returned report.`
- Lines 141–144: delete `### Dimension D — Agent-specific (agent mode only)` and its paragraph. Change the Phase 3 order sentence `Dimension A → B → C/D → E` to `Dimension A → B → C → E`.
- Lines 168–182: delete the `## Agent Definition Mode` section.
- Line 235: `agent targets have no suites and are always SKIP` → delete the clause.
- Line 395 criterion 9: `skills and agents (including `waza-runner.md`) call that launcher` → `skills call that launcher`.

- [ ] **Step 3: Confirm no sweep remains**

Run: `grep -n -i 'claude/agents\|agent mode\|Dimension D\|Agent Definition' agents/claude/skills/skill-improver/SKILL.md`
Expected: no output.

- [ ] **Step 4: Validate, eval, commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/skill-improver` → `All checks passed.`
Run: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/skill-improver/eval.yaml --label roles-after --trials 3`.
Commit: `refactor(skills): skill-improver에서 에이전트 모드를 걷어내다`.

---

### Task 5: humanizer roles and the scanner merge

**Files:**
- Create: `agents/claude/skills/humanizer/references/roles/monolith.md`, `rewriter.md`, `fidelity-auditor.md` (moved), `scanner.md` (new, from detector + naturalness-reviewer)
- Delete: `agents/claude/agents/humanize-monolith.md`, `humanize-detector.md`, `humanize-rewriter.md`, `humanize-fidelity-auditor.md`, `humanize-naturalness-reviewer.md`
- Modify: `agents/claude/skills/humanizer/scripts/check-consistency:22-33,52-53,66-75,88-95,110-113`, `agents/claude/skills/humanizer/SKILL.md:22,41,72-80,113,124,128,132-136,162,278-290,294`, `agents/claude/skills/humanizer/LICENSE-THIRD-PARTY:17-25`, `agents/claude/skills/humanizer/references/quick-rules.md:5`

**Interfaces:**
- Produces: `scanner.md` with `mode: baseline|review`; `review` requires `round` (1–3).

- [ ] **Step 1: Make check-consistency fail for the right reason**

Edit `scripts/check-consistency`:

```python
ROLES = ROOT / "references" / "roles"

SKILL = ROOT / "SKILL.md"
QUICK = REFS / "quick-rules.md"
TAXONOMY = REFS / "taxonomy-ko.md"
MONOLITH = ROLES / "monolith.md"
REWRITER = ROLES / "rewriter.md"
SCANNER = ROLES / "scanner.md"
FIDELITY = ROLES / "fidelity-auditor.md"
```

Remove the `AGENTS`, `NATURAL`, and `DETECTOR` names. In `FILES`, list `(SKILL, QUICK, TAXONOMY, MONOLITH, REWRITER, SCANNER, FIDELITY)`. Check #1: `has_four = has(skill_lines, r"3(인|-agent)")`, `stray` regex `r"[45](인|-agent)"`, name `"pipeline-count=3"`. Checks #4 and #5: replace `NATURAL` with `SCANNER`. Check #8: replace `DETECTOR` with `SCANNER`. Check #9: replace `NATURAL` with `SCANNER`. Update the docstring's "pipeline agent count" sentence to mention the historical "5인→4인→3인" sequence.

Run: `agents/claude/skills/humanizer/scripts/check-consistency`
Expected: exit 2, `✗ MISSING FILE` for the four role files.

- [ ] **Step 2: Move three roles**

```bash
mkdir -p agents/claude/skills/humanizer/references/roles
git mv agents/claude/agents/humanize-monolith.md agents/claude/skills/humanizer/references/roles/monolith.md
git mv agents/claude/agents/humanize-rewriter.md agents/claude/skills/humanizer/references/roles/rewriter.md
git mv agents/claude/agents/humanize-fidelity-auditor.md agents/claude/skills/humanizer/references/roles/fidelity-auditor.md
```

In each: delete lines 1–5 (frontmatter), keep the `<!-- Adapted from ... -->` comment but change its path to `See ../../LICENSE-THIRD-PARTY.`, and replace the `## 모델 선택` section (lines 13–17) with one line: `모델 선택: [디스패치 라우팅](../../../generate-skills/references/model-selection.md#dispatch-routing)을 따른다. 호출자는 monolith/rewriter를 Advanced, fidelity-auditor를 Advanced로 보낸다.` (adjust the role name per file). Fix any `../skills/generate-skills/...` link to `../../../generate-skills/...`.

- [ ] **Step 3: Write `roles/scanner.md`**

Compose from `humanize-detector.md` lines 6–87 and `humanize-naturalness-reviewer.md` lines 6–98 (read both before deleting). Structure:

```markdown
<!-- Adapted from epoko77-ai/im-not-ai (MIT). See ../../LICENSE-THIRD-PARTY. -->

# Scanner role

한글 텍스트를 taxonomy-ko.md로 스캔한다. `mode`에 따라 두 가지 일을 한다.

- `baseline`: 원문을 탐지해 재작성자가 소비할 `02_detection.json`을 쓴다. 윤문이나 판정은 하지 않는다.
- `review`: 윤문본을 같은 규칙으로 재스캔하고 잔존 패턴·과윤문을 판정해 `05_naturalness_review{_vN}.json`을 쓴다. 내용 무결성은 fidelity auditor가 담당하며 텍스트나 summary.md를 수정하지 않는다.

모델 선택: [디스패치 라우팅](../../../generate-skills/references/model-selection.md#dispatch-routing)을 따른다. 호출자는 baseline을 Standard, review를 Advanced로 보낸다.

## 입력
(공통) `mode`, `input_path`(baseline: 01_input.txt 또는 Korean fast redo의 final.md / review: 현재 rewrite 파일), `taxonomy_path`, `output_path`, `run_id`, `genre_hint`, `min_severity`, `include_document_level`
(review 전용) `original_path`, `original_detection_path`, `round` (1–3, 필수)
`input_path`를 Read로 읽는다. review에서는 `original_detection_path`의 `min_severity`와 `include_document_level`을 그대로 재사용한다.

## 탐지 규칙
(detector 29–38 verbatim)

## baseline 출력
(detector 40–78 verbatim: JSON schema with findings, category_summary, meta)

## review 지표
(reviewer 30–36 verbatim)

## review 판정표
(reviewer 38–51 verbatim)

## review 출력
(reviewer 53–90 verbatim)

## 실패 처리
(detector 80–85 for baseline; reviewer 92–95 for review, with `round 3에서도 C` now reading `round == 3이고 C: 강제로 hold_and_report`)

성공 시 baseline은 출력 경로, finding 수, 기준 점수만, review는 verdict, quality, 출력 경로만 반환한다.
```

Every "(verbatim)" marker means copy those source lines unchanged; keep the protected-token sentence (`커밋 메시지`), the `명사형 종결` guard, the bold **A**–**D** mapping, and the `3회`/`round 3` wording so check-consistency's regexes keep matching.

- [ ] **Step 4: Delete the two merged agents**

```bash
git rm agents/claude/agents/humanize-detector.md agents/claude/agents/humanize-naturalness-reviewer.md
```

- [ ] **Step 5: Run check-consistency**

Run: `agents/claude/skills/humanizer/scripts/check-consistency`
Expected: exit 1 with only `pipeline-count=3` failing (SKILL.md still says 4). Any other ✗ means a verbatim block was dropped in Step 3; fix it before continuing.

- [ ] **Step 6: Update SKILL.md wording and dispatches**

- Line 22: `Strict mode (4-agent pipeline)` → `Strict mode (3-agent pipeline)`.
- Line 41: `"4인 파이프라인"` → `"3인 파이프라인"`.
- Line 113: `4인 파이프라인 실행 가능` → `3인 파이프라인 실행 가능`.
- Line 294: `(4-agent count,` → `(3-agent count,`.
- Lines 72–80 (Korean fast): replace `Call the `humanize-monolith` agent once via the `Agent` tool.` with `Dispatch the monolith role once: `Agent` with `subagent_type: "general-purpose"`, Advanced routing from [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing), prompt "Read `<abs>/references/roles/monolith.md` first and follow it." plus the arguments below.` Keep the argument block. Keep the sentence `The monolith runs detection → rewrite → self-validation → output in one call` and `track=monolith` wording wherever it appears.
- Line 124 (Phase A): `Call `humanize-detector` with absolute ...` → `Dispatch the scanner role in `baseline` mode (`general-purpose`, Standard routing, prompt "Read `<abs>/references/roles/scanner.md` first and follow it. mode: baseline") with absolute `input_path`, `taxonomy_path`, `output_path` plus `run_id`, `genre_hint`, `min_severity`, `include_document_level: true`.`
- Line 128 (Phase B): `Call `humanize-rewriter`` → `Dispatch the rewriter role (`general-purpose`, Advanced routing, prompt "Read `<abs>/references/roles/rewriter.md` first and follow it.")`.
- Lines 132–136 (Phase C): `Call the `Agent` tool twice in parallel` stays; replace the two bullets with:
  - `fidelity-auditor role (`general-purpose`, Advanced; "Read `<abs>/references/roles/fidelity-auditor.md` first and follow it.") with `original_path`, `rewrite_path`, `diff_path`, `output_path` → `04_fidelity_audit{_vN}.json``
  - `scanner role in `review` mode (`general-purpose`, Advanced; "Read `<abs>/references/roles/scanner.md` first and follow it. mode: review") with `original_path`, `original_detection_path`, `rewrite_path`, `taxonomy_path`, `output_path`, and `round` (1–3) → `05_naturalness_review{_vN}.json``
- Line 162 (Redo): `scan `final.md` into `02_detection.json`` → `run the scanner role in `baseline` mode on `final.md` into `02_detection.json``.
- Lines 278–290 (`## Sub-agents`): rename to `## Worker roles` and list `references/roles/monolith.md` (Fast Korean), `scanner.md` (Strict Phase A baseline, Phase C-2 review, redo rescan), `rewriter.md` (Phase B, redo), `fidelity-auditor.md` (Phase C-1). Replace `These live in ~/.config/dotrc/agents/claude/agents/ (= ~/.claude/agents/).` with `All four dispatch as `general-purpose` with routing from model-selection.md; they write only their own output files.` Replace `Strict mode requires the named agents` with `Strict mode requires a host `Agent` tool`.
- Line 296: `the sub-agent definitions` → `the role files`.

- [ ] **Step 7: Make `round` explicit in the verdict loop**

In the Phase C verdict section, after the precedence sentence add: `Pass `round` = 1, 2, or 3 to the scanner review call; it never infers the round from the file suffix.`

- [ ] **Step 8: LICENSE and quick-rules**

`LICENSE-THIRD-PARTY` lines 17–21: replace the five `~/.config/dotrc/agents/claude/agents/...` entries with:

```
- `references/roles/monolith.md`
- `references/roles/scanner.md` (merged from `ai-tell-detector.md` and `naturalness-reviewer.md`)
- `references/roles/rewriter.md` (from `korean-style-rewriter.md`)
- `references/roles/fidelity-auditor.md` (from `content-fidelity-auditor.md`)
```

Line 23–25 "Modifications applied": append `; the detector and naturalness reviewer were merged into one scanner role with `baseline` and `review` modes`.

`references/quick-rules.md:5`: `` `humanize-monolith` 에이전트가 `` → `` monolith 역할(`roles/monolith.md`)이 ``.

- [ ] **Step 9: Verify**

Run: `agents/claude/skills/humanizer/scripts/check-consistency` → `All N consistency checks passed.`
Run: `grep -rn 'humanize-\|4인\|4-agent' agents/claude/skills/humanizer` → no output except LICENSE history lines and `3회`-style matches that are not `4인`.
Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/humanizer` → `All checks passed.`
Run: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/humanizer/eval.yaml --label roles-after --trials 3`; `positive-trigger-3` (`track=monolith`) must pass.

- [ ] **Step 10: Commit**

Commit: `refactor(skills): humanizer 워커를 세 역할로 합치다` (body: scanner merges detector and reviewer; roles under references/roles; 4→3 pipeline).

---

### Task 6: waza-runner removal

**Files:**
- Delete: `agents/claude/agents/waza-runner.md`
- Modify: `agents/claude/skills/waza/SKILL.md:17-18`, `agents/claude/skills/generate-skills/SKILL.md:352-354`, `agents/claude/skills/waza/references/waza-install.md:109`, `agents/claude/evals/generate-agent-docs/behavior-cases.md:105`, `agents/CLAUDE.md:3`, `README.md:295-296`

- [ ] **Step 1: Delete and reword**

```bash
git rm agents/claude/agents/waza-runner.md
```

`waza/SKILL.md:17`: replace the sentence starting `In Claude Code the `waza-runner` subagent wraps this same launcher` with:

`In Claude Code a caller that wants an isolated context dispatches `Agent` with `subagent_type: "general-purpose"`, Lightweight routing from [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing), and the prompt "Run `bash <abs>/scripts/waza-run.sh <dispatch>` and return stdout verbatim, keeping any `⚠️` line first." The launcher remains the only place that invokes the `waza` binary.`

`generate-skills/SKILL.md:352-354`: replace `dispatch the `waza-runner` agent ([definition](../../agents/waza-runner.md)) when an isolated context is preferable; it forwards the same `scaffold`/`eval` dispatch string to the launcher.` with `dispatch a `general-purpose` worker at Lightweight routing that runs the launcher and returns stdout verbatim when an isolated context is preferable (see the `waza` SKILL.md).`

`waza-install.md:109`: delete the `waza-runner` bullet.

`evals/generate-agent-docs/behavior-cases.md:105`: `Use the waza-runner agent for optional automated runs` → `Dispatch a Lightweight general-purpose worker that runs waza-run.sh for optional automated runs`.

`agents/CLAUDE.md:3`: replace the bullet with `- For waza suites, Claude Code may dispatch a Lightweight `general-purpose` worker that runs `waza-run.sh` in an isolated context.`

Root `README.md:295-296`: replace `Claude Code의 `waza-runner` 에이전트는 이 런처를 격리 컨텍스트에서 호출하는 래퍼다.` with `Claude Code에서는 격리 컨텍스트가 필요할 때 경량 워커가 같은 런처를 호출한다.`

- [ ] **Step 2: Verify and commit**

Run: `git grep -n 'waza-runner' -- . ':!agents/docs' ':!docs'` → no output.
Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/waza` and the same for `generate-skills` → `All checks passed.`
Commit: `refactor(skills): waza-runner 에이전트를 런처 워커로 대체하다`.

---

### Task 7: commit skill model routing

**Files:**
- Modify: `agents/claude/skills/commit/SKILL.md:5` (allowed-tools), `:12-16` (Model guidance), `:92-109` (step 7)

**Interfaces:**
- Consumes: `model-selection.md#dispatch-routing`.
- Produces: drafter prompt contract: returns `subject:` line and `body:` block only.

- [ ] **Step 1: Allow the Agent tool**

Line 5: append `, Agent` to `allowed-tools`.

- [ ] **Step 2: Replace Model guidance (lines 12–16)**

```markdown
## Model guidance

The message draft is delegated by diff size, per [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing):
after staging, read `git diff --cached --shortstat`. ≤2 files and ≤40 changed
lines → Lightweight (`haiku`/`medium`); otherwise Standard (`sonnet`/`medium`).
Mixed or unclear scope is a staging question (Step 4), not a model question.
Tell the user the chosen profile in one line. The commit itself, the 50/72
checks, and doc updates stay in this skill.
```

- [ ] **Step 3: Insert the drafter dispatch into step 7**

At the start of step 7 (line 92), before "Apply all three checks", add:

```markdown
   Dispatch the drafter: `Agent` with `subagent_type: "Explore"`, `model`/`effort`
   from the routing above, and this prompt:

   ```
   Draft a git commit message for the staged diff. Run `git diff --cached` and
   `git log --oneline -10` yourself. Rules: subject `<type>(<scope>): <한국어 제목 -다>`,
   ≤50 characters including the prefix, no trailing period; scopes: {scopes from
   project instructions}; body wrapped at 72 columns with Why/How lines when the
   type is feat or fix, otherwise optional. Return exactly:
   subject: <one line>
   body:
   <lines or empty>
   ```

   Treat the returned draft as the candidate for the checks below; rewrite it
   yourself if any check fails.
```

- [ ] **Step 4: Add the width check to self-check 1**

After the `printf '%s' '<subject>' | wc -m` sentence add: `For the body, `printf '%s\n' "<body>" | awk 'length > 72' | wc -l` must print `0`.`

- [ ] **Step 5: Validate, eval, live test, commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/commit` → `All checks passed.`
Run: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/commit/eval.yaml --label roles-after --trials 3`.
Live test: commit this task's own change through the `commit` skill. Expected: the one-line profile notice names Lightweight or Standard (the diff is one file, so Lightweight unless over 40 lines), and the commit passes the hook. Subject: `feat(skills): commit 초안을 diff 크기별 모델로 맡기다` (body: Why — haiku for short commits, sonnet for multi-file; How — Explore drafter, checks stay in the skill).

---

### Task 8: generate-skills authoring guidance

**Files:**
- Modify: `agents/claude/skills/generate-skills/references/subagent-guidelines.md:21-37`, `agents/claude/skills/generate-skills/SKILL.md:270`, `:296`, `agents/claude/skills/generate-skills/references/redundancy-check.md:7-20`, `:53`, `:59`, `:75-77`

- [ ] **Step 1: Fix the Explore row and document roles**

`subagent-guidelines.md` table row for Explore: `Cannot edit files or run arbitrary commands` → `No `Edit`/`Write`; has `Bash`, so it can run checks and return text`. After the "**Default**" line add:

```markdown
Worker roles a skill dispatches repeatedly live in that skill's
`references/roles/<role>.md`. The dispatch prompt begins with "Read `<absolute
role path>` first and follow it." Read-only roles use `Explore` and return
text; writing roles use `general-purpose`. Choose `model`/`effort` per call
from [dispatch routing](model-selection.md#dispatch-routing); never pin them in
frontmatter. `Explore` does not load CLAUDE.md, so the role file carries every
rule the worker needs.
```

- [ ] **Step 2: Reword the redundancy audit**

`SKILL.md:270`: `already enforced by dispatched agent definitions` → `already stated in dispatched role files`; `whenever the body references an agent file` → `whenever the body references a role file`.
`SKILL.md:296`: `duplicates dispatched agent definitions` → `duplicates dispatched role files`; `constraints mirrored between skill and agent, prompt templates restating agent rules` → `constraints mirrored between skill and role file, prompt templates restating role rules`.
`redundancy-check.md:7-20`: heading `### 1. Agent definition overlap` → `### 1. Role file overlap`; `If a skill dispatches an agent, compare the skill with that agent's definition` → `If a skill dispatches a worker role, compare the skill with that `references/roles/` file`; delete `Use the active host's agent directory; `~/.claude/agents/X.md` is the Claude Code example.`; `open the agent's `.md` file` → `open the role file`; `link to the agent definition` → `link to the role file`. Line 53: `references an agent file` → `references a role file`. Line 59: `grep SKILL.md for `~/.claude/agents/`, `references/`` → `grep SKILL.md for `references/``. Lines 75–77: `agent file` / `agent already enforces` / `between skill and agent` → `role file` / `role file already states` / `between skill and role file`.

- [ ] **Step 3: Validate and commit**

Run: `bash agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/generate-skills` → `All checks passed.`
Run: `git grep -n -i 'agent file\|agent definition\|~/.claude/agents' -- agents/claude/skills ':!agents/claude/skills/humanizer/LICENSE-THIRD-PARTY'` → no output.
Commit: `docs(skills): 스킬 작성 지침을 역할 파일 기준으로 고치다`.

---

### Task 9: Remove the agents directory and finish docs

**Files:**
- Delete: `agents/claude/agents/README.md` (directory becomes empty and disappears)
- Modify: `agents/AGENTS.md:19`, `agents/claude/skills/README.md:23`, `agents/claude/skills/AGENTS.md` (add one bullet)

- [ ] **Step 1: Delete the README and confirm the directory is gone**

```bash
git rm agents/claude/agents/README.md
ls agents/claude/agents 2>&1
```

Expected: `No such file or directory`. If other files remain, a previous task missed them; stop and finish that task.

- [ ] **Step 2: Docs**

`agents/AGENTS.md:19`: `Put reusable agents and skills under `agents/claude/`.` → `Put reusable skills under `agents/claude/`; worker roles live in the owning skill's `references/roles/`.`
`agents/claude/skills/README.md:23`: `각 스킬과 에이전트 본문에` → `각 스킬 본문과 역할 파일에`.
`agents/claude/skills/AGENTS.md`: add the bullet `- Worker roles a skill dispatches live in `references/roles/<role>.md`; dispatch built-in `Explore` (read-only) or `general-purpose` with per-call `model`/`effort` from `generate-skills/references/model-selection.md#dispatch-routing`. Do not create `~/.claude/agents/` definitions.`

- [ ] **Step 3: Final greps**

Run: `git grep -n -E 'humanize-(monolith|detector|rewriter|fidelity-auditor|naturalness-reviewer)|waza-runner|skill-engineer\.md|researcher\.md|verifier\.md|debugger\.md|implementer\.md|claude/agents' -- . ':!agents/docs' ':!docs'`
Expected: no output.
Run: `bash agents/hooks/test-workflow-hooks.sh` → `workflow hook tests: PASS`.
Run: `agents/claude/skills/humanizer/scripts/check-consistency` → all passed.

- [ ] **Step 4: Compare waza results**

For each suite run in Tasks 2–5 and 7, rerun with the baseline: `bash agents/claude/skills/waza/scripts/waza-run.sh eval agents/claude/evals/<skill>/eval.yaml --label roles-confirm --trials 3 --baseline-json <latest pre-change JSON under ~/.claude/data/waza/results/>`. Report any `⚠️ **regression**` line to the user before the final commit; do not revert on your own.

- [ ] **Step 5: Commit and run skill-improver**

Commit: `refactor(agents): 사용자 전역 에이전트 디렉터리를 없애다` (body: roles moved under skills; see spec path).
Then run the `skill-improver` skill on `implement-plan deep-read skill-improver humanizer waza commit generate-skills` as `agents/AGENTS.md` requires after skill changes, and report its table.
