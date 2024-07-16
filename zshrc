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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# deno
if [ -f "$HOME/.deno/bin/deno" ]; then
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# asdf
if (( $+commands[asdf] )); then
    . $(brew --prefix asdf)/libexec/asdf.sh
fi

# work
[ -f ~/.zshrc.work ] && source ~/.zshrc.work

function update_system() {
    brew update
    brew upgrade
    zplug update
    gh ext upgrade --all
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
