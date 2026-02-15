# 전역환경 환경변수 용

# Set ZDOTDIR
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}
export DOTRCDIR=${DOTRCDIR:-$XDG_CONFIG_HOME/dotrc}

# Homebrew prefix (for opt/ references)
export HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-/opt/homebrew}

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
