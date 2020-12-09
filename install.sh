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

function install_lang() {
    asdf plugin-add $1
    asdf install $1 latest

    asdf_plugin_version=`asdf lastest $1`
    asdf global $1 $asdf_plugin_version
}

function install_shell() {
    brew install zplug starship
    symlink_rc zshenv
    symlink_rc zshrc
    source $HOME/.zshrc
    zplug install
    mkdir $HOME/.zfunc
}

function install_vim() {
    brew install neovim

    curl -sLf https://spacevim.org/install.sh | bash
    synlink_rc SpaceVim.d/init.toml

    npm install --global vscode-html-languageserver-bin
    npm -g install remark remark-cli remark-stringify remark-frontmatter wcwidth \
        prettier
}

function config_git() {
    brew install git-flow-avh

    cargo install delta

    # git config
    git config --global user.email "ujuc@ujuc.me"
    git config --global user.name "Thomas Sungjin Kang"

    git config --global core.editor vi
    git config --global core.autocrlf input
    git config --global core.whitespace fix,-indent-with-non-tab,trailing-space,cr-at-eol
    git conifg --global core.pager delta

    git config --global commit.template $BASE/gitmessage

    git config --global color.ui auto

    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.features 'side-by-side line-numbers decorations'
    git config --global delta.whitespace-error-style '22 reverse'
    git config --global delta.decorations.commit-decoration-style 'bold yellow box ul'
    git config --global delta.decorations.file-style 'bold yellow ul',
    git config --global delta.decorations.file-decoration-style none

    git config --global gitreview.username sungjin

    symlink_rc gitmessage

    # gpgkey settings
    brew install gpg
    brew cask install keybase gpg-suite
}

function set_gpgkey() {
    keybase pgp export | gpg --import
    keybase pgp export --secret | gpg --allow-secret-key-import --import

    keyid=`gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | awk -F "[/]" '{print $2}'`
    git config --global user.signingkey $keyid
    git config --global commit.gpgsign true
    echo no-tty >> ~/.gnupg/gpg.conf
    git config --global gpg.program gpg2
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

function install_poetry() {
    curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
    source $HOME/.poetry/env
    poetry completions zsh > ~/.zfunc/_poetry
}

function install_node() {
    asdf plugin-add nodejs
    bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
    asdf install node latest

    asdf_node_version=`asdf latest nodejs`
    asdf global nodejs $asdf_node_version

    npm i -g yarn
}

function install_mac_app() {
    brew tap homebrew/cask-versions
    brew cask install google-drive-file-stream iterm2 alfred \
        jetbrains-toolbox visual-studio-code-insiders slack \
        docker corretto

    # Snapscan Home
    open http://scansnap.fujitsu.com/global/dl/mac-1014-ix500.html
    # istate
    open https://bjango.com/mac/istatmenus/
}

function install_asdf() {
    brew install asdf \
        readline libxslt unzip curl
}

function install_hammerspoon() {
    brew cask install hammerspoon
    symlink_rc hammerspon
}

function install_spacemacs() {
    brew install emacs
    synlink_rc spacemacs
    git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
}

function install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}
function install_golang() {
    brew install go
}

function setting_mac() {
    # configure xcode
    xcode-select --install

    # install brew
    /usr/bin/ruby -e \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

    # install font
    brew tap homebrew/cask-fonts
    brew cask install font-noto-sans-cjk font-noto-serif-cjk \
        font-ibm-plex font-blexmono-nerd-font

    install_tig

    install_asdf
    install_shell

    # Program language env
    install_lang python
    install_poetry
    install_node
    install_golang
    install_rust

    config_git

    install_vim
    install_spacemacs
    install_fzf
    install_mac_app
    install_hammerspoon
}

function bootstrap() {
    setting_mac
}

bootstrap

