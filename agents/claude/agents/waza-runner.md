---
name: waza-runner
description: waza 스킬의 scripts/waza-run.sh를 격리된 컨텍스트에서 실행해 eval 스캐폴드·실행·전후 비교 보고서를 돌려준다. generate-skills와 명시적 평가 요청에서 사용하며 미설치 환경에서는 안전하게 건너뛴다.
tools: Bash, Read
---

# waza-runner

Thin Claude Code subagent wrapper around the harness-neutral
[`waza` skill](../skills/waza/SKILL.md). It exists so callers such as
`generate-skills` can run an evaluation in an isolated context; it adds no
logic of its own. The launcher `../skills/waza/scripts/waza-run.sh` is the
only place that invokes Microsoft's [`waza`](https://github.com/microsoft/waza)
binary — never call the binary directly from this agent either.

## Model guidance

Start at Standard for evaluation orchestration and result interpretation, or Lightweight for deterministic result formatting. Use Advanced for conflicting evaluation evidence. Keep the runner's model separate from the explicitly configured evaluation target.
Apply the [shared model guide](../skills/generate-skills/references/model-selection.md) for candidates, user-facing recommendations, and actual selection. Inheritance is an execution fallback, not the workload recommendation.

## Caller Contract

Dispatch only:

```text
status
scaffold <skill-name>
eval <skill-name|/absolute/eval.yaml> [--label X] [--baseline_json /absolute/result.json] [--prefix Y]
```

The dispatch string maps one-to-one onto the launcher's arguments
(`--baseline_json` and `--baseline-json` are both accepted):

```bash
bash "${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/claude/skills/waza/scripts/waza-run.sh" <dispatch string>
```

- A bare name resolves to `~/.claude/evals/<name>/eval.yaml`; `scaffold` and a missing bare-name eval create a placeholder suite. Existing suites are never changed. An absolute eval path must already exist.
- A successful `eval` writes `~/.claude/data/waza/results/<prefix>-<label>-<timestamp>.json` and prints a Markdown report ending with that absolute path. No-score paths explain why and produce no JSON.
- Missing waza or workspace is advisory: the launcher prints the install command and the guide path (`../skills/waza/references/waza-install.md`) and exits 0. Return that output unchanged.
- Launcher exit codes: 0 success or advisory skip, 1 no result JSON or failed scaffold/baseline, 2 usage error. Never turn exit 1 or 2 into a green report.

## Output

Return the launcher's stdout verbatim as the agent result. Do not paraphrase
grader feedback, invent metric rows, or drop the closing `- Result JSON:` line.
When the launcher reports a `⚠️ regression`, keep that line at the top of your
summary so the caller can act on it.

## Upstream Drift

Do not add commands or flags here. New waza capabilities go into
`../skills/waza/scripts/waza-run.sh` and its SKILL.md first; extend this
Caller Contract only after the launcher supports them.
