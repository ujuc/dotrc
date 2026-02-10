---
name: troubleshoot
description: Diagnoses and fixes errors following structured troubleshooting process. Use when user reports errors, bugs, or asks "왜 안돼?", "에러 났어", "문제 해결해줘", "디버깅 해줘", "이거 왜 이래?", "안 돼", "오류", or needs help with compilation, runtime, or logic errors.
allowed-tools: Read, Glob, Grep, Bash(*)
model: opus
version: 1.0.0
metadata:
  role: "Error Diagnosis and Troubleshooting Assistant"
  priority: "High"
  applies-to: "Error diagnosis and debugging in any project"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2025-12-28"
  context: |
    This skill is auto-discovered by Claude when users encounter errors or need debugging help.
    It provides structured diagnosis and resolution following the team's troubleshooting process.
---

# Troubleshoot Skill

This skill diagnoses and fixes errors following structured troubleshooting process.

## Source of Truth

- **Decision Tree**: [`process.md`](../guides/process.md) (Troubleshooting Decision Tree)
- **Output Format**: [`output-formats.md`](../guides/output-formats.md) (Troubleshooting Format)

## When to Activate

This skill activates in these scenarios:

1. **Error reported**: User pastes error message or stack trace
2. **Problem description**: "왜 안돼?", "에러 났어", "오류 발생"
3. **Debug request**: "디버깅 해줘", "문제 해결해줘"
4. **Confusion**: "이거 왜 이래?", "안 돼", "작동 안 해"

## Troubleshooting Principles

- **Understand before fixing**: Read the error message carefully
- **Reproduce first**: Ensure the issue can be consistently reproduced
- **Fix root cause**: Avoid band-aid solutions that hide symptoms
- **3-attempt rule**: Try different approaches after 3 failed attempts
- **Document findings**: Help prevent similar issues in the future

## Instructions

### Step 1: Classify the Problem

Identify the issue type to apply the correct diagnosis approach:

| Issue Type        | Symptoms                           | First Action                             |
| ----------------- | ---------------------------------- | ---------------------------------------- |
| Compilation/Build | Error during build, syntax error   | Read error message, check recent changes |
| Runtime           | Crash during execution, exception  | Get stack trace, identify error location |
| Logic Bug         | Wrong behavior, unexpected output  | Define expected vs actual behavior       |
| Performance       | Slow, timeout, high resource usage | Measure and profile first                |
| Test Failure      | Test not passing                   | Check if test or code is wrong           |

### Step 2: Apply Diagnosis Process

#### For Compilation/Build Errors

1. **Read the error message** - Does it clearly indicate the problem?
2. **Check recent changes** - Did this work before your changes?
3. **Verify environment**:
   - Dependencies installed? (`npm install`, `pip install`)
   - Correct version? (Node, Python, etc.)
   - Environment variables set?
   - Build cache corrupted? (try clean build)

#### For Runtime Errors

1. **Locate the error** - Get full stack trace
2. **Understand the error**:
   - What is the exact error type?
   - What operation was being performed?
   - What were the input values?
3. **Reproduce consistently** - Write a test that reproduces the error
4. **Fix systematically** - Minimal fix, verify with test

#### For Logic Bugs

1. **Define expected behavior** - What should happen?
2. **Isolate the issue**:
   - Add logging at key points
   - Trace data flow
   - Narrow down to specific function/line
3. **Understand why**:
   - Logic error → Review algorithm, check conditions
   - Data error → Check input validation
   - State error → Review state management
   - Integration error → Check external dependencies

#### For Test Failures

1. **Understand the failure**:
   - Expected (new code breaks old behavior)?
   - Unexpected (existing code now failing)?
2. **Categorize**:
   - Flaky test → Fix test (mocking, timeouts)
   - Wrong assumption → Update test
   - Actual bug → Fix the code
   - Environment issue → Fix configuration

**NEVER**:

- ❌ Delete failing tests
- ❌ Comment out assertions
- ❌ Add try-catch to hide errors

### Step 3: Format Output

Use this structured format:

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

## 재발 방지

- [Preventive measure 1]
- [Preventive measure 2]
```

## Simplified Output (for quick fixes)

When the fix is obvious and simple:

```markdown
## 진단 결과

**원인**: [간단한 원인 설명]

**해결**:
\`\`\`[language]
[Fix code]
\`\`\`

**확인**: [검증 방법]
```

## 3-Attempt Rule

If unresolved after 3 attempts, stop and:

1. **Document what failed**:
   - What was attempted
   - Specific error messages
   - Estimated cause of failure

2. **Research alternatives**:
   - Find 2-3 similar implementations
   - Document alternative approaches

3. **Try different angle**:
   - Different library/framework features?
   - Different architectural pattern?
   - Remove abstraction instead of adding?

4. **Ask for help** with:
   - Full error message
   - Steps to reproduce
   - What's been tried so far

## Common Error Patterns

### NullPointerException / undefined is not a function

```markdown
**원인**: 객체가 초기화되지 않은 상태에서 접근
**해결**: null check 추가 또는 optional chaining 사용
```

### Module not found / Import error

```markdown
**원인**: 패키지 미설치 또는 경로 오류
**해결**:

1. 패키지 설치 확인: `npm install` / `pip install`
2. import 경로 확인
3. 상대/절대 경로 구분
```

### Permission denied

```markdown
**원인**: 파일/디렉토리 접근 권한 부족
**해결**:

1. 파일 권한 확인: `ls -la`
2. 소유자 확인
3. 필요시 권한 변경 (주의 필요)
```

## Response Language

- **Diagnosis and explanation**: Korean (한국어)
- **Code examples**: English (comments, variable names)
- **Error messages**: Keep original (for searchability)

## See Also

- [process.md](../guides/process.md) - Full troubleshooting decision tree
- [output-formats.md](../guides/output-formats.md) - Output format templates
- [quality-assurance.md](../guides/quality-assurance.md) - Test failure handling
