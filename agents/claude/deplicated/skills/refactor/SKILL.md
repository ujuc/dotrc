---
name: refactor
description: Suggests and performs code refactoring following best practices. Use when user asks to "리팩토링 해줘", "refactor this", "코드 개선해줘", "정리해줘", "클린 코드로", "중복 제거해줘", "이거 더 깔끔하게", or wants to improve code quality without changing functionality.
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git diff:*), Bash(git status:*)
model: opus
version: 1.0.0
metadata:
  role: "Code Refactoring Assistant"
  priority: "Medium"
  applies-to: "Code refactoring and improvement in any project"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2025-12-28"
  context: |
    This skill is auto-discovered by Claude when users request code refactoring.
    It suggests improvements and performs refactoring while maintaining functionality.
    After refactoring, it naturally connects with /review and /commit skills.
---

# Refactor Skill

This skill suggests and performs code refactoring following best practices.

## Source of Truth

- **Output Format**: [`output-formats.md`](../guides/output-formats.md) (Refactoring Format)
- **Success Criteria**: [`quality-assurance.md`](../guides/quality-assurance.md) (Refactoring Criteria)

## When to Activate

This skill activates in these scenarios:

1. **Explicit request**: "리팩토링 해줘", "refactor this"
2. **Improvement request**: "코드 개선해줘", "정리해줘"
3. **Clean code request**: "클린 코드로", "이거 더 깔끔하게"
4. **Specific refactoring**: "중복 제거해줘", "함수 분리해줘"

## Refactoring Principles

- **Preserve functionality**: Tests must pass before and after
- **Small steps**: Make incremental changes, verify each step
- **Improve readability**: Code should be easier to understand
- **Reduce complexity**: Lower cyclomatic complexity when possible
- **Remove duplication**: DRY (Don't Repeat Yourself)

## Instructions

### Step 1: Analyze Current State

1. Read the target code thoroughly
2. Identify issues:
   - Long functions (>30 lines)
   - High complexity (>10 cyclomatic)
   - Code duplication
   - Unclear naming
   - Deep nesting
   - God classes/functions

3. Check for existing tests

### Step 2: Plan Refactoring

Determine the refactoring type:

| Type                 | When to Use                  | Example                          |
| -------------------- | ---------------------------- | -------------------------------- |
| Extract Function     | Long function, repeated code | Split into smaller functions     |
| Rename               | Unclear naming               | `x` → `userCount`                |
| Inline               | Unnecessary abstraction      | Remove wrapper function          |
| Move                 | Wrong location               | Move method to appropriate class |
| Simplify Conditional | Complex if/else              | Use early return, guard clauses  |
| Replace Magic Number | Hardcoded values             | Use named constants              |

### Step 3: Perform Refactoring

1. **Before changing**: Ensure tests exist and pass
2. **Make one change at a time**: Don't combine multiple refactorings
3. **Verify after each change**: Run tests if available
4. **Show Before/After**: Clear comparison of changes

### Step 4: Format Output

Use this structured format:

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

---

## 우선순위

**Priority**: [High/Medium/Low]
**Effort**: [Hours/Days]
**Impact**: [High/Medium/Low]

**권장**: [Yes/No and why]
```

## Simplified Output (for small refactoring)

When the change is simple:

```markdown
## 리팩토링

### Before

\`\`\`[language]
[Current code]
\`\`\`

### After

\`\`\`[language]
[Refactored code]
\`\`\`

**개선**: [What improved]
```

## Success Criteria

Before completing refactoring, verify:

- ✅ All tests still pass
- ✅ Functionality unchanged (verified by tests)
- ✅ Code complexity reduced or maintained
- ✅ No new bugs introduced
- ✅ Code readability improved

## Common Refactoring Patterns

### Extract Function

```markdown
**Before**: 50-line function doing multiple things
**After**: 3 focused functions of ~15 lines each
**Benefit**: Single responsibility, easier to test
```

### Replace Conditional with Polymorphism

```markdown
**Before**: Switch/case with type checking
**After**: Interface with multiple implementations
**Benefit**: Open/Closed principle, easier to extend
```

### Introduce Parameter Object

```markdown
**Before**: Function with 5+ parameters
**After**: Single object parameter with named properties
**Benefit**: Clearer API, easier to add optional params
```

## Related Skills

After refactoring, you may want to:

- **Review changes**: Ask "리뷰해줘" or use `/review`
- **Commit changes**: Ask "커밋해줘" or use `/commit`

**Important**: Always ask user before committing. Never auto-commit.

### Typical Workflow

```
1. /refactor → 리팩토링 수행
2. "리뷰할까요?" → 사용자 선택 시 /review
3. "커밋할까요?" → 사용자 승인 시 /commit
```

## Response Language

- **Explanation and analysis**: Korean (한국어)
- **Code examples**: English (comments, variable names)
- **Technical terms**: Keep in English (e.g., refactoring, DRY, SOLID)

## See Also

- [output-formats.md](../guides/output-formats.md) - Refactoring output format
- [quality-assurance.md](../guides/quality-assurance.md) - Refactoring success criteria
- [technical-standards.md](../guides/technical-standards.md) - Code quality standards
