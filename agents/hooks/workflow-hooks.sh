#!/usr/bin/env bash
set -euo pipefail

ACTION=${1:-}
INPUT=$(cat)

if [ -z "$ACTION" ] || ! jq -e 'type == "object"' <<<"$INPUT" >/dev/null 2>&1; then
    printf 'usage: workflow-hooks.sh <cadence|clarify|annotation|context|typecheck|archive> < input.json\n' >&2
    exit 2
fi

empty_result() {
    printf '{}\n'
}

message_result() {
    jq -n --arg message "$1" '{message:$message}'
}

parse_date_epoch() {
    local value=$1
    date -j -u -f '%Y-%m-%d' "$value" '+%s' 2>/dev/null ||
        date -u -d "$value" '+%s' 2>/dev/null
}

run_cadence() {
    local stamp now last last_epoch days elapsed count message
    stamp="$HOME/.claude/.last_skill_improver_run"
    now=$(date -u +%s)
    elapsed='실행 기록 없음'

    if [ -f "$stamp" ]; then
        last=$(head -n1 "$stamp" | tr -d '[:space:]')
        last_epoch=$(parse_date_epoch "$last" || printf '0')
        if [ "$last_epoch" -gt 0 ]; then
            days=$(( (now - last_epoch) / 86400 ))
            [ "$days" -le 7 ] && { empty_result; return; }
            elapsed="${days}일 경과"
        fi
    fi

    count=$(find "$HOME/.claude/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
    message="skill-improver cadence check: surface a short, non-blocking notice — \"마지막 skill-improver 실행 후 ${elapsed}, ${count}개 스킬 점검 가능. 지금 실행할까요?\" Do not auto-run without consent. On consent, invoke the skill-improver skill through the active harness and do not write the timestamp; the skill writes it only after successful completion. On decline or dismissal, write today's UTC date (YYYY-MM-DD) to ~/.claude/.last_skill_improver_run so the prompt does not repeat next session."
    message_result "$message"
}

run_clarify() {
    local prompt
    prompt=$(jq -r '.prompt // ""' <<<"$INPUT")
    case "$prompt" in
        *업데이트*|*변경사항*)
            message_result "Reminder: prompt contains '업데이트/변경사항' — per shared guidance, confirm whether the user means 'commit' or 'update content' before proceeding."
            ;;
        *) empty_result ;;
    esac
}

run_annotation() {
    local files file matched
    files=$(jq -r '.files[]? // empty' <<<"$INPUT")
    matched=false

    while IFS= read -r file; do
        case "/$file" in
            */.research/*.md|*/.plans/plan-*.md)
                matched=true
                break
                ;;
        esac
    done <<EOF
$files
EOF

    if [ "$matched" = true ]; then
        message_result "A research or plan document was written. Prompt the user to review it before proceeding, and do not move to implementation until the user confirms."
    else
        empty_result
    fi
}

run_context() {
    local cwd message file title
    cwd=$(jq -r '.cwd // "."' <<<"$INPUT")
    [ -d "$cwd" ] || { empty_result; return; }
    cwd=$(cd "$cwd" && pwd -P)
    message=''

    for file in "$cwd"/.research/*.md "$cwd"/.plans/plan-*.md; do
        [ -f "$file" ] || continue
        title=$(sed -n 's/^#\{1,\}[[:space:]]*//p' "$file" | head -n1)
        [ -n "$title" ] || title=$(basename "$file")
        if [ -z "$message" ]; then
            message='Active research/plan artifacts:'
        fi
        message="${message}
- $file: $title"
    done

    if [ -n "$message" ]; then
        message_result "${message}
Refer to these files for active workflow context."
    else
        empty_result
    fi
}

find_ancestor() {
    local directory=$1 marker=$2
    while :; do
        if [ -f "$directory/$marker" ]; then
            printf '%s\n' "$directory"
            return 0
        fi
        [ "$directory" = / ] && return 1
        directory=$(dirname "$directory")
    done
}

append_error() {
    local current=$1 next=$2
    if [ -z "$current" ]; then
        printf '%s' "$next"
    else
        printf '%s\n\n%s' "$current" "$next"
    fi
}

run_typecheck() {
    local cwd files file path extension directory check_directory key seen output errors
    cwd=$(jq -r '.cwd // "."' <<<"$INPUT")
    [ -d "$cwd" ] || { empty_result; return; }
    cwd=$(cd "$cwd" && pwd -P)
    [ -f "$cwd/.plans/.implementing" ] || { empty_result; return; }

    files=$(jq -r '.files[]? // empty' <<<"$INPUT")
    errors=''
    seen='|'

    while IFS= read -r file; do
        [ -n "$file" ] || continue
        case "$file" in
            /*) path=$file ;;
            *) path="$cwd/$file" ;;
        esac
        [ -f "$path" ] || continue

        extension=${path##*.}
        directory=$(dirname "$path")
        case "$extension" in
            py)
                check_directory=$(find_ancestor "$directory" pyproject.toml || printf '%s' "$directory")
                key="py:$path"
                case "$seen" in *"|$key|"*) continue ;; esac
                seen="${seen}${key}|"
                if ! output=$(cd "$check_directory" && mypy "$path" 2>&1); then
                    errors=$(append_error "$errors" "$output")
                fi
                ;;
            rs)
                check_directory=$(find_ancestor "$directory" Cargo.toml || true)
                [ -n "$check_directory" ] || continue
                key="rs:$check_directory"
                case "$seen" in *"|$key|"*) continue ;; esac
                seen="${seen}${key}|"
                if ! output=$(cd "$check_directory" && cargo check 2>&1); then
                    errors=$(append_error "$errors" "$output")
                fi
                ;;
            go)
                check_directory=$(find_ancestor "$directory" go.mod || printf '%s' "$directory")
                key="go:$check_directory"
                case "$seen" in *"|$key|"*) continue ;; esac
                seen="${seen}${key}|"
                if ! output=$(cd "$check_directory" && go vet ./... 2>&1); then
                    errors=$(append_error "$errors" "$output")
                fi
                ;;
        esac
    done <<EOF
$files
EOF

    if [ -n "$errors" ]; then
        jq -n --arg message "$errors" '{block:true,message:$message}'
    else
        empty_result
    fi
}

archive_error() {
    jq -n --arg error "$1" '{error:$error}' >&2
    exit 1
}

run_archive() {
    local cwd plan relative_plan plan_name feature section sources source source_name destination
    local plan_destination moved moved_sources item_slugs item_slug
    cwd=$(jq -r '.cwd // "."' <<<"$INPUT")
    plan=$(jq -r '.plan // empty' <<<"$INPUT")
    [ -d "$cwd" ] || archive_error "Archive cwd does not exist: $cwd"
    cwd=$(cd "$cwd" && pwd -P)
    relative_plan=$plan

    [ "$(dirname "$relative_plan")" = .plans ] || archive_error "Plan must be directly under .plans/: $relative_plan"
    plan_name=$(basename "$relative_plan")
    case "$plan_name" in
        plan-*.md) ;;
        *) archive_error "Plan must match .plans/plan-*.md: $relative_plan" ;;
    esac
    [ -f "$cwd/$relative_plan" ] || archive_error "Plan does not exist: $relative_plan"

    feature=${plan_name#plan-}
    feature=${feature%.md}
    [ -n "$feature" ] || archive_error "Plan feature is empty: $relative_plan"
    sources=''

    if grep -qE '^## Research Sources[[:space:]]*$' "$cwd/$relative_plan"; then
        section=$(awk '
            /^## Research Sources[[:space:]]*$/ { active=1; next }
            active && /^## / { exit }
            active { print }
        ' "$cwd/$relative_plan")
        sources=$(printf '%s\n' "$section" | sed -n 's/.*`\(\.research\/research-[^`]*\.md\)`.*/\1/p')
        if [ -z "$sources" ] && ! printf '%s\n' "$section" | grep -qE '^[[:space:]]*None[[:space:]]*$'; then
            archive_error "Research Sources must contain exact backticked paths or None"
        fi
    elif [ -f "$cwd/.research/research-$feature.md" ]; then
        sources=".research/research-$feature.md"
    fi

    plan_destination="$cwd/docs/plans/$plan_name"
    [ ! -e "$plan_destination" ] && [ ! -L "$plan_destination" ] || archive_error "Archive destination exists: docs/plans/$plan_name"

    while IFS= read -r source; do
        [ -n "$source" ] || continue
        source_name=$(basename "$source")
        [ "$source" = ".research/$source_name" ] || archive_error "Research source must be directly under .research/: $source"
        case "$source_name" in
            research-*.md) ;;
            *) archive_error "Invalid research source: $source" ;;
        esac
        [ -f "$cwd/$source" ] || archive_error "Declared research source does not exist: $source"
        destination="$cwd/docs/research/$source_name"
        [ ! -e "$destination" ] && [ ! -L "$destination" ] || archive_error "Archive destination exists: docs/research/$source_name"
    done <<EOF
$sources
EOF

    item_slugs=$(jq -r '.item_slugs[]? // empty' <<<"$INPUT")
    while IFS= read -r item_slug; do
        [ -n "$item_slug" ] || continue
        case "$item_slug" in
            *[!A-Za-z0-9._-]*) archive_error "Invalid item slug: $item_slug" ;;
        esac
    done <<EOF
$item_slugs
EOF

    mkdir -p "$cwd/docs/research" "$cwd/docs/plans"
    moved='[]'
    moved_sources=''

    while IFS= read -r source; do
        [ -n "$source" ] || continue
        source_name=$(basename "$source")
        destination="$cwd/docs/research/$source_name"
        if ! mv "$cwd/$source" "$destination"; then
            while IFS= read -r source_name; do
                [ -n "$source_name" ] || continue
                mv "$cwd/docs/research/$source_name" "$cwd/.research/$source_name" || true
            done <<EOF
$moved_sources
EOF
            archive_error "Failed to move research source: $source"
        fi
        moved_sources="${moved_sources}${moved_sources:+
}$source_name"
        moved=$(jq --arg path "docs/research/$source_name" '. + [$path]' <<<"$moved")
    done <<EOF
$sources
EOF

    if ! mv "$cwd/$relative_plan" "$plan_destination"; then
        while IFS= read -r source_name; do
            [ -n "$source_name" ] || continue
            mv "$cwd/docs/research/$source_name" "$cwd/.research/$source_name" || true
        done <<EOF
$moved_sources
EOF
        archive_error "Failed to move plan: $relative_plan"
    fi
    moved=$(jq --arg path "docs/plans/$plan_name" '. + [$path]' <<<"$moved")

    rm -f \
        "$cwd/.plans/.implementing" \
        "$cwd/.plans/.plan-$feature.md.prev" \
        "$cwd/.plans/.plan-$feature.cycle" \
        "$cwd/.plans/.verify-final-$feature.md"

    while IFS= read -r item_slug; do
        [ -n "$item_slug" ] || continue
        rm -f \
            "$cwd/.plans/.verify-$item_slug.md" \
            "$cwd/.plans/.blocker-$item_slug.md" \
            "$cwd/.plans/.debug-$item_slug.md"
    done <<EOF
$item_slugs
EOF

    jq -n --argjson moved "$moved" '{moved:$moved}'
}

case "$ACTION" in
    cadence) run_cadence ;;
    clarify) run_clarify ;;
    annotation) run_annotation ;;
    context) run_context ;;
    typecheck) run_typecheck ;;
    archive) run_archive ;;
    *)
        printf 'unknown workflow hook action: %s\n' "$ACTION" >&2
        exit 2
        ;;
esac
