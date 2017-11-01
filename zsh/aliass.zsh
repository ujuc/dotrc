# vi path setting
alias vi="vim"

alias custom_update="zplug update; cd ~/.vim_runtime; git pull --rebase; vi +PlugUpdate +qall; vim +PlugUpgrade +qall"

################################

DISTRO_ID=$(python -c "import distro; print(distro.id())")

if [[ $(uname -s) == "Darwin" ]]; then
    # OS X
    alias install="brew install"
    alias uninstall="brew uninstall --force"
    alias search="brew search"
    alias info="brew info"
    alias blist="brew list"
    alias cask="brew cask"
    alias update="brew update; brew upgrade"
    alias upip="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U"
elif [[ $DISTRO_ID == "ubuntu" ]]; then
    alias install="sudo apt install -y"
    alias uninstall="sudo apt purge -y"
    alias search="sudo apt search"
    alias info="sudo apt show"
    alias update="sudo apt update; sudo apt full-upgrade"
    alias clean="sudo apt autoremove -y"
    alias add_repo="sudo add-apt-repository"
    alias rm_reop="sudo add-apt-repository -r"
elif [[ $DISTRO_ID == "manjaro" ]]; then
    # Manjaro
    alias install="yaourt -S"
    alias uninstall="yaourt -Rns"
    alias search="yaourt -Ss"
    alias info="yaourt -Si"
    alias update="yaourt -Syu"
fi

# help
help_command="""
$fg_bold[blue]# OS X
$fg_bold[red]* install: $fg_bold[white]brew install
$fg_bold[red]* uninstall: $fg_bold[white]brew uninstall --force
$fg_bold[red]* search: $fg_bold[white]brew search
$fg_bold[red]* info: $fg_bold[white]brew info
$fg_bold[red]* blist: $fg_bold[white]brew list
$fg_bold[red]* update: $fg_bold[white]brew update; brew upgrade
$fg_bold[red]* upip: $fg_bold[white]pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U

$fg_bold[blue]# Ubuntu
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
