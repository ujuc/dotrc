# MyDotrc

## 설치전 작업

### MacOS

```sh
xcode-select --install
```

### [Homebrew](https://brew.sh/)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Auth 환경 구성

### 1Password

- [SSH agent 설정](https://developer.1password.com/docs/ssh/agent/)

```sh
brew install --cask 1password 1password-cli
```

### [GitHub CLI](https://cli.github.com/manual/)

```sh
brew install gh
gh auth login
```

## Repo 환경 작업

```sh
gh repo clone ujuc/dotrc ${HOME}/.config/dotrc
```

### `zshenv` 파일 링크

```sh
ln -sf ${HOME}/.config/dotrc/zshenv ${HOME}/.zshenv
```

## 사용하는 cli 패키지 설치하고 설정

### Zsh 사전 작업

```sh
mkdir -p ${XDG_CONFIG_HOME}/zsh
mkdir -p ${XDG_CONFIG_HOME}/zsh/.zfunc
```

### [starship](https://starship.rs/)

- CLI 테마

```sh
brew install starship
ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml
```

### [ZimFW](https://zimfw.sh/)

```sh
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
ln -sf ${DOTRCDIR}/zimrc ${ZDOTDIR}/.zimrc
ln -sf ${DOTRCDIR}/zshrc ${ZDOTDIR}/.zshrc
```

### [bat](https://github.com/sharkdp/bat)

```sh
brew install bat
mkdir -p ${XDG_CONFIG_HOME}/bat
ln -sf ${DOTRCDIR}/batrc ${XDG_CONFIG_HOME}/bat/config
```

### [lsd](https://github.com/lsd-rs/lsd)

```sh
brew install lsd
```

### [vim](https://www.vim.org/)

```sh
brew install vim
```

### [GitHub CLI- Extentions](https://github.com/topics/gh-extension)

- 할께 있으면 하는걸로...

### git

- 따로 설치하지 않으면 xcode 에서 제공하는 git을 사용하게됨.

```sh
brew install git
```

#### 구성

- User

```sh
git config --global user.email ""
git config --global user.name ""
```

- Core

```sh
git config --global core.autocrlf input
git config --global core.whitespace cr-at-eol,fix,trailing-space,-indent-with-non-tab
```

- Merge

```sh
git config --global merge.conflictstyle zdiff3
```

- Commit

```sh
git config --global commit.template ${DOTRCDIR}/gitmessage
```

### [git-delta](https://github.com/dandavison/delta)

```sh
brew install git-delta
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.line-numbers true
git config --global delta.side-by-side true
git config --global delta.navigate true
git config --global delta.diff-so-fancy true
git config --global delta.hyperlinks true
```

### [tig](https://jonas.github.io/tig/)

- [한글 메뉴얼](https://ujuc.github.io/2016/02/10/tig-manual/)

```sh
brew install tig
mkdir -p .config/tig
ln -sf ${DOTRCDIR}/tigrc ${XDG_CONFIG_HOME}/tig/config
```

## Apps

### [raycast](https://www.raycast.com/)

```sh
brew install --cask raycast
```

### [Zed](https://zed.dev/)

- [Zed config](https://zed.dev/docs/configuring-zed)
- [Zed themes](https://zed-themes.com/)

```sh
brew install --cask zed

ln -sf ${DOTRCDIR}/zed/settings.json ${XDG_CONFIG_HOME}/zed/settings.json
ln -sf ${DOTRCDIR}/zed/nordic.json ${XDG_CONFIG_HOME}/zed/themes/nordic.json
```

### [Visual Studio Code](https://code.visualstudio.com/)

```sh
brew install --cask visual-studio-code
```

### [ollama](https://ollama.com/)

```sh
brew install ollama
ollama pull gemma3
ollama pull qwen3
```

## Terminal

### [Ghostty](https://ghostty.org)

```sh
brew install ghostty
mkdir -p ${XDG_CONFIG_HOME}/ghostty
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config
```

## Lang

### [mise-en-place](https://mise.jdx.dev/)

```sh
brew install mise

# Autocomplete
mise use -g usage
mise use -g uv
```

### [rust](https://www.rust-lang.org/tools/install)

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Font

```sh
# MS cascdia code font https://github.com/microsoft/cascadia-code
font-cascadia-code
font-cascadia-code-nf

# D2 coding
font-d2coding-nerd-font

# ibm
font-ibm-plex-sans-kr
font-ibm-plex-serif

# noto
font-noto-color-emoji
font-noto-emoji
font-noto-sans-cjk
font-noto-serif-cjk

# nanum
font-nanum-square
font-nanum-square-neo
font-nanum-square-round
```

## Config

### Zsh

- 업무용은 `zshrc.work` 파일을 이용

## 기타

### SnapScan

- https://www.pfu.ricoh.com/global/scanners/scansnap/dl/mac-1014-ix500.html

## License

[MIT](./LICENSE)
