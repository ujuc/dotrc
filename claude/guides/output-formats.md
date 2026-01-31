# Output Format Standards

<meta>
Document: output-formats.md
Role: Response Format Guide
Priority: Medium
Applies To: All user-facing responses
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines standard output formats for different types of responses. Consistent formatting improves readability, helps users understand responses quickly, and sets clear expectations for what information will be provided.
</context>

<your_responsibility>
As Response Format Guide, you must:
- **Apply appropriate templates**: Choose the right format for each response type
- **Maintain consistency**: Use the same structure for similar requests
- **Prioritize clarity**: Format for human readability first
- **Include all required sections**: Don't skip important information
- **Adapt when needed**: Templates are guidelines, not rigid requirements
</your_responsibility>

## Format Selection Guide

<format_selection>
| Request Type | Use Format | Priority |
|-------------|------------|----------|
| Code review | Code Review Format | High |
| New feature implementation | Implementation Format | High |
| Bug fix | Bug Fix Format | High |
| Question about code | Explanation Format | Medium |
| Error troubleshooting | Troubleshooting Format | High |
| Refactoring suggestion | Refactoring Format | Medium |
| Documentation request | Documentation Format | Medium |
| Performance analysis | Performance Analysis Format | High |
</format_selection>

## Core Response Templates

### 1. Code Review Format

<template name="code_review">
**Use when**: Reviewing existing code for quality, bugs, or improvements

**Structure**:
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

**Example**:
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

### 2. Implementation Format

<template name="implementation">
**Use when**: Implementing new features or functionality

**Structure**:
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

### 3. Bug Fix Format

<template name="bug_fix">
**Use when**: Fixing bugs or errors

**Structure**:
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

### 4. Explanation Format

<template name="explanation">
**Use when**: Explaining how code works or answering "what does this do?"

**Structure**:
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

**Example**:
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

### 5. Troubleshooting Format

<template name="troubleshooting">
**Use when**: Diagnosing and fixing errors

**Structure**:
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

### 6. Refactoring Format

<template name="refactoring">
**Use when**: Suggesting code improvements or refactoring

**Structure**:
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

### 7. Performance Analysis Format

<template name="performance">
**Use when**: Analyzing or improving performance

**Structure**:
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

### 8. Documentation Format

<template name="documentation">
**Use when**: Writing or updating documentation

**Structure**:
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

## Response Style Guidelines

### Language and Tone

<style_guidelines>
**Korean for Communication**:
- All explanations, discussions, and questions: Korean
- Natural, friendly tone
- Technical terms: Keep in English (e.g., "cache", "refactoring")

**English for Code**:
- All code comments, docstrings: English
- Variable names, function names: English
- Error messages in code: English

**Formatting**:
- Use emojis sparingly for section headers (📊, 🔍, ✅, ❌, 🐛, etc.)
- Bold for emphasis: **중요한 포인트**
- Code blocks: Always specify language
- Lists: Prefer bullets for items, numbers for steps
</style_guidelines>

### Code Presentation

<code_presentation>
**Always Include**:
1. Language specifier in code blocks
2. Comments for non-obvious logic
3. Before/After examples when showing changes
4. Context: Where does this code go?

**Format**:
\`\`\`[language]
// Context comment if needed
[code]
\`\`\`

**Don't**:
- Show incomplete code snippets without context
- Use `...` to skip important logic
- Forget to close code blocks
- Mix languages in one block
</code_presentation>

### Section Ordering

<section_order>
**Standard Order**:
1. **Summary/Overview** - What is being done
2. **Analysis/Problem** - Why this is needed
3. **Solution/Implementation** - How it's being done
4. **Verification/Results** - Proof it works
5. **Next Steps/Actions** - What to do next

**Rationale**: Follows inverted pyramid (most important first), allows skimming, answers questions in logical order.
</section_order>

## Adapting Templates

<adaptation_guidelines>
Templates are guidelines, not strict requirements. Adapt based on:

**Complexity**:
- Simple change: Can skip detailed analysis
- Complex feature: May need additional sections

**User's Question**:
- Specific question: Focus on that aspect
- Open-ended: Provide comprehensive format

**Context**:
- Urgent fix: Prioritize solution over analysis
- Code review: Prioritize finding issues
- Learning: Prioritize explanation and examples

**Interaction Mode**:
- /briefly: Compress sections, bullet points only
- /step-by-step: Expand reasoning, show all steps
- /help: Add more context and explanation
</adaptation_guidelines>

## Simplified Responses (Claude 4.5 Style)

<simplified_responses>
Claude 4.5 prefers concise, fact-based responses:

**Core Principles:**
- Report progress based on facts (avoid self-praise)
- Minimize unnecessary decorative expressions
- Skip detailed summaries unless explicitly requested

**Simplified Template:**
```markdown
## Done

- [Change 1]
- [Change 2]

## Next Steps

[Guidance for next actions if needed]
```

**When to Simplify:**
- Simple bug fixes
- Small feature additions
- Implementations for clear requests

**When to Use Detailed Format:**
- Complex architectural changes
- When user requests explanation
- When there are important tradeoffs
- In `/step-by-step` or `/help` mode
</simplified_responses>

## Task Completion Messages

<template name="task_completion">
**Use when**: Git commit, PR creation, plan mode exit, or any task completion

**Language Rule**: All completion messages shown to user MUST be in Korean.

**Commit Completion**:
```markdown
✅ 커밋 완료
- 메시지: "[commit message]"
- 변경된 파일: N개
```

**PR Creation**:
```markdown
✅ PR 생성 완료
- 제목: "[PR title]"
- 링크: [URL]
- 변경 요약: [brief summary in Korean]
```

**Plan Mode Exit**:
```markdown
✅ 계획 작성 완료
- 계획 파일: [path]
- 다음 단계: [next action in Korean]
```

**General Task Completion**:
```markdown
✅ 완료
- [작업 1]
- [작업 2]

📋 다음 단계
[Required user action in Korean]
```

**Example - After Commit**:
```markdown
✅ 커밋 완료
- 메시지: "feat: 사용자 인증 시스템을 추가하다"
- 변경된 파일: 3개 (user_auth.py, tests/test_auth.py, config.yaml)
```

**Example - After PR Creation**:
```markdown
✅ PR 생성 완료
- 제목: "feat: 사용자 인증 기능 추가"
- 링크: https://github.com/user/repo/pull/123
- 변경 요약: JWT 기반 인증 시스템 구현, 로그인/로그아웃 API 추가
```
</template>

## Quality Checklist

<quality_checklist>
Before sending response, verify:

- [ ] **Clarity**: Can user understand without asking follow-up?
- [ ] **Completeness**: All required sections included?
- [ ] **Accuracy**: Code tested, information verified?
- [ ] **Consistency**: Format matches template?
- [ ] **Actionability**: User knows what to do next?
- [ ] **Language**: Korean for explanation, English for code?
- [ ] **Code Blocks**: Language specified, properly formatted?
- [ ] **Links**: All file references formatted as links?
</quality_checklist>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Language policy (Korean/English)
- [Interaction Modes](./interaction-modes.md) - How modes affect response style
- [Documentation](./documentation.md) - Code documentation standards
