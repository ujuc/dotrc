#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_display=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Replace home directory with ~
home_replaced="${cwd/#$HOME/\~}"

# Get git branch if in a git repository
git_info=""
if git --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check for uncommitted changes
    if [ -n "$(git --no-optional-locks status --porcelain 2>/dev/null)" ]; then
        status_indicator="[✗]"
        status_color=31  # Red
    else
        status_indicator="[✓]"
        status_color=32  # Green
    fi

    git_info=$(printf " \033[35mon\033[0m %s $(printf "\033[${status_color}m%s\033[0m" "$status_indicator")" "$branch")
fi

# Simplify model name
model_short="$model_display"

# Build status line with colors
status_line=$(printf "\033[36m%s\033[0m%s \033[34mvia\033[0m %s" \
    "$home_replaced" \
    "$git_info" \
    "$model_short")

# Add context percentage if available
if [ -n "$used_pct" ]; then
    status_line="$status_line $(printf "\033[33m[%s%%]\033[0m" "$used_pct")"
fi

echo "$status_line"
