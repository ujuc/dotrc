# Gemma delegation for large commits

> Optional pre-summarization of huge `git diff --cached` output via local Gemma. Used by SKILL.md only when the commit is large enough that delegating saves time.

For very large changes, the commit **body** can be drafted by local Gemma first. The subject (`<type>(<scope>): <한국어 제목>`) is always written by Claude. Gemma helps only with light fact enumeration in the body. Call convention, fallback rules, and result-handling principles follow `../gemma/references/delegation-guide.md`.

## When to delegate

Trigger if any of the following holds:

- `git diff --cached --shortstat` reports ≥ 500 changed lines
- ≥ 10 files changed
- The user hints with `큰 diff`, `요약해서 커밋`, `gemma로 정리`, etc.

For smaller changes, Claude writing the body directly is faster and more accurate — skip this step.

## How to call

After staging, before the commit command (Step 7 of SKILL.md), call once. The pattern below avoids two common pitfalls:

- **Quoted heredoc trap**: `<<'EOF'` treats the inner `$()` command substitution as a literal. Putting `$(git diff --cached)` inside a quoted heredoc passes the literal string `$(git diff --cached)` to gemma, not the actual diff. Capture the diff into a variable first, then interpolate via a double-quoted string.
- **zsh noclobber trap**: with `set -o noclobber` enabled, repeating `2>/tmp/foo.log` to a fixed path fails on the second call with "file exists". Use a PID-based name plus a leading `rm -f`.

```bash
# log file — avoid zsh noclobber
LOG=/tmp/gemma-commit-$$.log
rm -f "$LOG"

# capture staged diff into a variable first (avoid quoted-heredoc trap)
DIFF=$(git diff --cached)

# build prompt — $DIFF interpolates inside double-quoted string,
# while $·backticks inside the diff stay un-reinterpreted
PROMPT="다음 git diff를 5개 이하의 글머리 기호로 요약해줘. 각 변경의 *의도*에 집중하고, 코드 인용은 하지 마. 한국어로 출력해.

---
$DIFF"

# call local Ollama + quiet fallback
gemma_summary=$(bash ~/.claude/skills/gemma/scripts/query.sh "$PROMPT" 2>"$LOG") || gemma_summary=""
```

- stdout captured to `$gemma_summary`, stderr split to the log file.
- The gemma skill uses Ollama only and has no remote inference fallback.
- `|| gemma_summary=""` is the fallback trigger — empty string when query.sh exits non-zero.

## Fallback rules

**Gemma availability is not assumed.** If Ollama is stopped or the configured model is unavailable, the commit procedure must continue normally:

1. Empty `$gemma_summary` → skip the gemma step, Claude writes the body directly.
2. Notify the user once per session, briefly (e.g., `note: gemma 사전 요약을 건너뛰었습니다 — Ollama 미가동/모델 없음`).
3. The commit must not fail because of this — gemma failure is a **normal path**, not an error.

## Using the result

1. Even with `$gemma_summary` in hand, do not paste it directly. Claude reads and **verifies accuracy** first.
2. Treat it as a reference draft only — Claude owns the final body.
3. Conventional Commits format and the Korean verb-declarative `-다` ending rule are still applied by Claude.
4. When explaining the commit diff to the user, label the gemma-derived part (e.g., `gemma 사전 요약에 따르면: ...`). The subject and final commit message stay in Claude's voice.
