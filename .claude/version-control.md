# Version Control

## Git Workflow

- Use feature branch strategy
- Meaningful branch names (feature/fix/chore/docs)
- Follow Conventional Commits specification
- Utilize PR templates
- Mandatory code reviews
- Squash commits when merging

## Commit Message Format

### Template Structure

```
<type>: <subject>

<body>

<footer>
```

### Writing Principles

- **Intent focused**: Explain WHY the change was made, not just WHAT changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Reflect requirements and problem awareness for team collaboration

### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring (no functional changes)
- `style`: Formatting changes (no code changes)
- `docs`: Documentation updates
- `test`: Add or refactor tests
- `chore`: Build process, dependencies, or tooling changes

### Commit Message Rules

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
- Include Claude Code attribution when applicable (see below)

### Korean Commit Messages

For Korean developers, commit messages can be written in Korean while maintaining conventional commit format:

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

When using Claude Code to generate commits or code changes, include attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

For detailed Claude Code attribution guidelines, see `claude/commands/commit.md`.

### Examples

#### Feature with Attribution
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

#### Refactoring
```
refactor: simplify database connection logic

Extract connection pooling into separate module to improve
code maintainability and reduce duplication across services.

Related to INF-24
```

#### Bug Fix
```
fix: correct typo in error message

Fix typo in authentication error message that was confusing users.
This change improves user experience by providing clear error feedback.

Related to #256
```

#### Documentation Update
```
docs: update API documentation for v2 endpoints

Add missing parameter descriptions and response examples for
new v2 endpoints to help developers integrate more effectively.

Closes #89
```