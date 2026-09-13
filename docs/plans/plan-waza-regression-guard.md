# Plan: waza-regression-guard

## Goal

Make the skill-improver Waza regression guard neither revert on noise nor trust signal-free results. Evidence (scratchpad `findings.md`, 2026-09-13): an unchanged `annotate-plan` suite scored weighted 1.000 then 0.944 across two `--trials 3` runs, which today's `Δ < 0` rule would flag as a regression; mock-executor suites never load SKILL.md and always score 1.0; `skill_invocations` was 0 in all 18 real runs; `waza compare`/`waza gate` accept engine-mismatched pairs.

## Approach

- Reuse waza's own result fields (`config.engine_type|model_id|runs_per_test`, `tasks[].stats.avg_weighted_score|pass_rate`, `runs[].skill_invocations`); compute no new statistics.
- Verdict = rounded weighted Δ < −epsilon (default 0.1). Per-task `pass_rate` drops are informational: upstream marks a task failed when any single trial fails (runner.go:1118-1139), so status/pass_rate are noisier than weighted score.
- Comparability via one jq comparator, twice: pre-run (engine from eval.yaml `executor:`, model from `$COPILOT_MODEL` because the launcher always passes `--model`, trials from `--trials` or `trials_per_task`) to avoid a wasted 13–20 min run; post-run on both JSONs adding the sorted `test_id` set. Mismatch → `⚠️ incomparable`, no verdict, exit 1.
- Exit codes: 0 success incl. a reported regression; 1 no JSON / scaffold or baseline validation failed / incomparable; 2 usage.
- Mock results render with a reference-only note and never produce the regression line (user decision: run, reference-only).
- `status` probes Ollama `/api/tags` for `$COPILOT_MODEL` and ends with `- Usable: yes` / `- Usable: no (<reason>)`; exit stays 0.
- `--trials` is forwarded only when given (`${trials:+--trials "$trials"}`), so existing generate-skills argv is unchanged.
- Fixed strings shared by launcher, test, and docs: `| Engine | … |`, `| Model | … |`, `| Trials | … |`, `| Skill invocations | N / M |`, `> ℹ️ reference-only (mock engine: SKILL.md not exercised)`, `### ⚠️ incomparable (<fields>)`, `⚠️ **regression**`, `### Per-task drops`, `- Usable: yes|no (<reason>)`.

## Acceptance Criteria

No active contract

Plan-level checks from the user's decisions:

1. Epsilon default 0.1 on weighted score; Δ −0.056 not flagged, Δ −0.2 flagged; `--epsilon X` overrides.
2. skill-improver guard uses `--trials 3`; launcher forwards `--trials` only when given.
3. Mock suites still run; reports mark them reference-only; they never yield a regression verdict or revert.
4. Engine/model/trials/task-set mismatch → `⚠️ incomparable`, exit 1; pre-run-knowable mismatches skip the waza run.
5. Report shows Engine, Model, Trials, Skill invocations; per-task drops listed.
6. `status` ends with a greppable `- Usable:` line including the Ollama model probe.
7. skill-improver: Phase 0 usable iff `- Usable: yes`; Phase 4 baseline only before model-visible edits; Phase 5 confirmation rerun before revert, revert all model-visible fixes of that iteration, exit 1/no JSON/incomparable → UNVERIFIED; Phase 6 per-skill line; Criterion 11 rewritten; Criterion 9 stays true.
8. B.10 report-only `low-signal suite` WARN; no suite edits.
9. Synthetic self-test `test-waza-run`, executable, `--help` exits 0.
10. Exclusions: no edits under `agents/claude/evals/`, repo-root `evals/`, `agents/claude/skills/prompting-assist/`, `agents/claude/skills/generate-skills/`; no dependencies beyond bash/jq/awk/curl.

## Workflow Sources
- Product Spec: None
- Sprint Contract: None
- Research: None

## Reference Implementations

- `agents/claude/skills/waza/scripts/waza-run.sh`: header/exit codes `:4-12` (`usage()` `:33-35` prints lines 2–16, through the first truly empty line); `find_waza` `:39-49` (`command -v` first, so a fake binary on PATH wins); `cmd_status` `:84-110`; `fmt_pct`/`fmt_num` `:171-172`; report table `:211-218`; `render_comparison` `:254-280` (rule `d < 0` at `:275`, early return without jq `:256`); flag loop `:282-304`; baseline validation `:311-320`; run line `:346`; unconditional `return 0` `:367`.
- `agents/claude/skills/skill-improver/scripts/test-collect-sessions`: `--help` `:9-13`, mktemp/trap `:15-16`, `check`/`absent`/`expect_status` `:19-37`, jq fixtures `:39-47`, exit `:149-150`.
- `agents/hooks/test-workflow-hooks.sh:65-86`: the repo's fake-binary-on-PATH pattern.
- `agents/claude/skills/gemma/scripts/bulk-read.sh:39-45`: existing Ollama HTTP call style.
- Probe fixtures: scratchpad `probe/ap-t3-1.json`, `probe/ap-t3-2.json` (noise pair; `runs[]` omits `skill_invocations` → jq null), `probe/commit-mock-t3.json`.
- Docs stating the old rule: `agents/claude/skills/waza/SKILL.md:6,51-52,58,60`; `agents/claude/agents/waza-runner.md:24-29,41,47-48`; `agents/claude/skills/skill-improver/SKILL.md:81-86,219-234,268-279,301-302,357-361,378,380`; `agents/claude/skills/skill-improver/references/quality-checks.md:27-54`.
- Callers that must keep working: `agents/claude/skills/generate-skills/SKILL.md:157-158,344-360` (no `--trials`).
- Dimension C runs `./script --help` for executables in `scripts/` (`skill-improver/SKILL.md:141-143`); `validate-skill` does not inspect `scripts/`.

## File Changes

| Path | Change |
|---|---|
| `agents/claude/skills/waza/scripts/waza-run.sh` | header; flag-value guard; `--trials`/`--epsilon`; `yaml_config`, `incomparable_fields`, `print_incomparable`; report rows + mock note; `render_comparison` gate/drops/epsilon/reference-only returning 1 on incomparable; pre-run gate; status probe + `Usable` |
| `agents/claude/skills/waza/scripts/test-waza-run` | **new**, mode 0755, synthetic self-test |
| `agents/claude/skills/waza/SKILL.md` | argument-hint, flags, Contract, self-test pointer |
| `agents/claude/agents/waza-runner.md` | dispatch flags, exit-code bullet, relay `⚠️ incomparable` |
| `agents/claude/skills/skill-improver/SKILL.md` | Phase 0 step 7, Phase 4 baseline, Phase 5 guard, Phase 6 template, Gotcha 5, Criterion 11 |
| `agents/claude/skills/skill-improver/references/quality-checks.md` | B.10 low-signal WARN block |

Test path for all behavior items: `agents/claude/skills/waza/scripts/test-waza-run`.

## Code Snippets

Flag parsing (also fixes the pre-existing hang where `shift 2` on a trailing value-less flag loops forever):

```bash
local target="" label="run" prefix="" baseline_json="" trials="" epsilon="0.1"
while [ $# -gt 0 ]; do
  case "$1" in
    --label|--prefix|--baseline-json|--baseline_json|--trials|--epsilon)
      [ $# -ge 2 ] || { echo "error: $1 needs a value" >&2; return 2; } ;;
  esac
  case "$1" in
    --trials) trials="$2"; shift 2 ;;
    --epsilon) epsilon="$2"; shift 2 ;;
    --trials=*) trials="${1#*=}"; shift ;;
    --epsilon=*) epsilon="${1#*=}"; shift ;;
    # existing branches unchanged
  esac
done
[ -z "$trials" ] || [[ "$trials" =~ ^[1-9][0-9]*$ ]] || { echo "error: --trials must be a positive integer" >&2; return 2; }
[[ "$epsilon" =~ ^[0-9]*\.?[0-9]+$ ]] || { echo "error: --epsilon must be a non-negative number" >&2; return 2; }

"$WAZA_BIN" run "$EVAL_YAML" --model "$COPILOT_MODEL" ${trials:+--trials "$trials"} \
  --no-update-check --output "$result_json" >|"$run_log" 2>&1
```

Comparator (argument 1 = baseline JSON, argument 2 = current JSON or process substitution):

```bash
# ponytail: top-level key read from eval.yaml without a YAML parser; the post-run comparator backstops misreads
yaml_config() { awk -v k="$1:" '$1 == k { gsub(/["'\'']/, "", $2); print $2; exit }' "$EVAL_YAML"; }

incomparable_fields() {
  jq -r --slurpfile cur "$2" '
    . as $b | $cur[0] as $c |
    ( ("engine_type", "model_id", "runs_per_test") as $k
      | select($c.config[$k] != null and $b.config[$k] != $c.config[$k])
      | "- \($k): baseline \($b.config[$k]) → current \($c.config[$k])" ),
    ( select($c.tasks != null)
      | ([$b.tasks[]?.test_id] | sort) as $bt | ([$c.tasks[]?.test_id] | sort) as $ct
      | select($bt != $ct)
      | "- tasks: baseline \($bt | join(",")) → current \($ct | join(","))" )
  ' "$1"
}
```

Pre-run gate, after `EVAL_YAML` resolves and before the run:

```bash
if [ -n "$baseline_json" ] && command -v jq >/dev/null 2>&1; then
  local t_eff="${trials:-$(yaml_config trials_per_task)}"
  if ! print_incomparable "$baseline_json" <(jq -n --arg e "$(yaml_config executor)" \
        --arg m "$COPILOT_MODEL" --arg t "$t_eff" \
        '{config: {engine_type: (if $e == "" then null else $e end), model_id: $m,
                   runs_per_test: (if $t == "" then null else ($t | tonumber) end)}}'); then
    echo "- Run skipped: result would not be comparable."
    return 1
  fi
fi
```

Per-task drops and verdict in `render_comparison "$baseline_json" "$result_json" "$epsilon"`:

```bash
print_incomparable "$baseline_json" "$result_json" || return 1
drops="$(jq -r --slurpfile base "$baseline_json" --argjson eps "$epsilon" '
  def r: . * 1000 | round / 1000;
  ($base[0].tasks // [] | map({key: .test_id, value: .stats}) | from_entries) as $b
  | .tasks[]? | select(.stats != null and $b[.test_id] != null) | $b[.test_id] as $p
  | select((($p.avg_weighted_score - .stats.avg_weighted_score) | r) > $eps or .stats.pass_rate < $p.pass_rate)
  | "- **\(.test_id)**: weighted \($p.avg_weighted_score | r) → \(.stats.avg_weighted_score | r), pass_rate \($p.pass_rate | r) → \(.stats.pass_rate | r)"
' "$result_json")"
if [ "$(jq -r '.config.engine_type' "$result_json")" = "mock" ]; then
  echo "ℹ️ reference-only (mock engine: SKILL.md not exercised) — no regression verdict."
elif awk -v a="$prev_score" -v b="$new_score" -v e="$epsilon" 'BEGIN { d = sprintf("%.3f", b - a) + 0; exit !(d < -e) }'; then
  echo "⚠️ **regression** — weighted score dropped by more than $epsilon. Roll back or compare both JSON files to find the cause."
fi
```

Status probe tail:

```bash
tags_url="${COPILOT_PROVIDER_BASE_URL%/v1}/api/tags"
if ! tags="$(curl -fsS --max-time 3 "$tags_url" 2>/dev/null)"; then reason="Ollama unreachable at $tags_url"
elif ! jq -e --arg m "$COPILOT_MODEL" '.models[]? | select(.name == $m or .model == $m)' <<<"$tags" >/dev/null; then reason="model $COPILOT_MODEL not served by Ollama"; fi
[ -z "$reason" ] && echo "- Usable: yes" || echo "- Usable: no ($reason)"
```

## Dependencies & Ordering

| Item | Consumes | Produces | Predecessors | Parallel-safe |
|---|---|---|---|---|
| T1 launcher | findings, fixed strings | flags, rows, exit semantics, `Usable` | none | with T2 (strings fixed), T5 |
| T2 self-test | fixed strings, fixture template | runnable check for T1 | none to write; T1 to pass | with T1 |
| T3 waza docs | T1 flags/exits | caller contract | T1 | with T4, T5 |
| T4 skill-improver SKILL.md | T1 strings, exit-1 class | guard procedure, report, Criterion 11 | T1 contract (from this plan) | with T3, T5 |
| T5 B.10 WARN | Engine/Skill invocations rows | WARN rule referenced by T4 | none | yes |
| T6 verification | T1–T5 | fresh evidence | all | no |

## Risk Assessment

- Confidence is lower: no spec/contract/research doc; the noise pair covers one suite. Epsilon 0.1 is a user decision; real drops under 0.1 go unflagged.
- generate-skills sees three behavior changes through defaults: Δ in (−0.1, 0) no longer flags; renamed/added `test_id`s between its baseline and candidate now exit 1 `⚠️ incomparable` (report and JSON still printed); every existing result JSON has `runs_per_test: 1`, so reusing old baselines with `--trials 3` exits 1 before running.
- Cost: one copilot-sdk suite with `--trials 3` measured 13–20 min. Baseline+after ≈ 26–40 min per target per iteration, confirmation adds 13–20 min; three iterations can approach 2 h per target. Hence baseline only before model-visible edits and whole-iteration revert instead of per-fix bisection.
- `yaml_config` is a naive first-match read; a misread wastes one run but the post-run comparator prevents a wrong verdict.
- `Usable: yes` requires Ollama even for mock-only suites; with Ollama down, mock suites become SKIP, acceptable because mock never gates reverts.
- All 16 current suites use only `text`/`behavior` graders, so the first sweep will WARN for every suite — intended, report-only.
- Criterion 9 scan: the self-test must not contain literal `waza run|new|compare|gate`, including comments.
- `shellcheck` is not installed; verification is `bash -n` plus the self-test.
- Upstream field renames fail closed: rows show `unknown`, comparator reports incomparable → UNVERIFIED.

## Open Questions

1. Guard cadence: per iteration with model-visible fixes (default) vs once after the last iteration (≈⅔ cheaper, coarser revert).
2. Confirmation rerun not reproducing: `preserved` with an "unconfirmed drop" note (default) vs `UNVERIFIED`.
3. Keep one unconditional `Usable` rule even when all targeted suites are mock (default: yes).

## Todo

Run all commands from `/Users/ujuc/.config/dotrc`.

- [x] T1 — Launcher. `agents/claude/skills/waza/scripts/waza-run.sh`: header usage adds `[--trials N] [--epsilon X]` and exit-code lines (0 includes a reported regression; 1 includes incomparable); flag-value guard; `--trials`/`--epsilon` parse+validate; `yaml_config`, `incomparable_fields`, `print_incomparable`; Engine/Model/Trials/Skill-invocations rows and mock note in `render_report`; `render_comparison` comparability gate, per-task drops, mock reference-only line, epsilon rule replacing `d < 0`, `return 1` on incomparable; pre-run gate; conditional `--trials`; `render_comparison … || return 1`; `cmd_status` Ollama probe and final `- Usable:` line. Test: `agents/claude/skills/waza/scripts/test-waza-run`. Verify: `bash -n agents/claude/skills/waza/scripts/waza-run.sh && bash agents/claude/skills/waza/scripts/waza-run.sh --help >/dev/null`
- [x] T2 — Self-test. Create `agents/claude/skills/waza/scripts/test-waza-run` (style of `test-collect-sessions`, `chmod +x`). Env: fake `waza` in `$root/bin` prepended to PATH (dispatch on `$1`; `run` records argv to `$FAKE_ARGV`, copies `$FAKE_FIXTURE` to `--output`, exits 1 when unset), `WAZA_WORKSPACE`, `WAZA_RESULTS_DIR`, `WAZA_EVALS_DIR` under mktemp, `COPILOT_MODEL=gemma4:26b-mlx`, `COPILOT_PROVIDER_BASE_URL=http://127.0.0.1:1/v1`; suites `live` (`executor: copilot-sdk`, `trials_per_task: 1`) and `mock` (`executor: mock`); distinct `--label` per case. Checks: (a) plain live run → exit 0, argv lacks `--trials`, four new rows with `Skill invocations | 3 / 9`; (b) noise pair Δ≈−0.056 with `--trials 3` → exit 0, argv has `--trials 3`, no `**regression**`, per-task drops list only `c`; (c) Δ −0.2 → `⚠️ **regression**`; (d) same with `--epsilon 0.3` → none; (e) mock pair Δ −0.2 → reference-only, no regression; (f) mock suite vs live baseline → exit 1, `incomparable`, `engine_type`, no argv file; (g) `--trials 1` vs 3-trial baseline → exit 1, `runs_per_test`, no argv file; (h) task-set change → exit 1, `tasks`, `- Result JSON:` present, no regression; (i) missing fixture → exit 1, `run failed`; (j) `--trials 0`, `--epsilon abc`, trailing `--label` → exit 2 without hanging; (k) status unreachable → last line `- Usable: no (Ollama unreachable`; (l) fake `curl` serving the model → `- Usable: yes`, other model → `- Usable: no (model other:tag not served by Ollama)`; (m) launcher `--help` exits 0. Test: the file itself. Verify: `bash -n agents/claude/skills/waza/scripts/test-waza-run && agents/claude/skills/waza/scripts/test-waza-run --help && agents/claude/skills/waza/scripts/test-waza-run`
- [x] T3 — waza docs. `agents/claude/skills/waza/SKILL.md`: argument-hint, status comment (`- Usable:` line), flags `--trials` (forwarded only when given) and `--epsilon` (default 0.1), Contract exit codes, epsilon/mock/incomparable/per-task-drops rules replacing the negative-delta bullet, Procedure line to run `scripts/test-waza-run` after launcher edits. `agents/claude/agents/waza-runner.md`: dispatch flags, exit bullet (1 covers incomparable; regression report exits 0), relay `⚠️ incomparable` at top. Test: `agents/claude/skills/waza/scripts/test-waza-run`. Verify: `agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/waza && grep -n -- '--epsilon' agents/claude/skills/waza/SKILL.md agents/claude/agents/waza-runner.md && grep -n 'incomparable' agents/claude/skills/waza/SKILL.md agents/claude/agents/waza-runner.md`
- [x] T4 — skill-improver. `agents/claude/skills/skill-improver/SKILL.md`: Phase 0 step 7 usable iff `- Usable: yes`, else SKIP with reason; Phase 4 baseline `--trials 3` only before a model-visible edit (frontmatter, description, body, reference path), catalog-only fixes SKIP, cost stated; Phase 5 rerun `--trials 3 --baseline-json`, `⚠️ **regression**` → one `--label improver-confirm` rerun, reproduced → revert all model-visible fixes of that iteration for the target and reclassify manual (no bisection, cost rationale), not reproduced → `preserved` with "unconfirmed drop", exit 1/no Result JSON/`⚠️ incomparable` → UNVERIFIED without revert, mock → reference-only; Phase 6 per-skill line `engine, trials, weighted before → after (Δ), skill invocations, verdict <preserved|regression-reverted|reference-only|UNVERIFIED|SKIP>` plus `Suite signal:` WARN lines; Gotcha 5 includes confirmation JSON; Criterion 11 rewritten; Criterion 9 unchanged. Test: `agents/claude/skills/waza/scripts/test-waza-run`. Verify: `agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/skill-improver && grep -c -- '--trials 3' agents/claude/skills/skill-improver/SKILL.md && grep -n 'Usable: yes\|improver-confirm\|reference-only\|low-signal suite' agents/claude/skills/skill-improver/SKILL.md`
- [x] T5 — B.10 WARN. `agents/claude/skills/skill-improver/references/quality-checks.md`: report-only "WARN — low-signal suite" when the executor/Engine row is `mock`, a copilot-sdk result shows `Skill invocations | 0 / M`, or every grader is text `contains`/`not_contains` or behavior token budget; never edit `claude/evals/`; route to `generate-skills` via the `waza` skill; WARN is never PASS evidence and never blocks Phase 5. Test: none (doc-only). Verify: `grep -n 'low-signal suite' agents/claude/skills/skill-improver/references/quality-checks.md && agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/skill-improver`
- [x] T6 — Full verification. Paths: all six in File Changes. Test: `agents/claude/skills/waza/scripts/test-waza-run`. Verify: `bash -n agents/claude/skills/waza/scripts/waza-run.sh && agents/claude/skills/waza/scripts/test-waza-run && agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/waza && agents/claude/skills/generate-skills/scripts/validate-skill agents/claude/skills/skill-improver`; Criterion 9 scan prints only launcher lines: `grep -rnE '\bwaza (run|new|compare|gate)\b' agents/claude/skills agents/claude/agents | grep -v waza-install.md`; exclusions print nothing: `git status --porcelain -- agents/claude/evals evals agents/claude/skills/prompting-assist agents/claude/skills/generate-skills`; live smoke: `bash agents/claude/skills/waza/scripts/waza-run.sh status | tail -1`.
