# Zsh configuration
# All settings in a single file with section separators

# Auto-compile this file if modified
if [[ ! -f ${DOTRCDIR}/zshrc.zwc ]] || [[ ${DOTRCDIR}/zshrc -nt ${DOTRCDIR}/zshrc.zwc ]]; then
    zcompile ${DOTRCDIR}/zshrc
fi

# ── Environment ────────────────────────────────────────────

# Zsh function file dir
ZFUNCDIR=${ZDOTDIR}/.zfunc
fpath=(${ZFUNCDIR} $fpath)

# User local binaries (claude, custom scripts, etc.)
if [[ -d "${HOME}/.local/bin" ]]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# amp
if [[ -d "${HOME}/.amp/bin" ]]; then
    export PATH="${HOME}/.amp/bin:${PATH}"
fi

# JetBrains Toolbox CLI scripts
if [[ -d "/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts" ]]; then
    export PATH="${PATH}:/Users/ujuc/Library/Application Support/JetBrains/Toolbox/scripts"
fi

# Obsidian CLI
if [[ -d "/Applications/Obsidian.app" ]]; then
    export PATH="${PATH}:/Applications/Obsidian.app/Contents/MacOS"
fi

# ── History ────────────────────────────────────────────────

setopt HIST_IGNORE_ALL_DUPS

# ── Plugins ────────────────────────────────────────────────

# zimfw
ZIM_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}/zim

## Install zimfw if not exists
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

## Initialize zimfw
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR}/.zimrc} ]]; then
    source ${ZIM_HOME}/zimfw.zsh init
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
if (( $+commands[fzf] )); then
    if [[ -f ${HOME}/.fzf.zsh ]]; then
        source ${HOME}/.fzf.zsh
    else
        source <(fzf --zsh)
    fi
fi

# zoxide (lazy loading)
if (( $+commands[zoxide] )); then
    # Create wrapper function that initializes on first use
    function z() {
        unfunction z
        _evalcache zoxide init zsh
        z "$@"
    }

    # Alias zi for interactive mode
    function zi() {
        unfunction zi
        _evalcache zoxide init zsh
        zi "$@"
    }
fi

# mise (lazy loading)
if (( $+commands[mise] )); then
    # Create wrapper function that activates on first use
    function mise() {
        unfunction mise
        eval "$(${HOME}/.local/bin/mise activate zsh)"
        mise "$@"
    }

    # But activate immediately if we're in a project directory with mise config
    if [[ -f .mise.toml ]] || [[ -f .tool-versions ]] || [[ -f mise.toml ]]; then
        eval "$(${HOME}/.local/bin/mise activate zsh)"
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

# Compile Zsh configs for faster loading
function compile_zsh() {
    ${DOTRCDIR}/scripts/compile-zsh.sh
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
alias zcompile=compile_zsh
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
if [[ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/op/plugins.sh ]]; then
    source ${XDG_CONFIG_HOME:-${HOME}/.config}/op/plugins.sh
fi
