#!/usr/bin/env bash
# PostToolUse hook: run typecheck after edits during implement-plan execution
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only active during implement-plan (flag file check)
[ -f "$CWD/.plans/.implementing" ] || exit 0
[ -n "$FILE_PATH" ] || exit 0

EXT="${FILE_PATH##*.}"
DIR=$(dirname "$FILE_PATH")
ERRORS=""

case "$EXT" in
  py)
    # Find nearest pyproject.toml and run mypy
    CHECK_DIR="$DIR"
    while [ "$CHECK_DIR" != "/" ]; do
      [ -f "$CHECK_DIR/pyproject.toml" ] && break
      CHECK_DIR=$(dirname "$CHECK_DIR")
    done
    ERRORS=$(cd "$CHECK_DIR" && mypy "$FILE_PATH" 2>&1) || true
    ;;
  rs)
    CHECK_DIR="$DIR"
    while [ "$CHECK_DIR" != "/" ]; do
      [ -f "$CHECK_DIR/Cargo.toml" ] && break
      CHECK_DIR=$(dirname "$CHECK_DIR")
    done
    ERRORS=$(cd "$CHECK_DIR" && cargo check 2>&1) || true
    ;;
  go)
    ERRORS=$(cd "$DIR" && go vet ./... 2>&1) || true
    ;;
  ts|tsx)
    # Skip — handled by existing TypeScript tooling
    exit 0
    ;;
  *)
    exit 0
    ;;
esac

# If no errors, silent pass
[ -z "$ERRORS" ] && exit 0

# Feed errors back to Claude for auto-fix
echo "$ERRORS" >&2
exit 2
