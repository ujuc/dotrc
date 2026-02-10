---
# Work Document Metadata (YAML Frontmatter)
# Reference: https://agentskills.io/specification#frontmatter-required
name: "[YYYY-MM-DD_TYPE_description]"
description: "[이 작업 문서의 목적을 한 문장으로 설명]"
version: "YYYY.MM.01"

# Optional fields
tags: []
context: |
  이 문서는 [작업 목적]을 위해 작성되었습니다.

  **작업 범위**:
  - [범위 1]
  - [범위 2]
  - [범위 3]

  **배경**:
  [이 작업을 수행하게 된 이유나 문제 상황 설명]
last_updated: "YYYY-MM-DD"

# Work-specific fields
metadata:
  type: "[OPTIMIZATION/TEST/REFACTOR/REVIEW/TROUBLESHOOT/ANALYSIS/IMPLEMENTATION/DOCUMENTATION]"
  status: "Planning"
  agent: "[현재 사용 중인 모델명 기록. e.g., Claude Sonnet 4, GPT-4o, Gemini 2.5 Pro]"
  related: "[관련 문서/이슈/PR 링크]"
  started: "YYYY-MM-DD"
---

# [Work Title]

<!-- Objective: 작업의 구체적인 목표와 성공 기준을 정의합니다 -->
## Objective

**작업 목표**:
1. [목표 1]: 구체적이고 측정 가능한 목표
2. [목표 2]: 구체적이고 측정 가능한 목표
3. [목표 3]: 구체적이고 측정 가능한 목표

**성공 기준**:
- ✅ [기준 1]
- ✅ [기준 2]
- ✅ [기준 3]

## 1. 분석 (Analysis)

### 현재 상태 (Current State)

[현재 상황에 대한 분석]

```bash
# 현재 상태 확인 명령어/코드
```

### 문제점 (Issues)

- **Issue 1**: 설명
- **Issue 2**: 설명
- **Issue 3**: 설명

### 원인 분석 (Root Cause)

[문제의 근본 원인 분석]

## 2. 계획 (Planning)

### 접근 방법 (Approach)

[선택한 접근 방법과 그 이유]

### 작업 단계 (Steps)

| 단계 | 작업 내용 | 예상 시간 | 상태 |
|------|-----------|-----------|------|
| 1 | [작업 1] | [시간] | ⬜️ Todo |
| 2 | [작업 2] | [시간] | ⬜️ Todo |
| 3 | [작업 3] | [시간] | ⬜️ Todo |
| 4 | [작업 4] | [시간] | ⬜️ Todo |

**상태 표시**:
- ⬜️ Todo
- 🔄 In Progress
- ✅ Done
- ❌ Blocked

### 예상 영향 (Impact)

**변경될 파일**:
- `path/to/file1` - 변경 내용
- `path/to/file2` - 변경 내용

**의존성**:
- [의존하는 도구/라이브러리]
- [영향받는 다른 설정]

## 3. 구현 (Implementation)

### 변경 사항 (Changes)

#### 파일 1: `path/to/file`

**변경 전**:
```language
# 이전 코드
```

**변경 후**:
```language
# 새 코드
```

**변경 이유**: [설명]

#### 파일 2: `path/to/file`

[같은 형식으로 반복]

### 주요 결정 사항 (Key Decisions)

1. **결정**: [내용]
   - **이유**: [설명]
   - **대안**: [고려했던 다른 방법]

2. **결정**: [내용]
   - **이유**: [설명]
   - **대안**: [고려했던 다른 방법]

## 4. 테스트 (Testing)

### 테스트 계획 (Test Plan)

| 테스트 케이스 | 예상 결과 | 실제 결과 | 상태 |
|---------------|-----------|-----------|------|
| [케이스 1] | [예상] | [실제] | ✅/❌ |
| [케이스 2] | [예상] | [실제] | ✅/❌ |
| [케이스 3] | [예상] | [실제] | ✅/❌ |

### 테스트 결과 (Test Results)

```bash
# 테스트 명령어 및 결과
```

**발견된 이슈**:
- [이슈 1]: 해결 방법
- [이슈 2]: 해결 방법

## 5. 결과 (Results)

### 달성한 목표 (Achievements)

- ✅ [목표 1]: [결과 설명]
- ✅ [목표 2]: [결과 설명]
- ⚠️ [목표 3]: [부분 달성 또는 미달성 설명]

### 성능 비교 (Performance Comparison)

**변경 전**:
```
지표 1: [값]
지표 2: [값]
지표 3: [값]
```

**변경 후**:
```
지표 1: [값] ([개선율]% 개선)
지표 2: [값] ([개선율]% 개선)
지표 3: [값] ([개선율]% 개선)
```

### 스크린샷/로그 (Evidence)

```
[관련 로그나 출력 결과]
```

## 6. 문서화 (Documentation)

### 업데이트된 문서

- [x] `README.md` - [변경 내용]
- [x] `AGENTS.md` - [변경 내용]
- [ ] `docs/other.md` - [예정]

### 새로 추가된 문서

- `docs/new-doc.md` - [설명]

## 7. 후속 작업 (Follow-up)

### 남은 작업 (Remaining Tasks)

- [ ] [작업 1]
- [ ] [작업 2]
- [ ] [작업 3]

### 개선 사항 (Future Improvements)

- [개선 1]: [설명]
- [개선 2]: [설명]

### 관련 이슈/PR

- Issue #XXX: [제목]
- PR #YYY: [제목]

## 8. 회고 (Retrospective)

### 잘된 점 (What Went Well)

- [항목 1]
- [항목 2]

### 개선할 점 (What Could Be Improved)

- [항목 1]
- [항목 2]

### 배운 점 (Lessons Learned)

- [교훈 1]
- [교훈 2]

<!-- See Also: 항상 AGENTS.md, CLAUDE.md 를 포함하고, 관련 문서를 추가합니다 -->
## See Also

- [**AGENTS.md**](../../AGENTS.md) - Universal AI agent guide
- [**CLAUDE.md**](../../claude/CLAUDE.md) - Claude-specific guidelines

<!-- 아래는 예시입니다. 관련 문서에 맞게 수정하세요 -->
<!-- - [**README.md**](../ai/README.md) - AI documentation directory guide -->
<!-- - [Related work document](./YYYY-MM-DD_TYPE_related.md) - Description -->

---

## Version History

| Version | Date | Changes | Status |
|---------|------|---------|--------|
| YYYY.MM.01 | YYYY-MM-DD | 초기 작성 | Planning |
| YYYY.MM.02 | YYYY-MM-DD | [변경 사항] | In Progress |
| YYYY.MM.03 | YYYY-MM-DD | [변경 사항] | Completed |
