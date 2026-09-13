#!/usr/bin/env bash
# waza-run.sh — the single entry point for Microsoft's `waza` skill-eval CLI.
#
# Usage:
#   waza-run.sh status
#   waza-run.sh scaffold <skill-name>
#   waza-run.sh eval <skill-name|/absolute/eval.yaml> [--label X] [--baseline-json /absolute/result.json] [--prefix Y] [--trials N] [--epsilon X]
#
# --trials is forwarded only when given. --epsilon (default 0.1) is the weighted-score
# drop that counts as a regression. Mock-engine results are reference-only.
#
# Exit codes:
#   0  success (including a reported ⚠️ regression), or an advisory skip
#   1  no result JSON, scaffold/baseline failed, or ⚠️ incomparable baseline
#      (engine, model, trials, or task set differ)
#   2  usage error
#
# Every harness (Claude Code, Amp, Codex, Pi) runs waza through this script.
# Callers never invoke the binary directly.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_GUIDE="${SKILL_DIR}/references/waza-install.md"

WORKSPACE="${WAZA_WORKSPACE:-$HOME/.claude/data/waza-workspace}"
RESULTS_DIR="${WAZA_RESULTS_DIR:-$HOME/.claude/data/waza/results}"
EVALS_DIR="${WAZA_EVALS_DIR:-$HOME/.claude/evals}"

export WAZA_NO_UPDATE_CHECK=1
export COPILOT_PROVIDER_BASE_URL="${COPILOT_PROVIDER_BASE_URL:-http://localhost:11434/v1}"
export COPILOT_PROVIDER_TYPE="${COPILOT_PROVIDER_TYPE:-openai}"
export COPILOT_MODEL="${COPILOT_MODEL:-gemma4:26b-mlx}"
export COPILOT_OFFLINE="${COPILOT_OFFLINE:-true}"

usage() {
  sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# --- discovery ---------------------------------------------------------------

find_waza() {
  local cand
  for cand in "$(command -v waza 2>/dev/null)" "$HOME/bin/waza" "/usr/local/bin/waza" \
              "/opt/homebrew/bin/waza" "$(go env GOPATH 2>/dev/null)/bin/waza"; do
    if [ -n "$cand" ] && [ -x "$cand" ]; then
      printf '%s\n' "$cand"
      return 0
    fi
  done
  return 1
}

skip_missing_binary() {
  echo "## ⚠️ waza not installed"
  echo "- Install: \`curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash\` (or \`scripts/install.sh --agents\`)"
  echo "- Guide: \`$INSTALL_GUIDE\`"
  echo
  echo "**Evaluation skipped.**"
}

skip_missing_workspace() {
  echo "## ⚠️ waza workspace not configured"
  echo "- Expected: \`$WORKSPACE/.waza.yaml\`"
  echo "- Setup guide: \`$INSTALL_GUIDE\`"
  echo
  echo "**Evaluation skipped.**"
}

# Sets WAZA_BIN and cds into the workspace. Returns 1 on an advisory skip.
preflight() {
  if ! WAZA_BIN="$(find_waza)"; then
    skip_missing_binary
    return 1
  fi
  if [ ! -f "$WORKSPACE/.waza.yaml" ]; then
    skip_missing_workspace
    return 1
  fi
  mkdir -p "$RESULTS_DIR"
  cd "$WORKSPACE" || return 1
  return 0
}

# --- status ------------------------------------------------------------------

cmd_status() {
  echo "## waza status"
  echo
  if WAZA_BIN="$(find_waza)"; then
    echo "- Binary: \`$WAZA_BIN\` ($("$WAZA_BIN" --version 2>/dev/null | head -1))"
    local on_path
    on_path="$(command -v waza 2>/dev/null || true)"
    if [ "$on_path" != "$WAZA_BIN" ]; then
      echo "  - ⚠️ Not on PATH; using a fallback location."
    fi
  else
    echo "- Binary: ❌ missing (install guide: \`$INSTALL_GUIDE\`)"
  fi
  if [ -f "$WORKSPACE/.waza.yaml" ]; then
    echo "- Workspace: \`$WORKSPACE\` ✅"
  else
    echo "- Workspace: \`$WORKSPACE\` ❌ (.waza.yaml missing)"
  fi
  echo "- Evals: \`$EVALS_DIR\`"
  echo "- Results: \`$RESULTS_DIR\`"
  echo "- Eval model: \`$COPILOT_MODEL\` via \`$COPILOT_PROVIDER_BASE_URL\` (offline=$COPILOT_OFFLINE)"
  local reason=""
  if command -v jq >/dev/null 2>&1; then
    echo "- jq: ✅"
  else
    echo "- jq: ❌ missing — reports will contain only the result JSON path."
    reason="jq missing"
  fi

  local tags_url="${COPILOT_PROVIDER_BASE_URL%/v1}/api/tags" tags
  [ -f "$WORKSPACE/.waza.yaml" ] || reason="workspace missing"
  [ -n "${WAZA_BIN:-}" ] || reason="waza binary missing"
  if [ -z "$reason" ]; then
    if ! tags="$(curl -fsS --max-time 3 "$tags_url" 2>/dev/null)"; then
      reason="Ollama unreachable at $tags_url"
    elif ! jq -e --arg m "$COPILOT_MODEL" '.models[]? | select(.name == $m or .model == $m)' <<<"$tags" >/dev/null; then
      reason="model $COPILOT_MODEL not served by Ollama"
    fi
    echo "- Ollama: ${reason:-✅ $COPILOT_MODEL served}"
  fi
  if [ -z "$reason" ]; then
    echo "- Usable: yes"
  else
    echo "- Usable: no ($reason)"
  fi
}

# --- scaffold ----------------------------------------------------------------

SCAFFOLDED=0

# auto_scaffold <skill-name>: ensures $EVALS_DIR/<name>/eval.yaml exists.
# Sets EVAL_YAML; sets SCAFFOLDED=1 when a placeholder suite was created.
auto_scaffold() {
  local skill_name="$1" scaffold_log scaffold_rc
  EVAL_YAML="$EVALS_DIR/${skill_name}/eval.yaml"

  if [ -f "$EVAL_YAML" ]; then
    return 0
  fi

  if scaffold_log="$("$WAZA_BIN" new eval "$skill_name" --no-update-check 2>&1)"; then
    scaffold_rc=0
  else
    scaffold_rc=$?
  fi

  if [ "$scaffold_rc" -ne 0 ] || [ ! -f "$EVAL_YAML" ]; then
    echo "## ❌ eval.yaml scaffold failed — $skill_name"
    echo
    printf '%s\n' '```'
    printf '%s\n' "$scaffold_log" | tail -30
    printf '%s\n' '```'
    return 1
  fi

  SCAFFOLDED=1
  return 0
}

cmd_scaffold() {
  local skill_name="${1:-}"
  if [ -z "$skill_name" ] || [ $# -gt 1 ]; then
    echo "usage: waza-run.sh scaffold <skill-name>" >&2
    return 2
  fi

  preflight || return 0

  local eval_yaml="$EVALS_DIR/${skill_name}/eval.yaml"
  if [ -f "$eval_yaml" ]; then
    echo "## ℹ️ eval.yaml already exists — $skill_name"
    echo "- Path: \`$eval_yaml\`"
    echo "- Action: left unchanged."
    return 0
  fi

  auto_scaffold "$skill_name" || return 1

  echo "## ✅ eval.yaml scaffolded — $skill_name"
  echo "- Path: \`$eval_yaml\`"
  echo "- Scaffold: positive×2 + negative×1 placeholder tasks"
}

# --- eval --------------------------------------------------------------------

fmt_pct() { awk -v v="$1" 'BEGIN { printf "%.1f%%", v * 100 }'; }
fmt_num() { awk -v v="$1" 'BEGIN { printf "%.3f", v }'; }

render_report() {
  local skill_name="$1" label="$2" result_json="$3" waza_rc="$4" on_path

  if [ "$SCAFFOLDED" -eq 1 ]; then
    echo "> ⚠️ No eval.yaml existed; a placeholder suite was auto-generated."
    echo "> Read these scores for regressions, not as absolute quality."
    echo
  fi

  echo "## waza eval result — $skill_name [$label]"
  echo

  if ! command -v jq >/dev/null 2>&1; then
    echo "> ⚠️ jq is missing; the result was not rendered. Inspect the JSON directly."
    echo
    echo "- Result JSON: \`$result_json\`"
    return 0
  fi

  if ! jq -e '.summary' "$result_json" >/dev/null 2>&1; then
    echo "> ⚠️ Result JSON has no \`.summary\`."
    echo
    echo "- Result JSON: \`$result_json\`"
    return 0
  fi

  local total ok failed errors skipped rate agg weighted dur
  total="$(jq -r '.summary.total_tests' "$result_json")"
  ok="$(jq -r '.summary.succeeded' "$result_json")"
  failed="$(jq -r '.summary.failed' "$result_json")"
  errors="$(jq -r '.summary.errors' "$result_json")"
  skipped="$(jq -r '.summary.skipped' "$result_json")"
  rate="$(jq -r '.summary.success_rate' "$result_json")"
  agg="$(jq -r '.summary.aggregate_score' "$result_json")"
  weighted="$(jq -r '.summary.weighted_score' "$result_json")"
  dur="$(jq -r '.summary.duration_ms' "$result_json")"

  echo "| Item | Value |"
  echo "|---|---|"
  echo "| Passed / run | $ok / $total |"
  echo "| Failed / errors / skipped | $failed / $errors / $skipped |"
  echo "| Weighted score | $(fmt_num "$weighted") |"
  echo "| Aggregate score | $(fmt_num "$agg") |"
  echo "| Success rate | $(fmt_pct "$rate") |"
  echo "| Duration | ${dur}ms |"
  local engine
  engine="$(jq -r '.config.engine_type // "unknown"' "$result_json")"
  echo "| Engine | $engine |"
  echo "| Model | $(jq -r '.config.model_id // "unknown"' "$result_json") |"
  echo "| Trials | $(jq -r '.config.runs_per_test // "unknown"' "$result_json") |"
  jq -r '[.tasks[]?.runs[]?] | "| Skill invocations | \(map(select((.skill_invocations // []) | length > 0)) | length) / \(length) |"' "$result_json"
  if [ "$engine" = "mock" ]; then
    echo
    echo "> ℹ️ reference-only (mock engine: SKILL.md not exercised)"
  fi

  if [ "$(jq -r '.metrics // {} | length' "$result_json")" != "0" ]; then
    echo
    echo "### metrics"
    echo
    echo "| Metric | Value |"
    echo "|---|---|"
    jq -r '.metrics | to_entries[] | "| \(.key) | \(.value | tostring) |"' "$result_json"
  fi

  local failing
  failing="$(jq -r '[.tasks[]? | select(.status != "passed" and .status != "succeeded")] | length' "$result_json")"
  if [ "$failing" != "0" ]; then
    echo
    echo "### Failed / errored tasks"
    echo
    jq -r '
      .tasks[]? | select(.status != "passed" and .status != "succeeded") |
      "- **\(.test_id)** (\(.status)) — \(.display_name)",
      ( .runs[]?.validations // {} | to_entries[] | select(.value.passed != true) |
        "  - `\(.key)` [\(.value.type)] score=\(.value.score): \(.value.feedback)" )
    ' "$result_json"
  fi

  echo
  if [ "$waza_rc" -ne 0 ]; then
    echo "- ⚠️ waza exit code: $waza_rc (result JSON was still written)"
  fi
  on_path="$(command -v waza 2>/dev/null || true)"
  if [ "$on_path" != "$WAZA_BIN" ]; then
    echo "- Binary used: \`$WAZA_BIN\`"
  fi
  echo "- Result JSON: \`$result_json\`"
}

# ponytail: first-match `key: value` read from eval.yaml, no YAML parser; the post-run comparator backstops misreads
yaml_config() { awk -v k="$1:" '$1 == k { gsub(/["'\'']/, "", $2); print $2; exit }' "$EVAL_YAML"; }

# incomparable_fields BASELINE CURRENT: one line per differing engine/model/trials/task set.
# A CURRENT without .tasks is a pre-run expectation whose unknown (null) fields are skipped;
# a real result compares every field, so a missing field fails closed.
incomparable_fields() {
  jq -r --slurpfile cur "$2" '
    . as $b | $cur[0] as $c |
    ( ("engine_type", "model_id", "runs_per_test") as $k
      | select(($c.tasks == null and $c.config[$k] == null) | not)
      | select($b.config[$k] != $c.config[$k])
      | "- \($k): baseline \($b.config[$k]) → current \($c.config[$k])" ),
    ( select($c.tasks != null)
      | ([$b.tasks[]?.test_id] | sort) as $bt | ([$c.tasks[]?.test_id] | sort) as $ct
      | select($bt != $ct)
      | "- tasks: baseline \($bt | join(",")) → current \($ct | join(","))" )
  ' "$1"
}

# print_incomparable BASELINE CURRENT: prints the block and returns 1 when anything differs.
print_incomparable() {
  local diffs fields
  diffs="$(incomparable_fields "$1" "$2")"
  [ -z "$diffs" ] && return 0
  fields="$(printf '%s\n' "$diffs" | sed 's/^- \([a-z_]*\):.*/\1/' | paste -sd, - | sed 's/,/, /g')"
  echo
  echo "### ⚠️ incomparable ($fields)"
  echo
  printf '%s\n' "$diffs"
  echo
  echo "**No regression verdict.** Rerun with the baseline's engine, model, trials, and task set."
  echo "- Baseline JSON: \`$1\`"
  return 1
}

render_comparison() {
  local baseline_json="$1" result_json="$2" epsilon="$3"
  command -v jq >/dev/null 2>&1 || return 0
  print_incomparable "$baseline_json" "$result_json" || return 1

  local prev_score new_score delta prev_rate new_rate prev_failed new_failed
  prev_score="$(jq -r '.summary.weighted_score' "$baseline_json")"
  new_score="$(jq -r '.summary.weighted_score' "$result_json")"
  prev_rate="$(jq -r '.summary.success_rate' "$baseline_json")"
  new_rate="$(jq -r '.summary.success_rate' "$result_json")"
  prev_failed="$(jq -r '.summary.failed + .summary.errors' "$baseline_json")"
  new_failed="$(jq -r '.summary.failed + .summary.errors' "$result_json")"
  delta="$(awk -v a="$prev_score" -v b="$new_score" 'BEGIN { printf "%+.3f", b - a }')"

  echo
  echo "### Baseline comparison"
  echo
  echo "| Item | before | after | Δ |"
  echo "|---|---|---|---|"
  echo "| Weighted score | $(fmt_num "$prev_score") | $(fmt_num "$new_score") | $delta |"
  echo "| Success rate | $(fmt_pct "$prev_rate") | $(fmt_pct "$new_rate") | |"
  echo "| Failed + errored tasks | $prev_failed | $new_failed | |"

  local drops
  drops="$(jq -r --slurpfile base "$baseline_json" --argjson eps "$epsilon" '
    def r: . * 1000 | round / 1000;
    ($base[0].tasks // [] | map({key: .test_id, value: .stats}) | from_entries) as $b
    | .tasks[]? | select(.stats != null and $b[.test_id] != null) | $b[.test_id] as $p
    | select((($p.avg_weighted_score - .stats.avg_weighted_score) | r) > $eps or .stats.pass_rate < $p.pass_rate)
    | "- **\(.test_id)**: weighted \($p.avg_weighted_score | r) → \(.stats.avg_weighted_score | r), pass_rate \($p.pass_rate | r) → \(.stats.pass_rate | r)"
  ' "$result_json")"
  if [ -n "$drops" ]; then
    echo
    echo "### Per-task drops"
    echo
    printf '%s\n' "$drops"
  fi

  echo
  if [ "$(jq -r '.config.engine_type' "$result_json")" = "mock" ]; then
    echo "ℹ️ reference-only (mock engine: SKILL.md not exercised) — no regression verdict."
  elif awk -v d="$delta" -v e="$epsilon" 'BEGIN { exit !(d + 0 < -e) }'; then
    echo "⚠️ **regression** — weighted score dropped by more than $epsilon. Roll back or compare both JSON files to find the cause."
  fi
  echo "- Baseline JSON: \`$baseline_json\`"
}

cmd_eval() {
  local target="" label="run" prefix="" baseline_json="" trials="" epsilon="0.1"

  while [ $# -gt 0 ]; do
    case "$1" in
      --label|--prefix|--baseline-json|--baseline_json|--trials|--epsilon)
        if [ $# -lt 2 ]; then
          echo "error: $1 needs a value" >&2
          return 2
        fi ;;
    esac
    case "$1" in
      --label) label="$2"; shift 2 ;;
      --prefix) prefix="$2"; shift 2 ;;
      --baseline-json|--baseline_json) baseline_json="$2"; shift 2 ;;
      --trials) trials="$2"; shift 2 ;;
      --epsilon) epsilon="$2"; shift 2 ;;
      --label=*) label="${1#*=}"; shift ;;
      --prefix=*) prefix="${1#*=}"; shift ;;
      --baseline-json=*|--baseline_json=*) baseline_json="${1#*=}"; shift ;;
      --trials=*) trials="${1#*=}"; shift ;;
      --epsilon=*) epsilon="${1#*=}"; shift ;;
      -*)
        echo "error: unknown flag '$1'" >&2
        usage >&2
        return 2 ;;
      *)
        if [ -n "$target" ]; then
          echo "error: unexpected argument '$1'" >&2
          return 2
        fi
        target="$1"; shift ;;
    esac
  done

  if [ -z "$target" ]; then
    echo "usage: waza-run.sh eval <skill-name|/absolute/eval.yaml> [--label X] [--baseline-json /absolute/result.json] [--prefix Y] [--trials N] [--epsilon X]" >&2
    return 2
  fi
  if [ -n "$trials" ] && ! [[ "$trials" =~ ^[1-9][0-9]*$ ]]; then
    echo "error: --trials must be a positive integer" >&2
    return 2
  fi
  if ! [[ "$epsilon" =~ ^[0-9]*\.?[0-9]+$ ]]; then
    echo "error: --epsilon must be a non-negative number" >&2
    return 2
  fi

  if [ -n "$baseline_json" ]; then
    if [ ! -f "$baseline_json" ]; then
      echo "## ❌ Baseline JSON not found — $baseline_json"
      return 1
    fi
    if command -v jq >/dev/null 2>&1 && ! jq -e '.summary' "$baseline_json" >/dev/null 2>&1; then
      echo "## ❌ Baseline JSON has no .summary — $baseline_json"
      return 1
    fi
  fi

  preflight || return 0

  local skill_name
  case "$target" in
    /*)
      EVAL_YAML="$target"
      skill_name="$(basename "$(dirname "$EVAL_YAML")")"
      if [ ! -f "$EVAL_YAML" ]; then
        echo "## ❌ eval.yaml not found — $EVAL_YAML"
        return 1
      fi
      ;;
    *)
      skill_name="$target"
      auto_scaffold "$skill_name" || return 1
      ;;
  esac

  # Fail before an expensive run when the baseline is already known to be incomparable.
  if [ -n "$baseline_json" ] && command -v jq >/dev/null 2>&1; then
    local t_eff expected
    t_eff="${trials:-$(yaml_config trials_per_task)}"
    expected="$(jq -n --arg e "$(yaml_config executor)" --arg m "$COPILOT_MODEL" --arg t "$t_eff" \
      '{config: {engine_type: (if $e == "" then null else $e end), model_id: $m,
                 runs_per_test: (if $t == "" then null else ($t | tonumber) end)}}')"
    if ! print_incomparable "$baseline_json" <(printf '%s' "$expected"); then
      echo "- Run skipped: the result would not be comparable."
      return 1
    fi
  fi

  prefix="${prefix:-$skill_name}"
  local ts result_json run_log waza_rc
  ts="$(date +%Y%m%d-%H%M%S)"
  result_json="$RESULTS_DIR/${prefix}-${label}-${ts}.json"
  run_log="$(mktemp)"

  # ${trials:+...} is unquoted on purpose: it expands to nothing or to two words.
  if "$WAZA_BIN" run "$EVAL_YAML" --model "$COPILOT_MODEL" ${trials:+--trials "$trials"} \
       --no-update-check --output "$result_json" >|"$run_log" 2>&1; then
    waza_rc=0
  else
    waza_rc=$?
  fi

  if [ ! -s "$result_json" ]; then
    echo "## ❌ waza run failed — exit $waza_rc"
    echo
    printf '%s\n' '```'
    tail -30 "$run_log"
    printf '%s\n' '```'
    rm -f "$run_log"
    return 1
  fi
  rm -f "$run_log"

  render_report "$skill_name" "$label" "$result_json" "$waza_rc"
  if [ -n "$baseline_json" ]; then
    render_comparison "$baseline_json" "$result_json" "$epsilon" || return 1
  fi
  return 0
}

# --- main --------------------------------------------------------------------

main() {
  local cmd="${1:-}"
  [ $# -gt 0 ] && shift
  case "$cmd" in
    status) cmd_status "$@" ;;
    scaffold) cmd_scaffold "$@" ;;
    eval) cmd_eval "$@" ;;
    -h|--help|help) usage ;;
    "")
      usage >&2
      return 2 ;;
    *)
      echo "error: unknown command '$cmd'" >&2
      usage >&2
      return 2 ;;
  esac
}

main "$@"
