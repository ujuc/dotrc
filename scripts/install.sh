#!/usr/bin/env bash
set -uo pipefail

DOTRCDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
SELECT_CLI=false
SELECT_APPS=false
SELECT_FONTS=false
SELECT_AGENTS=false
AGENTS_REPO_READY=false
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

check_link_destination() {
    local source=$1 destination=$2 current_target

    if [ -L "$destination" ]; then
        current_target=$(readlink "$destination")
        if [ "$current_target" = "$source" ]; then
            return 0
        fi
    elif [ ! -e "$destination" ]; then
        return 0
    fi

    printf 'Link conflict: %s\n' "$destination" >&2
    return 1
}

visit_static_selected_links() {
    local callback=$1 failed=0

    if $SELECT_CLI; then
        "$callback" "$DOTRCDIR/starship.toml" "$XDG_CONFIG_HOME/starship.toml" || failed=1
        "$callback" "$DOTRCDIR/zshrc" "$HOME/.zshrc" || failed=1
        "$callback" "$DOTRCDIR/batrc" "$XDG_CONFIG_HOME/bat/config" || failed=1
        "$callback" "$DOTRCDIR/tigrc" "$XDG_CONFIG_HOME/tig/config" || failed=1
    fi
    if $SELECT_APPS; then
        "$callback" "$DOTRCDIR/zed/settings.json" "$XDG_CONFIG_HOME/zed/settings.json" || failed=1
        "$callback" "$DOTRCDIR/ghosttyrc" "$XDG_CONFIG_HOME/ghostty/config" || failed=1
    fi
    if $SELECT_AGENTS; then
        "$callback" "$DOTRCDIR/agents/claude" "$HOME/.claude" || failed=1
        "$callback" "$DOTRCDIR/agents/rules/AGENTS.md" "$HOME/.codex/AGENTS.md" || failed=1
        "$callback" "$DOTRCDIR/agents/amp/AGENTS.md" "$XDG_CONFIG_HOME/amp/AGENTS.md" || failed=1
        "$callback" "$DOTRCDIR/agents/amp/settings.json" "$XDG_CONFIG_HOME/amp/settings.json" || failed=1
    fi
    return "$failed"
}

preflight_static_links() {
    local conflicts=0
    visit_static_selected_links check_link_destination || conflicts=1
    if [ "$conflicts" -ne 0 ]; then
        printf 'Link preflight failed; no installation steps were run.\n' >&2
        exit 1
    fi
}

preflight_codex_skill_links() {
    local skill conflicts=0
    $SELECT_AGENTS || return 0
    for skill in "$DOTRCDIR"/agents/claude/skills/*; do
        [ -d "$skill" ] || continue
        check_link_destination "$skill" "$HOME/.codex/skills/$(basename "$skill")" || conflicts=1
    done
    if [ "$conflicts" -ne 0 ]; then
        printf 'Codex skill link preflight failed; no package, configuration, or link steps were run.\n' >&2
        exit 1
    fi
}

validate_agents_repo() {
    local top_level status failure_status
    top_level=$(git -C "$DOTRCDIR/agents" rev-parse --show-toplevel 2>&1)
    status=$?
    if [ "$status" -eq 0 ] && [ "$top_level" = "$DOTRCDIR/agents" ]; then
        return 0
    fi
    printf '%s\n' "$top_level" >&2
    failure_status=$status
    [ "$failure_status" -ne 0 ] || failure_status=1
    record_failure agents "Validate initialized agents repository" "$failure_status" \
        "git -C $DOTRCDIR/agents rev-parse --show-toplevel # expected $DOTRCDIR/agents"
    return 1
}

prepare_agents_repo() {
    run_step agents "Initialize agent submodule" git -C "$DOTRCDIR" submodule update --init --recursive
    if [ "$LAST_STEP_STATUS" -ne 0 ]; then
        return 1
    fi
    if validate_agents_repo; then
        AGENTS_REPO_READY=true
        return 0
    fi
    return 1
}

safe_link() {
    local source=$1 destination=$2
    if [ ! -e "$source" ]; then
        record_failure links "Source exists: $source" 1 "test -e $source"
        return 0
    fi
    run_step links "Create parent for $destination" mkdir -p "$(dirname "$destination")"
    if [ "$LAST_STEP_STATUS" -eq 0 ]; then
        run_step links "Link $destination" ln -sfn "$source" "$destination"
    fi
}

ensure_homebrew() {
    local shellenv
    if ! command -v brew >/dev/null 2>&1; then
        run_shell_step homebrew "Install Homebrew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        if [ "$LAST_STEP_STATUS" -ne 0 ]; then
            print_summary
            exit 1
        fi
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        shellenv=$(/opt/homebrew/bin/brew shellenv)
        eval "$shellenv"
    elif [ -x /usr/local/bin/brew ]; then
        shellenv=$(/usr/local/bin/brew shellenv)
        eval "$shellenv"
    fi
    if ! command -v brew >/dev/null 2>&1; then
        record_failure homebrew "Find brew after installation" 1 "command -v brew"
        print_summary
        exit 1
    fi
}

install_formula() {
    local group=$1 name=$2
    brew list --formula "$name" >/dev/null 2>&1 && return 0
    run_step "$group" "Install formula $name" brew install "$name"
}

install_cask() {
    local group=$1 name=$2
    brew list --cask "$name" >/dev/null 2>&1 && return 0
    run_step "$group" "Install cask $name" brew install --cask "$name"
}

configure_git() {
    local key value
    while IFS='|' read -r key value; do
        run_step cli "Configure git $key" git config --global "$key" "$value"
    done <<EOF
core.autocrlf|input
core.whitespace|cr-at-eol,fix,trailing-space,-indent-with-non-tab
merge.conflictstyle|zdiff3
init.defaultBranch|main
commit.template|$DOTRCDIR/gitmessage
core.pager|delta
interactive.diffFilter|delta --color-only
delta.line-numbers|true
delta.side-by-side|true
delta.navigate|true
delta.diff-so-fancy|true
delta.hyperlinks|true
EOF

    configure_git_identity user.name "Git user name"
    configure_git_identity user.email "Git user email"
    run_step cli "Configure root git hooks" git -C "$DOTRCDIR" config core.hooksPath .githooks
    if $AGENTS_REPO_READY; then
        run_step cli "Configure agents git hooks" git -C "$DOTRCDIR/agents" config core.hooksPath .githooks
    else
        printf '[cli] Skipping agents hooks: agents is not an initialized independent repository.\n' >&2
    fi
}

configure_git_identity() {
    local key=$1 prompt=$2 value command_text
    git config --global --get "$key" >/dev/null 2>&1 && return 0
    if [ -t 0 ]; then
        printf '%s: ' "$prompt"
        IFS= read -r value
        if [ -n "$value" ]; then
            run_step cli "Configure git $key" git config --global "$key" "$value"
            return 0
        fi
    fi
    command_text="git config --global $key '<value>'"
    printf '[cli] Missing %s; run: %s\n' "$key" "$command_text" >&2
    record_failure cli "Configure git $key manually" 1 "$command_text"
}

install_cli() {
    local item
    for item in 1password 1password-cli; do install_cask cli "$item"; done
    for item in gh starship zimfw coreutils bat eza zoxide fzf vim git git-delta tig yq; do
        install_formula cli "$item"
    done
    if ! command -v mise >/dev/null 2>&1; then
        run_shell_step cli "Install mise" 'curl https://mise.run | sh'
        export PATH="$HOME/.local/bin:$PATH"
    fi
    if command -v mise >/dev/null 2>&1; then
        run_step cli "Install uv with mise" mise use -g uv
        run_step cli "Install node with mise" mise use -g node
    else
        record_failure cli "Find mise after installation" 1 "command -v mise"
    fi
    configure_git
    if ! gh auth status; then run_step cli "Authenticate GitHub CLI" gh auth login; fi
    visit_cli_links
}

visit_cli_links() {
    safe_link "$DOTRCDIR/starship.toml" "$XDG_CONFIG_HOME/starship.toml"
    safe_link "$DOTRCDIR/zshrc" "$HOME/.zshrc"
    safe_link "$DOTRCDIR/batrc" "$XDG_CONFIG_HOME/bat/config"
    safe_link "$DOTRCDIR/tigrc" "$XDG_CONFIG_HOME/tig/config"
}

install_apps() {
    local item machine
    machine=$(uname -m)
    if [ "$machine" = arm64 ] && ! pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
        run_step apps "Install Rosetta" sudo softwareupdate --install-rosetta --agree-to-license
    fi
    for item in raycast zed visual-studio-code ghostty fujitsu-scansnap-home google-drive adobe-creative-cloud; do
        install_cask apps "$item"
    done
    install_formula apps ollama
    if command -v ollama >/dev/null 2>&1; then
        run_step apps "Pull ollama model gemma3" ollama pull gemma3
        run_step apps "Pull ollama model qwen3" ollama pull qwen3
    fi
    safe_link "$DOTRCDIR/zed/settings.json" "$XDG_CONFIG_HOME/zed/settings.json"
    safe_link "$DOTRCDIR/ghosttyrc" "$XDG_CONFIG_HOME/ghostty/config"
}

install_fonts() {
    local item
    for item in font-google-sans-code font-cascadia-code font-cascadia-code-nf \
        font-d2coding-nerd-font font-ibm-plex-sans-kr font-ibm-plex-serif \
        font-noto-color-emoji font-noto-emoji font-noto-sans-cjk \
        font-noto-serif-cjk font-nanum-square font-nanum-square-neo \
        font-nanum-square-round; do
        install_cask fonts "$item"
    done
}

install_agent_links() {
    local skill
    safe_link "$DOTRCDIR/agents/claude" "$HOME/.claude"
    safe_link "$DOTRCDIR/agents/rules/AGENTS.md" "$HOME/.codex/AGENTS.md"
    safe_link "$DOTRCDIR/agents/amp/AGENTS.md" "$XDG_CONFIG_HOME/amp/AGENTS.md"
    safe_link "$DOTRCDIR/agents/amp/settings.json" "$XDG_CONFIG_HOME/amp/settings.json"
    for skill in "$DOTRCDIR"/agents/claude/skills/*; do
        [ -d "$skill" ] || continue
        safe_link "$skill" "$HOME/.codex/skills/$(basename "$skill")"
    done
}

json_has_string_field() {
    local json=$1 field=$2 value=$3
    printf '%s' "$json" | grep -E "\"${field}\"[[:space:]]*:[[:space:]]*\"${value}\"" >/dev/null 2>&1
}

install_agents() {
    local item marketplace_source marketplace_name marketplace_json plugin_json marketplace_status plugin_status
    if ! command -v claude >/dev/null 2>&1; then
        run_shell_step agents "Install Claude Code" 'curl -fsSL https://claude.ai/install.sh | bash'
        export PATH="$HOME/.local/bin:$PATH"
    fi
    if command -v mise >/dev/null 2>&1; then
        run_step agents "Install Pi coding agent" mise exec -- npm install -g @mariozechner/pi-coding-agent
    elif command -v npm >/dev/null 2>&1; then
        run_step agents "Install Pi coding agent" npm install -g @mariozechner/pi-coding-agent
    else
        record_failure agents "Install Pi coding agent (npm missing)" 127 "npm install -g @mariozechner/pi-coding-agent"
    fi
    if command -v claude >/dev/null 2>&1; then
        marketplace_json=$(claude plugin marketplace list --json 2>&1)
        marketplace_status=$?
        printf '%s\n' "$marketplace_json"
        if [ "$marketplace_status" -ne 0 ]; then
            record_failure agents "List plugin marketplaces" "$marketplace_status" "claude plugin marketplace list --json"
        else
            for item in \
                anthropics/claude-plugins-official\|claude-plugins-official \
                affaan-m/ECC\|ecc \
                jarrodwatts/claude-hud\|claude-hud \
                revfactory/harness\|harness-marketplace \
                ujuc/amp-plugin-cc\|amp-plugin-cc \
                openai/codex-plugin-cc\|openai-codex \
                warpdotdev/claude-code-warp\|claude-code-warp; do
                marketplace_source=${item%%|*}
                marketplace_name=${item#*|}
                if ! json_has_string_field "$marketplace_json" name "$marketplace_name"; then
                    run_step agents "Add marketplace $marketplace_source" claude plugin marketplace add "$marketplace_source"
                fi
            done
        fi
        plugin_json=$(claude plugin list --json 2>&1)
        plugin_status=$?
        printf '%s\n' "$plugin_json"
        if [ "$plugin_status" -ne 0 ]; then
            record_failure agents "List plugins" "$plugin_status" "claude plugin list --json"
        else
            for item in superpowers@claude-plugins-official ecc@ecc claude-hud@claude-hud code-review@claude-plugins-official code-simplifier@claude-plugins-official feature-dev@claude-plugins-official claude-md-management@claude-plugins-official security-guidance@claude-plugins-official rust-analyzer-lsp@claude-plugins-official harness@harness-marketplace amp-plugin-cc@amp-plugin-cc codex@openai-codex warp@claude-code-warp; do
                if ! json_has_string_field "$plugin_json" id "$item"; then
                    run_step agents "Install plugin $item" claude plugin install "$item"
                fi
            done
        fi
        printf 'Manual step: run /claude-hud:setup in a Claude session.\n'
    else
        record_failure agents "Find Claude after installation" 1 "command -v claude"
    fi
    install_agent_links
}

preflight_static_links
if $SELECT_CLI || $SELECT_AGENTS; then
    if ! prepare_agents_repo && $SELECT_AGENTS; then
        print_summary
        exit 1
    fi
fi
preflight_codex_skill_links
if $SELECT_CLI || $SELECT_APPS || $SELECT_FONTS; then ensure_homebrew; fi
$SELECT_CLI && install_cli
$SELECT_APPS && install_apps
$SELECT_FONTS && install_fonts
$SELECT_AGENTS && install_agents
print_summary
exit $?
