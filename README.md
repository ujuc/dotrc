# MyDotrc

## License

[MIT](./LICENSE)

## Pre-install package

### MacOS

```shell
xcode-select --install
```

### [Homebrew](https://brew.sh/)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## CLI

### [starship](https://starship.rs/)

```shell
brew install starship
```

### [zplug](https://github.com/zplug/zplug)

```shell
brew install zplug
```

### [vim](https://www.vim.org/)

```shell
brew install vim
```

### [bat](https://github.com/sharkdp/bat)

```shell
brew install bat
```

### [lsd](https://github.com/lsd-rs/lsd)

```shell
brew install lsd
```

### [GitHub CLI](https://cli.github.com/)

```shell
brew install gh

## Install gh extensions
gh ext install github/gh-copilot
```

### Git Plugins

#### [git-delta](https://github.com/dandavison/delta)

```shell
brew install git-delta
```

#### [tig](https://jonas.github.io/tig/)

- [한글 메뉴얼](https://ujuc.github.io/2016/02/10/tig-manual/)

```shell
brew install tig

mkdir -p .config/tig && ln -sf $HOME/dotrc/tigrc $HOME/.config/tig/config
```

## Apps

### 1Password

```shell
brew install --cask 1password 1password-cli
```

#### 1Password SSH key config

- [1Password ssh docs](https://developer.1password.com/docs/ssh)

### [raycast](https://www.raycast.com/)

```shell
brew install --cask raycast
```

### [Visual Studio Code](https://code.visualstudio.com/)

```shell
brew install --cask visual-studio-code
```

### [Arc Browser](https://arc.net/)

```shell
brew install --cask arc
```

### SnapScan

- https://www.pfu.ricoh.com/global/scanners/scansnap/dl/mac-1014-ix500.html

## Terminal

### [warp](https://www.warp.dev/)

```shell
brew install --cask warp
```

### [iTerm2](https://iterm2.com/)

```shell
brew install --cask iterm2
```

## Font

```shell
# MS cascdia code font https://github.com/microsoft/cascadia-code
font-cascadia-code
font-cascadia-code-nf

# D2 coding
font-d2coding-nerd-font
```

## Lang

### Rust

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Config

### Zsh

```shell
ln -sf $HOME/dotrc/zshrc $HOME/.zshrc
```

- 업무용은 `zshrc.work` 파일을 이용

### Git

- User

```shell
git config --global user.email ""
git config --global user.name ""
```

- Core

```shell
git config --global core.autocrlf input
git config --global core.whitespace cr-at-eol,fix,trailing-space,-indent-with-non-tab
```

- Merge

```shell
git config --global merge.conflictstyle zdiff3
```

- Commit

```shell
git config --global commit.template $HOME/dotrc/gitmessage
```

- Delta

```shell
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.navigate true
git config --global delta.diff-so-fancy true
git config --global delta.hyperlinks true
```
