# README 기반 설치 스크립트 설계

## 목적

`README.md`에 흩어진 macOS 개발 환경 설치 명령을 하나의 Bash 스크립트로 자동화한다. 패키지 그룹을 선택해 실행할 수 있고, 재실행해도 이미 완료된 항목을 안전하게 유지해야 한다.

## 인터페이스

스크립트는 `scripts/install.sh`에 둔다.

```sh
./scripts/install.sh --cli
./scripts/install.sh --apps
./scripts/install.sh --fonts
./scripts/install.sh --agents
./scripts/install.sh --cli --agents
./scripts/install.sh --all
```

- 인자가 없거나 `--help`를 사용하면 도움말만 출력한다.
- 그룹 옵션은 함께 사용할 수 있다.
- `--all`은 모든 그룹을 선택한다.
- 알 수 없는 옵션은 사용법과 오류를 출력하고 실패한다.

## 설치 그룹

### `--cli`

- Homebrew가 없으면 공식 설치 스크립트로 설치한다.
- 1Password CLI, GitHub CLI, Starship, ZimFW와 README의 CLI 패키지를 설치한다.
- Starship, Zsh, Bat, Tig 설정을 심볼릭 링크로 연결한다.
- Git 전역 설정과 저장소별 hooks 경로를 구성한다.
- Git 이름과 이메일은 기존 값을 재사용하고, 없을 때만 입력받는다.
- GitHub CLI가 인증되지 않았을 때만 `gh auth login`을 실행한다.

### `--apps`

- Raycast, Zed, Visual Studio Code, Ollama, Ghostty와 README의 기타 앱을 설치한다.
- Zed와 Ghostty 설정을 심볼릭 링크로 연결한다.
- Ollama 모델 가져오기를 실행한다.
- Rosetta 설치처럼 권한이 필요한 명령은 macOS의 표준 인증 흐름을 사용한다.

### `--fonts`

- README에 열거된 Homebrew 폰트 cask를 항목별로 설치한다.

### `--agents`

- Git 서브모듈을 초기화한다.
- Claude Code와 Pi를 설치한다.
- Claude, Codex, Amp 설정과 스킬을 README의 경로로 연결한다.
- README의 Claude 플러그인 marketplace와 플러그인을 `claude plugin` CLI로 등록·설치한다.
- Claude 세션 내부에서만 가능한 HUD 설정은 완료 안내에 수동 단계로 표시한다.

## 안전성과 멱등성

- 선택된 그룹의 모든 심볼릭 링크를 설치 전에 검사한다.
- 링크가 이미 올바른 대상을 가리키면 통과한다.
- 다른 파일, 디렉터리 또는 링크가 있으면 변경하기 전에 충돌 경로를 알리고 중단한다.
- 비밀번호와 토큰은 스크립트가 직접 받거나 저장하지 않는다.
- 패키지 관리 도구와 인증 도구의 기존 상태를 확인해 완료된 작업은 안전하게 재실행한다.

## 실패 처리

- 패키지와 설치 작업은 항목별로 실행해 실패 대상을 식별할 수 있게 한다.
- 독립 항목이 실패해도 나머지 항목은 계속 실행한다.
- 각 실패에는 그룹, 항목명, 실행 명령, 종료 코드와 원본 도구 출력을 보존한다.
- 실행 종료 시 실패 항목과 재실행에 필요한 명령을 모아 출력하고 0이 아닌 상태로 종료한다.
- 링크 충돌이나 필수 실행 환경처럼 후속 결과를 신뢰할 수 없게 만드는 사전 검사 실패는 즉시 중단한다.

## 문서와 검증

- `README.md`에 그룹 옵션과 대표 사용 예를 추가한다.
- `bash -n scripts/install.sh`로 구문을 검사한다.
- ShellCheck가 있으면 `shellcheck scripts/install.sh`을 실행한다.
- 인자 없음, `--help`, 알 수 없는 옵션과 링크 사전 검사 경로를 실제 설치 없이 확인한다.
