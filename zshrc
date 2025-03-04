# Zplug
source $(brew --prefix zplug)/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2, as:plugin
zplug "zsh-users/zsh-autosuggestions", as:plugin

zplug load

## ENV
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/dotrc/starship/config.toml"

# asdf
if (($ + commands[asdf])); then
    export ASDF_DATA_DIR=$HOME/.asdf
    export PATH="${ASDF_DATA_DIR}/shims:${PATH}"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# work
[ -f ~/.zshrc.work ] && source ~/.zshrc.work

function update_system() {
    brew update
    brew upgrade
    zplug update
    gh ext upgrade --all
    brew cleanup

    if (($ + commands[asdf])); then
        asdf plugin update --all
    fi
}

# Aliases
alias update=update_system
alias bws="brew search"
alias bwi="brew install"

alias ls="lsd"
alias ll="lsd -l"
alias lt="lsd --tree"
alias cat="bat"
alias vi="vim"
