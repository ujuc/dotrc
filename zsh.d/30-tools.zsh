# External tools initialization
# Tools with lazy loading for performance

# starship (always load - needed for prompt)
if (( $+commands[starship] )); then
    _evalcache starship init zsh
fi

# fzf
# Note: fzf init is fast (~10ms), so eager loading is fine
# For lazy loading, uncomment the lazy version in comments below
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
