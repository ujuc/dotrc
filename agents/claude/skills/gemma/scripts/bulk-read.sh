#!/usr/bin/env bash
# bulk-read.sh — Send several files plus one question to the local Gemma worker.
# Usage: bulk-read.sh --question "<q>" --paths <file>...
# The files never enter Claude's context; only the summary does.

set -euo pipefail

QUESTION=""
PATHS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --question) QUESTION="$2"; shift 2 ;;
    --paths) shift; while [[ $# -gt 0 && "$1" != --* ]]; do PATHS+=("$1"); shift; done ;;
    --help) sed -n '2,4p' "$0"; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; exit 64 ;;
  esac
done

if [[ -z "$QUESTION" || ${#PATHS[@]} -eq 0 ]]; then
  echo "error: usage: bulk-read.sh --question <q> --paths <file>..." >&2
  exit 64
fi

CORPUS=""
for p in "${PATHS[@]}"; do
  [[ -r "$p" ]] || { echo "error: cannot read $p" >&2; exit 66; }
  CORPUS+="<file path=\"$p\">"$'\n'"$(cat "$p")"$'\n'"</file>"$'\n'
done

PROMPT="You are a precise code analyst. Read the provided files and answer the question concisely.
Output structured bullets only. No greetings, no prose, no preambles.
Lead every bullet with the exact name, type, or line number. Use nested bullets for details.
Skip anything the caller did not ask for.

Question: $QUESTION

$CORPUS"

MODEL="${GEMMA_MODEL:-gemma4:e4b-mlx}"
HOST="${OLLAMA_HOST:-http://localhost:11434}"
echo "info: backend=ollama model=${MODEL} files=${#PATHS[@]} chars=${#CORPUS}" >&2
# ponytail: calls /api/generate directly; `ollama run` added ~50s of overhead per call and cannot set num_ctx.
RESP=$(jq -n --arg m "$MODEL" --arg p "$PROMPT" \
  '{model:$m,prompt:$p,stream:false,think:false,options:{num_ctx:32768,temperature:0.2}}' \
  | curl -sS --fail-with-body "$HOST/api/generate" -d @-) || { echo "error: ollama request failed: $RESP" >&2; exit 1; }
jq -r '"info: prompt_tok=\(.prompt_eval_count) gen_tok=\(.eval_count) total=\(.total_duration/1e9|floor)s"' <<<"$RESP" >&2
jq -r '.response' <<<"$RESP"
