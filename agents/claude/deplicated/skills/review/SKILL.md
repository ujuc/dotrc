---
name: review
description: Performs code review following team's quality assurance guidelines. Use when the user asks to "review code", "check this code", "리뷰해줘", "코드 리뷰", "코드 검토", "이 코드 봐줘", "이거 괜찮아?", "확인해줘", "문제 없어?", or after writing code when they want feedback on the changes just made.
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git log:*), Bash(git show:*)
model: sonnet
version: 1.0.0
metadata:
  role: "Code Review Assistant"
  priority: "High"
  applies-to: "Code review in any project"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2025-12-28"
  context: |
    This skill is auto-discovered by Claude when users request code review tasks.
    It can also be triggered naturally after code has been written, when the user
    wants to verify the quality of recent changes.
---

# Code Review Skill

This skill performs code reviews following the team's quality assurance guidelines.

## Source of Truth

- **Review Format**: [`output-formats.md`](../guides/output-formats.md)
- **Quality Standards**: [`quality-assurance.md`](../guides/quality-assurance.md)
- **Security Guidelines**: [`security.md`](../guides/security.md)

## When to Activate

This skill activates in these scenarios:

1. **Explicit request**: User asks for code review directly
2. **After code writing**: User asks "이거 괜찮아?", "확인해줘", "문제 없어?" after Claude wrote code
3. **Change verification**: User wants to check staged/unstaged changes
4. **PR preparation**: Before committing, user wants quality check

## Review Principles

When reviewing code, follow these core principles:

- **Actionable feedback**: Every issue must have a clear fix suggestion
- **Prioritized issues**: Critical issues first, then improvements
- **Balanced perspective**: Acknowledge good practices, not just problems
- **Educational tone**: Explain WHY something is an issue

## Instructions

### Step 1: Understand the Scope

1. Identify what code to review:
   - **Just written code**: Review the changes Claude just made in this conversation
   - **Specific file(s)**: Files provided by user
   - **Recent changes**: `git diff` for unstaged, `git diff --cached` for staged
   - **PR/commit changes**: `git show <commit>`

2. Read the code thoroughly before commenting

### Step 2: Analyze Code

Check for issues in these categories:

| Category        | Priority    | Examples                                       |
| --------------- | ----------- | ---------------------------------------------- |
| Security        | 🔴 Critical | SQL injection, XSS, secrets in code            |
| Bugs            | 🔴 Critical | Logic errors, null references, race conditions |
| Performance     | 🟡 Medium   | N+1 queries, unnecessary loops, memory leaks   |
| Maintainability | 🟡 Medium   | Long functions, unclear names, missing docs    |
| Style           | 🟢 Low      | Formatting, conventions, minor improvements    |

### Step 3: Apply Self-Review Checklist

Before providing feedback, verify against this checklist:

- [ ] All tests pass (if applicable)
- [ ] Edge cases handled
- [ ] Performance impact considered
- [ ] No security vulnerabilities
- [ ] Error messages are user-friendly
- [ ] No commented-out code
- [ ] No debug statements (console.log, print, etc.)

### Step 4: Format Review Output

Use this structured format for review results:

```markdown
## 코드 리뷰 결과

### 📊 전체 평가

- **품질**: [상/중/하]
- **주요 이슈**: [N개 발견]
- **긴급도**: [즉시 수정 필요/개선 권장/양호]

### 🔴 Critical Issues (우선순위: 높음)

**[Issue Title]** (`file:line`)

- **Problem**: [명확한 문제 설명]
- **Impact**: [영향 범위와 위험도]
- **Fix**: [구체적인 수정 방법]

\`\`\`[language]
// Bad
[problematic code]

// Good
[fixed code]
\`\`\`

### 🟡 Improvements (우선순위: 중간)

1. **[Issue Title]** (`file:line`)
   - [문제 설명]
   - [개선 방법]

### 🟢 Good Practices

- ✅ [잘 작성된 부분 1]
- ✅ [잘 작성된 부분 2]

### ✅ Action Items

1. [ ] [우선순위별 작업 목록]
2. [ ] [...]
```

## Simplified Output (for small changes)

When reviewing small changes or code just written, use a lighter format:

```markdown
## 리뷰 결과

✅ **양호** - 주요 문제 없음

### 확인 사항

- ✅ [확인된 항목 1]
- ✅ [확인된 항목 2]

### 개선 제안 (선택)

- 💡 [사소한 개선 사항]
```

## Issue Templates

### Security Issue

```markdown
**[보안 취약점 유형]** (`file:line`)

- **Problem**: [취약점 설명]
- **Impact**: [공격 시나리오와 피해 범위]
- **Fix**: [수정 방법]
- **Reference**: [OWASP 또는 관련 문서 링크]
```

### Performance Issue

```markdown
**[성능 문제 유형]** (`file:line`)

- **Problem**: [현재 성능 문제]
- **Impact**: [예상 성능 저하]
- **Fix**: [최적화 방법]
```

### Maintainability Issue

```markdown
**[유지보수 문제 유형]** (`file:line`)

- **Problem**: [현재 코드의 문제점]
- **Impact**: [향후 유지보수 어려움]
- **Fix**: [리팩토링 제안]
```

## Quality Ratings

### 품질 평가 기준

| Rating      | Criteria                                                                 |
| ----------- | ------------------------------------------------------------------------ |
| 상 (High)   | No critical issues, minor improvements only, follows best practices      |
| 중 (Medium) | No critical issues, some improvements needed, mostly follows conventions |
| 하 (Low)    | Critical issues found, significant refactoring needed                    |

### 긴급도 평가 기준

| Urgency        | Criteria                                                  |
| -------------- | --------------------------------------------------------- |
| 즉시 수정 필요 | Security vulnerabilities, data loss risk, production bugs |
| 개선 권장      | Performance issues, code smells, missing tests            |
| 양호           | Only minor style/formatting suggestions                   |

## Response Language

- **Review comments**: Korean (한국어)
- **Code examples**: English (comments, variable names)
- **Technical terms**: Keep in English (e.g., SQL injection, N+1, refactoring)

## See Also

- [output-formats.md](../guides/output-formats.md) - Review output format template
- [quality-assurance.md](../guides/quality-assurance.md) - Quality standards and checklists
- [security.md](../guides/security.md) - Security guidelines
- [technical-standards.md](../guides/technical-standards.md) - Code quality requirements
