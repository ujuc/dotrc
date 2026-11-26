# dotrc

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

## 기본 작업

### [Homebrew](https://brew.sh/)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1Password

- [SSH agent 설정](https://developer.1password.com/docs/ssh/agent/)

```sh
brew install --cask 1password 1password-cli
```

### GitHub CLI

```sh
brew install gh
gh auth login
```

## 레포 clone

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

- `cat` 명령어 rust 구현체

```sh
brew install bat
mkdir -p ${XDG_CONFIG_HOME}/bat
ln -sf ${DOTRCDIR}/batrc ${XDG_CONFIG_HOME}/bat/config
```

### [eza](https://github.com/eza-community/eza)

- `ls` 명령어 rust 구현체

```sh
brew install eza
```

### [zoxide](https://github.com/ajeetdsouza/zoxide)

- `cd` 명령어를 좀 좋게 만든거

```sh
brew install zoxide
```

### [fzf](https://github.com/junegunn/fzf)

- 그냥 기본 값으로 설치

```sh
brew install fzf
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

- git diff 보기 좋게 만들어 줌

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

- git tui 구현체
- [한글 메뉴얼](https://ujuc.github.io/2016/02/10/tig-manual/)

```sh
brew install tig
mkdir -p ${XDG_CONFIG_HOME}/tig
ln -sf ${DOTRCDIR}/tigrc ${XDG_CONFIG_HOME}/tig/config
```

### [mise-en-place](https://mise.jdx.dev/)

- 환경 설정, 패키지 설치... 뭐 많이 됨

```sh
curl https://mise.run | sh

# Autocomplete
mise use -g uv
mise use -g node@lts
mise use -g rust
mise use -g duckdb
mise use -g bun
mise use -g python
```

### [yq](https://github.com/mikefarah/yq), [jq](https://jqlang.org/)

- YAML, JSON 파서

```sh
brew install yq jq
```

## Agent

에이전트 설정은 이 저장소의 `agents/` 디렉터리에서 함께 관리합니다.

### 공용

#### 공용 전역 지침 (`AGENTS.global.md`)

```sh
ln -sf ${DOTRC_AGENTS_DIR}/claude/AGENTS.global.md ${HOME}/.codex/AGENTS.md
ln -sf ${DOTRC_AGENTS_DIR}/claude/AGENTS.global.md ${HOME}/.omp/agent/AGENTS.md
ln -sf ${DOTRC_AGENTS_DIR}/claude/AGENTS.global.md ${HOME}/.pi/agent/AGENTS.md
ln -sf ${DOTRC_AGENTS_DIR}/claude/AGENTS.global.md ${XDG_CONFIG_HOME}/amp/AGENTS.md
```

### [Claude](https://claude.ai/)

```sh
curl -fsSL https://claude.ai/install.sh | bash
ln -sf ${DOTRC_AGENTS_DIR}/claude ${HOME}/.claude
```

#### Plugins

```sh
# Marketplaces
/plugin marketplace add anthropics/claude-plugins-official
/plugin marketplace add dietrichgebert/ponytail
/plugin marketplace add ayghri/i-have-adhd
/plugin marketplace add jarrodwatts/claude-hud
/plugin marketplace add typesafe-ai/skills

# Plugins
/plugin install superpowers@claude-plugins-official
/plugin install remember@claude-plugins-official
/plugin install ponytail@ponytail
/plugin install i-have-adhd@i-have-adhd
/plugin install claude-hud@claude-hud
/plugin install typesafe@typesafe-ai
```

- [superpowers](https://github.com/obra/superpowers) — workflow skills 및 superpowers framework
- [ponytail](https://github.com/dietrichgebert/ponytail) — 단순한 구현을 우선하는 개발 모드
- remember — 세션 기록 저장
- [i-have-adhd](https://github.com/ayghri/i-have-adhd) — ADHD 친화 출력 형식
- [claude-hud](https://github.com/jarrodwatts/claude-hud) — 컨텍스트·에이전트·todo를 보여주는 상태줄 (아래 `claude-hud` 절)
- [typesafe](https://github.com/typesafe-ai/skills) — TypeSafe 판단 프리미티브 스킬

#### settings.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "respectGitignore": true,
  "skillListingBudgetFraction": 0.05,
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
    "CLAUDISH_MD_MODE": "sibling",
    "MAX_MCP_OUTPUT_TOKENS": "10000"
  },
  "permissions": {
    "allow": [
    ],
    "deny": [
      "Skill(superpowers:writing-skills)"
    ],
    "ask": [],
    "defaultMode": "auto",
    "disableBypassPermissionsMode": "disable"
  },
  "worktree": {
    "baseRef": "fresh"
  },
  "outputStyle": "explanatory-concise",
  "language": "Korean",
  "feedbackDrafts": "notify",
  "spinnerTipsEnabled": false,
  "modelSettings": {
    "claude-opus-5-5": {
      "effortLevel": "medium"
    },
    "claude-sonnet-5-5": {
      "effortLevel": "low"
    },
    "claude-fable-5-2": {
      "effortLevel": "high"
    }
  },
  "advisorModel": "fable",
  "ultracode": true,
  "promptSuggestionEnabled": false,
  "awaySummaryEnabled": false,
  "askUserQuestionTimeout": "never",
  "pluginConfigs": {
    "agents-md@builtin": {
      "options": {
        "instructionFiles": "claude-md-and-agents-md"
      }
    },
    "cc-plugin-agents-md@builtin": {
      "options": {
        "instructionFiles": "claude-md-and-agents-md"
      }
    },
    "ponytail@ponytail": {
      "options": {
        "sendNames": true,
        "ledger": true
      }
    }
  },
  "tui": "fullscreen",
  "timeFormat": "24-hour",
  "skipWorkflowUsageWarning": true,
  "theme": "dark-ansi",
  "editorMode": "normal",
  "preferredNotifChannel": "auto",
  "switchModelsOnFlag": true,
  "autoContinueAtUsageLimit": true,
  "showTurnDuration": true,
  "terminalProgressBarEnabled": true,
  "teammateMode": "auto",
  "inputNeededNotifEnabled": true,
  "agentPushNotifEnabled": true,
  "skipAutoPermissionPrompt": true,
  "useAutoModeDuringPlan": true
}
```

#### claude-hud


```json
{
  "lineLayout": "compact",
  "showSeparators": false,
  "display": {
    "showTools": false,
    "showAgents": true,
    "showTodos": true,
    "showSkills": true,
    "showMcp": true,
    "showEffortLevel": true,
    "showDuration": true,
    "showConfigCounts": true
  }
}
```

#### 개인 스킬 (`ujuc` 플러그인)

- 위치: `agents/claude/skills/ujuc/skills/<name>/`
- 로드: `ujuc/.claude-plugin/plugin.json`으로 `ujuc@skills-dir` 플러그인이 제자리 로드된다(설치·마켓플레이스 없음).
- 호출: `/ujuc:commit`처럼 `ujuc:` 접두사를 붙인다. 프로젝트 `.claude/skills/`의 같은 이름 스킬을 가리지 않기 위해서다.

#### 외부 스킬

`agents/claude/skills/` 바로 아래에 추가로 설치되어 있다.

- [skill-diet](https://github.com/nicobailon/skill-diet) (subtree, `v0.2.0`) — 스킬 다이어트. `/skill-diet:skill-diet`
- [dual-brain](https://github.com/sleeplesshan/dual-brain) (subtree, `v1.7.0`) — 설계·구현 두 관점 검토. `/dual-brain`
- [egm](https://github.com/google/elephant-goldfish-model) (릴리스 zip, `v0.1.1`) — 설계 문서 작성·검토. `/egm:egm-review` 등
- `ego-browser` (외부 심링크) — 브라우저 자동화

### [Amp](https://ampcode.com/)

```sh
curl -fsSL https://ampcode.com/install.sh | bash
mkdir -p ${XDG_CONFIG_HOME}/amp
ln -sf ${DOTRC_AGENTS_DIR}/claude/AGENTS.global.md ${XDG_CONFIG_HOME}/amp/AGENTS.md
```

- 스킬은 `~/.claude/skills`를 그대로 읽는다.

### [omp](https://github.com/can1357/oh-my-pi)

```sh
mise use -g github:can1357/oh-my-pi
omp config set enabledProviders '["claude","claude-plugins"]'
omp config set skills.customDirectories '["~/.claude/skills/ujuc/skills","~/.claude/skills/egm/skills","~/.claude/skills/skill-diet/skills"]'
```

- `~/.claude`의 스킬을 그대로 쓴다. `install.sh --agents`가 mise로 omp·pi를 설치하고 위 설정을 넣으므로, mise가 없으면 `--cli`를 먼저 실행한다.

### [pi](https://github.com/earendil-works/pi)

```sh
mise use -g npm:@earendil-works/pi-coding-agent
mkdir -p ${HOME}/.pi/agent/extensions
ln -sf ${DOTRC_AGENTS_DIR}/pi-extensions/claude-skills.ts ${HOME}/.pi/agent/extensions/claude-skills.ts
```

- 위 확장으로 `~/.claude`의 스킬을 쓴다. `install.sh --agents`가 링크를 만든다.
- omp·pi 모두 스킬만 공유된다. 플러그인의 hooks·에이전트·MCP 서버는 빠진다.

### [waza](https://github.com/microsoft/waza)

```sh
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash
```

## Apps

### [raycast](https://www.raycast.com/)

```sh
brew install --cask raycast
```

### [Zed](https://zed.dev/)

- [Zed config](https://zed.dev/docs/configuring-zed)
- [Zed themes](https://zed-themes.com/)
- [Delta](https://delta.dev/)

```sh
brew install --cask zed zed-delta
```

### [Visual Studio Code](https://code.visualstudio.com/)

```sh
brew install --cask visual-studio-code
```

## Terminal

### Rex

- Open 되면 그걸로 바꿔야지.

### [Ghostty](https://ghostty.org)

```sh
brew install --cask ghostty
mkdir -p ${XDG_CONFIG_HOME}/ghostty
ln -sf ${DOTRCDIR}/ghosttyrc ${XDG_CONFIG_HOME}/ghostty/config
```

### [Orca](https://orca.dev/)

```sh
brew install --cask stablyai/orca/orca
```

## Font

```sh
# google sans
brew install font-google-sans-code font-googlesanscode-nerd-font

# MS cascdia code font https://github.com/microsoft/cascadia-code
brew install font-cascadia-code font-cascadia-code-nf

# D2 coding
brew install font-d2coding font-d2coding-nerd-font

# ibm
brew install font-ibm-plex-sans-kr font-ibm-plex-serif font-ibm-plex-mono

# noto
brew install font-noto-sans-mono-cjk-kr

# nanum
brew install font-nanum-square font-nanum-square-neo font-nanum-square-round
```

## Config

### Zsh

- 업무용은 `zshrc.work` 파일을 이용

## 기타

### ScanSnap Home

V3.6.0부터 Apple Silicon 네이티브라 Rosetta 2가 필요 없다.

```bash
brew install --cask scansnap-home
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
