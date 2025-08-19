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

### Format Rules

#### Subject Line

- Maximum 50 characters
- Include type prefix (e.g., `feat: add user authentication`)
- Use imperative mood ("add" not "added" or "adds")
- Capitalize first letter after type
- No period at the end

#### Body

- Maximum 72 characters per line
- Explain the motivation for the change
- Focus on why and what, not how
- Use "-" for bullet points
- Separate from subject with blank line

#### Footer

- Reference related issues, PRs, or tickets

### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring (no functional changes)
- `style`: Formatting changes (no code changes)
- `docs`: Documentation updates
- `test`: Add or refactor tests
- `chore`: Build process, dependencies, or tooling changes

### Best Practices

1. **Capitalize** the subject line after type
2. **Use imperative mood** in subject line
3. **No period** at the end of subject line
4. **Blank line** between subject and body
5. **Explain why** in body, not how
6. **Use bullet points** with "-" for multiple items

### Claude Code Attribution

When using Claude Code to generate commits or code changes, include attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

This attribution:
- Provides transparency about AI-assisted development
- Maintains proper co-authorship records
- Links to the tool used for generation
- Follows Git's standard co-author format

### Examples

<example>
feat: add user authentication system

Implement JWT-based authentication to secure API endpoints.
This change was needed because:

- Previous system lacked proper security measures
- Users requested account protection features
- Compliance requirements for data protection

Fixes #142

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
</example>

<example>
refactor: simplify database connection logic

Extract connection pooling into separate module to improve
code maintainability and reduce duplication across services.

Related to INF-24

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
</example>

<example>
fix: correct typo in error message

Fix typo in authentication error message that was confusing users.
This change improves user experience by providing clear error feedback.

Related to #256
</example>
