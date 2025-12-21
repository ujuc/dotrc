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

<your_responsibility>
As Version Control Specialist, you must:
- **Write meaningful commits**: Clearly convey the intent (WHY) of changes
- **Follow conventions**: Adhere to Conventional Commits format
- **Keep history clean**: Organize commits in logical units
- **Include attribution**: Include attribution in Claude Code generated commits
</your_responsibility>

**Source of Truth**: The commit message rules in this document are based on the [`gitmessage`](../../gitmessage) template.
**Detailed Guide**: See [`.claude/commands/commit.md`](../commands/commit.md) for implementation details.

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

### Korean Commit Messages (Based on gitmessage)

When writing commit messages in Korean, follow these rules:

- **Type**: Keep in English (`feat:`, `fix:`, `docs:`, etc.)
- **Subject and body**: Write in Korean
- **Verb form**: Use "-하다" ending (e.g., 추가하다, 수정하다, 개선하다)
- **Period**: No period at the end of subject
- **Character limit**: Subject 50 chars, body 72 chars

**Correct example**:
```
feat: 사용자 인증 시스템을 추가하다

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
이 변경이 필요한 이유:

- 기존 시스템에 적절한 보안 조치가 부족했음
- 사용자들이 계정 보호 기능을 요청함
```

**Incorrect example** ❌:
```
feat: 사용자 인증 시스템 추가  ← Missing "-하다" ending
```

> **Detailed Guide**: For more examples and verb form guide, see [`.claude/commands/commit.md`](../commands/commit.md#한국어-동사-형태-가이드).

### Claude Code Attribution

When using Claude Code to generate commits, include attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

`<model>`: Current Claude model name (e.g., `Opus 4.5`, `Sonnet 4`)

## Document Reference

This document has the following hierarchy:

```
gitmessage (Source of Truth)
├── version-control.md (This document - Summary guide)
└── commit.md (Detailed implementation guide)
```

- **Git template**: [`gitmessage`](../../gitmessage) - Source of all commit message rules
- **Detailed implementation guide**: [`.claude/commands/commit.md`](../commands/commit.md) - Auto commit generation and examples
- **Change synchronization**: If gitmessage changes, both documents need updating

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Documentation](../documentation.md) - Documentation and change management
- [Quality Assurance](../quality-assurance.md) - Code review and quality gates