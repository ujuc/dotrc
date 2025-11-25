---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(gdate:*)
contexts: project, gitignored
description: Create a git commit following team's version control guidelines
---

## Context

- Session ID: !`gdate +%s%N`
- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Overview

This command creates git commits following the team's version control guidelines defined in [`.claude/version-control.md`](../version-control.md). It analyzes changes, generates conventional commit messages, and creates commits automatically.

## 커밋 메시지 작성 원칙

변경사항을 기반으로 의미 있는 커밋 메시지를 작성합니다:

- **의도 중심**: 단순 변경 내용보다 **왜** 변경했는지 의도를 드러낸다
- **맥락 반영**: 변경하게 된 배경과 목적을 포함한다
- **협업 중심**: 다른 개발자가 이해할 수 있도록 요구사항과 문제 의식을 반영한다

## Your task

Generate a conventional commit message following the team's version control guidelines and create the commit automatically.

STEP 1: Analyze current git state and changes

- EXAMINE output from Context section for current status
- DETERMINE if there are staged changes ready for commit
- IF staged changes found:
  - PROCEED with commit for staged files only
  - DO NOT automatically add unstaged files
- IF no staged changes found:
  - CHECK for unstaged changes
  - ASK user if they want to stage specific files or all files
  - STAGE files based on user preference using `git add`
- VALIDATE that commit is appropriate (not empty, not work-in-progress)

STEP 2: Determine conventional commit type and scope

- ANALYZE the nature of changes from git diff output
- CATEGORIZE changes using conventional commit types defined in [`version-control.md`](../version-control.md#commit-types)
- IDENTIFY scope if applicable (component, module, or functional area affected)

STEP 3: Compose conventional commit message

Follow the formatting rules defined in [`version-control.md`](../version-control.md#formatting-rules):

### Subject Line (max 50 characters)
- Format: `<type>: <subject>` or `<type>(<scope>): <subject>`
- **Language**: 한국어로 작성 (영문 50자 이내로 한국어 작성)
- **Verb form**: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- **No period**: 제목에 마침표 사용하지 않음
- Follow formatting rules from version-control.md

### Body (REQUIRED - MANDATORY)
- **MUST include body for ALL commits**
- Follow the core principles and formatting rules from version-control.md
- Minimum content requirements:
  - Explain the motivation for the change (WHY)
  - Include context about why this change was needed
  - For simple changes, at least one sentence explaining why

### Footer
- Reference related issues, PRs, or tickets
- Include Claude Code attribution (see format below)

STEP 4: Create the commit

TRY:
- EXECUTE `git commit` with generated message
- USE heredoc for multi-line messages to ensure proper formatting
- ENSURE proper line breaks between subject, body, and footer

CATCH (commit_failed):
- ANALYZE error message
- PROVIDE guidance on resolution
- SUGGEST alternative approaches

STEP 5: Validate commit result

- CONFIRM commit was created successfully
- DISPLAY commit hash and message
- PROVIDE summary of what was committed
- REMIND about push if needed

## Claude Code Attribution Format

All commits created by Claude Code must include this attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 커밋 메시지 언어 정책

**기본 원칙: 한국어로 작성**

자세한 가이드라인은 [`version-control.md`](../version-control.md#korean-commit-messages)를 참조하세요.

### 작성 규칙:
- **Type**: 영어 유지 (`feat:`, `fix:`, `docs:`, etc.)
- **제목 및 본문**: **한국어로 작성** (영문 50자 이내로 한국어 작성)
- **동사 형태**: 현재 완료형 어미 "-하다" 사용 (예: 추가하다, 수정하다, 개선하다)
- **마침표**: 제목에 마침표 사용하지 않음
- **문자 제한**: 제목 50자, 본문 72자

## 커밋 메시지 예제 (한국어)

### 기능 추가:

```
feat: 사용자 인증 시스템을 추가하다

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
이 변경이 필요한 이유:

- 기존 시스템에 적절한 보안 조치가 부족했음
- 사용자들이 계정 보호 기능을 요청함
- 데이터 보호 규정 준수 필요

Fixes #142

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 버그 수정:

```
fix: 인증 오류 메시지 오타를 수정하다

사용자에게 혼란을 주던 인증 오류 메시지의 오타를 수정합니다.
명확한 오류 피드백으로 사용자 경험을 개선합니다.

Related to #256

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 코드 리팩토링:

```
refactor: 데이터베이스 연결 로직을 단순화하다

연결 풀링을 별도 모듈로 추출하여 코드 유지보수성을
향상시키고 서비스 간 중복을 제거합니다.

Related to INF-24

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 한국어 동사 형태 가이드

**올바른 형태 ✅**:
- `feat: 사용자 인증을 추가하다`
- `fix: 로그인 버그를 수정하다`
- `refactor: 코드 구조를 개선하다`
- `docs: README를 업데이트하다`
- `test: 단위 테스트를 추가하다`
- `chore: 의존성 패키지를 업그레이드하다`

**잘못된 형태 ❌**:
- `feat: 사용자 인증 추가` (어미 없음)
- `fix: 로그인 버그 수정` (어미 없음)
- `refactor: 코드 구조 개선` (어미 없음)

**핵심 원칙**: 항상 "-하다" 어미를 포함하여 현재 완료형으로 작성합니다.

## 참고: 영어 커밋 메시지 예제

영어로 작성이 필요한 경우를 위한 참고 예제입니다.

### Feature addition:
```
feat: add user authentication system

Implement JWT-based authentication to secure API endpoints.
This change was needed because:

- Previous system lacked proper security measures
- Users requested account protection features
- Compliance requirements for data protection

Fixes #142

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Bug fix:
```
fix: correct typo in error message

Fix typo in authentication error message that was confusing users.
This change improves user experience by providing clear error feedback.

Related to #256

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Code refactoring:
```
refactor: simplify database connection logic

Extract connection pooling into separate module to improve
code maintainability and reduce duplication across services.

Related to INF-24

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Documentation update:
```
docs: update API documentation for v2 endpoints

Add missing parameter descriptions and response examples for
new v2 endpoints. This helps developers integrate with our API
more effectively.

Closes #89

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## 언어별 작성 규칙

### 한국어 커밋 (기본)

**제목 작성**:
- 형식: `<type>: <한국어 제목>`
- 동사: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- 길이: 영문 50자 이내 (한글 약 25자 내외)
- 마침표: 사용하지 않음

**본문 작성**:
- 언어: 한국어
- 내용: 변경의 이유(WHY), 배경, 맥락 포함
- 길이: 각 줄 72자 이내

**예시**:
```
feat: 사용자 인증 시스템을 추가하다

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
보안 강화 요구사항을 충족하기 위해 필요합니다.
```

### 영어 커밋 (참고용)

**Subject Line**:
- Format: `<type>: <English subject>`
- Verb: Imperative mood (add, fix, update)
- Length: 50 characters max
- No period at the end

**Body**:
- Language: English
- Content: Explain WHY, context, and background
- Length: 72 characters per line

**Example**:
```
feat: add user authentication system

Implement JWT-based authentication to secure API endpoints.
This addresses security enhancement requirements.
```

## Commit Options

### --staged-only mode
To commit only staged files without adding any unstaged changes:
1. Check for staged changes with `git status`
2. If staged changes exist, proceed directly to commit
3. Skip any automatic `git add` operations
4. This is useful when you want to commit specific changes while keeping others for a separate commit

### --all mode (default behavior)
To stage and commit all changes:
1. Check current status
2. If unstaged changes exist, stage them with `git add`
3. Proceed with commit

## Implementation Notes

### Important Requirements

1. **BODY IS MANDATORY** - Every commit MUST have a body explaining WHY
2. **Follow all formatting rules** from [`version-control.md`](../version-control.md#formatting-rules)
3. **CLAUDE CODE ATTRIBUTION IS REQUIRED** - Always include the Claude Code footer
4. **Respect staging choices** - For staged-only commits, don't auto-add files

### Validation Checklist

Before creating commit, ensure:
- [ ] Subject line follows format and is under 50 characters
- [ ] Body is present and explains WHY the change was made
- [ ] Body lines are wrapped at 72 characters
- [ ] Blank line separates subject from body
- [ ] Related issues/tickets are referenced if applicable
- [ ] Claude Code attribution is included in footer
- [ ] Staged files are handled according to user preference

### Reference Documentation

- **Principles & Guidelines**: [`version-control.md`](../version-control.md)
- **Commit Types**: [`version-control.md#commit-types`](../version-control.md#commit-types)
- **Formatting Rules**: [`version-control.md#formatting-rules`](../version-control.md#formatting-rules)
- **Korean Guidelines**: [`version-control.md#korean-commit-messages`](../version-control.md#korean-commit-messages)
