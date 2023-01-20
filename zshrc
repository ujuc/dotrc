# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export DOTRC="${HOME}/dotrc"
export DOTRC_ZSH="${DOTRC}/zsh"

eval "$(starship init zsh)"

# User configuration
source $DOTRC_ZSH/zplug.zsh
source $DOTRC_ZSH/aliases.zsh
source $DOTRC_ZSH/env.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Get the aliases and functions for Kurly Kubernetes Config
[[ ! -f ~/.zshrc.kurly ]] || source ~/.zshrc.kurly

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /Users/122d6405/.asdf/installs/terraform/1.3.7/bin/terraform terraform

