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

    mkdir -p $HOME/.vim/vimundo
    mkdir -p $HOME/.vim/colors

    # vim plug
    curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    ln -sf $BASE/vimrcs $HOME/.vim/vimrcs
    symlink_rc vimrc

    # install fzf
    install_fzf

    # install vim plugins
    vi +PlugInstall +qall

    # vim theme
	ln -sf $HOME/.vim/plugged/seoul256.vim/colors/seoul256.vim $HOME/.vim/colors
}

function install_tmux() {
    brew install tmux
    symlink_rc tmux.conf
}

function install_git() {
    brew install git

    # git config
    git config --global user.email "ujuc@ujuc.kr"
    git config --global user.name "Thomas Sungjin Kang"

    git config --global core.editor vim
    git config --global core.autocrlf input
    git config --global core.whitespace fix, -indent-with-non-tab,trailing-space,cr-at-eol

    git config --global color.ui auto
    git config --global diff.tool vimdiff
    git config --global difftool.prompt false

    git config --global gitreview.username sungjin

    # gpgkey settings
    brew install gpg
    brew cask intall keybase gpg-suite

    keybase pgp export | gpg --import
    keybase pgp export --secret | gpg --allow-secret-key-import --import

    keyid=`gpg --list-secret-keys --keyid-format LONG | grep sec | aws '{print $2}' | awk -F "[/]" '{print $2}'`
    git config --global user.signingkey $keyid
    git config --global commit.gpgsign true
    echo no-tty >> ~/.gnupg/gpg.conf
    git config --global gpg.program ${which gpg}

    set_git_alias
}

function set_git_alias() {

}

function install_tig() {
    brew install tig
    symlink_rc tigrc
}

function install_fzf() {
    brew install fzf
    $(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
    source $HOME/.zshrc

    gem install rouge
}

function install_python() {
    # pyenv
    brew install pyenv
    source $HOME/.zshrc

    # pipenv
    #brew install pipenv
}

function install_go() {
    brew install go
}

function install_mac_app() {
    brew cask install google-chrome google-drive-file-stream
    brew cask install iterm2 alfred
    brew cask install jetbrains-toolbox
    brew cask install visual-studio-code
    brew cask install 1password
    brew cask install tower
    brew cask install paw
    brew cask install slack notion timing

    # docker desktop
    open https://store.docker.com/editions/community/docker-ce-desktop-mac
    # Snapscan Home
    open http://scansnap.fujitsu.com/global/dl/mac-1014-ix500.html
    # istate
    open https://bjango.com/mac/istatmenus/
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
        font-noto-mono font-ibm-plex font-inter-ui

    # Add package
    brew install bat fd

    # install zsh
    install_zsh

    # install vim
    install_vim

    # install tmux
    install_tmux

    # install git
    install_git

    # install tig
    install_tig

    # install python
    install_python

    # install go
    install_go

    # install mac app
    install_mac_app
}

function setting_ubuntu() {
    # install linux brew
    sudo apt-get install build-essential curl file git
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
}

function setting_redhat() {
    # install linux brew
    sudo yum groupinstall 'Development Tools' && sudo yum install curl file git
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
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
