export DOTRC_ZSH="$HOME/dotrc/zsh"

eval "$(starship init zsh)"

# User configuration
source $DOTRC_ZSH/zplug.zsh
source $DOTRC_ZSH/aliases.zsh
source $DOTRC_ZSH/env.zsh
