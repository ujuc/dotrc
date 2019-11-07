#!/usr/bin/env bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#   Version : 3.0           #
#############################

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function symlink_rc() {
    ln -sf $BASE/$1 $HOME/.$1
}

function install_shell() {
    brew install zplug starship
    symlink_rc zshrc
    zplug install
    mkdir $HOME/.zfunc
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

    # install vim plugins
    vi +PlugInstall +qall

    # vim theme
	ln -sf $HOME/.vim/plugged/seoul256.vim/colors/seoul256.vim $HOME/.vim/colors
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
}

function install_python() {
    # pyenv
    brew install pyenv
    pyenv install 3.8.0
    pyenv global 3.8.0

    # poetry
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
    source $HOME/.poetry/env
    poetry completions zsh > ~/.zfunc/_poetry
}

function install_go() {
    brew install go
}

function install_rust() {
    # https://github.com/rust-lang/rustup.rs/blob/master/README.md
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    rustup completions zsh > ~/.zfunc/_rustup
}

function install_mac_app() {
    brew cask install google-chrome google-drive-file-stream iterm2 alfred \
        jetbrains-toolbox visual-studio-code 1password tower paw slack notion \
        docker

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

    install_shell
    install_fzf
    install_vim
    install_git
    install_tig
    install_python
    install_go
    install_rust
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

