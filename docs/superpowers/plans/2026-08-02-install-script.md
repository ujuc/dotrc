# README 기반 설치 스크립트 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `README.md`의 macOS 환경 구성 명령을 그룹별로 안전하게 실행하고, 실패 항목과 재실행 명령을 끝에 요약하는 설치 스크립트를 제공한다.

**Architecture:** `scripts/install.sh` 하나가 옵션 해석, 링크 충돌 사전 검사, 그룹별 설치와 결과 요약을 담당한다. 독립 작업은 공통 `run_step` 함수를 통과해 원본 출력을 유지하고 실패 메타데이터를 수집하며, Homebrew 부재와 링크 충돌 같은 전제 조건 실패만 즉시 종료한다.

**Tech Stack:** macOS, Bash 3.2 호환 셸, Homebrew, GitHub CLI, Claude Code CLI, mise, npm

## Global Constraints

- 인자 없음과 `--help`는 도움말만 출력한다.
- `--cli`, `--apps`, `--fonts`, `--agents`는 조합할 수 있고 `--all`은 모두 선택한다.
- 기존 대상이 정확한 심볼릭 링크가 아니면 변경 전에 중단하며 자동 백업하거나 덮어쓰지 않는다.
- 기존 Git 이름과 이메일은 재사용하고 값이 없을 때만 입력받는다.
- 독립 작업 실패 후에도 계속 진행하고 마지막에 그룹, 항목, 명령, 종료 코드를 출력한다.
- 비밀번호, 토큰과 인증 결과를 저장소나 스크립트에 기록하지 않는다.
- `agents/` 서브모듈 파일은 수정하지 않는다.
- macOS 기본 Bash 3.2에서 지원하지 않는 연관 배열, `mapfile`, `readarray`를 사용하지 않는다.

---

## File Map

- Create: `scripts/install.sh` — 인자 해석, 안전 검사, 설치 그룹, 실패 수집과 최종 요약
- Modify: `README.md` — 자동 설치 진입점과 옵션 예시를 추가하고 수동 명령을 자동화 대상과 일치시킴

### Task 1: 명령행 인터페이스와 실패 수집 기반

**Files:**
- Create: `scripts/install.sh`

**Interfaces:**
- Consumes: `HOME`, 선택적 `XDG_CONFIG_HOME`, 스크립트 위치에서 계산한 저장소 루트
- Produces: `run_step <group> <label> <command...>`, `run_shell_step <group> <label> <shell-command>`, `record_failure`, `print_summary`, 네 개의 `SELECT_*` 플래그

- [ ] **Step 1: 구현 전 실패 확인**

Run: `bash scripts/install.sh --help`

Expected: FAIL with `No such file or directory`.

- [ ] **Step 2: Bash 3.2 호환 인터페이스 작성**

다음 상태를 초기화하고 `case`로 옵션을 해석한다.

```bash
#!/usr/bin/env bash
set -uo pipefail

DOTRCDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
SELECT_CLI=false
SELECT_APPS=false
SELECT_FONTS=false
SELECT_AGENTS=false
FAILURE_COUNT=0
FAILURE_GROUPS=()
FAILURE_LABELS=()
FAILURE_STATUSES=()
FAILURE_COMMANDS=()
LAST_STEP_STATUS=0
```

옵션 규칙은 `--cli`, `--apps`, `--fonts`, `--agents`가 해당 플래그 하나를 켜고, `--all`이 네 플래그를 모두 켜는 것이다. `-h|--help`와 인자 없음은 사용법을 출력하고 0으로 종료한다. 알 수 없는 옵션은 `Unknown option: <value>`와 사용법을 stderr에 출력하고 2로 종료한다.

- [ ] **Step 3: 실행 래퍼와 최종 요약 작성**

`run_step`은 실행할 인자를 `printf '%q'`로 조합해 먼저 출력한다. 명령 성공 시 완료를 표시한다. 실패 시 원본 stdout/stderr를 그대로 둔 채 다음 함수로 같은 인덱스의 네 배열에 정보를 저장하고 호출자에게는 0을 반환해 후속 작업을 계속한다.

```bash
record_failure() {
    local group=$1 label=$2 status=$3 command_text=$4 index=$FAILURE_COUNT
    FAILURE_GROUPS[$index]=$group
    FAILURE_LABELS[$index]=$label
    FAILURE_STATUSES[$index]=$status
    FAILURE_COMMANDS[$index]=$command_text
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
}

run_shell_step() {
    local group=$1 label=$2 shell_command=$3
    run_step "$group" "$label" /bin/bash -o pipefail -c "$shell_command"
}
```

`LAST_STEP_STATUS`에는 직전 실제 종료 코드를 저장한다. `print_summary`는 실패가 없으면 0을 반환한다. 실패가 있으면 번호별 그룹, 라벨, 종료 코드와 `$ <명령>`을 출력하고 1을 반환한다.

- [ ] **Step 4: 인터페이스 검증**

```bash
chmod +x scripts/install.sh
bash -n scripts/install.sh
./scripts/install.sh >/tmp/dotrc-install-help.out
./scripts/install.sh --help >/tmp/dotrc-install-explicit-help.out
cmp /tmp/dotrc-install-help.out /tmp/dotrc-install-explicit-help.out
if ./scripts/install.sh --unknown >/tmp/dotrc-install-unknown.out 2>&1; then exit 1; fi
grep -F 'Unknown option: --unknown' /tmp/dotrc-install-unknown.out
```

Expected: syntax and help checks pass; invalid option exits 2.

- [ ] **Step 5: 기반 구현 커밋**

```bash
git add scripts/install.sh
git commit -m "feat(scripts): 설치 스크립트 실행 기반을 추가하다"
```

### Task 2: 안전 검사와 그룹별 설치 구현

**Files:**
- Modify: `scripts/install.sh`

**Interfaces:**
- Consumes: Task 1의 실행 래퍼, 선택 플래그와 실패 배열
- Produces: `preflight_links`, `safe_link`, `ensure_homebrew`, `install_formula`, `install_cask`, `install_cli`, `install_apps`, `install_fonts`, `install_agents`

- [ ] **Step 1: 링크 사전 검사와 생성 구현**

`check_link_destination <source> <destination>`은 기존 링크의 `readlink` 값이 절대 원본 경로와 정확히 일치할 때만 통과한다. 다른 링크, 파일 또는 디렉터리가 있으면 충돌 경로를 출력한다. `preflight_links`는 선택 그룹의 충돌을 모두 수집한 뒤 하나라도 있으면 설치 전에 종료한다. `safe_link`는 원본 존재 여부 확인, 부모 디렉터리 생성, `ln -sfn`을 각각 실행한다.

```text
--cli:
  starship.toml -> ${XDG_CONFIG_HOME}/starship.toml
  zshrc -> ${HOME}/.zshrc
  batrc -> ${XDG_CONFIG_HOME}/bat/config
  tigrc -> ${XDG_CONFIG_HOME}/tig/config
--apps:
  zed/settings.json -> ${XDG_CONFIG_HOME}/zed/settings.json
  ghosttyrc -> ${XDG_CONFIG_HOME}/ghostty/config
--agents:
  agents/claude -> ${HOME}/.claude
  agents/rules/AGENTS.md -> ${HOME}/.codex/AGENTS.md
  agents/amp/AGENTS.md -> ${XDG_CONFIG_HOME}/amp/AGENTS.md
  agents/amp/settings.json -> ${XDG_CONFIG_HOME}/amp/settings.json
  agents/claude/skills/<name> -> ${HOME}/.codex/skills/<name>
```

`agents/pi`는 현재 서브모듈에 없으므로 생성하거나 링크하지 않고 Pi 패키지만 설치한다.

- [ ] **Step 2: Homebrew와 패키지 헬퍼 구현**

`ensure_homebrew`는 `brew`가 없으면 공식 명령을 실행하고 `/opt/homebrew/bin/brew shellenv` 또는 `/usr/local/bin/brew shellenv`을 현재 셸에 반영한다. 설치 실패 또는 설치 후에도 `brew`가 없으면 실패 요약 후 즉시 종료한다.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

`install_formula`와 `install_cask`는 각각 `brew list --formula <name>`과 `brew list --cask <name>`으로 기존 설치를 건너뛰고, 미설치 항목을 `brew install <name>` 또는 `brew install --cask <name>`으로 하나씩 `run_step`에 전달한다.

- [ ] **Step 3: `--cli` 그룹 구현**

```text
cask:    1password, 1password-cli
formula: gh, starship, zimfw, coreutils, bat, eza, zoxide, fzf, vim,
         git, git-delta, tig, yq
```

mise가 없으면 `curl https://mise.run | sh`를 실행하고 `${HOME}/.local/bin`을 `PATH`에 추가한다. mise가 준비되면 `mise use -g uv`, `mise use -g node`를 별도 단계로 실행한다.

Git은 `core.autocrlf=input`, `core.whitespace=cr-at-eol,fix,trailing-space,-indent-with-non-tab`, `merge.conflictstyle=zdiff3`, `init.defaultBranch=main`, `commit.template=${DOTRCDIR}/gitmessage`와 README의 delta 설정을 항목별로 적용한다. `user.name`과 `user.email`이 없으면 TTY에서 입력받고, 비대화형이면 수동 `git config --global` 명령을 실패 목록에 기록한다. `gh auth status`가 실패할 때만 `gh auth login`을 실행한다. 루트와 `agents/` 저장소에 `core.hooksPath=.githooks`를 설정한다.

- [ ] **Step 4: `--apps`와 `--fonts` 그룹 구현**

```text
app cask: raycast, zed, visual-studio-code, ghostty,
          fujitsu-scansnap-home, google-drive, adobe-creative-cloud
app formula: ollama
font cask: font-google-sans-code, font-cascadia-code, font-cascadia-code-nf,
           font-d2coding-nerd-font, font-ibm-plex-sans-kr,
           font-ibm-plex-serif, font-noto-color-emoji, font-noto-emoji,
           font-noto-sans-cjk, font-noto-serif-cjk, font-nanum-square,
           font-nanum-square-neo, font-nanum-square-round
```

Apple Silicon에서 `pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto`가 실패할 때만 `sudo softwareupdate --install-rosetta --agree-to-license`를 실행한다. `ollama` 명령이 있으면 `ollama pull gemma3`, `ollama pull qwen3`를 별도 단계로 실행한다.

- [ ] **Step 5: `--agents` 그룹 구현**

정적으로 알려진 링크 대상을 먼저 검사한 뒤 `git submodule update --init --recursive`를 필수 전제로 실행하고, 초기화 후 열거할 수 있는 Codex 스킬 링크 대상을 별도로 검사한다. Claude가 없으면 공식 설치 명령을 실행하고 `${HOME}/.local/bin`을 `PATH`에 추가한다. mise가 있으면 `mise exec -- npm install -g @mariozechner/pi-coding-agent`를 실행하고, mise 없이 npm만 있으면 npm을 직접 실행하며, 둘 다 사용할 수 없으면 실패 목록에 해당 명령을 기록한다.

`claude plugin marketplace list --json`과 `claude plugin list --json`에서 기존 이름/ID를 확인해 다음 항목을 하나씩 추가한다.

```text
marketplace: anthropics/claude-plugins-official, affaan-m/ECC,
             jarrodwatts/claude-hud, revfactory/harness, ujuc/amp-plugin-cc,
             openai/codex-plugin-cc, warpdotdev/claude-code-warp
plugin: superpowers@claude-plugins-official, ecc@ecc,
        claude-hud@claude-hud, code-review@claude-plugins-official,
        code-simplifier@claude-plugins-official,
        feature-dev@claude-plugins-official,
        claude-md-management@claude-plugins-official,
        security-guidance@claude-plugins-official,
        rust-analyzer-lsp@claude-plugins-official, harness@harness-marketplace,
        amp-plugin-cc@amp-plugin-cc, codex@openai-codex,
        warp@claude-code-warp
```

플러그인 단계가 선택되면 마지막에 Claude 세션의 `/claude-hud:setup` 수동 실행을 안내한다.

- [ ] **Step 6: 메인 실행 순서 연결**

```text
parse_args
선택 그룹의 정적으로 알려진 모든 링크 대상 preflight
cli 또는 agents 선택 시 agents submodule 초기화 및 독립 저장소 검증
agents 선택 시 동적으로 열거한 Codex skill 링크 대상 preflight
cli/apps/fonts 선택 시 ensure_homebrew
install_cli -> install_apps -> install_fonts -> install_agents
print_summary
```

그룹 함수 실패는 실행을 끊지 않으며 `FAILURE_COUNT`만 최종 종료 상태를 결정한다.

- [ ] **Step 7: 정적 검사와 충돌 안전성 검증**

```bash
bash -n scripts/install.sh
./scripts/install.sh --help
if command -v shellcheck >/dev/null 2>&1; then shellcheck scripts/install.sh; fi
sandbox=$(mktemp -d)
cp -R . "$sandbox/dotrc"
mkdir -p "$sandbox/home"
printf 'do not replace\n' >"$sandbox/home/.zshrc"
if HOME="$sandbox/home" XDG_CONFIG_HOME="$sandbox/home/.config" "$sandbox/dotrc/scripts/install.sh" --cli >"$sandbox/output" 2>&1; then exit 1; fi
grep -F "$sandbox/home/.zshrc" "$sandbox/output"
grep -F 'brew install' "$sandbox/output" && exit 1 || true
test "$(cat "$sandbox/home/.zshrc")" = 'do not replace'
rm -rf "$sandbox"
```

Expected: conflict path is printed, Homebrew install does not run, and the original file is unchanged.

- [ ] **Step 8: 설치 구현 커밋**

```bash
git add scripts/install.sh
git commit -m "feat(scripts): 그룹별 개발 환경 설치를 자동화하다"
```

### Task 3: README 사용법과 최종 검증

**Files:**
- Modify: `README.md:3-33`

**Interfaces:**
- Consumes: `scripts/install.sh`의 공개 옵션
- Produces: clone 후 선택 설치 또는 전체 설치를 실행할 수 있는 문서

- [ ] **Step 1: 자동 설치 섹션 추가**

제목 다음에 인자 없음은 도움말, 옵션은 조합 가능, `--all`은 전체 설치임을 설명하고 다음 예시를 추가한다.

```bash
./scripts/install.sh --cli
./scripts/install.sh --apps
./scripts/install.sh --fonts
./scripts/install.sh --agents
./scripts/install.sh --cli --agents
./scripts/install.sh --all
```

독립 실패는 계속 진행하고 마지막에 실패 정보와 재실행 명령을 출력하며, 기존 설정 충돌은 덮어쓰지 않는다고 명시한다. 폰트 코드 블록의 각 이름 앞에는 `brew install --cask`를 붙인다. 존재하지 않는 `agents/pi` 링크 명령은 제거한다. Everything Claude Code의 현재 marketplace와 플러그인 이름은 각각 `affaan-m/ECC`, `ecc@ecc`로 스크립트와 맞춘다.

- [ ] **Step 2: 문서와 스크립트 일치 검증**

```bash
for option in --cli --apps --fonts --agents --all; do
    grep -F -- "$option" README.md >/dev/null
    ./scripts/install.sh --help | grep -F -- "$option" >/dev/null
done
grep -F 'affaan-m/ECC' README.md
grep -F 'ecc@ecc' README.md
if grep -F 'agents/pi' README.md; then exit 1; fi
bash -n scripts/install.sh
git diff --check
```

Expected: all checks pass.

- [ ] **Step 3: 문서 커밋**

```bash
git add README.md
git commit -m "docs: 자동 설치 스크립트 사용법을 안내하다"
```
