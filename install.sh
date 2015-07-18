#!/bin/bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#############################

BASE=$(pwd)

function printMessage() {
    echo -e "\e[1;37m# $1\033[0m"
}

function installSystemPackage() {
    printMessage "\nInstall defualt"

    if [ $(uname -s) = "Darwin" ]; then
        [ -z "$(which brew)" ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        [ -z "$(which brew-cask)" ] && brew install caskroom/cask/brew-cask
        brew install ctags git tig tmux zsh python python3 curl
        brew install vim --with-cscope --with-lua --override-system-vim
    elif [ $(uname -s) = "Linux" ]; then
        sudo apt-get -y install ctags vim tig tmux zsh python python3 curl
    fi
}

function settingTmux() {
    printMessage "\nSetting tmux"
    ln -sf $BASE/tmux.conf ~/.tmux.conf
    git clone https://github.com/erikw/tmux-powerline.git ~/.vim/tmux-powerline
    tmux source-file ~/.tmux.conf
}

function settingZsh() {
    printMessage "\nSetting zsh"

    # zshrc setting
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    ln -sf $BASE/zshrc ~/.zshrc
    chsh -s /bin/zsh

    # bullet-train theme setting
    printMessage "\nbullet-train"
    git clone https://github.com/caiogondim/bullet-train-oh-my-zsh-theme.git ~/base_git/bullet-train
    ln -sf ~/base_git/bullet-train/bullet-train.zsh-theme ~/.oh-my-zsh/themes/bullet-train.zsh-theme

    # zsh-syntax-highlighting setting
    mkdir -p ~/.oh-my-zsh/custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    source ~/.zshrc
}

function settingVim() {
    bash <(curl -L https://raw.githubusercontent.com/kepbod/ivim/master/setup.sh) -i

    # Bundle
    ln -sf $BASE/vimrc.bundles.local ~/.vimrc.bundles.local

    sudo pip install flake8 flake8-docstings
}

installSystemPackage
settingTmux
settingZsh
