# Subagent roles redesign — execution report

Date: 2026-10-09
Spec: `agents/docs/superpowers/specs/2026-10-09-subagent-roles-redesign-design.md`
Plan: `agents/docs/superpowers/plans/2026-10-09-subagent-roles-redesign.md`
Method: Superpowers subagent-driven development on `main` (sequential, no
worktrees). One implementer and one reviewer per task, a whole-branch review on
Fable, one fix dispatch, one scoped re-review.

## Outcome

`agents/claude/agents/` (11 custom Claude Code subagents plus README) is gone.
Each skill now owns its worker roles as `references/roles/<role>.md` and
dispatches the built-in `Explore` (read-only, returns text) or
`general-purpose` (writes its own output file) with `model`/`effort` chosen per
call from `generate-skills/references/model-selection.md#dispatch-routing`:

| Profile | model / effort |
|---|---|
| Lightweight | haiku / medium |
| Standard | sonnet / medium |
| Advanced | opus / high |
| Frontier | fable / xhigh |

| Skill | Roles | Type |
|---|---|---|
| implement-plan | verifier (absorbs debugger: `## Diagnosis` on FAIL), implementer | Explore, general-purpose (worktree) |
| deep-read | researcher ×3 | Explore |
| skill-improver | skill-engineer | Explore |
| humanizer | monolith, scanner (`mode: baseline\|review`, merges detector + naturalness reviewer), rewriter, fidelity-auditor | general-purpose |
| waza | none — one paragraph: Lightweight general-purpose worker runs the launcher | general-purpose |
| commit | Explore drafter; ≤2 files and ≤40 lines → Lightweight, else Standard | Explore |

## Commits (4246d1c..HEAD)

| SHA | Subject |
|---|---|
| 301e703 | docs(agents): 서브에이전트 역할 재설계 스펙과 계획을 더하다 |
| ef6b471 | docs(skills): 워커 디스패치 라우팅 표를 더하다 |
| 90c1520 | refactor(skills): implement-plan 워커를 역할 파일로 옮기다 |
| 82973c7 | refactor(skills): deep-read 연구자를 Explore 역할로 바꾸다 |
| e9a6f48 | fix(skills): deep-read 대형 대상 안내를 읽기 전용 워커에 맞추다 |
| ae12459 | refactor(skills): skill-improver에서 에이전트 모드를 걷어내다 |
| 6fb263f | refactor(skills): humanizer 워커를 세 역할로 합치다 |
| a25dd47 | fix(skills): humanizer scanner 쓰기 범위를 두 모드에 걸다 |
| 327b552 | refactor(skills): waza-runner 에이전트를 런처 워커로 대체하다 |
| b3c50c4 | feat(skills): commit 초안을 diff 크기별 모델로 맡기다 |
| d8a9b90 | fix(skills): 한국어 길이 검사가 바이트로 세지 않게 하다 |
| 286cc6e | docs(skills): 스킬 작성 지침을 역할 파일 기준으로 고치다 |
| eb4f17a | refactor(agents): 사용자 전역 에이전트 디렉터리를 없애다 |
| 2a7f1f2 | docs(agents): claude 디렉터리 설명에서 에이전트를 빼다 |
| e2dc1b0 | fix(skills): 역할 파일 전환 뒤 남은 문구를 정리하다 |

## Verification (spec §8)

| Item | Result |
|---|---|
| `validate-skill` for implement-plan, deep-read, skill-improver, humanizer, waza, commit, generate-skills | PASS (final review + skill-improver audit) |
| every `references/roles/` link and `#dispatch-routing` anchor resolves | PASS (15 links, 8 anchors) |
| `humanizer/scripts/check-consistency` | 32/32 PASS |
| `agents/hooks/test-workflow-hooks.sh` | PASS (contract unchanged) |
| live `commit` on a 1-file change | PASS on d8a9b90: "Lightweight(haiku/medium)" notice, haiku Explore drafter returned subject+body, 50/72 checks and hook passed |
| `git grep` for old agent names outside `agents/docs/`, `docs/` | only `generate-skills/references/frontmatter-spec.md:235` (host option description, kept) |
| skill-improver audit of the seven skills (report-only) | A PASS ×7, C PASS ×7, E SKIP (no failed sessions); its manual proposals were applied in e2dc1b0 |
| waza before/after | see below |

waza (local `gemma4:e4b-mlx`, 3 trials after; baseline = latest pre-change JSON):

| Suite | Baseline → after (weighted) | Verdict |
|---|---|---|
| implement-plan | 1.000 → 0.944 | no regression (Δ −0.056) |
| deep-read | 0.944 → 1.000 | no regression |
| skill-improver | 1.000 → 1.000 | no regression |
| commit | 0.944 → 1.000 | no regression |
| humanizer | 1.000 → 0.931 | Δ −0.069 within ε, but INCOMPARABLE by the launcher rule (baseline ran 1 trial, after ran 3); `positive-trigger-003` failed 2/3 on unchanged classification text — treated as local-model noise |
| generate-skills | 1.000 → 1.000 (launcher comparison, 4/4 both) | no regression |
| waza | no suite exists |

Comparison of the first five was done offline from the existing result JSONs
with the launcher's own rule (Δ < −0.1 = regression; engine/model/trials/task
set mismatch = incomparable) instead of rerunning each suite; generate-skills
was rerun through the launcher with `--baseline-json`.

## Rulings made during execution

- Pre-existing uncommitted Korean edits in the old rewriter and
  naturalness-reviewer agent files rode along into the role files via `git mv`.
- scanner.md keeps the literal `round 3` so check-consistency's regex matches.
- The plan's waza commands failed because they used a relative `eval.yaml`
  path; the launcher accepts a bare skill name or an absolute path. The
  skill-improver guidance ("always pass the absolute path") is correct and was
  left unchanged; the final review's proposal to switch it was dropped.
- Task 4 and Task 5 implementers stalled after background waza runs; the
  controller applied the remaining one-line edits itself.
- Task 5's commit trailer was amended from the subagent's model to the
  session-supplied attribution.
- Task 7's implementer could not reach the Explore drafter (nested subagent
  dispatch returns no hand-back) and found `awk length` counts bytes on macOS
  (3 Korean chars → 9); the width check now uses `${#l}`, and the live test was
  rerun from the main session.
- Task 9's five `roles-confirm` reruns were replaced by the offline comparison
  above; the plan's final grep pattern was filtered to exclude the new role-file
  paths and generate-agent-docs' `stage4-verifier.md`.
- No scoped re-review was dispatched for the two one-sentence controller fixes
  (a25dd47, d8a9b90); the whole-branch review covered them.

## Left as is

- Verifier appends `## Diagnosis` on any FAIL; the Advanced rerun only improves
  it. `criteria:` line is final-run only.
- Korean example sentence inside the English routing procedure (plan-mandated).
- Long joined lines in generate-skills/SKILL.md and root README.md from Task 6.
- `multi-agent-orchestrator/SKILL.md:63` still says "debug state"; the
  contract keeps `debug_pattern` for archive cleanup.
- `generate-skills/references/frontmatter-spec.md:235` describes the host's
  `.claude/agents/` option; a local-policy line was added under it.
- skill-improver's description trigger "에이전트 정의 개선" was kept (WHEN
  clause; changing it needs user approval).
- Pre-existing uncommitted changes (zshrc, agents/claude/settings.json,
  agents/codex/hooks.json, autoresearch, frontend-design-evaluator,
  qa-evaluator SKILL.md, skill-improver quality-checks.md) were never staged.

## Not checked

- Whether Explore's built-in "locate, don't audit" system prompt degrades
  verifier or skill-engineer output quality in a live managed run.
- No fresh 3-trial pre-change baselines exist; humanizer's comparison is
  therefore formally incomparable.
- skill-engineer trigger/overlap/model-fitness checks (the audit could not
  dispatch it).
