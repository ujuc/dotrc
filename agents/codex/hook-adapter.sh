#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-}
INPUT=$(cat)
CORE="${DOTRCDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/dotrc}/agents/hooks/workflow-hooks.sh"

[ -x "$CORE" ] || exit 0

additional_context() {
    local event=$1 message=$2
    [ -n "$message" ] || return 0
    jq -n --arg event "$event" --arg message "$message" '{
      hookSpecificOutput: {
        hookEventName: $event,
        additionalContext: $message
      }
    }'
}

run_advisory() {
    local policy=$1 event=$2 normalized=$3 result message
    result=$(printf '%s' "$normalized" | "$CORE" "$policy") || exit 0
    message=$(jq -r '.message // empty' <<<"$result")
    additional_context "$event" "$message"
}

case "$ACTION" in
    cadence)
        run_advisory cadence SessionStart '{}'
        ;;
    clarify)
        normalized=$(jq -n --arg prompt "$(jq -r '.prompt // empty' <<<"$INPUT")" '{prompt:$prompt}')
        run_advisory clarify UserPromptSubmit "$normalized"
        ;;
    context)
        normalized=$(jq -n --arg cwd "$(jq -r '.cwd // "."' <<<"$INPUT")" '{cwd:$cwd}')
        run_advisory context SessionStart "$normalized"
        ;;
    post-tool)
        cwd=$(jq -r '.cwd // "."' <<<"$INPUT")
        patch=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
        files=$(printf '%s\n' "$patch" |
            sed -n \
                -e 's/^\*\*\* Add File: //p' \
                -e 's/^\*\*\* Update File: //p' \
                -e 's/^\*\*\* Delete File: //p' \
                -e 's/^\*\*\* Move to: //p' |
            jq -Rsc 'split("\n") | map(select(length > 0)) | unique')
        normalized=$(jq -n --arg cwd "$cwd" --argjson files "$files" '{cwd:$cwd,files:$files}')

        annotation_result=$(printf '%s' "$normalized" | "$CORE" annotation || printf '{}')
        annotation_message=$(jq -r '.message // empty' <<<"$annotation_result")
        typecheck_result=$(printf '%s' "$normalized" | "$CORE" typecheck || printf '{}')

        if [ "$(jq -r '.block // false' <<<"$typecheck_result")" = true ]; then
            typecheck_message=$(jq -r '.message' <<<"$typecheck_result")
            jq -n \
                --arg reason "$typecheck_message" \
                --arg context "$annotation_message" \
                '{
                  decision: "block",
                  reason: $reason,
                  hookSpecificOutput: {
                    hookEventName: "PostToolUse",
                    additionalContext: $context
                  }
                }'
        else
            additional_context PostToolUse "$annotation_message"
        fi
        ;;
    *)
        printf 'unknown Codex hook adapter action: %s\n' "$ACTION" >&2
        exit 2
        ;;
esac
