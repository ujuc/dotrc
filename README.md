# MyDotrc

## 설치전 작업

- MacOS

```sh
xcode-select --install
```

- [Homebrew](https://brew.sh/)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Auth 환경 구성

- 1Password
  - [SSH agent 설정](https://developer.1password.com/docs/ssh/agent/)

```sh
brew install --cask 1password 1password-cli
```

- [GitHub CLI](https://cli.github.com/manual/)

```sh
brew install gh

gh auth login
```

## Repo 환경 작업

```sh
gh repo clone ujuc/dotrc $HOME/.config/dotrc
```

- `zshenv` 파일 링크

```sh
ln -sf $HOME/.config/dotrc/zshenv $HOME/.zshenv
mkdir -p $HOME/.config/zsh
```

## 사용하는 cli 패키지 설치하고 설정

- [starship](https://starship.rs/)
  - CLI 테마

```sh
brew install starship
ln -sf $DOTRCDIR/starship.toml $XDG_CONFIG_HOME/starship.toml
```

- [ZimFW](https://zimfw.sh/)

```sh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
ln -sf $DOTRCDIR/zimrc $ZDOTDIR/.zimrc
```

- `zshrc` 파일 링크

```sh
mkdir -p $XDG_CONFIG_HOME/zsh
ln -sf $DOTRCDIR/zshrc $ZDOTDIR/.zshrc
```

### [vim](https://www.vim.org/)

```shell
brew install vim
```

### [bat](https://github.com/sharkdp/bat)

```shell
brew install bat

mkdir -p .config/bat && ln -sf $HOME/dotrc/batrc $HOME/.config/bat/config
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

### Git

#### Git

- 따로 설치하지 않으면 xcode 에서 제공하는 git을 사용하게됨.

```shell
brew install git
```

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

### [Zed](https://zed.dev/)

- [Zed config](https://zed.dev/docs/configuring-zed)
- [Zed themes](https://zed-themes.com/)

```shell
brew install --cask zed

ln -sf $HOME/dotrc/zed/settings.json $HOME/.config/zed/settings.json
ln -sf $HOME/dotrc/zed/nordic.json $HOME/.config/zed/themes/nordic.json
```

### [Visual Studio Code](https://code.visualstudio.com/)

```shell
brew install --cask visual-studio-code
```

### SnapScan

- https://www.pfu.ricoh.com/global/scanners/scansnap/dl/mac-1014-ix500.html

## Terminal

### [Ghostty](https://ghostty.org)

```shell
brew install ghostty

mkdir -p $HOME/.config/ghostty && ln -sf $HOME/dotrc/ghosttyrc $HOME/.config/ghostty/config
```

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

### Deno

```shell
asdf plugin add deno
asdf install deno latest
asdf global deno latest
```

## Config

### Zsh

```shell
ln -sf $HOME/dotrc/zshrc $HOME/.zshrc
```

- 업무용은 `zshrc.work` 파일을 이용

### Zed

```shell
ln -sf $HOME/dotrc/zed/settings.json $HOME/.config/zed/settings.json
```

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

## License

[MIT](./LICENSE)
