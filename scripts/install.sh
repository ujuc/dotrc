#!/usr/bin/env bash
set -uo pipefail

DOTRCDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
SELECT_CLI=false
SELECT_APPS=false
SELECT_FONTS=false
SELECT_AGENTS=false
FAILURE_COUNT=0
FAILURE_GROUPS=()
FAILURE_LABELS=()
FAILURE_STATUSES=()
FAILURE_COMMANDS=()
LAST_STEP_STATUS=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [--cli] [--apps] [--fonts] [--agents] [--all]

Options:
    --cli       Install command-line tools and configuration
    --apps      Install applications
    --fonts     Install fonts
    --agents    Install agent configuration
    --all       Install all groups
    -h, --help  Show this help
EOF
}

record_failure() {
    local group=$1 label=$2 status=$3 command_text=$4 index=$FAILURE_COUNT
    FAILURE_GROUPS[$index]=$group
    FAILURE_LABELS[$index]=$label
    FAILURE_STATUSES[$index]=$status
    FAILURE_COMMANDS[$index]=$command_text
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
}

run_step() {
    local group=$1 label=$2
    shift 2

    local command_text='' quoted_argument argument status
    for argument in "$@"; do
        printf -v quoted_argument '%q' "$argument"
        if [ -n "$command_text" ]; then
            command_text="$command_text $quoted_argument"
        else
            command_text=$quoted_argument
        fi
    done

    printf '[%s] %s\n' "$group" "$label"
    printf '$ %s\n' "$command_text"
    "$@"
    status=$?
    LAST_STEP_STATUS=$status

    if [ "$status" -eq 0 ]; then
        printf '[%s] Done: %s\n' "$group" "$label"
    else
        printf '[%s] Failed (%s): %s\n' "$group" "$status" "$label" >&2
        record_failure "$group" "$label" "$status" "$command_text"
    fi

    return 0
}

run_shell_step() {
    local group=$1 label=$2 shell_command=$3
    run_step "$group" "$label" /bin/bash -o pipefail -c "$shell_command"
}

print_summary() {
    local index

    if [ "$FAILURE_COUNT" -eq 0 ]; then
        return 0
    fi

    printf '\nFailures: %s\n' "$FAILURE_COUNT"
    index=0
    while [ "$index" -lt "$FAILURE_COUNT" ]; do
        printf '%s. [%s] %s (exit %s)\n' \
            "$((index + 1))" \
            "${FAILURE_GROUPS[$index]}" \
            "${FAILURE_LABELS[$index]}" \
            "${FAILURE_STATUSES[$index]}"
        printf '   $ %s\n' "${FAILURE_COMMANDS[$index]}"
        index=$((index + 1))
    done

    return 1
}

if [ "$#" -eq 0 ]; then
    usage
    exit 0
fi

while [ "$#" -gt 0 ]; do
    case $1 in
        --cli)
            SELECT_CLI=true
            ;;
        --apps)
            SELECT_APPS=true
            ;;
        --fonts)
            SELECT_FONTS=true
            ;;
        --agents)
            SELECT_AGENTS=true
            ;;
        --all)
            SELECT_CLI=true
            SELECT_APPS=true
            SELECT_FONTS=true
            SELECT_AGENTS=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done
