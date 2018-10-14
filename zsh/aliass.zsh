# vi path setting
alias vi="vim"

################################

if [[ $(uname -s) == "Darwin" ]]; then
    # OS X
    alias install="brew install"
    alias uninstall="brew uninstall --force"
    alias search="brew search"
    alias info="brew info"
    alias list="brew list"
    alias cask="brew cask"
    alias update="brew update; brew upgrade; zplug update; cd ~/.vim_runtime; git pull --rebase; vi +PlugUpdate +qall; vim +PlugUpgrade +qall"
    alias cleanup="brew cleanup"
else
    DISTRO_ID=$(python -c "import distro; print(distro.id())")

    if [[ $DISTRO_ID == "ubuntu" ]]; then
        alias update="sudo apt update; sudo apt full-upgrade"
        alias install="sudo apt install -y"
        alias uninstall="sudo apt purge -y"
        alias search="sudo apt search"
        alias info="sudo apt show"
        alias cleanup="sudo apt autoremove -y"
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
fi

# help
help_command="""
$fg_bold[blue]# OS X
$fg_bold[red]* install: $fg_bold[white]brew install
$fg_bold[red]* uninstall: $fg_bold[white]brew uninstall --force
$fg_bold[red]* search: $fg_bold[white]brew search
$fg_bold[red]* info: $fg_bold[white]brew info
$fg_bold[red]* list: $fg_bold[white]brew list
$fg_bold[red]* update: $fg_bold[white]brew update; brew upgrade
$fg_bold[red]* cleanup: $fg_bold[white]brew clenaup

$fg_bold[blue]# Ubuntu
$fg_bold[red]* update: $fg_bold[white]sudo apt-get update; sudo apt-get dist-upgrade
$fg_bold[red]* install: $fg_bold[white]sudo apt-get install -y
$fg_bold[red]* uninstall: $fg_bold[white]sudo apt-get purge -y
$fg_bold[red]* search: $fg_bold[white]sudo apt-cache search
$fg_bold[red]* info: $fg_bold[white]sudo apt-cahce show
$fg_bold[red]* cleanup: $fg_bold[white]sudo apt-get autoremove -y
$fg_bold[red]* add_repo: $fg_bold[white]sudo add-apt-repository
$fg_bold[red]* rm_reop: $fg_bold[white]sudo add-apt-repository -r
"""

alias help_shell='echo ${help_command}'
