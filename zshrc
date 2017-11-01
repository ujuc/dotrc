# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export RC_ZSH=$HOME/dotrc/zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
TERM=xterm-256color

source $RC_ZSH/zplug.zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="powerlevel9k"

source $RC_ZSH/theme.zsh

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting git-flow git-extras)

# User configuration
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh
source $RC_ZSH/env.zsh

# Bind key settings
bindkey "ee[D" backward-word
bindkey "ee[C" forward-word

source $RC_ZSH/aliass.zsh
