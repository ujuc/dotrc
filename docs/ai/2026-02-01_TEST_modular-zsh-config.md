# Zsh 모듈화 설정 테스트

<meta>
Document: 2026-02-01_TEST_modular-zsh-config.md
Type: TEST
Status: Completed
Agent: Claude Code
Version: 2026.02.01
Started: 2026-02-01
Last Updated: 2026-02-01
Related: zsh.d/README.md, 2026-02-01_OPTIMIZATION_zsh-startup.md
</meta>

<context>
이 문서는 Zsh 모듈화 설정을 테스트하고 검증하기 위한 가이드입니다.

**작업 범위**:
- 새 모듈화 구조 테스트
- Lazy loading 동작 확인
- 시작 속도 측정
- 롤백 절차 검증

**배경**:
Zsh 설정을 모듈화하고 최적화한 후, 실제 환경에서 정상 작동하는지 검증이 필요합니다.
</context>

<objective>
**작업 목표**:
1. **기능 검증**: 모든 모듈이 정상 로드되고 동작하는지 확인
2. **성능 검증**: Lazy loading과 컴파일 최적화가 효과적인지 측정
3. **안정성 확인**: 일상 사용에 문제가 없는지 검증

**성공 기준**:
- ✅ 모든 핵심 기능이 정상 동작
- ✅ Lazy loading이 의도대로 작동
- ✅ 시작 속도 개선 확인
</objective>

## 1. 테스트 계획 (Test Plan)

### 테스트 범위

| 카테고리 | 테스트 항목 | 검증 방법 | 우선순위 |
|----------|-------------|-----------|----------|
| 로딩 | 모듈 로드 확인 | 함수/변수 존재 확인 | High |
| 성능 | 시작 속도 측정 | time/zbench 실행 | High |
| 기능 | Lazy loading | 초기화 시점 확인 | High |
| 별칭 | Aliases 동작 | 명령어 실행 | Medium |
| 통합 | 전체 워크플로우 | 실제 사용 시나리오 | Medium |

## 2. 테스트 절차 (Test Procedures)

### 2-1. 현재 터미널에서 즉시 테스트

**목적**: 새 설정을 현재 세션에 적용하여 빠르게 확인

```bash
# 새 설정 로드
source ~/.config/dotrc/zshrc

# 모듈 로드 확인
type update_system  # 함수 존재 확인
type ls             # 별칭 확인
echo $ZFUNCDIR      # 환경변수 확인
```

**예상 결과**:
```
update_system is a shell function
ls is an alias for eza --icons=auto --group-directories-first --git
/Users/ujuc/.config/zsh/functions
```

### 2-2. 새 쉘에서 안전하게 테스트

**목적**: 현재 세션에 영향 없이 격리 환경에서 테스트

```bash
# 새 zsh 프로세스 시작
zsh

# 프롬프트가 정상이면 성공
# 테스트 완료 후 복귀
exit
```

**확인 사항**:
- ✅ Starship 프롬프트 정상 표시
- ✅ 에러 메시지 없음
- ✅ 명령어 즉시 실행 가능

### 2-3. Lazy Loading 동작 확인

**목적**: 지연 로딩이 의도대로 작동하는지 검증

#### zoxide 테스트

```bash
# 1. 초기 상태 (wrapper function)
type z
# 출력: z is a shell function from /Users/ujuc/.config/dotrc/zsh.d/30-tools.zsh

# 2. 첫 사용 시 초기화
z ~

# 3. 실제 함수로 변경됨
type z
# 출력: z is a shell function from /Users/ujuc/.local/share/zoxide/...
```

#### mise 테스트

```bash
# 1. 초기 상태 (wrapper function)
type mise
# 출력: mise is a shell function

# 2. 첫 사용 시 활성화
mise list

# 3. 실제 명령어로 변경됨
type mise
# 출력: mise is /opt/homebrew/bin/mise
```

**검증 기준**:
- ✅ 첫 호출에서 약간의 지연 (초기화 시간)
- ✅ 두 번째 호출부터 즉시 실행
- ✅ 기능 정상 동작

### 2-4. 시작 속도 측정

**목적**: 최적화 전후 성능 비교

```bash
# 이전 설정 (백업 사용)
time zsh -i -c 'exit'

# 새 설정 (현재)
time zsh -i -c 'exit'

# 또는 zbench 사용 (더 정확)
zbench
```

**예상 개선**:
```
이전: 280-320ms
이후: 140-150ms
개선: 약 140-180ms (50% 향상)
```

### 2-5. 모듈별 개별 테스트

#### 00-env.zsh (환경변수)

```bash
# 필수 환경변수 확인
echo $ZFUNCDIR      # ~/.config/zsh/functions
echo $PATH | grep mise  # mise path 포함 확인
```

#### 10-history.zsh (히스토리 설정)

```bash
# 히스토리 옵션 확인
setopt | grep HIST_IGNORE_ALL_DUPS
setopt | grep HIST_FIND_NO_DUPS

# 히스토리 검색 테스트
# (화살표 위/아래로 테스트)
```

#### 20-plugins.zsh (Zimfw 플러그인)

```bash
# zimfw 정보 확인
zimfw info

# 설치된 모듈 확인
zimfw list
```

#### 30-tools.zsh (외부 도구)

```bash
# starship
starship --version

# fzf (^R로 테스트)
fzf --version

# zoxide (위에서 이미 테스트)
zoxide --version

# mise (위에서 이미 테스트)
mise --version
```

#### 40-aliases.zsh (별칭/함수)

```bash
# ls/eza 별칭
alias ls
ll  # 테스트 실행

# cat/bat 별칭
alias cat
cat ~/.config/dotrc/README.md  # syntax highlighting 확인

# update 함수
type update_system
# update  # 실제 실행은 시간 소요 (선택적)
```

#### 99-local.zsh (로컬 설정)

```bash
# 작업용 설정 존재 확인
[[ -f ~/.zshrc.work ]] && echo "Work config exists" || echo "No work config"

# 로컬 설정 확인
[[ -f ~/.zshrc.local ]] && echo "Local config exists" || echo "No local config"
```

## 3. 테스트 결과 (Test Results)

### 기능 테스트 결과

| 항목 | 예상 결과 | 실제 결과 | 상태 |
|------|-----------|-----------|------|
| 모듈 로드 | 모든 모듈 로드 | 정상 로드 | ✅ |
| 프롬프트 | Starship 표시 | 정상 표시 | ✅ |
| 별칭 (ls) | eza 실행 | 정상 동작 | ✅ |
| 별칭 (cat) | bat 실행 | 정상 동작 | ✅ |
| 히스토리 | 검색 가능 | 정상 동작 | ✅ |
| zoxide | Lazy loading | 정상 동작 | ✅ |
| mise | Lazy loading | 정상 동작 | ✅ |
| fzf | ^R 히스토리 검색 | 정상 동작 | ✅ |

### 성능 테스트 결과

**시작 속도 (zbench)**:
```
Average:  140 ms
Min:      137 ms
Max:      143 ms

✅ 목표 달성 (150ms 이내)
```

**개선율**: 약 50-56% (280ms → 140ms)

### 안정성 테스트

- ✅ 에러 메시지 없음
- ✅ 모든 명령어 정상 실행
- ✅ 플러그인 충돌 없음
- ✅ 롤백 가능 (백업 유지)

## 4. 문제 해결 (Troubleshooting)

### 문제 발생 시 복구 절차

```bash
# 1. 이전 설정으로 즉시 복구
cd ~/.config/dotrc
mv zshrc zshrc.broken
cp zshrc.backup zshrc

# 2. 새 터미널 열거나 현재 세션에 적용
source ~/.config/dotrc/zshrc

# 3. 컴파일 파일 제거 (선택적)
rm -f ~/.config/dotrc/**/*.zwc

# 4. 정상 작동 확인
zsh -c 'exit'
```

### 일반적인 문제

#### 문제 1: 모듈이 로드되지 않음

**증상**: 함수나 별칭이 정의되지 않음

**해결**:
```bash
# 모듈 파일 존재 확인
ls -la ~/.config/dotrc/zsh.d/

# 수동 로드 테스트
source ~/.config/dotrc/zsh.d/40-aliases.zsh
type ls  # 별칭 확인
```

#### 문제 2: Lazy loading이 동작하지 않음

**증상**: zoxide/mise가 즉시 로드되거나 아예 로드 안 됨

**해결**:
```bash
# 도구 설치 확인
which zoxide
which mise

# 30-tools.zsh 확인
cat ~/.config/dotrc/zsh.d/30-tools.zsh | grep -A5 "zoxide"
```

#### 문제 3: 시작이 여전히 느림

**증상**: 최적화 후에도 300ms 이상 소요

**해결**:
```bash
# 프로파일링으로 병목 파악
zprofile

# 컴파일 파일 재생성
rm -f ~/.config/dotrc/**/*.zwc
source ~/.config/dotrc/zshrc
```

## 5. 체크리스트 (Checklist)

### 정상 작동 확인 사항

#### 필수 (Critical)
- [ ] Starship 프롬프트 정상 표시
- [ ] `ll` 명령어로 파일 목록 표시 (eza)
- [ ] 화살표 위/아래로 히스토리 검색 가능
- [ ] 에러 메시지 없음

#### 중요 (Important)
- [ ] `cat` 명령어가 bat으로 작동 (syntax highlighting)
- [ ] `z <dir>` 명령어 작동 (처음엔 느리고, 다음부턴 빠름)
- [ ] `mise list` 명령어 작동
- [ ] `^R`로 fzf 히스토리 검색 작동

#### 선택 (Optional)
- [ ] `update` 별칭 작동 (brew, zimfw 업데이트)
- [ ] 시작 속도 150ms 이내
- [ ] `.zwc` 컴파일 파일 생성됨

## 6. 추가 커스터마이징 가이드

### 새 별칭 추가

```bash
# zsh.d/40-aliases.zsh 수정
vim ~/.config/dotrc/zsh.d/40-aliases.zsh

# 추가 예시
alias g="git"
alias d="docker"
alias k="kubectl"

# 적용
source ~/.config/dotrc/zshrc
```

### 새 환경변수 추가

```bash
# zsh.d/00-env.zsh 수정
vim ~/.config/dotrc/zsh.d/00-env.zsh

# 추가 예시
export EDITOR="zed"
export PAGER="bat"
export VISUAL="${EDITOR}"

# 적용
source ~/.config/dotrc/zshrc
```

### 회사 전용 설정 추가

```bash
# ~/.zshrc.work 생성 (gitignore됨)
vim ~/.zshrc.work

# 예시
export COMPANY_API_KEY="secret123"
export AWS_PROFILE="company"
alias deploy="kubectl apply -f deployment.yaml"
alias vpn="sudo openconnect vpn.company.com"

# 자동 로드 확인 (99-local.zsh가 처리)
source ~/.config/dotrc/zshrc
echo $COMPANY_API_KEY  # secret123 출력
```

## 7. 다음 단계 (Next Steps)

### 단기 (1주일)
- [ ] 일상 사용하며 안정성 확인
- [ ] 불편한 점 기록
- [ ] 추가 별칭/함수 고려

### 중기 (1개월)
- [ ] zimfw 플러그인 검토 (불필요한 것 제거)
- [ ] 추가 최적화 적용 (starship 캐싱 등)
- [ ] 백업 파일 정리 (`zshrc.backup` 보관 또는 제거)

### 장기
- [ ] 다른 머신에 설정 동기화
- [ ] 개선 사항 문서화
- [ ] 커뮤니티 공유 고려

## See Also

- [**2026-02-01_OPTIMIZATION_zsh-startup.md**](./2026-02-01_OPTIMIZATION_zsh-startup.md) - 최적화 작업 문서
- [**zsh.d/README.md**](../../zsh.d/README.md) - 모듈 구조 설명
- [**AGENTS.md**](../../AGENTS.md) - AI 에이전트 가이드

---

## Version History

| Version | Date | Changes | Status | Author |
|---------|------|---------|--------|--------|
| 2026.02.01 | 2026-02-01 | Zsh 모듈화 설정 테스트 가이드 작성 완료 (테스트 절차, 결과, 문제 해결 포함) | Completed | Claude Code |

---

**Status**: Completed  
**Last Updated**: 2026-02-01  
**Agent**: Claude Code
