---
name: commit
description: Creates git commits following team's version control guidelines. Use when the user asks to "commit changes", "create a commit", "make a commit", "커밋해줘", "변경사항 저장", "커밋 메시지 작성", "커밋 만들어줘", or needs to commit staged/unstaged changes to git.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(gdate:*)
version: 1.0.0
---

<meta>
Document: SKILL.md
Role: Git Commit Generator
Priority: Medium - Git workflow automation
Applies To: Git commit creation in any project
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-22
</meta>

<context>
This skill is auto-discovered by Claude when users request commit-related tasks.
It replaces the previous /commit command with natural language activation.
</context>

# Git Commit Skill

This skill creates git commits following the team's version control guidelines.

## Source of Truth

- **Commit Template**: [`gitmessage`](../../gitmessage)
- **Guidelines**: [`version-control.md`](../guides/version-control.md)

## Commit Message Principles

When creating commits, follow these core principles:

- **Intent focused**: Explain WHY the change was made, not just what changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Write for other developers to understand

## Instructions

### Step 1: Analyze Git State

1. Run `git status` to check for staged/unstaged changes
2. Run `git diff HEAD` to see all changes
3. If no staged changes exist, ask user which files to stage

### Step 2: Determine Commit Type and Scope

Analyze changes and categorize using conventional commit types:

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `test` | Adding/updating tests |
| `chore` | Maintenance tasks |

### Step 3: Compose Commit Message

**Subject Line** (max 50 characters):
- Format: `<type>: <subject>` or `<type>(<scope>): <subject>`
- Language: Korean (한국어)
- Verb form: Use "-하다" ending (예: 추가하다, 수정하다, 개선하다)
- No period at end

**Body** (REQUIRED):
- Explain WHY the change was made
- Include context and background
- Wrap lines at 72 characters

**Footer**:
- Reference related issues/PRs
- Include Claude Code attribution

### Step 4: Create Commit

Use heredoc for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>: <한국어 제목>

<본문 - 변경 이유와 맥락>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model> <noreply@anthropic.com>
EOF
)"
```

## Korean Commit Message Rules

### Subject Line Examples

**Correct ✅**:
- `feat: 사용자 인증을 추가하다`
- `fix: 로그인 버그를 수정하다`
- `refactor: 코드 구조를 개선하다`
- `docs: README를 업데이트하다`

**Incorrect ❌**:
- `feat: 사용자 인증 추가` (missing verb ending)
- `fix: 로그인 버그 수정` (missing verb ending)

**Key Rule**: Always include "-하다" verb ending.

## Claude Code Attribution

All commits must include this footer:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <model> <noreply@anthropic.com>
```

Replace `<model>` with current model (e.g., `Opus 4.5`, `Sonnet 4`).

## See Also

- [gitmessage](../../gitmessage) - Git commit template (Source of Truth)
- [version-control.md](../guides/version-control.md) - Complete git workflow guidelines
