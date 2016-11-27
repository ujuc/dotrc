#!/usr/bin/env bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#############################

BASE=$(pwd)
FUNC=$1

function printMessage() {
    echo -e "\e[1;37m# $1\033[0m"
}

function installSystemPackage() {
    printMessage "\nInstall defualt"

    linux=`cat /etc/*-release | grep '_ID'`

    if [ $(uname -s) = "Darwin" ]; then
        [ -z "$(which brew)" ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        [ -z "$(which brew-cask)" ] && brew install caskroom/cask/brew-cask
        brew install tig tmux python python3 zsh git
        brew install vim --with-cscope --with-lua --override-system-vim
        brew cask install caskroom/fonts/font-hack
    elif [ $(uname -s) = "Linux" ]; then
        if [[ $linux == *ManjaroLinux* ]]; then
            yaourt -S vim tig tmux zsh openssh
        elif [[ $linux == *Ubuntu* ]]; then
            sudo apt install -y vim tig tmux zsh
        fi
    fi
}

function settingTmux() {
    printMessage "\nSetting tmux"
    ln -sf $BASE/tmux.conf ~/.tmux.conf
    tmux source-file ~/.tmux.conf
}

function settingSubmodule () {
    git submodule init
    git submodule update
}

function settingZsh() {
    printMessage "\nSetting zsh"

    # zshrc setting
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    mkdir -p ~/.oh-my-zsh/custom/themes
    # custom zshrc themes
    ln -sf $BASE/spaceship-zsh-theme/spaceship.zsh ~/.oh-my-zsh/custom/themes/spaceship.zsh-theme

    ln -sf $BASE/zshrc ~/.zshrc
    #chsh -s /bin/zsh

    # Setting powerline font
    printMessage "\nPowerline Font"
    bash $BASE/fonts/install.sh

    # zsh-syntax-highlighting setting
    mkdir -p ~/.oh-my-zsh/custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    source ~/.zshrc
}

function settingVim() {
    # Link plug
    mkdir -p ~/.vim/autoload
    mkdir ~/.vim/bundle
    mkdir ~/.vim/vimundo
    ln -sf $BASE/vim-plug/plug.vim ~/.vim/autoload/plug.vim

    # Bundle
    #sudo pip install flake8 flake8-docstings
    #sudo gem install reek
    ln -sf $BASE/vimrcs ~/.vim/vimrcs
    ln -sf $BASE/vimrc ~/.vimrc
    #ln -sf /usr/local/bin/vim /usr/local/bin/vi

    # linked theme
    mkdir -p ~/.vim/colors
    ln -sf ~/.vim/plugged/sourcerer.vim/colors/sourcerer.vim ~/.vim/colors/sourcerer.vim

    # Install vim theme
    ln -sf $BASE/vim/autoload/airline ~/.vim/autoload
    git clone https://github.com/kristijanhusak/vim-hybrid-material.git $HOME/.vim/bundle/vim-hybrid-material
    # Install YCM
    git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
    cd ~/.vim/bundle
    git submodule update --init --recursive
    ~/.vim/bundle/YouCompleteMe/install.py --all

    # Install Plugins
    vi +PlugInstall +qall
}

case $FUNC in 
    "all")
        installSystemPackage
        settingSubmodule
        settingTmux
        settingZsh
        settingVim
        ;;
    "install")
        installSystemPackage
        ;;
    "submodule")
        settingSubmodule
        ;;
    "zsh")
        settingZsh
        ;;
    "vim")
        settingVim
        ;;
    "tmux")
        settingTmux
        ;;
   * )
        exit
        ;;
esac

#/* vim: noai:ts=4:sw=4
