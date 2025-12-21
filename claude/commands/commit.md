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

This command creates git commits following the team's version control guidelines. It analyzes changes, generates conventional commit messages, and creates commits automatically.

**Source of Truth**: 모든 커밋 메시지 규칙은 [`gitmessage`](../../gitmessage) 템플릿을 기반으로 합니다.
**요약 가이드**: 빠른 참조는 [`.claude/guides/version-control.md`](../guides/version-control.md)를 확인하세요.
**이 문서**: 자동 커밋 생성을 위한 상세 구현 가이드를 제공합니다.

## Commit Message Principles

변경사항을 기반으로 의미 있는 커밋 메시지를 작성합니다:

- **Intent focused**
  단순 변경 내용보다 **왜** 변경했는지 의도를 드러낸다
- **Context aware**
  변경하게 된 배경과 목적을 포함한다
- **Collaboration oriented**
  다른 개발자가 이해할 수 있도록 요구사항과 문제 의식을 반영한다

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
- CATEGORIZE changes using conventional commit types defined in [`version-control.md`](../guides/version-control.md#commit-types)
- IDENTIFY scope if applicable (component, module, or functional area affected)

STEP 3: Compose conventional commit message

Follow the formatting rules defined in [`version-control.md`](../guides/version-control.md#formatting-rules):

### Subject Line (max 50 characters)
- Format: `<type>: <subject>` or `<type>(<scope>): <subject>`
- **Language**: 한국어로 작성 (영문 50자 이내로 한국어 작성)
- **Verb form**: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- **No period**: 제목에 마침표 사용하지 않음
- Follow formatting rules from [version-control.md](../guides/version-control.md#formatting-rules)

### Body (REQUIRED - MANDATORY)
- **MUST include body for ALL commits**
- Follow the core principles and formatting rules from [version-control.md](../guides/version-control.md#formatting-rules)
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
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

`<model>`: 현재 사용 중인 Claude 모델명
- **기본값**: `Opus 4.5` (claude-opus-4-5-20251101)
- 예시: `Opus 4.5`, `Sonnet 4`, `Haiku 3.5`

## Commit Message Language Policy

**기본 원칙: 한국어로 작성** (출처: [`gitmessage`](../../gitmessage#L24))

자세한 가이드라인은 [`version-control.md`](../guides/version-control.md#한국어-커밋-메시지-gitmessage-기반)를 참조하세요.

### Writing Rules:
- **Type**: 영어 유지 (`feat:`, `fix:`, `docs:`, etc.)
- **제목 및 본문**: **한국어로 작성** (영문 50자 이내로 한국어 작성)
- **동사 형태**: 현재 완료형 어미 "-하다" 사용 (예: 추가하다, 수정하다, 개선하다)
- **마침표**: 제목에 마침표 사용하지 않음
- **문자 제한**: 제목 50자, 본문 72자

## Commit Message Examples

예제는 [version-control.md](../guides/version-control.md#한국어-커밋-메시지-gitmessage-기반)를 참조하세요.

### Korean Verb Form Guide

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

## Language-specific Rules

### Korean Commits (Default)

**제목 작성**:
- 형식: `<type>: <한국어 제목>`
- 동사: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- 길이: 영문 50자 이내 (한글 약 25자 내외)
- 마침표: 사용하지 않음

**본문 작성**:
- 언어: 한국어
- 내용: 변경의 이유(WHY), 배경, 맥락 포함
- 길이: 각 줄 72자 이내

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
2. **Follow all formatting rules** from [`version-control.md`](../guides/version-control.md#formatting-rules)
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

**Document Hierarchy**:
```
gitmessage (Source of Truth - Git 커밋 템플릿)
├── version-control.md (요약 가이드 - 빠른 참조)
└── commit.md (상세 구현 가이드 - 자동 커밋 생성)
```

**Reference Links**:
- **Source Template**: [`gitmessage`](../../gitmessage) - Git 커밋 템플릿 (모든 규칙의 기준)
- **Summary Guide**: [`version-control.md`](../guides/version-control.md) - 버전 관리 요약 가이드
- **Commit Types**: [`version-control.md#commit-types`](../guides/version-control.md#commit-types)
- **Formatting Rules**: [`version-control.md#formatting-rules`](../guides/version-control.md#formatting-rules)
- **Korean Guidelines**: [`version-control.md#한국어-커밋-메시지`](../guides/version-control.md#한국어-커밋-메시지-gitmessage-기반)
