#!/usr/bin/env bash
# UserPromptSubmit hook: when the prompt contains '업데이트' or '변경사항',
# inject a reminder to clarify commit-vs-content intent. Injection only — never blocks.
set -euo pipefail

prompt=$(jq -r '.prompt // empty' 2>/dev/null || true)

case "${prompt}" in
  *업데이트*|*변경사항*)
    echo "Reminder: prompt contains '업데이트/변경사항' — per shared guidance, confirm whether the user means 'commit' or 'update content' before proceeding."
    ;;
esac

exit 0
