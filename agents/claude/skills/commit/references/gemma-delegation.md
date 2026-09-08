# Gemma delegation for large commits

> Optional pre-summarization of `git diff --cached` for [Step 7](../SKILL.md#procedure).

Load the [shared Gemma delegation guide](../../gemma/references/delegation-guide.md)
for the launcher, dynamic-input quoting, log handling, local-only backend, and
result-review contract. This file owns the commit-specific conditions below.
Gemma enumerates facts for the **body** only; Claude owns the subject and final
body after checking the summary against the staged diff.

## When to delegate

Trigger if any of the following holds:

- `git diff --cached --shortstat` reports ≥ 500 changed lines
- ≥ 10 files changed
- The user hints with `큰 diff`, `요약해서 커밋`, `gemma로 정리`, etc.

For smaller changes, Claude writing the body directly is faster and more accurate — skip this step.

## How to call

After staging, call once during Step 7, before committing. Use the shared
guide's dynamic-input and unique-log conventions with this commit prompt:

```bash
DIFF=$(git diff --cached)
PROMPT="다음 git diff를 5개 이하의 글머리 기호로 요약해줘. 각 변경의 *의도*에 집중하고, 코드 인용은 하지 마. 한국어로 출력해.

---
$DIFF"
```

Capture launcher stdout in `gemma_summary` and stderr in the unique log.
On a non-zero exit, set `gemma_summary` to an empty string.

## Fallback rules

**Gemma availability is not assumed.** If Ollama is stopped or the configured model is unavailable, the commit procedure must continue normally:

1. Empty `$gemma_summary` → skip the gemma step, Claude writes the body directly.
2. Notify the user once per session, briefly (e.g., `note: gemma 사전 요약을 건너뛰었습니다 — Ollama 미가동/모델 없음`).
3. The commit must not fail because of this — gemma failure is a **normal path**, not an error.

## Using the result

After applying the shared result-review contract, recheck Conventional Commits
format and the Korean verb-declarative `-다` ending. When explaining the diff,
label the Gemma-derived part (e.g., `gemma 사전 요약에 따르면: ...`) and include
the actual model/backend as the shared guide requires. The final commit message
remains Claude-authored.
