#!/usr/bin/env bash
# SessionStart hook: 7-day skill-improver cadence check.
# Deterministic replacement for the former CLAUDE.md "Periodic skill-improver
# check" section — the date math runs here; the consent flow stays with Claude.
STAMP="$HOME/.claude/.last_skill_improver_run"
NOW=$(date +%s)

ELAPSED_KO="실행 기록 없음"
if [ -f "$STAMP" ]; then
  LAST=$(date -j -f "%Y-%m-%d" "$(head -1 "$STAMP" | tr -d '[:space:]')" +%s 2>/dev/null || echo 0)
  DAYS=$(( (NOW - LAST) / 86400 ))
  [ "$DAYS" -le 7 ] && exit 0
  ELAPSED_KO="${DAYS}일 경과"
fi

N=$(ls "$HOME"/.claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')

jq -n --arg msg "skill-improver cadence check: surface a short, non-blocking notice — \"마지막 skill-improver 실행 후 ${ELAPSED_KO}, ${N}개 스킬 점검 가능. 지금 실행할까요?\" Do NOT auto-run without consent. On consent, invoke Skill(\"skill-improver\") with no arguments and do NOT write the timestamp — its Phase 6 writes it only on successful completion (failed runs must re-prompt next session). On decline or dismissal, write today's date (YYYY-MM-DD) to ~/.claude/.last_skill_improver_run so the prompt does not repeat next session." '{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $msg
  }
}'
