#!/bin/zsh
# Claude Documentation Format Linter
# 문서 포맷 일관성을 검증하는 린터 스크립트
#
# Usage: ./lint-docs.sh [files...]
#        ./lint-docs.sh --all
#        ./lint-docs.sh --report

set -uo pipefail
# Note: -e is intentionally omitted because grep returns 1 when no match is found

# Colors for output
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Counters
typeset -i total_errors=0
typeset -i total_warnings=0
typeset -i files_checked=0

# Get script directory
SCRIPT_DIR="${0:A:h}"
CLAUDE_DIR="${SCRIPT_DIR:h}"

# ============================================================================
# Utility Functions
# ============================================================================

log_error() {
    local file="$1"
    local code="$2"
    local message="$3"
    local line="${4:-}"

    if [[ -n "$line" ]]; then
        echo -e "${RED}[E${code}]${NC} ${file}:${line}"
    else
        echo -e "${RED}[E${code}]${NC} ${file}"
    fi
    echo -e "  ${message}"
    ((total_errors++))
}

log_warning() {
    local file="$1"
    local code="$2"
    local message="$3"
    local line="${4:-}"

    if [[ -n "$line" ]]; then
        echo -e "${YELLOW}[W${code}]${NC} ${file}:${line}"
    else
        echo -e "${YELLOW}[W${code}]${NC} ${file}"
    fi
    echo -e "  ${message}"
    ((total_warnings++))
}

log_success() {
    local file="$1"
    echo -e "${GREEN}[OK]${NC} ${file}"
}

# ============================================================================
# Check Functions
# ============================================================================

# E001: Check for <meta> block
check_meta_block() {
    local file="$1"
    local content="$2"

    if ! grep -q '<meta>' <<< "$content"; then
        log_error "$file" "001" "Missing <meta> block"
        return 1
    fi
    return 0
}

# E002: Check meta required fields
check_meta_fields() {
    local file="$1"
    local content="$2"

    local meta_block
    meta_block=$(sed -n '/<meta>/,/<\/meta>/p' <<< "$content")

    if [[ -z "$meta_block" ]]; then
        return 1  # Already reported by E001
    fi

    local missing_fields=()

    if ! grep -q 'Document:' <<< "$meta_block"; then
        missing_fields+=("Document")
    fi
    if ! grep -q 'Role:' <<< "$meta_block"; then
        missing_fields+=("Role")
    fi
    if ! grep -q 'Priority:' <<< "$meta_block"; then
        missing_fields+=("Priority")
    fi
    if ! grep -q 'Last Updated:' <<< "$meta_block"; then
        missing_fields+=("Last Updated")
    fi

    if (( ${#missing_fields[@]} > 0 )); then
        log_error "$file" "002" "Missing meta fields: ${missing_fields[*]}"
        return 1
    fi
    return 0
}

# E003: Check for <context> block
check_context_block() {
    local file="$1"
    local content="$2"
    local filename="${file:t}"

    # Skip for commands with YAML frontmatter (different structure)
    if [[ "$file" == *"/commands/"* ]] && grep -q '^---$' <<< "$content"; then
        # Commands can use ## Context section instead
        if ! grep -q '<context>' <<< "$content" && ! grep -q '^## Context' <<< "$content"; then
            log_error "$file" "003" "Missing <context> block or ## Context section"
            return 1
        fi
        return 0
    fi

    if ! grep -q '<context>' <<< "$content"; then
        log_error "$file" "003" "Missing <context> block"
        return 1
    fi
    return 0
}

# E004: Check for See Also section
check_see_also() {
    local file="$1"
    local content="$2"

    if ! grep -qE '^## (See Also|References)' <<< "$content"; then
        log_error "$file" "004" "Missing ## See Also section"
        return 1
    fi
    return 0
}

# E005: Check Last Updated date format
check_date_format() {
    local file="$1"
    local content="$2"

    local date_line
    date_line=$(grep 'Last Updated:' <<< "$content" | head -1)

    if [[ -n "$date_line" ]]; then
        if ! grep -qE 'Last Updated: [0-9]{4}-[0-9]{2}-[0-9]{2}' <<< "$date_line"; then
            log_error "$file" "005" "Invalid date format. Expected: YYYY-MM-DD"
            return 1
        fi
    fi
    return 0
}

# W001: Check for <your_responsibility> in guides
check_responsibility() {
    local file="$1"
    local content="$2"

    # Only check guides/*.md files
    if [[ "$file" != *"/guides/"* ]]; then
        return 0
    fi

    if ! grep -q '<your_responsibility>' <<< "$content"; then
        log_warning "$file" "001" "Missing <your_responsibility> block (recommended for guides)"
        return 1
    fi
    return 0
}

# W002: Check for Korean H2 headers
check_header_language() {
    local file="$1"
    local content="$2"

    # Find H2 headers with Korean characters
    local korean_headers
    korean_headers=$(grep -n '^## ' <<< "$content" | grep -E '[가-힣]' || true)

    if [[ -n "$korean_headers" ]]; then
        while IFS= read -r line; do
            local line_num="${line%%:*}"
            local header="${line#*:}"
            log_warning "$file" "002" "Korean H2 header found: ${header}" "$line_num"
        done <<< "$korean_headers"
        return 1
    fi
    return 0
}

# W003: Check for stale Last Updated (30+ days)
check_stale_date() {
    local file="$1"
    local content="$2"

    local date_str
    date_str=$(grep -oE 'Last Updated: [0-9]{4}-[0-9]{2}-[0-9]{2}' <<< "$content" | head -1 | cut -d' ' -f3)

    if [[ -n "$date_str" ]]; then
        local file_date
        local current_date

        # macOS date command
        if command -v gdate &> /dev/null; then
            file_date=$(gdate -d "$date_str" +%s 2>/dev/null || echo "0")
            current_date=$(gdate +%s)
        else
            file_date=$(date -j -f "%Y-%m-%d" "$date_str" +%s 2>/dev/null || echo "0")
            current_date=$(date +%s)
        fi

        if (( file_date > 0 )); then
            local days_old=$(( (current_date - file_date) / 86400 ))
            if (( days_old > 30 )); then
                log_warning "$file" "003" "Last Updated is ${days_old} days old"
                return 1
            fi
        fi
    fi
    return 0
}

# ============================================================================
# Main Check Function
# ============================================================================

check_file() {
    local file="$1"
    local content
    local file_errors=0

    # Skip non-markdown files
    if [[ ! "$file" =~ \.md$ ]]; then
        return 0
    fi

    # Skip template files
    if [[ "$file" == *"/templates/"* ]]; then
        return 0
    fi

    # Skip plan files
    if [[ "$file" == *"/plans/"* ]]; then
        return 0
    fi

    # Skip plugins directory (external files)
    if [[ "$file" == *"/plugins/"* ]]; then
        return 0
    fi

    content=$(cat "$file")
    ((files_checked++))

    # Run all checks
    check_meta_block "$file" "$content" || ((file_errors++))
    check_meta_fields "$file" "$content" || ((file_errors++))
    check_context_block "$file" "$content" || ((file_errors++))
    check_see_also "$file" "$content" || ((file_errors++))
    check_date_format "$file" "$content" || ((file_errors++))
    check_responsibility "$file" "$content"  # Warning only
    check_header_language "$file" "$content"  # Warning only
    check_stale_date "$file" "$content"  # Warning only

    if (( file_errors == 0 )); then
        log_success "$file"
    fi

    echo ""
}

# ============================================================================
# Entry Point
# ============================================================================

print_header() {
    echo -e "${BLUE}=== Claude Documentation Lint ===${NC}"
    echo ""
}

print_summary() {
    echo -e "${BLUE}─────────────────────────────────${NC}"
    echo -e "Files checked: ${files_checked}"

    if (( total_errors > 0 )); then
        echo -e "Errors: ${RED}${total_errors}${NC}"
    else
        echo -e "Errors: ${GREEN}0${NC}"
    fi

    if (( total_warnings > 0 )); then
        echo -e "Warnings: ${YELLOW}${total_warnings}${NC}"
    else
        echo -e "Warnings: ${GREEN}0${NC}"
    fi

    echo ""

    if (( total_errors > 0 )); then
        echo -e "${RED}Lint failed${NC}"
        return 1
    else
        echo -e "${GREEN}Lint passed${NC}"
        return 0
    fi
}

main() {
    print_header

    local files=()

    if [[ $# -eq 0 ]] || [[ "$1" == "--all" ]]; then
        # Check all markdown files in claude/
        files=("${CLAUDE_DIR}"/**/*.md(N))
    else
        files=("$@")
    fi

    if (( ${#files[@]} == 0 )); then
        echo "No markdown files found"
        return 0
    fi

    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            check_file "$file"
        fi
    done

    print_summary
}

main "$@"
