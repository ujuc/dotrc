# Gemma Delegation Guide

Use this contract when another skill delegates a mechanical text task to the
local Ollama-backed Gemma model through `scripts/query.sh`.

## When to Delegate

Good fits:

- Long-document or large-log summarization
- Bulk translation
- Simple classification
- First drafts where structure matters more than judgment
- Sensitive text that should stay on the configured Ollama host

Keep hard reasoning, code review, architecture, conversation-dependent work,
and final judgment on Claude.

## Calling Convention

Always use the bundled launcher:

```bash
bash ~/.claude/skills/gemma/scripts/query.sh "<prompt>"
```

The default model is `gemma4:26b-mlx`. Override it only when the user asks for
another installed Ollama model:

```bash
GEMMA_MODEL=gemma4:4b bash ~/.claude/skills/gemma/scripts/query.sh "<prompt>"
```

### Passing Dynamic Input

Capture dynamic content first, then interpolate the variable into a quoted
prompt. A quoted heredoc would pass `$(command)` literally.

```bash
DIFF=$(git diff --cached)
PROMPT="Summarize this diff in five bullets:

---
$DIFF"
bash ~/.claude/skills/gemma/scripts/query.sh "$PROMPT"
```

When redirecting stderr repeatedly under zsh `noclobber`, clear a unique log
path first:

```bash
LOG=/tmp/gemma-$$.log
rm -f "$LOG"
bash ~/.claude/skills/gemma/scripts/query.sh "$PROMPT" 2>"$LOG"
```

## Process Contract

- stdout contains only the model response.
- stderr starts with `info: backend=ollama model=<id>` and may include Ollama
  errors.
- Exit 64 means the prompt was empty.
- Exit 127 means `ollama` is not installed.
- Other non-zero exits come from Ollama.

The skill has no LM Studio, Gemini API, or other remote inference fallback.
Standard Ollama configuration, including `OLLAMA_HOST`, still applies.

## Fallback Policy

Gemma is optional infrastructure. A delegating skill must continue through
its Claude-only path when `query.sh` exits non-zero. Keep the fallback silent
by default; at most, mention once per session that Gemma pre-processing was
skipped because Ollama or the selected model was unavailable.

## Result Presentation

Label Gemma output with the model and backend, then apply Claude's own review
before using it in a final answer:

```text
Gemma (gemma4:26b-mlx via Ollama) first-pass summary:
> ...

Claude review: ...
```

Do not present Gemma output as Claude's words or delegate decision-driving
reasoning without rechecking it.
