# MyDotrc

## 설치전 작업

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
gh repo clone ujuc/dotrc ${HOME}/.config/dotrc -- --recurse-submodules
```

## zsh 설정

### [starship](https://starship.rs/)

- CLI 테마

```sh
brew install starship
ln -sf ${DOTRCDIR}/starship.toml ${XDG_CONFIG_HOME}/starship.toml
```

### [ZimFW](https://zimfw.sh/)

```sh
brew install zimfw
```

### `zshrc` 파일 링크

```sh
ln -sf ${HOME}/.config/dotrc/zshrc ${HOME}/.zshrc
```

## CLI Packages

### GNU library

- xcode util에서 제공하는 라이브러리 말고 GNU 라이브러리를 사용하기 위해서 추가.

```sh
brew install coreutils
```

### [bat](https://github.com/sharkdp/bat)

```sh
brew install bat
mkdir -p ${XDG_CONFIG_HOME}/bat
ln -sf ${DOTRCDIR}/batrc ${XDG_CONFIG_HOME}/bat/config
```

### [eza](https://github.com/eza-community/eza)

```sh
brew install eza
```

### [zoxide](https://github.com/ajeetdsouza/zoxide)

```sh
brew install zoxide
```

### [fzf](https://github.com/junegunn/fzf)

```sh
brew install fzf
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
mkdir -p ${XDG_CONFIG_HOME}/tig
ln -sf ${DOTRCDIR}/tigrc ${XDG_CONFIG_HOME}/tig/config
```

### [mise-en-place](https://mise.jdx.dev/)

```sh
curl https://mise.run | sh

# Autocomplete
mise use -g uv
mise use -g node
```

## Agent

에이전트 설정은 [ujuc/agent-stuff](https://github.com/ujuc/agent-stuff) 저장소의 git submodule(`agents/`)로 관리됩니다.

> Repo clone 시 `--recurse-submodules` 를 사용하지 않았다면:
>
> ```sh
> cd ${DOTRCDIR}
> git submodule update --init --recursive
> ```

### [Claude](https://claude.ai/)

```sh
curl -fsSL https://claude.ai/install.sh | bash
ln -sf ${DOTRCDIR}/agents/claude ${HOME}/.claude
```

### [Pi](https://github.com/badlogic/pi-mono)

사용할때 연결

```sh
npm install -g @mariozechner/pi-coding-agent
ln -sf ${DOTRCDIR}/agents/pi ${HOME}/.pi
```

### [Gemini](https://geminicli.com/)

사용할때 연결

```sh
npm install -g @google/gemini-cli
ln -sf ${DOTRCDIR}/agents/gemini ${HOME}/.gemini
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

## Font

```sh
# google sans
font-google-sans-code

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

```bash
sudo softwareupdate --install-rosetta --agree-to-license

brew install --cask fujitsu-scansnap-home
```

### Google

```bash
brew install --cask google-drive
```

### Adobe

```bash
brew install --cask adobe-creative-cloud
```

## License

[MIT](./LICENSE)
