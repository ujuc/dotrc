#!/usr/bin/env bash
# PostToolUse hook: remind to wait for user review on research/plan files
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only trigger for research/plan artifacts
case "$FILE_PATH" in
  */.research/*.md|*/.plans/plan-*.md) ;;
  *) exit 0 ;;
esac

jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "suppressOutput": false,
    "systemMessage": "You just wrote a research/plan document. Prompt the user to review it before proceeding. Do NOT move to implementation until the user confirms."
  }
}'
