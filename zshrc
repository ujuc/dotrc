export DOTRC="${HOME}/dotrc"
export DOTRC_ZSH="${DOTRC}/zsh"


eval "$(starship init zsh)"

# User configuration
source $DOTRC_ZSH/zplug.zsh
source $DOTRC_ZSH/aliases.zsh
source $DOTRC_ZSH/env.zsh
