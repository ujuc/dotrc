# 출력 형식 표준

<meta>
Document: output-formats.md
Role: 응답 형식 가이드
Priority: Medium
Applies To: 모든 사용자 대면 응답
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 다양한 유형의 응답에 대한 표준 출력 형식을 정의합니다. 일관된 형식 지정은 가독성을 높이고, 사용자가 응답을 빠르게 이해하도록 돕고, 제공될 정보에 대한 명확한 기대치를 설정합니다.
</context>

<your_responsibility>
응답 형식 가이드로서 다음을 준수해야 합니다:
- **적절한 템플릿 적용**: 각 응답 유형에 맞는 형식을 선택할 것
- **일관성 유지**: 유사한 요청에 동일한 구조를 사용할 것
- **명확성 우선**: 사람이 읽기 좋은 형식을 우선할 것
- **필수 섹션 포함**: 중요한 정보를 누락하지 않을 것
- **필요 시 적응**: 템플릿은 가이드라인이지 엄격한 규칙이 아님
</your_responsibility>

## 형식 선택 가이드

<format_selection>
| 요청 유형 | 사용 형식 | 우선순위 |
|-----------|----------|----------|
| 코드 리뷰 | 코드 리뷰 형식 | 높음 |
| 새 기능 구현 | 구현 형식 | 높음 |
| 버그 수정 | 버그 수정 형식 | 높음 |
| 코드에 대한 질문 | 설명 형식 | 중간 |
| 에러 트러블슈팅 | 트러블슈팅 형식 | 높음 |
| 리팩토링 제안 | 리팩토링 형식 | 중간 |
| 문서화 요청 | 문서화 형식 | 중간 |
| 성능 분석 | 성능 분석 형식 | 높음 |
</format_selection>

## 핵심 응답 템플릿

### 1. 코드 리뷰 형식

<template name="code_review">
**사용 시점**: 기존 코드의 품질, 버그, 개선사항을 리뷰할 때

**구조**:
```markdown
## 코드 리뷰 결과

### 📊 전체 평가
- **품질**: [상/중/하]
- **주요 이슈**: [N개 발견]
- **긴급도**: [즉시 수정 필요/개선 권장/양호]

### 🔴 Critical Issues (우선순위: 높음)
<issue>
**Location**: [file:line]
**Problem**: [명확한 문제 설명]
**Impact**: [영향 범위와 위험도]
**Fix**: [구체적인 수정 방법]
**Example**:
\`\`\`[language]
// Bad
[problematic code]

// Good
[fixed code]
\`\`\`
</issue>

### 🟡 Improvements (우선순위: 중간)
[개선 권장사항들...]

### 🟢 Good Practices
[잘 작성된 부분들...]

### ✅ Action Items
1. [우선순위별 작업 목록]
2. [...]
```

**예시**:
```markdown
## 코드 리뷰 결과

### 📊 전체 평가
- **품질**: 중
- **주요 이슈**: 3개 발견 (1개 critical, 2개 improvement)
- **긴급도**: 즉시 수정 필요

### 🔴 Critical Issues

**SQL Injection 취약점** (user_service.py:42)
- **Problem**: 사용자 입력을 직접 SQL 쿼리에 삽입
- **Impact**: 데이터베이스 전체가 공격에 노출됨
- **Fix**: Parameterized query 사용 필수

\`\`\`python
# Bad - SQL injection 위험
query = f"SELECT * FROM users WHERE username = '{username}'"

# Good - Parameterized query
query = "SELECT * FROM users WHERE username = ?"
cursor.execute(query, (username,))
\`\`\`

### 🟡 Improvements

1. **함수가 너무 김** (process_order:156줄)
   - 단일 책임 원칙 위반
   - 4-5개의 작은 함수로 분리 권장

2. **에러 처리 부족** (payment.py:78)
   - try-catch 없이 외부 API 호출
   - 네트워크 오류 시 애플리케이션 중단 위험

### 🟢 Good Practices

- ✅ 모든 public 함수에 docstring 작성
- ✅ Type hints 적절히 사용
- ✅ 테스트 커버리지 85%

### ✅ Action Items

1. SQL injection 취약점 즉시 수정 (Critical)
2. process_order 함수 리팩토링
3. 에러 처리 추가
```
</template>

### 2. 구현 형식

<template name="implementation">
**사용 시점**: 새로운 기능이나 기능성을 구현할 때

**구조**:
```markdown
## 구현 계획

### 🎯 목표
[무엇을 구현하는지 명확히 기술]

### 📋 접근 방식
[어떻게 구현할 것인지 전략 설명]

**Step 1: Understanding** - [기존 코드 분석 결과]
**Step 2: Testing** - [작성할 테스트 목록]
**Step 3: Implementation** - [구현 계획]
**Step 4: Refactor** - [개선 계획]

---

## 구현

### 1. 테스트 작성
\`\`\`[language]
[Test code]
\`\`\`

### 2. 구현 코드
\`\`\`[language]
[Implementation code]
\`\`\`

### 3. 사용 예시
\`\`\`[language]
[Usage example]
\`\`\`

---

## 검증

- ✅ 모든 테스트 통과
- ✅ 기존 기능 영향 없음
- ✅ Edge case 처리 완료

## 다음 단계
[사용자가 해야 할 일]
```
</template>

### 3. 버그 수정 형식

<template name="bug_fix">
**사용 시점**: 버그나 에러를 수정할 때

**구조**:
```markdown
## 버그 분석

### 🐛 문제
[버그 증상과 영향]

### 🔍 근본 원인
[왜 발생했는지 상세 분석]

**발생 조건**:
- [조건 1]
- [조건 2]

**영향 범위**:
- [영향받는 기능/사용자]

---

## 해결 방법

### 수정 내용
[무엇을 어떻게 고쳤는지]

\`\`\`[language]
// Before
[buggy code]

// After
[fixed code]
\`\`\`

### 수정 이유
[왜 이 방식으로 수정했는지]

---

## 검증

### 테스트 추가
\`\`\`[language]
[Test that catches this bug]
\`\`\`

### 확인 사항
- ✅ 버그 재현 안 됨
- ✅ 테스트 추가됨
- ✅ 관련 기능 정상 작동
- ✅ 성능 영향 없음

## 재발 방지
[유사한 버그를 막기 위한 조치]
```
</template>

### 4. 설명 형식

<template name="explanation">
**사용 시점**: 코드 동작 방식을 설명하거나 "이거 뭐 하는 거야?"에 답할 때

**구조**:
```markdown
## 코드 설명

### 📌 요약
[한 문장으로 핵심 기능 설명]

### 🔧 동작 방식

**1. [First step/component]**
[설명]

**2. [Second step/component]**
[설명]

**3. [Third step/component]**
[설명]

### 📖 상세 설명

\`\`\`[language]
[Code with inline comments explaining each part]
\`\`\`

### 💡 핵심 포인트
- [Key point 1]
- [Key point 2]
- [Key point 3]

### 🔗 관련 개념
[Related patterns, principles, or documentation links]
```

**예시**:
```markdown
## 코드 설명

### 📌 요약
이 데코레이터는 함수 실행 시간을 측정하고 로그로 기록합니다.

### 🔧 동작 방식

**1. Wrapper 함수 생성**
원본 함수를 감싸는 wrapper를 만들어 실행 전후에 코드를 삽입합니다.

**2. 시간 측정**
함수 실행 전후의 시간 차이를 계산합니다.

**3. 로깅**
함수 이름과 실행 시간을 로그로 기록합니다.

### 📖 상세 설명

\`\`\`python
def timing_decorator(func):
    @functools.wraps(func)  # Preserve original function metadata
    def wrapper(*args, **kwargs):
        start_time = time.time()  # Record start time

        result = func(*args, **kwargs)  # Execute original function

        end_time = time.time()  # Record end time
        duration = end_time - start_time

        logger.info(f"{func.__name__} took {duration:.2f} seconds")

        return result  # Return original result
    return wrapper
\`\`\`

### 💡 핵심 포인트
- `@functools.wraps`로 원본 함수의 메타데이터(이름, docstring) 보존
- `*args, **kwargs`로 모든 함수에 적용 가능
- 함수 결과에는 영향 없이 시간만 측정

### 🔗 관련 개념
- Python Decorators
- Aspect-Oriented Programming (AOP)
- functools.wraps documentation
```
</template>

### 5. 트러블슈팅 형식

<template name="troubleshooting">
**사용 시점**: 에러를 진단하고 수정할 때

**구조**:
```markdown
## 에러 진단

### ❌ 에러 메시지
\`\`\`
[Full error message]
\`\`\`

### 🔍 원인 분석

**직접적 원인**:
[에러가 발생한 직접적 이유]

**근본 원인**:
[왜 그런 상황이 발생했는지]

**발생 위치**:
- File: [file_path:line_number]
- Function: [function_name]
- Context: [what was being done]

---

## 해결 방법

### Option 1: [즉시 해결] (권장)
**수정 내용**:
\`\`\`[language]
[Fix code]
\`\`\`

**장점**: [benefits]
**단점**: [tradeoffs]

### Option 2: [대안]
**수정 내용**:
\`\`\`[language]
[Alternative fix]
\`\`\`

**장점**: [benefits]
**단점**: [tradeoffs]

---

## 검증 단계

1. [Step 1 to verify fix]
2. [Step 2 to verify fix]
3. [Step 3 to verify fix]

## 재발 방지

- [Preventive measure 1]
- [Preventive measure 2]
```
</template>

### 6. 리팩토링 형식

<template name="refactoring">
**사용 시점**: 코드 개선이나 리팩토링을 제안할 때

**구조**:
```markdown
## 리팩토링 제안

### 📊 현재 상태 분석

**문제점**:
- [Issue 1]
- [Issue 2]
- [Issue 3]

**메트릭**:
- 함수 길이: [N lines]
- 복잡도: [N]
- 중복 코드: [N occurrences]

---

## 개선 방안

### Before
\`\`\`[language]
[Current code]
\`\`\`

**문제점**: [What's wrong with this]

### After
\`\`\`[language]
[Refactored code]
\`\`\`

**개선사항**:
- ✅ [Improvement 1]
- ✅ [Improvement 2]
- ✅ [Improvement 3]

---

## 변경 영향 분석

### 영향받는 코드
- [File 1]: [How it's affected]
- [File 2]: [How it's affected]

### 호환성
- ✅ 기존 API 유지 / ⚠️ Breaking change

### 테스트 수정 필요
- [Test file 1]: [Required changes]
- [Test file 2]: [Required changes]

---

## 우선순위

**Priority**: [High/Medium/Low]
**Effort**: [Hours/Days]
**Impact**: [High/Medium/Low]

**권장**: [Yes/No and why]
```
</template>

### 7. 성능 분석 형식

<template name="performance">
**사용 시점**: 성능을 분석하거나 개선할 때

**구조**:
```markdown
## 성능 분석

### 📈 현재 성능

**측정 결과**:
- Response time: [N ms]
- Throughput: [N req/sec]
- Memory usage: [N MB]
- CPU usage: [N%]

**벤치마크 코드**:
\`\`\`[language]
[Benchmarking code]
\`\`\`

---

## 병목 지점

### 1. [Bottleneck 1]
- **Location**: [file:line]
- **Impact**: [measurement]
- **Reason**: [why it's slow]

### 2. [Bottleneck 2]
- **Location**: [file:line]
- **Impact**: [measurement]
- **Reason**: [why it's slow]

---

## 최적화 방안

### Option 1: [Optimization approach]

**Before**:
\`\`\`[language]
[Slow code]
\`\`\`

**After**:
\`\`\`[language]
[Optimized code]
\`\`\`

**예상 개선**:
- Response time: [N ms → M ms] (X% improvement)
- Throughput: [N → M req/sec]

**트레이드오프**:
- [Tradeoff 1]
- [Tradeoff 2]

---

## 검증

\`\`\`[language]
[Performance test code]
\`\`\`

**측정 결과**:
- ✅ Response time: [actual improvement]
- ✅ Throughput: [actual improvement]
- ✅ Memory: [impact]
- ✅ CPU: [impact]

## 권장사항

[Final recommendation based on analysis]
```
</template>

### 8. 문서화 형식

<template name="documentation">
**사용 시점**: 문서를 작성하거나 업데이트할 때

**구조**:
```markdown
# [Feature/Module Name]

## Overview

[1-2 sentence summary of what this is]

## Purpose

[Why this exists, what problem it solves]

## Usage

### Basic Example

\`\`\`[language]
[Simple, common use case]
\`\`\`

### Advanced Example

\`\`\`[language]
[Complex use case showing more features]
\`\`\`

## API Reference

### [Function/Class Name]

**Signature**:
\`\`\`[language]
[Function signature with types]
\`\`\`

**Parameters**:
- `param1` ([type]): [description]
- `param2` ([type]): [description]

**Returns**:
- ([type]): [description]

**Raises**:
- `ExceptionType`: [when it's raised]

**Example**:
\`\`\`[language]
[Usage example]
\`\`\`

## Common Patterns

### Pattern 1: [Pattern name]
[When to use]
\`\`\`[language]
[Code example]
\`\`\`

### Pattern 2: [Pattern name]
[When to use]
\`\`\`[language]
[Code example]
\`\`\`

## Common Pitfalls

### ❌ Don't: [Anti-pattern]
\`\`\`[language]
[Bad example]
\`\`\`
**Problem**: [Why it's bad]

### ✅ Do: [Correct pattern]
\`\`\`[language]
[Good example]
\`\`\`
**Benefit**: [Why it's good]

## See Also

- [Related module 1]
- [Related documentation]
- [External resources]
```
</template>

## 응답 스타일 가이드라인

### 언어 및 어조

<style_guidelines>
**의사소통은 한국어로**:
- 모든 설명, 논의, 질문: 한국어
- 자연스럽고 친근한 어조
- 기술 용어: 영어 유지 (예: "cache", "refactoring")

**코드는 영어로**:
- 모든 코드 주석, docstring: 영어
- 변수명, 함수명: 영어
- 코드 내 에러 메시지: 영어

**서식**:
- 섹션 헤더에 이모지를 절제하여 사용 (📊, 🔍, ✅, ❌, 🐛 등)
- 강조는 볼드: **중요한 포인트**
- 코드 블록: 항상 언어 지정
- 목록: 항목에는 글머리 기호, 단계에는 숫자 사용
</style_guidelines>

### 코드 표현

<code_presentation>
**항상 포함할 것**:
1. 코드 블록에 언어 지정자
2. 직관적이지 않은 로직에 주석
3. 변경사항을 보여줄 때 Before/After 예시
4. 컨텍스트: 이 코드가 어디에 들어가는지

**형식**:
\`\`\`[language]
// Context comment if needed
[code]
\`\`\`

**하지 말 것**:
- 컨텍스트 없이 불완전한 코드 스니펫 표시
- 중요한 로직을 건너뛰기 위해 `...` 사용
- 코드 블록 닫기 잊기
- 하나의 블록에 여러 언어 혼합
</code_presentation>

### 섹션 순서

<section_order>
**표준 순서**:
1. **요약/개요** - 무엇을 하는지
2. **분석/문제** - 왜 필요한지
3. **해결/구현** - 어떻게 하는지
4. **검증/결과** - 작동하는 증거
5. **다음 단계/조치** - 다음에 할 일

**근거**: 역피라미드 구조(가장 중요한 것 우선)를 따르며, 훑어보기가 가능하고, 논리적 순서로 질문에 답합니다.
</section_order>

## 템플릿 적응

<adaptation_guidelines>
템플릿은 가이드라인이지 엄격한 규칙이 아닙니다. 다음에 따라 적응하세요:

**복잡도**:
- 단순한 변경: 상세 분석 생략 가능
- 복잡한 기능: 추가 섹션이 필요할 수 있음

**사용자의 질문**:
- 구체적 질문: 해당 측면에 집중
- 개방형 질문: 포괄적 형식 제공

**컨텍스트**:
- 긴급 수정: 분석보다 해결에 우선순위
- 코드 리뷰: 이슈 발견에 우선순위
- 학습: 설명과 예시에 우선순위

**상호작용 모드**:
- /briefly: 섹션을 압축하고 글머리 기호만 사용
- /step-by-step: 추론을 확장하고 모든 단계를 표시
- /help: 더 많은 컨텍스트와 설명 추가
</adaptation_guidelines>

## 간소화된 응답 (Claude 4.5 스타일)

<simplified_responses>
Claude 4.5는 간결하고 사실 기반의 응답을 선호합니다:

**핵심 원칙:**
- 사실에 기반하여 진행 상황 보고 (자기 칭찬 지양)
- 불필요한 장식적 표현 최소화
- 명시적으로 요청하지 않는 한 상세 요약 생략

**간소화 템플릿:**
```markdown
## Done

- [Change 1]
- [Change 2]

## Next Steps

[Guidance for next actions if needed]
```

**간소화할 때:**
- 간단한 버그 수정
- 소규모 기능 추가
- 명확한 요청에 대한 구현

**상세 형식을 사용할 때:**
- 복잡한 아키텍처 변경
- 사용자가 설명을 요청할 때
- 중요한 트레이드오프가 있을 때
- `/step-by-step` 또는 `/help` 모드일 때
</simplified_responses>

## 작업 완료 메시지

<template name="task_completion">
**사용 시점**: Git 커밋, PR 생성, 계획 모드 종료, 또는 모든 작업 완료 시

**언어 규칙**: 사용자에게 표시되는 모든 완료 메시지는 반드시 한국어여야 합니다.

**커밋 완료**:
```markdown
✅ 커밋 완료
- 메시지: "[commit message]"
- 변경된 파일: N개
```

**PR 생성**:
```markdown
✅ PR 생성 완료
- 제목: "[PR title]"
- 링크: [URL]
- 변경 요약: [brief summary in Korean]
```

**계획 모드 종료**:
```markdown
✅ 계획 작성 완료
- 계획 파일: [path]
- 다음 단계: [next action in Korean]
```

**일반 작업 완료**:
```markdown
✅ 완료
- [작업 1]
- [작업 2]

📋 다음 단계
[Required user action in Korean]
```

**예시 - 커밋 후**:
```markdown
✅ 커밋 완료
- 메시지: "feat: 사용자 인증 시스템을 추가하다"
- 변경된 파일: 3개 (user_auth.py, tests/test_auth.py, config.yaml)
```

**예시 - PR 생성 후**:
```markdown
✅ PR 생성 완료
- 제목: "feat: 사용자 인증 기능 추가"
- 링크: https://github.com/user/repo/pull/123
- 변경 요약: JWT 기반 인증 시스템 구현, 로그인/로그아웃 API 추가
```
</template>

## 품질 체크리스트

<quality_checklist>
응답을 보내기 전에 확인하세요:

- [ ] **명확성**: 사용자가 추가 질문 없이 이해할 수 있는가?
- [ ] **완전성**: 모든 필수 섹션이 포함되었는가?
- [ ] **정확성**: 코드가 테스트되고 정보가 검증되었는가?
- [ ] **일관성**: 형식이 템플릿과 일치하는가?
- [ ] **실행 가능성**: 사용자가 다음에 할 일을 알 수 있는가?
- [ ] **언어**: 설명은 한국어, 코드는 영어인가?
- [ ] **코드 블록**: 언어가 지정되고 적절히 포맷되었는가?
- [ ] **링크**: 모든 파일 참조가 링크로 포맷되었는가?
</quality_checklist>

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 주요 문서
- [시스템 규칙](../system-rules.md) - 언어 정책 (한국어/영어)
- [상호작용 모드](interaction-modes.md) - 모드가 응답 스타일에 미치는 영향
- [문서화](documentation.md) - 코드 문서화 표준
