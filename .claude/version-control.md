# Version Control

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

### Korean Commit Messages

Korean developers can write commit messages in Korean while maintaining the conventional format:

- **Type**: Keep in English (`feat:`, `fix:`, `docs:`, etc.)
- **Subject & Body**: Can be written in Korean
- **Format**: Same rules apply (50/72 character limits)

Example:
```
feat: 사용자 인증 시스템 추가

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
이 변경이 필요한 이유:

- 기존 시스템에 적절한 보안 조치가 부족했음
- 사용자들이 계정 보호 기능을 요청함
```

### Claude Code Attribution

When using Claude Code to generate commits, include attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

> **Note**: For detailed implementation instructions and extensive examples, see [`.claude/commands/commit.md`](./commands/commit.md)

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - Primary document with complete guidelines
- [System Rules](./system-rules.md) - Critical system-wide rules
- [Documentation](./documentation.md) - Documentation and change management
- [Quality Assurance](./quality-assurance.md) - Code review and quality gates