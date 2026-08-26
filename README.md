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

### [Pi](https://github.com/earendil-works/pi)

bun으로 전역 설치한다. `~/.bun/bin`은 `zshrc`의 `path`에 등록되어 있어 별도 별칭이
필요 없다. (mise node로 설치하면 node 버전이 바뀔 때 경로가 깨진다.)

```sh
bun add -g --ignore-scripts @earendil-works/pi-coding-agent
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

### [CodeGraph](https://github.com/colbymchenry/codegraph)

전역 CLI는 번들 설치 스크립트를 쓴다. 자체 런타임을 포함해
`~/.codegraph/versions/`에 설치되고 `~/.local/bin/codegraph` 심링크가 걸리므로
node 버전과 무관하다.

```sh
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
```

새 터미널에서 하네스에 MCP 서버를 연결한다. Claude Code의 경우
`~/.claude.json`의 `mcpServers`, `agents/claude/settings.json`의
`mcp__codegraph__*` 권한과 `codegraph prompt-hook`,
`agents/claude/CLAUDE.md`의 `CODEGRAPH_START` 블록이 함께 갱신된다.

```sh
codegraph install
```

설치 스크립트는 하네스 지침 파일에 `CODEGRAPH_START` 블록을 직접 써 넣는다.
이 저장소는 같은 내용을 `agents/rules/AGENTS.md`의 `Code Intelligence`에서
관리하므로, `codegraph install`·`upgrade` 뒤에 다시 주입된 블록은 지운다.
`~/.codex/AGENTS.md` 심링크도 실제 파일로 덮어쓰므로 `scripts/install.sh`를
다시 실행해 링크를 복구한다.

인덱스는 저장소마다 따로 만든다. `.codegraph/`는 로컬 산출물이라 커밋하지 않는다.

```sh
codegraph init      # 최초 인덱싱
codegraph sync      # 변경분 반영
codegraph upgrade   # CLI 갱신
```

### [graft](https://github.com/NanoNets/context-graph-engine)

npm 패키지지만 mise node에 설치하면 node 버전이 바뀔 때 경로가 깨지므로
Pi와 같이 bun 전역 설치를 쓴다.

```sh
bun add -g @nanonets/graft
```

bun은 native 의존성(tree-sitter 언어 바인딩)의 postinstall을 막지만, graft가
WASM 파서로 대체하므로 그대로 동작한다 (0.13.0에서 TypeScript·Python 파싱 확인).

저장소마다 `graft init`으로 그래프를 만들고 에이전트 연결을 붙인다.
`graft/`는 재생성 가능한 로컬 캐시라 `.gitignore`에 자동 등록되며,
커밋 대상은 `init`이 만든 `.claude/` 설정과 `.mcp.json` 항목이다.

```sh
graft init          # 그래프 빌드 + 에이전트 연결 (--dry-run 으로 미리 확인)
graft build         # 그래프 재생성 (체크아웃한 사람이 각자 실행)
```

개념 노드와 심볼 요약을 만드는 `graft build --deep`은 LLM 키가 필요하다
(`GRAFT_PROVIDER`, `GRAFT_API_KEY`, `GRAFT_MODEL`). 기본 `graft build`는
tree-sitter 기반이라 키 없이 동작한다.

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
