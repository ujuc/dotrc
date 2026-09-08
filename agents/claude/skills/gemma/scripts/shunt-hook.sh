#!/usr/bin/env bash
# shunt-hook.sh — PreToolUse hook. Blocks whole-file reads above SHUNT_MIN_LINES
# and redirects Claude to bulk-read.sh. Targeted reads (offset/limit, pipes) pass.
# Escape hatch: SHUNT_OFF=1.

set -euo pipefail
[[ "${SHUNT_OFF:-0}" == "1" ]] && exit 0
command -v jq >/dev/null || exit 0

INPUT=$(cat)
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT")
MIN="${SHUNT_MIN_LINES:-350}"
BULK="$(cd "$(dirname "$0")" && pwd)/bulk-read.sh"

block() {
  local file="$1" lines="$2"
  jq -n --arg reason "$file has $lines lines (> $MIN). Do not read it whole. For understanding, delegate to the local worker:
  bash $BULK --question \"<what you need to know>\" --paths $file [more files]
For editing, read only the needed section with offset/limit. Set SHUNT_OFF=1 to bypass." \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
  exit 0
}

case "$TOOL" in
  Read)
    FILE=$(jq -r '.tool_input.file_path // empty' <<<"$INPUT")
    HAS_RANGE=$(jq -r '(.tool_input.offset // .tool_input.limit) != null' <<<"$INPUT")
    [[ -f "$FILE" && "$HAS_RANGE" == "false" ]] || exit 0
    ;;
  Bash)
    CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
    # Only bare `cat|head|tail|less|more <file>` with no pipe/redirect.
    [[ "$CMD" =~ ^[[:space:]]*(cat|head|tail|less|more)[[:space:]]+([^|<>;&]+)$ ]] || exit 0
    set -- ${BASH_REMATCH[2]}
    FILE=""
    for a in "$@"; do [[ "$a" != -* && -f "$a" ]] && { FILE="$a"; break; }; done
    [[ -n "$FILE" ]] || exit 0
    ;;
  *) exit 0 ;;
esac

LINES=$(wc -l <"$FILE" | tr -d ' ')
(( LINES > MIN )) && block "$FILE" "$LINES"
exit 0
