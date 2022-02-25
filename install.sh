#!/usr/bin/env bash

# 전역 변수
#BASE="${0:A:h}"
BASE=${HOME}/dotrc

function reload_zsh() {
    # reload zsh
    env zsh -l
}

function symlink_rc() {
    ln -sf $BASE/$1 $HOME/.$1
}

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle

# home mac
# Snapscan Home
# open http://scansnap.fujitsu.com/global/dl/mac-1014-ix500.html

# Setup shell
symlink_rc zshrc
zplug install

# install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install --no-bash --no-fish

# Install spacevim
curl -sLf https://spacevim.org/install.sh | bash
ln -sf $BASE/spacevim $HOME/.SpaceVim.d

# git setup
git config --global user.email "ujuc@ujuc.me"
git config --global user.name "sungjin.kang"

git config --global core.editor vi
git config --global core.autocrlf input
git config --global core.whitespace fix,-indent-with-non-tab,trailing-space,cr-at-eol
git conifg --global core.pager delta
git config --global init.defaultBranch main

git config --global commit.template $BASE/gitmessage

git config --global color.ui auto

git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.features 'side-by-side line-numbers decorations'
git config --global delta.whitespace-error-style '22 reverse'
git config --global delta.decorations.commit-decoration-style 'bold yellow box ul'
git config --global delta.decorations.file-style 'bold yellow ul',
git config --global delta.decorations.file-decoration-style none

# tig setup
symlink_rc tigrc

# poetry setup
source $HOME/.poetry/env
poetry completions zsh > ~/.zfunc/_poetry

# language setup
langs=("deno" "golang" "nodejs" "python" "rust")
for lang in "${langs[@]}"; do
    asdf plugin add $lang
    asdf install $lang latest
    asdf global $lang latest
done

# function set_gpgkey() {
#     keybase pgp export | gpg --import
#     keybase pgp export --secret | gpg --allow-secret-key-import --import

#     keyid=`gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | awk -F "[/]" '{print $2}'`
#     git config --global user.signingkey $keyid
#     git config --global commit.gpgsign true
#     echo no-tty >> ~/.gnupg/gpg.conf
#     git config --global gpg.program gpg2
# }
