# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

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

# asdf
if (( $+commands[asdf] )); then
    . $(brew --prefix asdf)/libexec/asdf.sh
fi

## JAVA_HOME 설정
if (( $+commands[java] )); then
    . $HOME/.asdf/plugins/java/set-java-home.zsh
fi

# Aliases
alias bwu="brew update; brew upgrade; zplug update"
alias bws="brew search"
alias bwi="brew install"

alias ls="lsd"
alias ll="lsd -l"
alias lt="lsd --tree"
alias cat="bat"
alias vi="vim"

# work
alias tf="terraform"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
