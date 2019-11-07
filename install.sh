#!/usr/bin/env bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#   Version : 2.0           #
#############################

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function symlink_rc() {
    ln -sf $BASE/$1 $HOME/.$1
}

function install_shell() {
    brew install zplug starship
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
    brew install git git-flow-avh

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
    brew cask install keybase gpg-suite

    keybase pgp export | gpg --import
    keybase pgp export --secret | gpg --allow-secret-key-import --import

    keyid=`gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | awk -F "[/]" '{print $2}'`
    git config --global user.signingkey $keyid
    git config --global commit.gpgsign true
    git config --global gpg.program gpg2

    # Register Tower
    echo no-tty >> ~/.gnupg/gpg.conf
    git config --global gpg.program ${which gpg}
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

    # poetry
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

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
    brew tap homebrew/cask-fonts
    brew cask install font-iosevka font-fira-code font-noto-sans-cjk font-noto-serif-cjk \
        font-ibm-plex

    # Add package
    brew install fd

    # install shell program
    install_shell

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

# Todo: Settings snap
function setting_ubuntu() {
}

# Todo: ???
function setting_redhat() {
}

# Todo: Settings Jguer/yay
function setting_arch() {
}

function bootstrap() {
    # os check
    #if [[ "$OSTYPE" == "darwin"* ]]; then
    setting_mac
    #elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    #    name=`cat /etc/*-release | grep '_ID'`

    #    if [[ "$name" == *"Ubuntu"* ]]; then
    #        setting_ubuntu
    #    else
    #        echo "Not checked"
    #    fi
    #else
    #    echo "Not checked"
    #fi
}

bootstrap

