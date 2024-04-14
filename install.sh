#!/usr/bin/env bash

# Install the dependencies
xcode-select --install

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install \
    starship \
    zplug \
    vim \
    bat \
    lsd \
    git-delta \
    tig \
    gh

brew install --cask \
    1password 1password-cli \
    raycast \
    warp \
    cursor \
    discord

## Setup rust environment and Install rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## Install gh extensions
# gh ext install github/gh-copilot

# Configure the Git
git config --global user.email "ujuc@ujuc.me"
git config --global user.name "sungjin.kang"

git config --global core.autocrlf input
git config --global core.whitespace cr-at-eol,fix,trailing-space,-indent-with-non-tab

git config --global merge.conflictstyle zdiff3

## delta
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.navigate true
git config --global delta.diff-so-fancy true
git config --global delta.hyperlinks true

echo "git gpg key setup"
echo "https://developer.1password.com/docs/ssh/git-commit-signing/"
