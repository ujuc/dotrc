# MyDotrc

## 자동 설치

저장소를 clone한 뒤 설치할 그룹의 옵션을 지정해 실행한다. 인자 없이 실행하면 도움말을 표시하며, 옵션은 조합할 수 있다. `--all`은 모든 그룹을 설치한다.

```bash
./scripts/install.sh --help
./scripts/install.sh -h
./scripts/install.sh --cli
./scripts/install.sh --apps
./scripts/install.sh --fonts
./scripts/install.sh --agents
./scripts/install.sh --cli --agents
./scripts/install.sh --all
```

그룹별 설치의 독립적인 항목이 실패해도 가능한 나머지 작업은 계속 진행하며, 마지막에 실패 정보와 재실행 명령을 출력한다. 링크 원본이 없거나 기존 설정과 충돌하면 변경 전에 안전하게 중단하며, 기존 파일이나 링크를 덮어쓰지 않는다.

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
gh repo clone ujuc/dotrc ${HOME}/.config/dotrc
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

- Init

```sh
git config --global init.defaultBranch main
```

- Commit

```sh
git config --global commit.template ${DOTRCDIR}/gitmessage
```

- Hooks (커밋 메시지 동사형 `-다` 종결 검증)

```sh
git -C ${DOTRCDIR} config core.hooksPath .githooks
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

### [yq](https://github.com/mikefarah/yq)

- YAML 파서. Claude 스킬 검증 스크립트에서 사용.

```sh
brew install yq
```

## Agent

에이전트 설정은 이 저장소의 `agents/` 디렉터리에서 함께 관리합니다.

### [Claude](https://claude.ai/)

```sh
curl -fsSL https://claude.ai/install.sh | bash
ln -sf ${DOTRCDIR}/agents/claude ${HOME}/.claude
```

#### Plugins

```sh
# Marketplaces
/plugin marketplace add anthropics/claude-plugins-official
/plugin marketplace add affaan-m/ECC
/plugin marketplace add jarrodwatts/claude-hud
/plugin marketplace add revfactory/harness
/plugin marketplace add ujuc/amp-plugin-cc
/plugin marketplace add openai/codex-plugin-cc
/plugin marketplace add warpdotdev/claude-code-warp
/plugin marketplace add dietrichgebert/ponytail

# Plugins
/plugin install superpowers@claude-plugins-official
/plugin install ecc@ecc
/plugin install claude-hud@claude-hud
/plugin install code-review@claude-plugins-official
/plugin install code-simplifier@claude-plugins-official
/plugin install feature-dev@claude-plugins-official
/plugin install claude-md-management@claude-plugins-official
/plugin install security-guidance@claude-plugins-official
/plugin install rust-analyzer-lsp@claude-plugins-official
/plugin install harness@harness-marketplace
/plugin install amp-plugin-cc@amp-plugin-cc
/plugin install codex@openai-codex
/plugin install warp@claude-code-warp
/plugin install ponytail@ponytail

# claude-hud statusline 설정
/claude-hud:setup
```

- [superpowers](https://github.com/obra/superpowers) — workflow skills 및 superpowers framework
- [ponytail](https://github.com/dietrichgebert/ponytail) — 단순한 구현을 우선하는 개발 모드
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — 다수 스킬·커맨드 모음
- [claude-hud](https://github.com/jarrodwatts/claude-hud) — statusline
- code-review — 코드 리뷰 명령
- code-simplifier — 코드 단순화
- feature-dev — 기능 개발 가이드
- claude-md-management — CLAUDE.md 관리
- security-guidance — 보안 리뷰
- rust-analyzer-lsp — Rust LSP 통합
- [harness](https://github.com/revfactory/harness) — 에이전트 하네스 오케스트레이션
- [amp-plugin-cc](https://github.com/ujuc/amp-plugin-cc) — Amp Code 통합
- [codex](https://github.com/openai/codex-plugin-cc) — OpenAI Codex 통합 (Stop hook Review Gate)
- [warp](https://github.com/warpdotdev/claude-code-warp) — Warp terminal 통합

### [Pi](https://github.com/badlogic/pi-mono)

사용할때 연결

```sh
npm install -g @mariozechner/pi-coding-agent
```

### [Codex](https://developers.openai.com/codex)

전역 지침은 `agents/rules/AGENTS.md`를 심링크로 사용한다.

```sh
ln -sfn ${DOTRCDIR}/agents/rules/AGENTS.md ${HOME}/.codex/AGENTS.md
```

전역 스킬은 Claude 스킬 카탈로그를 스킬별 심링크로 재사용한다 (새 스킬 추가 시 재실행).

```sh
for d in ${DOTRCDIR}/agents/claude/skills/*/; do
  [ -f "$d/SKILL.md" ] && ln -sfn "${d%/}" ${HOME}/.codex/skills/$(basename "$d")
done
```

### [Amp](https://ampcode.com/)

전역 공용 규칙은 `amp/AGENTS.md`에서 가져오고, Amp 전용 설정은
`amp/settings.json`에서 관리한다. 전역 스킬은 Amp가 `~/.claude/skills/`를
자동으로 읽으므로 별도로 복제하지 않는다.

```sh
mkdir -p ${XDG_CONFIG_HOME}/amp
ln -sfn ${DOTRCDIR}/agents/amp/AGENTS.md ${XDG_CONFIG_HOME}/amp/AGENTS.md
ln -sfn ${DOTRCDIR}/agents/amp/settings.json ${XDG_CONFIG_HOME}/amp/settings.json
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
brew install --cask ghostty
mkdir -p ${XDG_CONFIG_HOME}/ghostty
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config
```

## Font

```sh
# google sans
brew install --cask font-google-sans-code

# MS cascdia code font https://github.com/microsoft/cascadia-code
brew install --cask font-cascadia-code
brew install --cask font-cascadia-code-nf

# D2 coding
brew install --cask font-d2coding-nerd-font

# ibm
brew install --cask font-ibm-plex-sans-kr
brew install --cask font-ibm-plex-serif

# noto
brew install --cask font-noto-color-emoji
brew install --cask font-noto-emoji
brew install --cask font-noto-sans-cjk
brew install --cask font-noto-serif-cjk

# nanum
brew install --cask font-nanum-square
brew install --cask font-nanum-square-neo
brew install --cask font-nanum-square-round
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
