# Zsh configuration
# All settings in a single file with section separators

# ── Environment ────────────────────────────────────────────

# Global environment (moved from zshenv)
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export DOTRCDIR=${DOTRCDIR:-$XDG_CONFIG_HOME/dotrc}
# Hardcode to avoid forking `brew` on every startup (Apple Silicon default, Intel fallback)
if [[ -z ${HOMEBREW_PREFIX} ]]; then
    [[ -d /opt/homebrew ]] && export HOMEBREW_PREFIX=/opt/homebrew || export HOMEBREW_PREFIX=/usr/local
fi

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Set the list of directories that zsh searches for commands.
# (N) drops missing paths, so no existence checks are needed.
path=(
    ${HOME}/{,s}bin(N)
    ${HOME}/.local/{,s}bin(N)
    ${HOME}/.amp/bin(N)
    /opt/{homebrew,local}/{,s}bin(N)
    /usr/local/{,s}bin(N)
    $path
    "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"(N)
    /Applications/Obsidian.app/Contents/MacOS(N)
    ${HOME}/.lmstudio/bin(N)
)

## ENV
# LANG only, never LC_ALL: LC_ALL force-overrides every LC_* category and makes
# per-category overrides (LC_TIME, LC_COLLATE, ...) impossible.
export LANG=en_US.UTF-8

# ── History ────────────────────────────────────────────────

# zimfw's environment module only defaults HISTFILE (to ~/.zhistory) when it is
# unset, and macOS /etc/zshrc sets ~/.zsh_history first — so the real location
# has always come from a file outside this repo. Pin it here instead.
# Keep the value as ~/.zsh_history: switching to zimfw's default would strand
# the existing history file.
# HISTSIZE/SAVEHIST do NOT belong here — zimfw assigns them unconditionally
# during init in the Plugins section below, so they would be silently clobbered.
HISTFILE=${HOME}/.zsh_history

setopt HIST_IGNORE_ALL_DUPS

# ── Plugins ────────────────────────────────────────────────

# zimfw
ZIM_HOME=${XDG_CONFIG_HOME}/zim
ZIM_CONFIG_FILE=${DOTRCDIR}/zimrc

zstyle ':zim:zim:zim' use 'degit'

## Initialize zimfw (installed via Homebrew)
# Guarded so a fresh machine still gets a usable shell — but noisily, because a
# silently plugin-less shell is much harder to notice than a missing `eza`.
if [[ -r ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh ]]; then
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
        source ${HOMEBREW_PREFIX}/opt/zimfw/share/zimfw.zsh init
    fi
    [[ -r ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh
else
    print -u2 "zshrc: zimfw not installed — run 'brew install zimfw' (starting without plugins)"
fi

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

# mise — hook mode: runs hook-env each prompt (cached; recomputes only when the
# config or working directory changes) so [tools] AND [env] apply to the shell.
# Needed because [env] like AWS_PROFILE must reach non-mise binaries (e.g. the aws
# CLI) and be visible in the shell/prompt, not just mise-managed shims.
if [[ -x "${HOME}/.local/bin/mise" ]]; then
    eval "$("${HOME}/.local/bin/mise" activate zsh)"
fi

# starship
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

# fzf
if (( $+commands[fzf] )); then
    source <(fzf --zsh)
fi

# zoxide
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# ── Aliases ────────────────────────────────────────────────

# System update function
function update_system() {
    # Plain `brew update`: --auto-update suppresses tap fetch errors and the
    # status line (Homebrew cmd/update.sh), which hides failures in a manual run.
    brew update
    brew upgrade --greedy -y
    zimfw update && zimfw upgrade
    brew cleanup
    mise self-update -y && mise up
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

# Modern CLI tool aliases (guarded so a fresh machine keeps working defaults)
if (( $+commands[eza] )); then
    alias ls="eza --icons=auto --group-directories-first --git"
    alias ll="eza -l --git --icons=auto"
    alias lt="eza -l --tree --icons=auto"
fi
if (( $+commands[bat] )); then
    alias cat="bat"
fi
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
