# Git Commit Message Guide

Reference for writing commit messages in this repository.
Based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
and [Better Commit Messages with a .gitmessage Template](https://thoughtbot.com/blog/better-commit-messages-with-a-gitmessage-template).

## Writing Principles

- **Intent-first**: Reveal *why* you changed something, not just *what* changed.
- **Context-aware**: Include the background and purpose behind the change.
- **Collaboration-friendly**: Reflect requirements and problem awareness for other developers.

Priority: **why > what > how**

## Format

```
<type>(<scope>): <subject>

<body>

<issue or URL>
```

### Subject line

- Written in Korean, ending with a verb in completed form (e.g., `수정하다`, `추가하다`)
- 50 characters or fewer (including type prefix)
- No trailing period
- Example: `docs: README.md 파일을 수정하다`

### Body

- Explain *why* and *what*, not *how*
- 72 characters per line
- Use `-` for bullet points
- Separate from subject with a blank line

### Issue / URL

- Related issue number or PR link (optional)

## Commit Types

| Type       | Description                          |
|------------|--------------------------------------|
| `feat`     | New feature                          |
| `fix`      | Bug fix                              |
| `refactor` | Code refactoring (no behavior change)|
| `style`    | Formatting only (no logic change)    |
| `docs`     | Documentation changes                |
| `test`     | Add or refactor tests                |
| `chore`    | Build, tooling, package manager, etc.|

## Examples

```
feat(auth): OAuth 로그인 기능을 추가하다

사용자가 Google 계정으로 로그인할 수 있도록 OAuth 2.0 플로우를 구현한다.
기존 세션 기반 인증과 병행 운용하며, 추후 단일화를 검토한다.

- Google OAuth 콜백 엔드포인트 추가
- 세션에 OAuth 토큰 저장

Closes #42
```

```
fix(zshrc): 플러그인 로드 순서 오류를 수정하다

zimfw 초기화 전에 PATH 설정이 선행되어야 하는데 순서가 뒤바뀌어
일부 툴(pyenv, rbenv)이 정상 동작하지 않던 문제를 수정한다.
```

## Notes for Skill Generation

When generating commit messages via AI:

1. Analyze the diff to understand *intent*, not just line changes.
2. Choose the most specific `type` that fits — avoid defaulting to `chore`.
3. Write the subject in Korean with a completed-action verb ending (`-하다`).
4. If the change has a non-obvious reason, always include a body.
5. Keep subject ≤ 50 chars; body lines ≤ 72 chars.
