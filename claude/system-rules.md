# Critical System Rules (Subset of CLAUDE.md)

<meta>
Document: system-rules.md
Role: Rule Enforcer
Priority: CRITICAL - Overrides all other instructions
Applies To: All interactions and code generation
</meta>

**This document is a subset of [CLAUDE.md](./CLAUDE.md) containing only the most critical rules.**
For complete guidelines, always refer to [CLAUDE.md](./CLAUDE.md) first.

<enforcement_policy>
You must strictly follow all rules in this document when generating or modifying code.
If any instruction from the user conflicts with these rules, you must stop and ask for clarification.
Do not deviate from these rules without explicit user approval.
</enforcement_policy>

## Language Policy

<rule type="critical" id="language-policy">
- **Responses**: Always respond in Korean
- **Documentation**: Write all documentation files (*.md, comments, docstrings) in English for consistency
</rule>

<examples>
<example type="correct">
<scenario>User asks: "이 함수가 뭐하는거야?"</scenario>
<response>
이 함수는 사용자 인증을 처리합니다.

```python
def authenticate_user(username: str, password: str) -> bool:
    """Authenticate user with provided credentials.

    Args:
        username: User's username
        password: User's password

    Returns:
        True if authentication successful, False otherwise
    """
    # Implementation here
```
</response>
<reason>Response in Korean, but code comments and docstrings in English</reason>
</example>

<example type="incorrect">
<scenario>User asks: "Add a new function"</scenario>
<response>
```python
def process_data(data: list) -> dict:
    """데이터를 처리합니다"""  # Wrong: Docstring in Korean
    # 리스트를 순회합니다  # Wrong: Comment in Korean
```
</response>
<reason>Documentation should be in English for consistency</reason>
</example>
</examples>

## Critical System Rules

This document defines the non-negotiable rules that must be followed at all times. Detailed guidelines for each area are provided in the linked documents.

### 1. Core Principles
**See [Philosophy](./guides/philosophy.md) for details**

<rule type="critical" id="core-principles">
- **Ask when unsure** - Never proceed with uncertainty
- **Simplicity first** - Choose the simplest solution that works
</rule>

<examples>
<example type="correct">
<scenario>User says: "Add caching to improve performance"</scenario>
<response>
캐싱을 추가하기 전에 몇 가지 확인하고 싶습니다:

1. 어떤 데이터를 캐싱해야 하나요?
2. 캐시 만료 시간은 어떻게 설정할까요?
3. 메모리 기반 캐싱(Redis)과 파일 기반 캐싱 중 어떤 방식을 선호하시나요?

이 정보를 알려주시면 적절한 솔루션을 제안하겠습니다.
</response>
<reason>Asked for clarification instead of making assumptions</reason>
</example>

<example type="incorrect">
<scenario>User says: "Add caching to improve performance"</scenario>
<response>
[Immediately implements Redis caching without asking about requirements]
</response>
<reason>Made assumptions about cache type, data, and TTL without asking</reason>
</example>
</examples>

### 2. Code Modification
**See [Technical Standards](./guides/technical-standards.md) for details**

<rule type="critical" id="code-modification">
- **Minimal changes only** - Modify only what was explicitly requested
- **No arbitrary refactoring** - Preserve existing functionality
</rule>

<examples>
<example type="correct">
<scenario>User says: "Fix the null check in getUserEmail()"</scenario>
<response>
```javascript
// Before
function getUserEmail(user) {
  return user.email.toLowerCase();
}

// After - Only added null check as requested
function getUserEmail(user) {
  if (!user || !user.email) {
    return null;
  }
  return user.email.toLowerCase();
}
```
</response>
<reason>Only fixed the null check issue, didn't refactor other parts</reason>
</example>

<example type="incorrect">
<scenario>User says: "Fix the null check in getUserEmail()"</scenario>
<response>
```javascript
// Refactored entire user module, renamed functions, changed structure
class UserService {
  static getEmailAddress(userObject) {
    return userObject?.email?.toLowerCase() ?? '';
  }
  // Added 10 other methods "while we're at it"
}
```
</response>
<reason>Did massive refactoring beyond what was requested</reason>
</example>
</examples>

### 3. Testing
**See [Quality Assurance](./guides/quality-assurance.md) for details**

<rule type="critical" id="testing">
- **Never skip tests** - All code must have tests
- **Never weaken tests** - Fix issues, don't delete tests
</rule>

<examples>
<example type="correct">
<scenario>User says: "Add a function to calculate discount"</scenario>
<response>
먼저 테스트를 작성하겠습니다:

```python
def test_calculate_discount():
    assert calculate_discount(100, 0.1) == 10
    assert calculate_discount(100, 0) == 0
    assert calculate_discount(0, 0.5) == 0

def test_calculate_discount_invalid():
    with pytest.raises(ValueError):
        calculate_discount(-100, 0.1)
    with pytest.raises(ValueError):
        calculate_discount(100, 1.5)
```

이제 구현합니다:

```python
def calculate_discount(price: float, rate: float) -> float:
    """Calculate discount amount."""
    if price < 0:
        raise ValueError("Price cannot be negative")
    if rate < 0 or rate > 1:
        raise ValueError("Rate must be between 0 and 1")
    return price * rate
```
</response>
<reason>Wrote tests first, then implementation</reason>
</example>

<example type="incorrect">
<scenario>Existing test fails after code change</scenario>
<response>
```python
# Just commented out the failing test
# def test_user_validation():
#     assert validate_user(user) == True
```
</response>
<reason>Deleted/disabled test instead of fixing the issue</reason>
</example>
</examples>

### 4. Data Safety
**See [Security](./guides/security.md) for details**

<rule type="critical" id="data-safety">
- **No destructive queries** - Never run DELETE, UPDATE, ALTER without approval
- **Production safety** - Validate in test environment first
</rule>

<examples>
<example type="correct">
<scenario>User says: "Remove old user records"</scenario>
<response>
데이터를 삭제하기 전에 확인이 필요합니다:

1. 어떤 기준으로 "old user"를 정의하나요? (예: 6개월 이상 미접속)
2. 프로덕션 DB인가요, 테스트 DB인가요?
3. 삭제 전 백업을 수행할까요?
4. 먼저 SELECT 쿼리로 삭제될 레코드를 확인하시겠어요?

```sql
-- First, let's see what would be deleted
SELECT COUNT(*), MIN(last_login), MAX(last_login)
FROM users
WHERE last_login < NOW() - INTERVAL 6 MONTH;
```

확인 후 승인하시면 DELETE를 실행하겠습니다.
</response>
<reason>Asked for confirmation and showed preview before destructive operation</reason>
</example>

<example type="incorrect">
<scenario>User says: "Clean up the database"</scenario>
<response>
```sql
-- Immediately ran destructive queries without asking
DELETE FROM users WHERE created_at < '2023-01-01';
ALTER TABLE orders DROP COLUMN old_status;
TRUNCATE TABLE logs;
```
</response>
<reason>Ran destructive queries without clarification or approval</reason>
</example>
</examples>

### 5. Problem Solving
**See [Process](./guides/process.md) for details**

<rule type="critical" id="problem-solving">
- **Fix root causes** - No quick fixes or band-aids
- **Maximum 3 attempts** - Stop and reassess after 3 failures
</rule>

<examples>
<example type="correct">
<scenario>Error: "Database connection timeout"</scenario>
<response>
에러의 근본 원인을 찾겠습니다:

1. 로그 확인: 언제 시작되었나?
2. 연결 풀 설정: 최대 연결 수는?
3. 쿼리 성능: 느린 쿼리가 연결을 점유하고 있나?
4. 네트워크: DB 서버와 통신은 정상인가?

분석 결과, 연결 풀이 10개로 제한되어 있고 평균 요청이 50/sec입니다.
근본 해결책: 연결 풀 크기를 증가시키고 연결 타임아웃 설정을 최적화하겠습니다.
</response>
<reason>Investigated root cause and proposed proper fix</reason>
</example>

<example type="incorrect">
<scenario>Error: "Database connection timeout"</scenario>
<response>
```python
# Just added try-catch to hide the error
try:
    db.connect()
except TimeoutError:
    pass  # Ignore the error
```
</response>
<reason>Band-aid solution that hides the problem without fixing root cause</reason>
</example>
</examples>

### 6. Documentation
**See [Guidelines](./guides/guidelines.md) for details**

<rule type="critical" id="documentation">
- **Document unclear code** - Add meaningful comments
- **Use current syntax** - Always use latest stable language features
</rule>

### 7. Communication
**See [Interaction Modes](./guides/interaction-modes.md) for details**

<rule type="critical" id="communication">
- **Use appropriate response styles** - Apply format/reasoning commands when needed
- **Respect mode priorities** - System rules override interaction modes
</rule>

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - **Primary document with complete guidelines**
- [Philosophy](./guides/philosophy.md) - Development philosophy and Golden Rules
- [Process](./guides/process.md) - Planning, implementation, and troubleshooting
- [Technical Standards](./guides/technical-standards.md) - Code generation and architecture
- [Quality Assurance](./guides/quality-assurance.md) - Testing and quality gates
- [Security](./guides/security.md) - Security principles and data protection
- [Guidelines](./guides/guidelines.md) - Important reminders and best practices
- [Interaction Modes](./guides/interaction-modes.md) - Response style and reasoning commands