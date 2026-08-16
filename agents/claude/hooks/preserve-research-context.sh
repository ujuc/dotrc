#!/usr/bin/env bash
# PreCompact hook: inject active research/plan file paths as system context
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')

FILES=""
for f in "$CWD"/.research/*.md "$CWD"/.plans/plan-*.md; do
  [ -f "$f" ] || continue
  TITLE=$(head -5 "$f" | grep -m1 '^#' | sed 's/^#* //')
  FILES="$FILES\n- $f: $TITLE"
done

[ -z "$FILES" ] && exit 0

jq -n --arg files "$FILES" '{
  "hookSpecificOutput": {
    "hookEventName": "PreCompact",
    "suppressOutput": false,
    "systemMessage": ("Active research/plan artifacts:" + $files + "\nRefer to these files for context after compaction.")
  }
}'
