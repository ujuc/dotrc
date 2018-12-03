#!/usr/bin/env bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#   Version : 2.0           #
#############################

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function symlink_rc() {
    ln -sf $BASE/templates/$1 $HOME/.$1
}

function install_zsh() {
    brew install zsh zplug
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    symlink_rc zshrc
    zplug install
    source ~/.zshrc
}

function install_vim() {
    brew install vim

    mkdir -p $HOME/.vim/bundle
    mkdir -p $HOME/.vim/vimundo
    midir -p $HOME/.vim/colors
    
    # vim plug
    curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    # amix/vimrc
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh

    ln -sf $BASE/vimrcs $HOME/.vim/vimrcs
    symlink_rc vimrc

    # TODO: remove all plugins settings for YCM
    # ycm
    # https://github.com/Valloric/YouCompleteMe#full-installation-guide

    # install vim plugins
    vi +PlugInstall +qall
}

function setting_mac() {
    # configure xcode
    xcode-select --install
    sudo xcodebuild -license

    # install brew
    [ -z "$(witch brew)" ] && \
        /usr/bin/ruby -e \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # install font
    brew cask install font-hack font-hack-nerd-font font-hack-nerd-font-mono \
        font-iosevka font-iosevka-nerd-font font-iosevka-nerd-font-mono \
        font-fira-code font-firacode-nerd-fonnt font-firacode-nerd-font-mono \
        font-noto-sans-cjk font-noto-sans font-noto-serif font-not-serif-cjk \
        font-noto-mono

    # install zsh
    install_zsh

    # install vim
    install_vim
}

function setting_ubuntu() {

}

function setting_redhat() {

}

function setting_arch() {

}

function bootstrap() {
    # os check
    if [[ "$OSTYPE" == "darwin"* ]]; then
        setting_mac
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        name=`cat /etc/*-release | grep '_ID'`

        if [[ "$name" == *"Ubuntu"* ]]; then
            setting_ubuntu
        else
            echo "Not checked"
        fi
    else
        echo "Not checked"
    fi
}

bootstrap

#/* vim: noai:ts=4:sw=4
