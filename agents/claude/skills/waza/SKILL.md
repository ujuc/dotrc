---
name: waza
description: "Microsoft waza CLI로 스킬 평가 스위트(evals/SKILL/eval.yaml)를 스캐폴드·실행하고 baseline과 비교한다. waza, 스킬 평가해줘, eval 실행, eval 만들어줘, 스킬 점수 비교, 회귀 확인, waza 상태 확인 요청 시 사용한다. 모든 waza 호출은 이 스킬의 scripts/waza-run.sh를 거치며 미설치 환경에서는 점수 없이 안전하게 건너뛴다."
group: meta
allowed-tools: Bash(bash:*), Read
argument-hint: "status | scaffold SKILL | eval SKILL-or-eval.yaml [--label X] [--baseline-json FILE]"
---

# waza (skill evaluation)

Run Microsoft's [`waza`](https://github.com/microsoft/waza) against the eval
suites under `~/.claude/evals/<skill>/`. This skill is harness-neutral: Claude
Code, Amp, Codex, and Pi all call the same launcher. **Never invoke the `waza`
binary directly** — every subcommand routes through `scripts/waza-run.sh` so
one place owns preflight, model defaults, result paths, and report format.

In Claude Code the `waza-runner` subagent wraps this same launcher; callers
that need an isolated context (for example `generate-skills`) may dispatch it
instead of running the script in the main context.

## Model guidance

Lightweight suits forwarding a command and relaying the rendered report;
Standard suits choosing labels, baselines, and interpreting failed tasks;
Advanced suits conflicting evaluation evidence. These levels describe the
calling agent only. The evaluation target stays the configured local Ollama
model (`gemma4:26b-mlx` by default) and is never replaced silently. Apply the
[shared selection guide](../generate-skills/references/model-selection.md) to
the orchestration side.

## How to invoke

```bash
WAZA_SKILL="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/claude/skills/waza"

# Is waza usable here? (binary, workspace, model, jq)
bash "$WAZA_SKILL/scripts/waza-run.sh" status

# Create a placeholder suite (positive×2 + negative×1). Existing suites are never touched.
bash "$WAZA_SKILL/scripts/waza-run.sh" scaffold commit

# Run a suite by skill name or absolute eval.yaml path; auto-scaffolds a missing bare-name suite.
bash "$WAZA_SKILL/scripts/waza-run.sh" eval commit --label baseline
bash "$WAZA_SKILL/scripts/waza-run.sh" eval /abs/path/evals/commit/eval.yaml --label after

# Run and compare against an earlier result JSON.
bash "$WAZA_SKILL/scripts/waza-run.sh" eval commit --label after \
  --baseline-json "$HOME/.claude/data/waza/results/commit-baseline-20260913-101500.json"
```

Flags: `--label` (default `run`), `--prefix` (default: skill name),
`--baseline-json` (also accepts `--baseline_json`). Unknown flags exit 2.

## Contract

- A bare name resolves to `~/.claude/evals/<name>/eval.yaml`; an absolute path must exist.
- A successful `eval` writes `~/.claude/data/waza/results/<prefix>-<label>-<timestamp>.json` and prints a Markdown report ending with that absolute path. Relay the report as-is; never paraphrase grader feedback or invent metric rows.
- Exit 0 covers success **and** advisory skips (no binary, no workspace, suite already exists). Exit 1 means waza ran but produced no result JSON, or scaffold/baseline validation failed. Exit 2 is a usage error. Read the report body, not just the exit code, before claiming a score.
- Waza exit 1 can still produce valid task-failure JSON; the script parses it and adds the exit code as a warning.
- With `--baseline-json`, a negative weighted-score delta is flagged `⚠️ regression`; recommend rollback or inspection of both JSON files.
- The script never modifies an existing eval suite. Refine placeholder tasks by editing `~/.claude/evals/<skill>/tasks/*.yaml` yourself before trusting scores.

## Environment

The launcher exports these defaults when unset; existing values win:

```sh
COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1
COPILOT_PROVIDER_TYPE=openai
COPILOT_MODEL=gemma4:26b-mlx
COPILOT_OFFLINE=true
WAZA_NO_UPDATE_CHECK=1
```

Override locations with `WAZA_WORKSPACE`, `WAZA_EVALS_DIR`, `WAZA_RESULTS_DIR`.
The workspace `.waza.yaml` uses relative `skills/` and `evals/` symlinks into
the dotrc tree; do not write absolute paths there. Ollama must be serving the
target model before a real (non-mock) run.

## Procedure

1. Run `status` when unsure whether waza is usable; on a missing binary or
   workspace, relay the skip report and continue the caller's work without a
   score.
2. For a new or changed skill, run `eval <skill> --label baseline` **before**
   editing, then `eval <skill> --label after --baseline-json <baseline>` after.
   Keep both JSON paths for `skill-improver`.
3. Read `references/waza-install.md` for installation, workspace setup, local
   Ollama model defaults, and troubleshooting.
4. Before adding a new subcommand or flag, read the current upstream README,
   add it to `scripts/waza-run.sh`, and document it in this file. Do not keep a
   full CLI snapshot here.
