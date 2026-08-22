#!/usr/bin/env bash
# Claude SessionStart(source=compact) adapter for active artifact context.
set -euo pipefail

CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"
INPUT=$(cat)
[ -x "$CORE" ] || exit 0

NORMALIZED=$(jq -n --arg cwd "$(jq -r '.cwd // "."' <<<"$INPUT")" '{cwd:$cwd}')
RESULT=$(printf '%s' "$NORMALIZED" | "$CORE" context) || exit 0
MESSAGE=$(jq -r '.message // empty' <<<"$RESULT")
[ -n "$MESSAGE" ] || exit 0

jq -n --arg message "$MESSAGE" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $message
  }
}'
