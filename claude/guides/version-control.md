# Version Control

<meta>
Document: version-control.md
Role: Version Control Guide
Priority: Medium
Applies To: Git workflow and commit practices
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines Git workflow and commit message conventions. Consistent version control practices improve collaboration and code history readability.
</context>

**Source of Truth**: 이 문서의 커밋 메시지 규칙은 [`gitmessage`](../../gitmessage) 템플릿을 기반으로 합니다.
**상세 가이드**: 구현 세부사항은 [`.claude/commands/commit.md`](../commands/commit.md)를 참조하세요.

## Git Workflow

- Use feature branch strategy
- Meaningful branch names (feature/fix/chore/docs)
- Follow Conventional Commits specification
- Utilize PR templates
- Mandatory code reviews
- Squash commits when merging

## Commit Message Format

### Core Principles

- **Intent focused**: Explain WHY the change was made, not just WHAT changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Reflect requirements and problem awareness for team collaboration

### Template Structure

```
<type>: <subject>

<body>

<footer>
```

### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring (no functional changes)
- `style`: Formatting changes (no code changes)
- `docs`: Documentation updates
- `test`: Add or refactor tests
- `chore`: Build process, dependencies, or tooling changes

### Formatting Rules

#### Subject Line
- Maximum 50 characters
- Include type prefix (e.g., `feat: add user authentication`)
- Use imperative mood ("add" not "added" or "adds")
- Capitalize first letter after type
- No period at the end

#### Body
- Maximum 72 characters per line
- Separate from subject with blank line
- Explain the motivation for the change
- Focus on why and what, not how
- Use "-" for bullet points

#### Footer
- Reference related issues, PRs, or tickets
- Include Claude Code attribution when applicable

### 한국어 커밋 메시지 (gitmessage 기반)

한국어로 커밋 메시지를 작성할 때는 다음 규칙을 따릅니다:

- **Type**: 영어 유지 (`feat:`, `fix:`, `docs:`, etc.)
- **제목 및 본문**: 한국어로 작성
- **동사 형태**: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- **마침표**: 제목에 마침표 사용하지 않음
- **문자 제한**: 제목 50자, 본문 72자

**올바른 예제**:
```
feat: 사용자 인증 시스템을 추가하다

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
이 변경이 필요한 이유:

- 기존 시스템에 적절한 보안 조치가 부족했음
- 사용자들이 계정 보호 기능을 요청함
```

**잘못된 예제** ❌:
```
feat: 사용자 인증 시스템 추가  ← "-하다" 어미 없음
```

> **상세 가이드**: 더 많은 예제와 동사 형태 가이드는 [`.claude/commands/commit.md`](../commands/commit.md#한국어-동사-형태-가이드)를 참조하세요.

### Claude Code Attribution

When using Claude Code to generate commits, include attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

`<model>`: 현재 사용 중인 Claude 모델명 (예: `Opus 4.5`, `Sonnet 4`)

## Document Reference

이 문서는 다음과 같은 계층 구조를 가집니다:

```
gitmessage (Source of Truth)
├── version-control.md (이 문서 - 요약 가이드)
└── commit.md (상세 구현 가이드)
```

- **Git 템플릿**: [`gitmessage`](../../gitmessage) - 모든 커밋 메시지 규칙의 기준
- **상세 구현 가이드**: [`.claude/commands/commit.md`](../commands/commit.md) - 자동 커밋 생성 및 예제
- **변경 동기화**: gitmessage를 변경하면 두 문서 모두 업데이트 필요

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Documentation](../documentation.md) - Documentation and change management
- [Quality Assurance](../quality-assurance.md) - Code review and quality gates