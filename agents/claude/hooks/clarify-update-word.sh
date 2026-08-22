#!/usr/bin/env bash
# Claude UserPromptSubmit adapter for the shared clarification policy.
set -euo pipefail

CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"
INPUT=$(cat)
[ -x "$CORE" ] || exit 0

NORMALIZED=$(jq -n --arg prompt "$(jq -r '.prompt // empty' <<<"$INPUT")" '{prompt:$prompt}')
RESULT=$(printf '%s' "$NORMALIZED" | "$CORE" clarify) || exit 0
MESSAGE=$(jq -r '.message // empty' <<<"$RESULT")
[ -n "$MESSAGE" ] && printf '%s\n' "$MESSAGE"

exit 0
