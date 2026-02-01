# AI Generated Documentation

<meta>
Directory: docs/ai/
Purpose: AI 에이전트 작업 기록 및 문서 보관소
Versioned: Yes (Git tracked)
Template: work-template.md
Last Updated: 2026-02-01
</meta>

AI 에이전트(Claude Code, GitHub Copilot, Cursor 등)가 생성하는 모든 작업 문서를 저장하고 버전 관리하는 디렉토리입니다.

## 목적

- ✅ AI 에이전트의 작업 과정과 결과를 체계적으로 기록
- ✅ 작업 히스토리를 Git으로 추적하여 변경 이력 관리
- ✅ 메타데이터와 버저닝을 통한 문서 품질 관리
- ✅ 프로젝트 지식베이스로 활용

## 디렉토리 구조

```
docs/ai/
├── README.md                      # 이 문서
├── work-template.md               # AI 작업 문서 템플릿
├── YYYY-MM-DD_<TYPE>_<DESC>.md   # 작업 문서 (날짜 접두사)
└── archive/                       # 완료된 작업 (선택적)
    └── YYYY-MM/
        └── old-work.md
```

## 문서 유형 (Types)

| Type | 설명 | 예시 |
|------|------|------|
| `OPTIMIZATION` | 성능 최적화 작업 | `2026-02-01_OPTIMIZATION_zsh-startup.md` |
| `TEST` | 테스트 및 검증 | `2026-02-01_TEST_new-config.md` |
| `REFACTOR` | 코드 리팩토링 | `2026-02-01_REFACTOR_zsh-modules.md` |
| `REVIEW` | 코드 리뷰 | `2026-02-01_REVIEW_commit-abc123.md` |
| `TROUBLESHOOT` | 문제 해결 | `2026-02-01_TROUBLESHOOT_startup-lag.md` |
| `ANALYSIS` | 분석 및 조사 | `2026-02-01_ANALYSIS_tool-comparison.md` |
| `IMPLEMENTATION` | 기능 구현 | `2026-02-01_IMPLEMENTATION_new-feature.md` |
| `DOCUMENTATION` | 문서화 작업 | `2026-02-01_DOCUMENTATION_agents-md.md` |

## 파일 명명 규칙

```
YYYY-MM-DD_<TYPE>_<description>.md

필수 요소:
- 날짜 (YYYY-MM-DD): 작업 시작일
- 타입 (TYPE): 위 표의 문서 유형 중 하나
- 설명 (description): kebab-case로 작성, 간결하고 명확하게

예시:
✅ 2026-02-01_OPTIMIZATION_zsh-startup.md
✅ 2026-02-01_REFACTOR_config-modules.md
✅ 2026-01-15_ANALYSIS_tool-comparison.md

❌ optimization.md (날짜 없음)
❌ 2026-02-01_fix_bug.md (타입이 표준이 아님)
❌ 2026-02-01_OPTIMIZATION_This is a test.md (공백 사용)
```

## 템플릿 사용

새 작업 문서를 만들 때는 `work-template.md`를 복사하여 시작하세요:

```bash
# 수동 생성
cp docs/ai/work-template.md docs/ai/2026-02-01_OPTIMIZATION_my-work.md

# Claude Code로 생성
"새로운 최적화 작업을 시작하고 docs/ai/에 문서를 만들어줘"
```

## 메타데이터 필수 항목

모든 문서는 다음 메타데이터를 포함해야 합니다:

```markdown
<meta>
Document: YYYY-MM-DD_TYPE_description.md
Type: [Type from table above]
Status: [Planning/In Progress/Completed/Archived]
Agent: [Claude Code/GitHub Copilot/Cursor/etc.]
Version: YYYY.MM.PATCH
Started: YYYY-MM-DD
Last Updated: YYYY-MM-DD
</meta>
```

## 버저닝 규칙

**CalVer (Calendar Versioning)** 사용: `YYYY.MM.PATCH`

- **YYYY**: 연도 (4자리)
- **MM**: 월 (2자리, 01-12)
- **PATCH**: 해당 월 내에서의 수정 번호 (01부터 시작)

**특징**:
- 날짜 기반으로 문서 생성/수정 시점을 명확히 표시
- 월이 바뀌면 PATCH는 01부터 다시 시작
- 상태는 Version이 아닌 Status 필드로 관리

예시:
```
2026.02.01 - 2월 첫 번째 버전 (초기 작성)
2026.02.02 - 2월 두 번째 버전 (분석 완료 업데이트)
2026.02.03 - 2월 세 번째 버전 (구현 완료 업데이트)
2026.02.04 - 2월 네 번째 버전 (작업 완료)
2026.03.01 - 3월 첫 번째 버전 (새로운 작업)
```

## Git 워크플로우

### 새 작업 시작
```bash
# 1. 템플릿에서 문서 생성
cp docs/ai/work-template.md docs/ai/2026-02-01_OPTIMIZATION_my-work.md

# 2. 메타데이터 작성
vim docs/ai/2026-02-01_OPTIMIZATION_my-work.md

# 3. Git 커밋
git add docs/ai/2026-02-01_OPTIMIZATION_my-work.md
git commit -m "docs(ai): 새로운 최적화 작업을 시작하다"
```

### 작업 진행 중
```bash
# 주요 업데이트마다 커밋
git add docs/ai/2026-02-01_OPTIMIZATION_my-work.md
git commit -m "docs(ai): 최적화 분석 단계를 완료하다 (v1.1.0)"
```

### 작업 완료
```bash
# 상태를 Completed로 변경하고 최종 커밋
git add docs/ai/2026-02-01_OPTIMIZATION_my-work.md
git commit -m "docs(ai): 최적화 작업을 완료하다 (v2026.02.04)"

# 선택적: 보관함으로 이동
mkdir -p docs/ai/archive/2026-02
git mv docs/ai/2026-02-01_OPTIMIZATION_my-work.md docs/ai/archive/2026-02/
git commit -m "docs(ai): 완료된 최적화 문서를 보관하다"
```

## 문서 라이프사이클

```
Planning (2026.02.01)
    ↓
In Progress (2026.02.02, 2026.02.03, ...)
    ↓
Completed (Status 변경)
    ↓
Archived (선택적, archive/ 이동)
```

**참고**: 상태(Status)는 메타데이터의 Status 필드로 관리하며, 버전은 단순히 수정 횟수를 표시합니다.

## AI 에이전트별 사용법

### Claude Code
```bash
# 자동 문서 생성
pi "Zsh 시작 속도 최적화 작업을 시작하고 docs/ai/에 문서를 만들어줘"

# 작업 업데이트
pi "현재 최적화 작업 문서를 업데이트해줘 (분석 완료)"

# 작업 완료
pi "최적화 작업 문서를 완료 상태로 변경하고 최종 정리해줘"
```

### GitHub Copilot / Cursor
```bash
# 주석으로 문서 생성 요청
# @docs/ai Create optimization work document for zsh startup

# 파일 편집 후 메타데이터 자동 완성
# Version: 1.1.0 [Copilot이 제안]
```

## 정리 및 유지보수

### 정기 정리 (월 1회 권장)
```bash
# 완료된 작업을 보관함으로 이동
mkdir -p docs/ai/archive/$(date +%Y-%m)
mv docs/ai/YYYY-MM-DD_*_*.md docs/ai/archive/$(date +%Y-%m)/

# 또는 스크립트 작성
./scripts/archive-ai-docs.sh
```

### 문서 검색
```bash
# 특정 타입 문서 찾기
find docs/ai -name "*_OPTIMIZATION_*"

# 날짜 범위로 찾기
find docs/ai -name "2026-02-*"

# 내용 검색
rg "zsh startup" docs/ai/
```

## 관련 디렉토리

- **`claude/guides/`** - Claude Code 가이드라인 (영구 문서, 정책)
- **`claude/skills/`** - Claude 자동 스킬 (기능 정의)
- **`claude/templates/`** - 문서 템플릿 (가이드 템플릿 등)
- **`docs/ai/`** - AI 작업 문서 (이 디렉토리, 작업 기록)

## 예시 문서

실제 사용 예시는 다음 문서를 참고하세요:
- `2026-02-01_OPTIMIZATION_zsh-startup.md` - Zsh 시작 속도 최적화
- `2026-02-01_TEST_new-config.md` - 새 설정 테스트
- `2026-02-01_DOCUMENTATION_agents-md.md` - AGENTS.md 문서화

## 문서 품질 기준

### 필수 (Must Have)
- ✅ 올바른 메타데이터 (모든 필드 작성)
- ✅ 명확한 제목과 설명
- ✅ 작업 목표 명시
- ✅ 버전 정보 (업데이트마다 증가)

### 권장 (Should Have)
- ✅ 작업 컨텍스트 설명
- ✅ 단계별 진행 과정
- ✅ 결과 요약
- ✅ 관련 문서 링크

### 선택 (Nice to Have)
- ✅ 코드 예시
- ✅ 스크린샷/로그
- ✅ 성능 비교표
- ✅ 학습한 내용 (Lessons Learned)

---

**Maintainer**: AI Agents (Claude Code, GitHub Copilot, Cursor, etc.)  
**Version**: 2.0.0  
**Last Updated**: 2026-02-01
