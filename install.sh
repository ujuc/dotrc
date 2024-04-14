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
    gh

## Setup rust environment and Install rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

## Install gh extensions
gh ext install github/gh-copilot
