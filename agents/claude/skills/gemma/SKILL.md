---
name: gemma
description: "로컬 Ollama의 Gemma 모델에 프롬프트를 전달한다. gemma, gemma4, ollama로 요약해줘, gemma로 번역해, 로컬 LLM, 오프라인 AI, 로컬로 처리해, Gemma 호출 요청 시 사용한다. 민감 정보 처리, 긴 문서 요약, 번역, 분류, 초안 생성에 적합하다."
group: llm
model: sonnet
allowed-tools: Bash(bash:*), Bash(ollama:*)
argument-hint: "[prompt]"
---

# Gemma (Ollama)

Send text prompts to a local Gemma model through Ollama. This skill has one
backend, no routing, and no remote API fallback.

## How to invoke

All requests go through `scripts/query.sh`:

```bash
bash ~/.claude/skills/gemma/scripts/query.sh "이 문단을 3줄로 요약해줘: ..."

# Use another installed Ollama model for one call.
GEMMA_MODEL=gemma4:4b bash ~/.claude/skills/gemma/scripts/query.sh "hello"
```

stdout contains only the model response. stderr starts with
`info: backend=ollama model=<id>`. Label user-visible output with the reported
model, for example `Gemma (gemma4:26b-mlx via Ollama):`.

## Setup (first run)

```bash
brew install ollama
ollama pull gemma4:26b-mlx
ollama list
```

Start the Ollama app or run `ollama serve` before querying. The launcher does
not install dependencies or pull models automatically.

## Procedure

1. Identify the prompt body from the user's request.
2. For long inputs, build the prompt with a clear instruction on top and the
   body in a single string (heredoc or quoted).
3. Call `query.sh` via `bash` without backend or variant flags.
4. Surface the stdout response to the user with a header that names the
   actual backend and model (read from the stderr `info:` line). Never
   present Gemma output as if it were Claude's own reply.
5. On failure, relay Ollama's error and continue through the primary
   Claude-only path when this skill is used as optional delegation.

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `GEMMA_MODEL` | `gemma4:26b-mlx` | Ollama model name |

Standard Ollama variables such as `OLLAMA_HOST` continue to work unchanged.

## When to use Gemma vs Claude

Appropriate for:

- Summarizing or classifying sensitive data locally
- Multilingual translation
- Long-document summarization within the selected model's context limit
- Drafting notes, initial outlines, or structured JSON

Better left to Claude:

- High-difficulty math or reasoning
- Large-codebase navigation
- Tasks requiring the current conversation or tool context

## Error handling

| Exit | Cause | Action |
|------|-------|--------|
| 64 | Missing or empty prompt | Supply prompt text |
| 127 | `ollama` not found | `brew install ollama` |
| other | Ollama command failure | Check `ollama serve`, `ollama list`, and stderr |

## References

- `references/delegation-guide.md` — when to delegate to Gemma from Claude.

## Eval Criteria

Binary checks the skill must pass when invoked in realistic conditions:

1. A default call uses `gemma4:26b-mlx` and logs `backend=ollama` on stderr.
2. `GEMMA_MODEL=<id>` passes that exact model ID to Ollama.
3. Missing or whitespace-only prompts exit 64 without invoking Ollama.
4. No LM Studio, Gemini API, 1Password, or Rust dependency is required.
