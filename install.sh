#!/usr/bin/env bash

# 전역 변수
BASE="${0:A:h}"

function reload_zsh() {
    # reload zsh
    env zsh -l
}

# install xcode cli tools
xcode-select --install

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install fzf
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install --no-bash --no-fish

# install applications
brew install --cask google-drive-file-stream dozer raycast logitech-options \
    firefox visual-studio-code iterm2-beta

# home mac
# Snapscan Home
# open http://scansnap.fujitsu.com/global/dl/mac-1014-ix500.html

# Setup shell
# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# insall zplug
brew install zplug

ln -sf $BASE/zshrc ~/.zshrc
reload_zsh

zplug install
reload_zsh



# function symlink_rc() {
#     ln -sf $BASE/$1 $HOME/.$1
# }

# function install_lang() {
#     asdf plugin-add $1
#     asdf install $1 latest

#     asdf_plugin_version=`asdf lastest $1`
#     asdf global $1 $asdf_plugin_version
# }

# function install_vim() {
#     brew install neovim

#     curl -sLf https://spacevim.org/install.sh | bash
#     synlink_rc SpaceVim.d/init.toml

#     npm install --global vscode-html-languageserver-bin
#     npm -g install remark remark-cli remark-stringify remark-frontmatter wcwidth \
#         prettier
# }

# function config_git() {
#     brew install git-flow-avh

#     cargo install git-delta

#     # git config
#     git config --global user.email "ujuc@ujuc.me"
#     git config --global user.name "Thomas Sungjin Kang"

#     git config --global core.editor vi
#     git config --global core.autocrlf input
#     git config --global core.whitespace fix,-indent-with-non-tab,trailing-space,cr-at-eol
#     git conifg --global core.pager delta
#     git config --global init.defaultBranch main

#     git config --global commit.template $BASE/gitmessage

#     git config --global color.ui auto

#     git config --global interactive.diffFilter 'delta --color-only'
#     git config --global delta.features 'side-by-side line-numbers decorations'
#     git config --global delta.whitespace-error-style '22 reverse'
#     git config --global delta.decorations.commit-decoration-style 'bold yellow box ul'
#     git config --global delta.decorations.file-style 'bold yellow ul',
#     git config --global delta.decorations.file-decoration-style none

#     symlink_rc gitmessage

#     # gpgkey settings
#     brew install gpg
#     brew cask install keybase gpg-suite
# }

# function set_gpgkey() {
#     keybase pgp export | gpg --import
#     keybase pgp export --secret | gpg --allow-secret-key-import --import

#     keyid=`gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | awk -F "[/]" '{print $2}'`
#     git config --global user.signingkey $keyid
#     git config --global commit.gpgsign true
#     echo no-tty >> ~/.gnupg/gpg.conf
#     git config --global gpg.program gpg2
# }

# function install_tig() {
#     brew install tig
#     symlink_rc tigrc
# }

# function install_poetry() {
#     curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python
#     source $HOME/.poetry/env
#     poetry completions zsh > ~/.zfunc/_poetry
# }

# function install_node() {
#     asdf plugin-add nodejs
#     bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
#     asdf install node latest

#     asdf_node_version=`asdf latest nodejs`
#     asdf global nodejs $asdf_node_version

#     npm i -g yarn
# }

# function install_asdf() {
#     brew install asdf \
#         readline libxslt unzip curl
# }

# function install_rust() {
#     curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# }
# function install_golang() {
#     brew install go
# }

# function setting_mac() {
    

#     # install font
#     brew tap homebrew/cask-fonts
#     brew cask install font-noto-sans-cjk font-noto-serif-cjk \
#         font-ibm-plex font-blexmono-nerd-font

#     install_tig

#     install_asdf
#     install_shell

#     # Program language env
#     install_lang python
#     install_poetry
#     install_node
#     install_golang
#     install_rust

#     config_git

#     install_vim
#     install_fzf
#     install_mac_app
# }

# function bootstrap() {
#     setting_mac
# }

# bootstrap
