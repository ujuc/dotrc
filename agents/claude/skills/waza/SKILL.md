---
name: waza
description: "Microsoft waza CLI로 스킬 평가 스위트(evals/SKILL/eval.yaml)를 스캐폴드·실행하고 baseline과 비교한다. /waza, waza, 스킬 평가해줘, 스킬 테스트해줘, test skills, eval 실행, eval 만들어줘, eval 스캐폴드, 스킬 점수 비교, baseline 비교, 회귀 확인, waza 상태 확인 요청 시 사용한다. 정의 개선은 skill-improver가 맡는다."
group: meta
allowed-tools: Bash(bash:*), Read
argument-hint: "status | scaffold SKILL | eval SKILL-or-eval.yaml [--label X] [--baseline-json FILE] [--trials N] [--epsilon X]"
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
model (`gemma4:e4b-mlx` by default) and is never replaced silently. Apply the
[shared selection guide](../generate-skills/references/model-selection.md) to
the orchestration side.

## How to invoke

```bash
WAZA_SKILL="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/claude/skills/waza"

# Is waza usable here? (binary, workspace, jq, Ollama model); the last line is `- Usable: yes|no (<reason>)`.
bash "$WAZA_SKILL/scripts/waza-run.sh" status

# Create a placeholder suite (positive×2 + negative×1). Existing suites are never touched.
bash "$WAZA_SKILL/scripts/waza-run.sh" scaffold commit

# Run a suite by skill name or absolute eval.yaml path; auto-scaffolds a missing bare-name suite.
bash "$WAZA_SKILL/scripts/waza-run.sh" eval commit --label baseline
bash "$WAZA_SKILL/scripts/waza-run.sh" eval /abs/path/evals/commit/eval.yaml --label after

# Run with 3 trials and compare against an earlier result JSON with the same engine, model, trials, and tasks.
bash "$WAZA_SKILL/scripts/waza-run.sh" eval commit --label after --trials 3 \
  --baseline-json "$HOME/.claude/data/waza/results/commit-baseline-20260913-101500.json"
```

Flags: `--label` (default `run`), `--prefix` (default: skill name),
`--baseline-json` (also accepts `--baseline_json`), `--trials N` (forwarded to
waza only when given; otherwise the suite's `trials_per_task` applies),
`--epsilon X` (default `0.1`, the weighted-score drop that counts as a
regression). Unknown flags, flags without a value, and invalid numbers exit 2.

## Contract

- A bare name resolves to `~/.claude/evals/<name>/eval.yaml`; an absolute path must exist.
- A successful `eval` writes `~/.claude/data/waza/results/<prefix>-<label>-<timestamp>.json` and prints a Markdown report ending with that absolute path. Relay the report as-is; never paraphrase grader feedback or invent metric rows.
- Exit 0 covers success, a reported `⚠️ **regression**`, **and** advisory skips (no binary, no workspace, suite already exists). Exit 1 means waza produced no result JSON, scaffold/baseline validation failed, or the baseline is `⚠️ incomparable`. Exit 2 is a usage error. Read the report body, not just the exit code, before claiming a score.
- Waza exit 1 can still produce valid task-failure JSON; the script parses it and adds the exit code as a warning.
- The report shows Engine, Model, Trials, and Skill invocations (runs with a recorded skill invocation / all runs). Invocations are recorded only when the agent calls the `skill` tool; with the default `inject_skill_body: true` the SKILL.md body is already in the system prompt, so `0 / M` is expected and is not a failure.
- With `--baseline-json`:
  - Engine, model, trials, or task-set differences print `⚠️ incomparable`, give no verdict, and exit 1. Differences knowable from eval.yaml, `--trials`, and `COPILOT_MODEL` skip the run entirely.
  - `⚠️ **regression**` appears only when the rounded weighted-score delta is below `-epsilon`; recommend rollback or inspection of both JSON files. Smaller drops are run-to-run noise at the default: an unchanged suite measured 1.000 → 0.944 across two 3-trial runs.
  - `### Per-task drops` lists tasks whose weighted score fell by more than epsilon or whose pass rate fell. It is informational; waza fails a task when any single trial fails.
- Mock-engine results are **reference-only**: the mock executor never loads SKILL.md, so they never produce a regression verdict.
- The script never modifies an existing eval suite. Refine placeholder tasks by editing `~/.claude/evals/<skill>/tasks/*.yaml` yourself before trusting scores.

## Environment

The launcher exports these defaults when unset; existing values win:

```sh
COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1
COPILOT_PROVIDER_TYPE=openai
COPILOT_MODEL=gemma4:e4b-mlx
COPILOT_OFFLINE=true
WAZA_NO_UPDATE_CHECK=1
```

Override locations with `WAZA_WORKSPACE`, `WAZA_EVALS_DIR`, `WAZA_RESULTS_DIR`.
The workspace `.waza.yaml` uses relative `skills/` and `evals/` symlinks into
the dotrc tree; do not write absolute paths there. Ollama must be serving the
target model before a real (non-mock) run.

## Judge grader

`scripts/typesafe-judge` is a waza `program` grader for answers a regex cannot
grade. It reads the answer on stdin, asks TypeSafe (Jev) one Noul per `--ask`
(optionally against `--source`), and passes when every probability reaches
`--pass` (default 0.7). See `~/.claude/evals/humanizer/tasks/` for the wiring.

- Exit 0 pass, 1 below threshold, 2 judge unavailable (no `TYPESAFE_API_KEY`,
  network, API error). waza scores 1 and 2 alike, so read the feedback before
  calling a drop a regression. The answer leaves the machine; offline runs fail.
- Judge only what the injected SKILL.md body dictates. Rules that live in
  `references/` never reach the eval model, so judging them measures the model.
- Keep exact strings (names, numbers) on `text` graders and leave the judge the
  semantic remainder. Every probability is appended to
  `~/.claude/data/waza/judge-log.jsonl`; add a second judge for the middle band
  only if that log shows one.
- It is a `uv run --script` program (PEP 723, standard library only), so `uv`
  must be on `PATH`; without it waza reports the task as failed. The key is read
  from `TYPESAFE_API_KEY`, then from `mise exec` when the shell skips mise hooks.
- `scripts/typesafe-judge --self-check` runs without network.

## Procedure

1. Run `status` when unsure whether waza is usable; on a missing binary or
   workspace, relay the skip report and continue the caller's work without a
   score.
2. For a new or changed skill, run `eval <skill> --label baseline` **before**
   editing, then `eval <skill> --label after --baseline-json <baseline>` after.
   Use the same `--trials` for both. Keep both JSON paths for `skill-improver`.
3. After changing `scripts/waza-run.sh`, run `bash scripts/test-waza-run`
   (synthetic; no install or Ollama needed).
4. Read `references/waza-install.md` for installation, workspace setup, local
   Ollama model defaults, and troubleshooting.
5. Before adding a new subcommand or flag, read the current upstream README,
   add it to `scripts/waza-run.sh`, and document it in this file. Do not keep a
   full CLI snapshot here.
