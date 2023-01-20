export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", defer:2, as:plugin
zplug "zsh-users/zsh-autosuggestions", as:plugin

zplug load
