#!/usr/bin/env bash
# Claude PostToolUse adapter for the shared annotation-review policy.
set -euo pipefail

CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"
INPUT=$(cat)
[ -x "$CORE" ] || exit 0

NORMALIZED=$(jq -n \
  --arg cwd "$(jq -r '.cwd // "."' <<<"$INPUT")" \
  --arg file "$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")" \
  '{cwd:$cwd,files:[$file] | map(select(length > 0))}')
RESULT=$(printf '%s' "$NORMALIZED" | "$CORE" annotation) || exit 0
MESSAGE=$(jq -r '.message // empty' <<<"$RESULT")
[ -n "$MESSAGE" ] || exit 0

jq -n --arg message "$MESSAGE" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $message
  }
}'
