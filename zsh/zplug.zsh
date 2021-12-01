export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-syntax-highlighting", as:plugin
zplug "zsh-users/zsh-autosuggestions", as:plugin

zplug load
