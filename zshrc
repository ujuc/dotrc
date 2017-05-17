# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="spaceship"

# Theme settings
SPACESHIP_TIME_SHOW=true


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting git-flow git-extras)

# User configuration
export PATH="/usr/local/sbin:/usr/local/bin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

if type go > /dev/null; then
    # Go Path
    export GOROOT=`go env GOROOT`
    export GOPATH="$HOME/repos/go"
    export PATH=$PATH:/usr/local/opt/go/libexec/bin
    export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"
fi

# NVM
if type nvm > /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

# Linux brew
if [ $(uname -s) = "Linux" ]; then
    export PATH="$HOME/.linuxbrew/bin:$PATH"
    export MANPATH="$MONE/.linuxbrew/share/man:$MANPATH"
    export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
fi

source $ZSH/oh-my-zsh.sh

# vi path setting
alias vi="vim"

if [ $(uname -s) = "Darwin" ]; then
    # OS X
    alias install="brew install"
    alias uninstall="brew uninstall --force"
    alias search="brew search"
    alias info="brew info"
    alias blist="brew list"
    alias cask="brew cask"
    alias update="brew update; brew upgrade"
    alias upip="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U"
elif [ $(lsb_release -a | grep Description | awk '{print $2}') = "Manjaro" ]; then
    # Manjaro
    alias install="yaourt -S"
    alias uninstall="pacman -Rns"
    alias search="pacman -Ss"
    alias info="pacman -Si"
    alias update="pacman -Syu"
elif [ $(lsb_release -a | grep Description | awk '{print $2}') = "Ubuntu" ]; then
    # Ubuntu
    alias install="sudo apt-get install -y"
    alias uninstall="sudo apt-get purge -y"
    alias search="sudo apt-cache search"
    alias info="sudo apt-cahce show"
    alias update="sudo apt-get update; sudo apt-get dist-upgrade"
    alias clean="sudo apt-get autoremove -y"
    alias add_repo="sudo add-apt-repository"
    alias rm_reop="sudo add-apt-repository -r"
fi

# help
help_command="""
$fg_bold[white]# OS X
$fg_bold[red]* install: $fg_bold[white]brew install
$fg_bold[red]* uninstall: $fg_bold[white]brew uninstall --force
$fg_bold[red]* search: $fg_bold[white]brew search
$fg_bold[red]* info: $fg_bold[white]brew info
$fg_bold[red]* blist: $fg_bold[white]brew list
$fg_bold[red]* update: $fg_bold[white]brew update; brew upgrade
$fg_bold[red]* upip: $fg_bold[white]pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U

$fg_bold[white]# Ubuntu
$fg_bold[red]* uupdate: $fg_bold[white]sudo apt-get update; sudo apt-get dist-upgrade
$fg_bold[red]* install: $fg_bold[white]sudo apt-get install -y
$fg_bold[red]* uninstall: $fg_bold[white]sudo apt-get purge -y
$fg_bold[red]* search: $fg_bold[white]sudo apt-cache search
$fg_bold[red]* info: $fg_bold[white]sudo apt-cahce show
$fg_bold[red]* clean: $fg_bold[white]sudo apt-get autoremove -y
$fg_bold[red]* update: $fg_bold[white]sudo apt-get update; sudo apt-get dist-upgrade
$fg_bold[red]* add_repo: $fg_bold[white]sudo add-apt-repository
$fg_bold[red]* rm_reop: $fg_bold[white]sudo add-apt-repository -r
"""
alias ujuc_help='echo ${help_command}'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

test -e ${HOME}/.iterm2_shell_integration.zsh && source ${HOME}/.iterm2_shell_integration.zsh

# Bind key settings
bindkey "ee[D" backward-word
bindkey "ee[C" forward-word

TERM=xterm-256color

source $HOME/.pyenv 2> /dev/null
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
source $HOME/.rbenv 2> /dev/null
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Autoenv
source $(brew --prefix autoenv)/activate.sh

eval $(/usr/libexec/path_helper -s)
