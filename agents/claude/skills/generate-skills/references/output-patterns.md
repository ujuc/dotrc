# Output Patterns Guide

> Two patterns for conveying desired output format to Claude.

---

## 1. Template Pattern

Provide the output format directly. Strictness is adjustable.

### Strict Template

When the format must be followed exactly:

~~~markdown
## Commit Message Format

**ALWAYS use this exact template:**

```
<type>(<scope>): <Korean subject ending with a verb declarative -다>

<body if needed, 72 chars per line>
```

Example:
```
feat(auth): JWT 기반 사용자 인증을 구현하다

리프레시 토큰은 httpOnly 쿠키에 저장하며,
액세스 토큰 만료 시 자동 갱신된다.
```
~~~

### Flexible Template

When structure matters but content has room to adapt:

~~~markdown
## PR Description Structure

Use this structure (adapt section length to PR size):

```
## Summary
[1-3 bullet points]

## Test plan
[Checklist of what to verify]
```
~~~

---

## 2. Examples Pattern

Demonstrate quality with input/output pairs. Best when conveying style over format.

### Basic Structure

~~~markdown
## Examples

**Input:** User requests "implement login button click handler"

**Output:**
```typescript
async function handleLogin(credentials: LoginCredentials): Promise<User> {
  const user = await authService.authenticate(credentials);
  if (!user) throw new AuthError('Invalid credentials');
  return user;
}
```

**Input:** Write commit for "add auth feature"

**Output:** `feat(auth): JWT 기반 사용자 인증을 구현하다`
~~~

### Korean Conventional Commits Examples

~~~markdown
## Commit Message Examples

Good:
- `feat(auth): 소셜 로그인 기능을 추가하다`
- `fix(api): 타임아웃 오류를 처리하다`
- `refactor(db): 쿼리 빌더를 단순화하다`

Bad:
- `Added login` — English, no -다 ending
- `fix: 버그 수정` — no scope, content unclear
- `feat(auth): 사용자가 소셜 계정으로 로그인할 수 있는 기능을 추가했습니다.` — too long, has period
~~~

---

## Pattern Selection Guide

| Situation | Recommended Pattern |
|-----------|---------------------|
| Output format must always be identical | Template (strict) |
| Structure matters, content is flexible | Template (flexible) |
| Conveying style or quality standards | Examples |
| Showing transformations across varied inputs | Examples |
| Format + style both critical | Template + Examples combined |
