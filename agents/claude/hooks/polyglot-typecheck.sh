#!/usr/bin/env bash
# Claude PostToolUse adapter for the shared implementation typecheck policy.
set -euo pipefail

CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"
INPUT=$(cat)
[ -x "$CORE" ] || exit 0

NORMALIZED=$(jq -n \
  --arg cwd "$(jq -r '.cwd // "."' <<<"$INPUT")" \
  --arg file "$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")" \
  '{cwd:$cwd,files:[$file] | map(select(length > 0))}')
RESULT=$(printf '%s' "$NORMALIZED" | "$CORE" typecheck) || exit 0

if [ "$(jq -r '.block // false' <<<"$RESULT")" = true ]; then
  jq -r '.message' <<<"$RESULT" >&2
  exit 2
fi

exit 0
