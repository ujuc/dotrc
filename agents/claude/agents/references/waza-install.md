# waza 설치 가이드

`waza`는 Microsoft가 만든 AI 에이전트 스킬 평가 CLI다. dotrc의 `generate-skills` 또는 명시적 평가 요청이 호출하며, 미설치 시 평가만 skip된다.

## 빠른 설치 (macOS / Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/waza/main/install.sh | bash
```

설치 위치: `/usr/local/bin`에 쓰기 권한이 있으면 그곳, 없으면 `$HOME/bin`.
`$HOME/bin` 사용 시 PATH 등록이 필요하다 — `~/.zshenv`(zsh) 또는 `~/.bashrc`(bash)에:

```sh
export PATH="$HOME/bin:$PATH"
```

> dotrc 환경에서는 `~/.zshenv`를 권장한다. interactive·non-interactive 셸 모두 적용되어 Claude Code의 Bash 도구에서도 `waza`가 잡힌다.

## 검증

```bash
waza --version          # waza version 0.38.6 (or higher)
waza --help             # 사용 가능한 서브커맨드 확인
which waza              # 설치 경로 확인
```

## 소스 빌드 (Go 1.21+)

GitHub release 바이너리가 플랫폼에 없거나 최신 main을 직접 빌드하고 싶을 때:

```bash
git clone https://github.com/microsoft/waza.git
cd waza
make install            # GOPATH/bin에 설치 (Go 1.21+, npm 필요 — web 대시보드 빌드 포함)
```

또는 사용자 디렉토리에 이미 클론되어 있다면:

```bash
cd ~/repos/waza
make install
```

`make install` 후 `$(go env GOPATH)/bin`이 PATH에 있는지 확인할 것.

## dotrc runner 준비 조건

바이너리 설치만으로 `~/.claude/data/waza-workspace/`가 만들어지지는 않는다. runner는 유효한 `.waza.yaml`과 `skills/`·`evals/` 상대 경로 및 대응 symlink가 이미 있을 때만 평가를 실행한다. 없으면 점수 없이 안전하게 종료한다.

워크스페이스를 만들 때는 현재 [upstream README](https://github.com/microsoft/waza/blob/main/README.md)의 초기화 절차와 스키마를 따른다. 빠르게 변하는 `.waza.yaml` 형식을 이 저장소가 임의로 생성하지는 않는다.

## 로컬 Ollama 모델

`waza-runner`는 Waza의 Copilot SDK BYOK 경로를 통해 로컬 Ollama의
`gemma4:26b-mlx`를 기본 평가 모델로 사용한다. 기본값은 다음과 같다.

```sh
COPILOT_PROVIDER_BASE_URL=http://localhost:11434/v1
COPILOT_PROVIDER_TYPE=openai
COPILOT_MODEL=gemma4:26b-mlx
COPILOT_OFFLINE=true
```

기존 환경변수 값이 있으면 runner 기본값보다 우선한다. Ollama 서버와 모델은
평가 전에 준비되어 있어야 한다.

## 트러블슈팅

**`waza: command not found` (셸에서는 보이는데 Claude Code 내부 Bash에서만 안 보임)**
- 비-interactive 셸이 `~/.zshrc`를 source하지 않아서 발생. 해결: PATH 추가 라인을 `~/.zshenv`로 옮기면 모든 셸에서 적용됨.
- 임시 우회: `waza-runner` 에이전트는 `$HOME/bin`, `/usr/local/bin`, GOPATH/bin을 자동으로 fallback 검색하므로 보통 그대로 동작한다.

**`Permission denied`**
- `chmod +x /usr/local/bin/waza` 또는 설치 위치의 바이너리에 실행 권한 부여.

**버전이 너무 낮음 (0.38.5 이하)**
- 로컬 Ollama BYOK 구성은 provider-only 모델 ID 수정이 포함된 0.35 이상이 필요하며, 현재 구성은 0.38.6 이상을 권장한다.

## 제거

```bash
rm -f "$(command -v waza)"
rm -rf "$HOME/.claude/data/waza-workspace" "$HOME/.claude/data/waza"
```

워크스페이스/결과 디렉토리는 dotrc 저장소 밖(`~/.claude/data/`)에 있어 git에 추적되지 않으므로 안전하게 제거 가능하다.

## 관련 위치

- workspace 설정: `~/.claude/data/waza-workspace/.waza.yaml`
- 평가 결과 JSON: `~/.claude/data/waza/results/`
- waza-runner 에이전트: `~/.claude/agents/waza-runner.md`
- eval.yaml 위치: `~/.claude/evals/<skill>/eval.yaml` (예: `~/.claude/evals/commit/eval.yaml`)
