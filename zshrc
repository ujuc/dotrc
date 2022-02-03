export DOTRC_ZSH="$HOME/dotrc/zsh"

eval "$(starship init zsh)"

# User configuration
if (( $+commands[zplug] )); then
  source $DOTRC_ZSH/zplug.zsh
fi

source $DOTRC_ZSH/aliases.zsh
source $DOTRC_ZSH/env.zsh
