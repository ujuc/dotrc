---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(gdate:*)
description: Create a git commit following team's version control guidelines
---

## Context

- Session ID: !`gdate +%s%N`
- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Generate a conventional commit message following the team's version control guidelines and create the commit automatically.

STEP 1: Analyze current git state and changes

- EXAMINE output from Context section for current status
- DETERMINE if there are staged changes ready for commit
- IF no staged changes found:
  - IDENTIFY unstaged changes that should be committed
  - STAGE appropriate files using `git add`
- VALIDATE that commit is appropriate (not empty, not work-in-progress)

STEP 2: Determine conventional commit type and scope

- ANALYZE the nature of changes from git diff output
- CATEGORIZE changes using conventional commit types:
  - `feat`: New feature
  - `fix`: Bug fix
  - `refactor`: Code refactoring (no functional changes)
  - `style`: Formatting changes (no code changes)
  - `docs`: Documentation updates
  - `test`: Add or refactor tests
  - `chore`: Build process, dependencies, or tooling changes

- IDENTIFY scope if applicable (component, module, or functional area affected)

STEP 3: Compose conventional commit message

### Subject Line (max 50 characters)
- Format: `<type>: <subject>` or `<type>(<scope>): <subject>`
- Capitalize first letter after type
- Use imperative mood ("add" not "added" or "adds")
- No period at the end

### Body (REQUIRED - MANDATORY)
- **MUST include body for ALL commits**
- Maximum 72 characters per line
- Separate from subject with blank line
- **Intent focused**: Explain WHY the change was made, not just WHAT changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Reflect requirements and problem awareness
- Use "-" for bullet points when listing multiple reasons
- Minimum content requirements:
  - At least explain the motivation for the change
  - Include "This change was needed because:" or similar context
  - For simple changes, at least one sentence explaining why

### Footer (REQUIRED for Claude Code commits)
- Reference related issues, PRs, or tickets (e.g., `Fixes #142`, `Related to INF-24`)
- **Always include Claude Code attribution**:
  ```
  🤖 Generated with [Claude Code](https://claude.ai/code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

STEP 4: Create the commit

TRY:
- EXECUTE `git commit` with generated message
- USE heredoc or -m flag for multi-line messages to ensure proper formatting
- ENSURE proper line breaks between subject, body, and footer
- VERIFY body is included (reject commits without body)
- INCLUDE Claude Code attribution in footer:
  ```
  🤖 Generated with [Claude Code](https://claude.ai/code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

CATCH (commit_failed):
- ANALYZE error message
- PROVIDE guidance on resolution
- SUGGEST alternative approaches

STEP 5: Validate commit result

- CONFIRM commit was created successfully
- VERIFY body was included in the commit message
- DISPLAY commit hash and message
- PROVIDE summary of what was committed
- REMIND about push if needed
- ENSURE Claude Code attribution is included in footer

## Example commit messages

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

## Important Guidelines

1. **BODY IS MANDATORY** - Every commit MUST have a body explaining WHY
2. **Always explain WHY** in the body, not just what changed
3. **Follow the 50/72 character limits** for subject/body
4. **Use imperative mood** and capitalize after type prefix
5. **Reference issues/tickets** in footer when applicable
6. **NO EMPTY BODIES** - Reject any commit without proper explanation
7. **CLAUDE CODE ATTRIBUTION IS REQUIRED** - Always include the Claude Code footer

## Claude Code Attribution Format

All commits created by Claude Code must include this attribution in the footer:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

This ensures:
- Transparency about AI-assisted development
- Proper co-authorship tracking in Git history
- Link to the tool for reference
- Compliance with team's attribution standards

## Validation Checklist

Before creating commit, ensure:
- [ ] Subject line follows format and is under 50 characters
- [ ] Body is present and explains WHY the change was made
- [ ] Body lines are wrapped at 72 characters
- [ ] Blank line separates subject from body
- [ ] Related issues/tickets are referenced if applicable
- [ ] Claude Code attribution is included in footer
