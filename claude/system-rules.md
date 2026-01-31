# System Rules (CLAUDE.md Core Summary)

<meta>
Document: system-rules.md
Role: Rule Enforcer
Priority: High - Takes precedence over other guidelines
Applies To: All interactions and code generation
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document extracts the core rules from CLAUDE.md.
These rules have the highest priority in all code generation and modification tasks.
</context>

**This document extracts the core rules from [CLAUDE.md](./CLAUDE.md).**
See [CLAUDE.md](./CLAUDE.md) for complete guidelines.

<enforcement_policy>
These rules apply during code generation and modification.
If user requests conflict with these rules, ask for confirmation first.
Proceed with deviations only after explicit user approval.
</enforcement_policy>

## Language Policy

<rule type="critical" id="language-policy">
- **Response language**: ALL responses to the user MUST be in Korean.
  This includes: explanations, summaries, status messages, commit completion messages,
  PR creation results, plan summaries, error messages, and any other text shown to the user.

- **File output language**: Write all file outputs in English by default.
  This ONLY applies to content written to files: code, comments, docstrings,
  documentation files, config files, commit message body, PR description body.
  Only write in Korean if explicitly requested by the user.

**Key distinction**:
- Text displayed to user in terminal/chat → Korean
- Text written to files → English
</rule>

<examples>
<example type="correct">
<scenario>User: "What does this function do?"</scenario>
<response>
This function handles user authentication. (Response in Korean to user)

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
<reason>Response is in Korean, code comments and docstrings are in English</reason>
</example>

<example type="incorrect">
<scenario>User: "Add a new function"</scenario>
<response>
```python
def process_data(data: list) -> dict:
    """데이터를 처리합니다"""  # Wrong: docstring in Korean
    # 리스트를 순회합니다  # Wrong: comment in Korean
```
</response>
<reason>File outputs must be in English for consistency</reason>
</example>
</examples>

## Core Rules

This document defines the core guidelines applied during development.
See linked documents for detailed instructions in each area.

### 1. Core Principles
**Details: [Philosophy](./guides/philosophy.md)**

<rule type="critical" id="core-principles">
- **Ask when uncertain**
  If requirements are unclear, ask questions instead of assuming.
  Wrong assumptions cause rework; questions ensure accurate implementation.

- **Simplicity first**
  Choose the simplest approach that meets requirements.
  Complex solutions increase bug probability and make maintenance harder.
</rule>

<examples>
<example type="correct">
<scenario>User: "Add caching for performance improvement"</scenario>
<response>
Before adding caching, I'd like to clarify a few things:

1. What data should be cached?
2. How should cache expiration be configured?
3. Do you prefer memory-based (Redis) or file-based caching?

Please provide this information so I can suggest an appropriate solution.
</response>
<reason>Clarified requirements first instead of making assumptions</reason>
</example>

<example type="incorrect">
<scenario>User: "Add caching for performance improvement"</scenario>
<response>
[Starts implementing Redis caching without confirming requirements]
</response>
<reason>Made assumptions about cache type, target data, and TTL.
Should clarify requirements first</reason>
</example>
</examples>

### 2. Code Modification
**Details: [Technical Standards](./guides/technical-standards.md)**

<rule type="critical" id="code-modification">
- **Read code first**
  Don't guess without reading the code.
  If the user mentions a specific file, always read it first.
  Understand existing style, conventions, and abstractions before implementing.

- **Minimal changes**
  Only modify what was requested.
  Unnecessary changes increase bug risk, complicate code reviews,
  and interfere with git blame tracking.

- **Preserve existing behavior**
  Don't refactor without explicit request.
  Other code may depend on existing behavior.
</rule>

<examples>
<example type="correct">
<scenario>User: "Fix the null check in getUserEmail() function"</scenario>
<response>
```javascript
// Before
function getUserEmail(user) {
  return user.email.toLowerCase();
}

// After - Only added the requested null check
function getUserEmail(user) {
  if (!user || !user.email) {
    return null;
  }
  return user.email.toLowerCase();
}
```
</response>
<reason>Only modified the null check, left other parts unchanged</reason>
</example>

<example type="incorrect">
<scenario>User: "Fix the null check in getUserEmail() function"</scenario>
<response>
```javascript
// Refactored entire module, renamed function, changed structure
class UserService {
  static getEmailAddress(userObject) {
    return userObject?.email?.toLowerCase() ?? '';
  }
  // "While at it" added 10 other methods
}
```
</response>
<reason>Performed large-scale refactoring beyond request scope.
Should have only fixed the null check as requested</reason>
</example>
</examples>

### 3. Testing
**Details: [Quality Assurance](./guides/quality-assurance.md)**

<rule type="critical" id="testing">
- **Tests required**
  All code must have tests.
  Tests document functionality and prevent regressions.

- **Maintain test integrity**
  Don't modify tests to make them pass.
  If tests fail, fix the code.

- **No hardcoding**
  Don't write solutions that only work for test cases.
  Implement actual logic that solves the problem generally.
</rule>

<examples>
<example type="correct">
<scenario>User: "Add a discount calculation function"</scenario>
<response>
First, I'll write the tests:

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

Now implementing:

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
<reason>Wrote tests first, then implemented with general logic</reason>
</example>

<example type="incorrect">
<scenario>Existing tests fail after code changes</scenario>
<response>
```python
# Commented out failing test
# def test_user_validation():
#     assert validate_user(user) == True
```
</response>
<reason>Deleted/disabled tests instead of fixing the problem.
When tests fail, fix the code</reason>
</example>
</examples>

### 4. Data Safety
**Details: [Security](./guides/security.md)**

<rule type="critical" id="data-safety">
- **Approve destructive queries**
  Get approval before running DELETE, UPDATE, ALTER queries.
  Data loss can be difficult or impossible to recover.

- **Production caution**
  Verify in test environment first.
  Operations affecting production data require additional confirmation.
</rule>

<examples>
<example type="correct">
<scenario>User: "Delete old user records"</scenario>
<response>
Before deleting data, I need some clarification:

1. How do you define "old users"? (e.g., no login for 6+ months)
2. Is this production DB or test DB?
3. Should I create a backup before deletion?
4. Would you like to preview records with SELECT first?

```sql
-- First, let's preview what will be deleted
SELECT COUNT(*), MIN(last_login), MAX(last_login)
FROM users
WHERE last_login < NOW() - INTERVAL 6 MONTH;
```

I'll execute DELETE after your approval.
</response>
<reason>Requested confirmation before destructive operation and provided preview</reason>
</example>

<example type="incorrect">
<scenario>User: "Clean up the database"</scenario>
<response>
```sql
-- Executed destructive queries without confirmation
DELETE FROM users WHERE created_at < '2023-01-01';
ALTER TABLE orders DROP COLUMN old_status;
TRUNCATE TABLE logs;
```
</response>
<reason>Executed destructive queries without confirmation or approval.
Operations with data loss risk always require prior approval</reason>
</example>
</examples>

### 5. Problem Solving
**Details: [Process](./guides/process.md)**

<rule type="critical" id="problem-solving">
- **Fix root cause**
  Avoid band-aids or hiding symptoms.
  Fixing the root cause prevents the problem from recurring.

- **Reassess after 3 attempts**
  If unresolved after 3 attempts, stop and consider different approaches.
  Repeating the same method is inefficient.
</rule>

<examples>
<example type="correct">
<scenario>Error: "Database connection timeout"</scenario>
<response>
Let me find the root cause of this error:

1. Check logs: When did this start?
2. Connection pool settings: What's the max connection count?
3. Query performance: Are slow queries holding connections?
4. Network: Is communication with DB server normal?

Analysis result: Connection pool is limited to 10 and average requests are 50/sec.
Root solution: I'll increase connection pool size and optimize connection timeout settings.
</response>
<reason>Investigated root cause and proposed appropriate solution</reason>
</example>

<example type="incorrect">
<scenario>Error: "Database connection timeout"</scenario>
<response>
```python
# Added try-catch to hide the error
try:
    db.connect()
except TimeoutError:
    pass  # Ignore error
```
</response>
<reason>Band-aid that hides the problem without fixing root cause.
Ignoring errors can lead to bigger problems later</reason>
</example>
</examples>

### 6. Documentation
**Details: [Guidelines](./guides/guidelines.md)**

<rule type="critical" id="documentation">
- **Document unclear code**
  Add meaningful comments.
  Non-obvious logic requires explanation.

- **Use modern syntax**
  Use stable, modern language features.
  Legacy syntax makes maintenance harder.
</rule>

### 7. Communication
**Details: [Interaction Modes](./guides/interaction-modes.md)**

<rule type="critical" id="communication">
- **Appropriate response style**
  Apply format and reasoning style appropriate to the situation.
  Consider user intent and context.

- **Follow priority order**
  System rules take precedence over interaction modes.
  If mode requests conflict with rules, follow the rules.
</rule>

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - **Primary document with complete guidelines**
- [Philosophy](./guides/philosophy.md) - Development philosophy and core principles
- [Process](./guides/process.md) - Planning, implementation, problem solving
- [Technical Standards](./guides/technical-standards.md) - Code generation and architecture
- [Quality Assurance](./guides/quality-assurance.md) - Testing and quality gates
- [Security](./guides/security.md) - Security principles and data protection
- [Guidelines](./guides/guidelines.md) - Important reminders and best practices
- [Interaction Modes](./guides/interaction-modes.md) - Response styles and reasoning commands