#!/usr/bin/env bash
# Claude SessionStart adapter for the shared cadence policy.
set -euo pipefail

CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"
[ -x "$CORE" ] || exit 0

RESULT=$(printf '{}' | "$CORE" cadence) || exit 0
MESSAGE=$(jq -r '.message // empty' <<<"$RESULT")
[ -n "$MESSAGE" ] || exit 0

jq -n --arg message "$MESSAGE" '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $message
  }
}'
