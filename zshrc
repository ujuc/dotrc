# Zsh configuration
# All settings in a single file with section separators

# ── Environment ────────────────────────────────────────────

# Global environment (moved from zshenv)
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export DOTRCDIR=${DOTRCDIR:-$XDG_CONFIG_HOME/dotrc}
export HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-$(brew --prefix)}

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Set the list of directories that zsh searches for commands.
path=(
    ${HOME}/{,s}bin(N)
    ${HOME}/.local/{,s}bin(N)
    /opt/{homebrew,local}/{,s}bin(N)
    /usr/local/{,s}bin(N)
    $path
)

## ENV
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# amp
if [[ -d "${HOME}/.amp/bin" ]]; then
    export PATH="${HOME}/.amp/bin:${PATH}"
fi

# JetBrains Toolbox CLI scripts
if [[ -d "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="${PATH}:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Obsidian CLI
if [[ -d "/Applications/Obsidian.app" ]]; then
    export PATH="${PATH}:/Applications/Obsidian.app/Contents/MacOS"
fi

# ── History ────────────────────────────────────────────────

setopt HIST_IGNORE_ALL_DUPS

# ── Plugins ────────────────────────────────────────────────

# zimfw
ZIM_HOME=${XDG_CONFIG_HOME}/zim
ZIM_CONFIG_FILE=${DOTRCDIR}/zimrc

## Initialize zimfw (installed via Homebrew)
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
    source ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh init
fi
source ${ZIM_HOME}/init.zsh

zstyle ':zim:zim:zim' use 'degit'

## zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

## zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

## zsh-history-substring-search
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ── Tools ──────────────────────────────────────────────────

# starship (always load - needed for prompt)
if (( $+commands[starship] )); then
    _evalcache starship init zsh
fi

# fzf
# Note: fzf init is fast (~10ms), so eager loading is fine
if (( $+commands[fzf] )) && [[ -f ${HOME}/.fzf.zsh ]]; then
    source ${HOME}/.fzf.zsh
elif (( $+commands[fzf] )); then
    source <(fzf --zsh)
fi

# zoxide (lazy loading)
if (( $+commands[zoxide] )); then
    # Create wrapper functions that initialize on first use
    function z zi() {
        unfunction z zi
        _evalcache zoxide init zsh
        $0 "$@"
    }
fi

# mise (lazy loading)
if (( $+commands[mise] )); then
    # Create wrapper function that activates on first use
    function mise() {
        unfunction mise
        _evalcache mise activate zsh
        mise "$@"
    }

    # But activate immediately if we're in a project directory with mise config
    if [[ -f .mise.toml || -f .tool-versions || -f mise.toml ]]; then
        unfunction mise
        _evalcache mise activate zsh
    fi
fi

# ── Aliases ────────────────────────────────────────────────

# System update function
function update_system() {
    brew update
    brew upgrade
    zimfw update && zimfw upgrade
    brew cleanup
    mise self-update && mise up
    # gh ext upgrade --all
}

# Benchmark Zsh startup time
function benchmark_zsh() {
    ${DOTRCDIR}/scripts/benchmark.sh "$@"
}

# Profile Zsh startup (show timing per module)
function profile_zsh() {
    ${DOTRCDIR}/scripts/profile-startup.zsh
}

# Update alias
alias update=update_system

# Zsh optimization aliases
alias zbench=benchmark_zsh
alias zprofile=profile_zsh

# Homebrew aliases
alias bws="brew search"
alias bwi="brew install"

# Modern CLI tool aliases
alias ls="eza --icons=auto --group-directories-first --git"
alias ll="eza -l --git --icons=auto"
alias lt="eza -l --tree --icons=auto"
alias cat="bat"
alias vi="vim"

# ── Local ──────────────────────────────────────────────────

# Work-specific config (gitignored)
if [[ -f ${HOME}/.zshrc.work ]]; then
    source ${HOME}/.zshrc.work
fi

# 1Password CLI plugins
if [[ -f ${XDG_CONFIG_HOME}/op/plugins.sh ]]; then
    source ${XDG_CONFIG_HOME}/op/plugins.sh
fi
