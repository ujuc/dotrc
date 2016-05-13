# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="bullet-train"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completionZ
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

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

#
# rbenv
if type rbenv > /dev/null; then
    export RBENV_ROOT=/usr/local/var/rbenv
    eval "$(rbenv init -)"
fi

#
# NVM
if type nvm > /dev/null; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

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
    alias update="brew update; brew upgrade; brew cask update"
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
