#!/usr/bin/env bash
# query.sh — Send one prompt to a local Ollama model.

set -euo pipefail

MODEL="${GEMMA_MODEL:-gemma4:26b-mlx}"
PROMPT="$*"

if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: query.sh <prompt>"
  echo "Environment: GEMMA_MODEL (default: gemma4:26b-mlx)"
  exit 0
fi

if [[ -z "${PROMPT//[[:space:]]/}" ]]; then
  echo "error: usage: query.sh <prompt>" >&2
  exit 64
fi

if ! command -v ollama >/dev/null 2>&1; then
  echo "error: ollama not found. Install it with: brew install ollama" >&2
  exit 127
fi

echo "info: backend=ollama model=${MODEL}" >&2
exec ollama run "$MODEL" --hidethinking --nowordwrap "$PROMPT"
