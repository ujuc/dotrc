#!/bin/bash -x

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

    if [ $(uname -s) = "Darwin" ]; then
        [ -z "$(which brew)" ] && ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        [ -z "$(which brew-cask)" ] && brew install caskroom/cask/brew-cask
        brew install tig tmux python python3 zsh
        brew install vim --with-cscope --with-lua --override-system-vim
        #brew tap neovim/neovim
        #brew install --HEAD neovim
        brew cask install caskroom/fonts/font-hack
    elif [ $(uname -s) = "Linux" ]; then
        sudo apt-get -y install ctags vim tig tmux zsh python python3 curl
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
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    ln -sf $BASE/zshrc ~/.zshrc
    chsh -s /bin/zsh

    # bullet-train theme setting
    printMessage "\nbullet-train"
    git clone https://github.com/caiogondim/bullet-train-oh-my-zsh-theme.git ~/base_git/bullet-train
    ln -sf ~/base_git/bullet-train/bullet-train.zsh-theme ~/.oh-my-zsh/themes/bullet-train.zsh-theme

    # Setting powerline font
    printMessage "\nPowerline Font"
    git clone git@github.com:powerline/fonts.git ~/base_git/powerline_font
    bash ~/base_git/powerline_font/install.sh

    # zsh-syntax-highlighting setting
    mkdir -p ~/.oh-my-zsh/custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

    source ~/.zshrc
}

function settingVim() {
	# Link plug
	mkdir -p ~/.vim/autoload
    mkdir ~/.vim/vimundo
	ln -sf $BASE/vim-plug/plug.vim ~/.vim/autoload/plug.vim

    # Bundle
    #sudo pip install flake8 flake8-docstings
    #sudo gem install reek
    ln -sf $BASE/vimrcs ~/.vim/vimrcs
	ln -sf $BASE/vimrc ~/.vimrc
    # Neovim setting
    ln -s ~/.vim ~/.nvim
    ln -s ~/.vimrc ~/.vimrc
    ln -sf /usr/local/bin/vim /usr/local/bin/vi

    # Install Plugins
	vi +PlugInstall +qall

    # linked theme
    mkdir -p ~/.vim/colors
    ln -sf ~/.vim/plugged/sourcerer.vim/colors/sourcerer.vim ~/.vim/colors/sourcerer.vim
}


case $FUNC in 
    "all")
        installSystemPackage
        settingSubmodule
        settingTmux
        settingZsh
        settingVim
        ;;
    "vim")
        settingSubmodule
        settingVim
        ;;
    * )
    	exit
    	;;
esac

/* vim: noai:ts=4:sw=4
