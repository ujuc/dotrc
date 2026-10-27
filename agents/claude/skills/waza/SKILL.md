---
name: waza
description: "Microsoft waza CLI로 스킬 평가 스위트를 스캐폴드·실행하고 baseline과 비교한다. /waza, waza, 스킬 평가해줘, 스킬 테스트해줘, test skills, eval 실행, eval 만들어줘, eval 스캐폴드, 스킬 점수 비교, baseline 비교, 회귀 확인, waza 상태 확인 요청 시 사용한다. 정의 개선은 skill-improver가 맡는다."
group: meta
allowed-tools: Bash(bash:*), Read
argument-hint: "status | scaffold SKILL | eval SKILL-or-eval.yaml [--label X] [--baseline-json FILE] [--trials N] [--epsilon X]"
---

# waza (skill evaluation)

Run Microsoft's [`waza`](https://github.com/microsoft/waza) on the suites under
`~/.claude/evals/<skill>/` through `scripts/waza-run.sh`, the one launcher every
harness uses. **Never invoke the `waza` binary directly**: the launcher owns
preflight, model defaults, result paths, and the report.

## Model guidance

Lightweight forwards a command and relays the report; Standard picks labels and
baselines and interprets failed tasks; Advanced weighs conflicting evaluation
evidence. These levels are the calling agent's only
([shared selection guide](../generate-skills/references/model-selection.md));
the evaluation target stays the configured local Ollama model and is never
swapped silently.

For an isolated context in Claude Code, dispatch `Agent` with `subagent_type: "general-purpose"`, Lightweight routing from [dispatch routing](../generate-skills/references/model-selection.md#dispatch-routing), and the prompt "Run `bash <abs>/scripts/waza-run.sh <dispatch>` and return stdout verbatim, keeping any `⚠️` line first."

## How to invoke

```bash
WAZA_SKILL="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/claude/skills/waza"
bash "$WAZA_SKILL/scripts/waza-run.sh" status           # last line: - Usable: yes|no (<reason>)
bash "$WAZA_SKILL/scripts/waza-run.sh" scaffold commit  # placeholder suite (positive×2 + negative×1)
bash "$WAZA_SKILL/scripts/waza-run.sh" eval commit --label baseline
bash "$WAZA_SKILL/scripts/waza-run.sh" eval /abs/path/evals/commit/eval.yaml --label after --trials 3 \
  --baseline-json "$HOME/.claude/data/waza/results/commit-baseline-20260913-101500.json"
```

`eval` flags: `--label <x>=run`, `--prefix <y>=<skill>`, `--baseline-json <file>`,
`--trials N` (forwarded only when given; otherwise the suite's `trials_per_task`),
`--epsilon <x>=0.1` (weighted-score drop that counts as a regression).
`waza-run.sh --help` prints usage and exit codes.

## Contract

- A bare name resolves to `~/.claude/evals/<name>/eval.yaml` and scaffolds it there (the dotrc repo) when missing; an absolute path must exist.
- A successful `eval` writes `~/.claude/data/waza/results/<prefix>-<label>-<timestamp>.json` and prints a Markdown report ending with that path. Relay the report as-is; never paraphrase grader feedback or invent metric rows.
- Exit 0: success, a reported `⚠️ **regression**`, or an advisory skip (no binary, no workspace, suite already exists). Exit 1: no result JSON, failed scaffold/baseline validation, or `⚠️ incomparable`. Exit 2: usage error. Read the report body, not just the exit code, before claiming a score.
- Waza exit 1 can still produce valid task-failure JSON; the report uses it and warns with the exit code.
- `Skill invocations` `0 / M` is expected: with the default `inject_skill_body: true` the SKILL.md body is already in the system prompt. It is not a failure.
- With `--baseline-json`:
  - An engine, model, trials, or task-set difference prints `⚠️ incomparable` with no verdict; when eval.yaml, `--trials`, or `COPILOT_MODEL` already shows it, the run is skipped.
  - `⚠️ **regression**` appears only when the rounded weighted-score delta is below `-epsilon`; smaller drops are run-to-run noise.
  - `### Per-task drops` lists tasks whose weighted score fell by more than epsilon or whose pass rate fell. It is informational; waza fails a task when any single trial fails.
- Waza scores the injected SKILL.md text on the local model. Whether a real agent reads the skill or its references is a skill-diet eval question (`generate-skills` Diet mode).
- Mock-engine results are **reference-only**: the mock executor never loads SKILL.md, so they never produce a regression verdict.
- The launcher never modifies an existing suite. Refine placeholder tasks in `~/.claude/evals/<skill>/tasks/*.yaml` before trusting scores.

## Environment

The launcher defaults to local Ollama (`COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1`,
`COPILOT_PROVIDER_TYPE=openai`, `COPILOT_MODEL=gemma4:e4b-mlx`, `COPILOT_OFFLINE=true`); values already set win.
Ollama must serve the target model before a real (non-mock) run. Override
locations with `WAZA_WORKSPACE`, `WAZA_EVALS_DIR`, `WAZA_RESULTS_DIR`. The
workspace `.waza.yaml` uses relative `skills/` and `evals/` symlinks into the
dotrc tree; never write absolute paths there.

## Judge grader

`scripts/typesafe-judge` is a waza `program` grader for answers a regex cannot
grade: it reads the answer on stdin, asks TypeSafe (Jev) one Noul per `--ask`
(optionally against `--source`), and passes when every probability reaches
`--pass` (default 0.7). Wiring: `~/.claude/evals/humanizer/tasks/`.

- The answer leaves the machine: it needs network and `TYPESAFE_API_KEY` (from the environment, then `mise exec`); offline runs fail.
- Exit 1 is below threshold, 2 is judge unavailable; waza fails both alike, so read the feedback before calling a drop a regression.
- Judge only what the injected SKILL.md body dictates; rules in `references/` never reach the eval model.
- Keep exact strings (names, numbers) on `text` graders. Add a second judge for the middle band only if `~/.claude/data/waza/judge-log.jsonl` shows one.
- It runs via `uv run --script`, so `uv` must be on `PATH` or waza fails the task. `--self-check` runs offline.

## Procedure

1. Unsure waza is usable → `status`. On a skip report (missing binary or workspace), relay it and continue the caller's work without a score.
2. Changing a skill → `eval <skill> --label baseline` **before** editing, then `eval <skill> --label after --baseline-json <baseline>`, with the same `--trials`. Keep both JSON paths for `skill-improver`.
3. Changed `scripts/waza-run.sh` → `bash scripts/test-waza-run` (synthetic; no install or Ollama).
4. New subcommand or flag → read the current upstream README, add it to `scripts/waza-run.sh`, and document it here. Keep no CLI snapshot here.
5. Install, update, version floor, workspace setup, `command not found`, uninstall → [references/waza-install.md](references/waza-install.md)
