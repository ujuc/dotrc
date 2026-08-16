---
name: commit
description: Creates git commits following team's version control guidelines. Use when the user asks to "commit changes", "create a commit", "make a commit", "커밋해줘", "변경사항 저장", "커밋 메시지 작성", "커밋 만들어줘", or needs to commit staged/unstaged changes to git.
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(gdate:*)
model: haiku
version: 1.0.0
metadata:
  role: "Git Commit Generator"
  priority: "Medium"
  applies-to: "Git commit creation in any project"
  optimized-for: "Claude 4.5 (Sonnet/Opus)"
  last-updated: "2025-12-22"
  context: |
    This skill is auto-discovered by Claude when users request commit-related tasks.
    It replaces the previous /commit command with natural language activation.
---

# Git Commit Skill

This skill creates git commits following the team's version control guidelines.

## Source of Truth

- **Commit Template**: [`gitmessage`](../../../gitmessage)
- **Guidelines**: [`version-control.md`](../guides/version-control.md)

## Commit Message Principles

When creating commits, follow these core principles:

- **Intent focused**: Explain WHY the change was made, not just what changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Write for other developers to understand

## Language Policy (Default: Korean)

커밋 메시지 언어의 기본값은 **한국어(Korean)**입니다.

- **Default**: Korean commit messages (subject and body)
- **Override**: If project's CLAUDE.md or AGENTS.md specifies a different language policy, follow that policy
- **Explicit request**: Use other languages only when explicitly requested by the user

This ensures consistency with the user's personal workflow while allowing project-specific flexibility.

## Instructions

### Step 1: Analyze Git State

1. Run `git status` to check for staged/unstaged changes
2. Run `git diff HEAD` to see all changes
3. If no staged changes exist, ask user which files to stage

### Step 2: Determine Commit Type and Scope

Analyze changes and categorize using conventional commit types:

| Type       | Description                |
| ---------- | -------------------------- |
| `feat`     | New feature                |
| `fix`      | Bug fix                    |
| `docs`     | Documentation only         |
| `style`    | Formatting, no code change |
| `refactor` | Code restructuring         |
| `test`     | Adding/updating tests      |
| `chore`    | Maintenance tasks          |

### Step 3: Compose Commit Message

**Subject Line** (max 50 characters):

- Format: `<type>: <subject>` or `<type>(<scope>): <subject>`
- Language: Korean (한국어)
- Verb form: Use "-하다" ending (예: 추가하다, 수정하다, 개선하다)
- No period at end

**Body** (REQUIRED):

- Language: Korean (한국어)
- Explain WHY the change was made
- Include context and background
- Wrap lines at 72 characters

**Footer**:

- Reference related issues/PRs

**AI agent footer**:

- Include AI agent attribution

### Step 4: Create Commit

Use heredoc for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
<type>: <한국어 제목>

<한국어 본문 - 변경 이유와 맥락 설명>

<footer>

<ai agent footer>
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

### Complete Commit Message Examples

**Example 1 - Feature Addition**:

```
feat(skills): PR 본문 작성 언어를 한국어로 변경하다

create-pr 스킬에서 PR 본문 작성 언어 정책을 영어에서 한국어로 변경하다.
이제 PR 제목과 본문 모두 일관성 있게 한국어로 작성된다.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Example 2 - Bug Fix**:

```
fix(alb): WAF 규칙 우선순위 충돌을 수정하다

동일한 우선순위를 가진 WAF 규칙들이 충돌을 일으키는 문제를 해결하다.
각 규칙에 고유한 우선순위 값을 할당하여 충돌을 방지한다.

Closes: RP-1234

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Example 3 - Documentation**:

```
docs(spec): ALB listener priority 정책 문서를 추가하다

ALB listener 우선순위 할당 규칙과 범위에 대한 명확한 가이드라인을 제공하다.
이를 통해 팀원들이 일관된 우선순위 전략을 따를 수 있다.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Key Points**:

- Subject and body both in Korean (한국어)
- Body explains WHY, not just WHAT
- Footer includes issue references and AI attribution

## Agent Footer Format

The `<ai agent footer>` placeholder in commit templates should be replaced with your AI agent's attribution.

### Format

```
🤖 Generated with [Agent Name](agent-url)
```

### Notes

- First line: Emoji + link to agent (optional if no URL)
- Model name is optional (Claude-specific)

## See Also

- [git message template](../../../gitmessage) - Git commit template (Source of Truth)
- [guide/version-control](../guides/version-control.md) - Complete git workflow guidelines
