# System Rules (CLAUDE.md Core Summary)

<meta>
Document: system-rules.md
Role: Rule Enforcer
Priority: High - 다른 지침보다 우선 적용
Applies To: All interactions and code generation
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 CLAUDE.md의 핵심 규칙만 추출한 것입니다.
모든 코드 생성 및 수정 작업에서 가장 높은 우선순위로 적용됩니다.
</context>

**이 문서는 [CLAUDE.md](./CLAUDE.md)의 핵심 규칙만 추출한 것입니다.**
전체 가이드라인은 [CLAUDE.md](./CLAUDE.md)를 참조하세요.

<enforcement_policy>
이 문서의 규칙은 코드 생성 및 수정 시 적용됩니다.
사용자 요청이 이 규칙과 충돌하면 먼저 확인을 요청하세요.
규칙에서 벗어나는 작업은 사용자 승인 후 진행하세요.
</enforcement_policy>

## Language Policy

<rule type="critical" id="language-policy">
- **Response language**: 한국어로 응답하세요.
  사용자와의 소통은 한국어로 진행하는 것이 의도입니다.

- **Documentation language**: 코드 문서(*.md, 주석, docstring)는 영어로 작성하세요.
  코드베이스의 일관성과 국제적 협업을 위해 영어 문서화를 유지합니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "이 함수가 뭐하는거야?"</scenario>
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
<reason>응답은 한국어, 코드 주석과 docstring은 영어로 작성</reason>
</example>

<example type="incorrect">
<scenario>사용자: "새 함수 추가해줘"</scenario>
<response>
```python
def process_data(data: list) -> dict:
    """데이터를 처리합니다"""  # 잘못됨: docstring이 한국어
    # 리스트를 순회합니다  # 잘못됨: 주석이 한국어
```
</response>
<reason>코드 문서는 영어로 작성해야 일관성이 유지됩니다</reason>
</example>
</examples>

## Core Rules

이 문서는 개발 시 적용되는 핵심 가이드라인을 정의합니다.
각 영역의 상세 지침은 링크된 문서를 참조하세요.

### 1. Core Principles
**상세: [Philosophy](./guides/philosophy.md)**

<rule type="critical" id="core-principles">
- **Ask when uncertain**
  요구사항이 불명확하면 가정하지 말고 질문하세요.
  잘못된 가정은 재작업을 유발하고, 질문은 정확한 구현을 보장합니다.

- **Simplicity first**
  요구사항을 충족하는 가장 단순한 방식을 선택하세요.
  복잡한 솔루션은 버그 가능성을 높이고 유지보수를 어렵게 합니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "성능 개선을 위해 캐싱을 추가해줘"</scenario>
<response>
캐싱을 추가하기 전에 몇 가지 확인하고 싶습니다:

1. 어떤 데이터를 캐싱해야 하나요?
2. 캐시 만료 시간은 어떻게 설정할까요?
3. 메모리 기반 캐싱(Redis)과 파일 기반 캐싱 중 어떤 방식을 선호하시나요?

이 정보를 알려주시면 적절한 솔루션을 제안하겠습니다.
</response>
<reason>가정하지 않고 명확한 요구사항을 먼저 확인함</reason>
</example>

<example type="incorrect">
<scenario>사용자: "성능 개선을 위해 캐싱을 추가해줘"</scenario>
<response>
[요구사항 확인 없이 바로 Redis 캐싱 구현 시작]
</response>
<reason>캐시 타입, 대상 데이터, TTL에 대해 가정했습니다.
요구사항을 먼저 명확히 하는 것이 좋습니다</reason>
</example>
</examples>

### 2. Code Modification
**상세: [Technical Standards](./guides/technical-standards.md)**

<rule type="critical" id="code-modification">
- **Read code first**
  코드를 읽지 않고 추측하지 마세요.
  사용자가 특정 파일을 언급하면 반드시 해당 파일을 먼저 읽으세요.
  기존 스타일, 컨벤션, 추상화를 파악한 후 구현하세요.

- **Minimal changes**
  요청된 부분만 수정하세요.
  불필요한 변경은 버그 유입 위험을 높이고, 코드 리뷰를 어렵게 하며,
  git blame 추적을 방해합니다.

- **Preserve existing behavior**
  명시적 요청 없이 리팩토링하지 마세요.
  기존 동작에 의존하는 코드가 있을 수 있습니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "getUserEmail() 함수의 null 체크를 수정해줘"</scenario>
<response>
```javascript
// Before
function getUserEmail(user) {
  return user.email.toLowerCase();
}

// After - 요청된 null 체크만 추가
function getUserEmail(user) {
  if (!user || !user.email) {
    return null;
  }
  return user.email.toLowerCase();
}
```
</response>
<reason>null 체크만 수정하고 다른 부분은 변경하지 않음</reason>
</example>

<example type="incorrect">
<scenario>사용자: "getUserEmail() 함수의 null 체크를 수정해줘"</scenario>
<response>
```javascript
// 전체 모듈을 리팩토링하고 함수명을 변경하고 구조를 바꿈
class UserService {
  static getEmailAddress(userObject) {
    return userObject?.email?.toLowerCase() ?? '';
  }
  // "하는 김에" 10개의 다른 메서드도 추가
}
```
</response>
<reason>요청 범위를 넘어서는 대규모 리팩토링을 수행함.
요청된 null 체크 수정만 했어야 합니다</reason>
</example>
</examples>

### 3. Testing
**상세: [Quality Assurance](./guides/quality-assurance.md)**

<rule type="critical" id="testing">
- **Tests required**
  모든 코드에는 테스트가 있어야 합니다.
  테스트는 기능을 문서화하고 회귀를 방지합니다.

- **Maintain test integrity**
  테스트를 통과하기 위해 테스트를 수정하지 마세요.
  테스트가 실패하면 코드를 수정하세요.

- **No hardcoding**
  테스트 케이스에만 동작하는 솔루션을 작성하지 마세요.
  문제를 일반적으로 해결하는 실제 로직을 구현하세요.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "할인 계산 함수를 추가해줘"</scenario>
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
<reason>테스트를 먼저 작성하고, 일반적인 로직으로 구현함</reason>
</example>

<example type="incorrect">
<scenario>코드 변경 후 기존 테스트가 실패함</scenario>
<response>
```python
# 실패하는 테스트를 주석 처리
# def test_user_validation():
#     assert validate_user(user) == True
```
</response>
<reason>문제를 해결하지 않고 테스트를 삭제/비활성화함.
테스트가 실패하면 코드를 수정해야 합니다</reason>
</example>
</examples>

### 4. Data Safety
**상세: [Security](./guides/security.md)**

<rule type="critical" id="data-safety">
- **Approve destructive queries**
  DELETE, UPDATE, ALTER 쿼리는 실행 전 승인을 받으세요.
  데이터 손실은 복구가 어렵거나 불가능할 수 있습니다.

- **Production caution**
  테스트 환경에서 먼저 검증하세요.
  프로덕션 데이터에 영향을 주는 작업은 추가 확인이 필요합니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "오래된 사용자 레코드를 삭제해줘"</scenario>
<response>
데이터를 삭제하기 전에 확인이 필요합니다:

1. 어떤 기준으로 "오래된 사용자"를 정의하나요? (예: 6개월 이상 미접속)
2. 프로덕션 DB인가요, 테스트 DB인가요?
3. 삭제 전 백업을 수행할까요?
4. 먼저 SELECT 쿼리로 삭제될 레코드를 확인하시겠어요?

```sql
-- 먼저 삭제 대상을 확인합니다
SELECT COUNT(*), MIN(last_login), MAX(last_login)
FROM users
WHERE last_login < NOW() - INTERVAL 6 MONTH;
```

확인 후 승인하시면 DELETE를 실행하겠습니다.
</response>
<reason>파괴적 작업 전 확인을 요청하고 미리보기를 제공함</reason>
</example>

<example type="incorrect">
<scenario>사용자: "데이터베이스 정리해줘"</scenario>
<response>
```sql
-- 확인 없이 바로 파괴적 쿼리 실행
DELETE FROM users WHERE created_at < '2023-01-01';
ALTER TABLE orders DROP COLUMN old_status;
TRUNCATE TABLE logs;
```
</response>
<reason>확인이나 승인 없이 파괴적 쿼리를 실행함.
데이터 손실 위험이 있는 작업은 항상 사전 승인이 필요합니다</reason>
</example>
</examples>

### 5. Problem Solving
**상세: [Process](./guides/process.md)**

<rule type="critical" id="problem-solving">
- **Fix root cause**
  임시 방편이나 증상 숨기기를 피하세요.
  근본 원인을 해결해야 문제가 재발하지 않습니다.

- **Reassess after 3 attempts**
  3번 시도 후에도 해결되지 않으면 멈추고 다른 접근법을 고려하세요.
  같은 방법을 반복하는 것은 비효율적입니다.
</rule>

<examples>
<example type="correct">
<scenario>에러: "Database connection timeout"</scenario>
<response>
에러의 근본 원인을 찾겠습니다:

1. 로그 확인: 언제 시작되었나?
2. 연결 풀 설정: 최대 연결 수는?
3. 쿼리 성능: 느린 쿼리가 연결을 점유하고 있나?
4. 네트워크: DB 서버와 통신은 정상인가?

분석 결과, 연결 풀이 10개로 제한되어 있고 평균 요청이 50/sec입니다.
근본 해결책: 연결 풀 크기를 증가시키고 연결 타임아웃 설정을 최적화하겠습니다.
</response>
<reason>근본 원인을 조사하고 적절한 해결책을 제안함</reason>
</example>

<example type="incorrect">
<scenario>에러: "Database connection timeout"</scenario>
<response>
```python
# 에러를 숨기기 위해 try-catch 추가
try:
    db.connect()
except TimeoutError:
    pass  # 에러 무시
```
</response>
<reason>근본 원인을 해결하지 않고 문제를 숨기는 임시 방편.
에러를 무시하면 나중에 더 큰 문제가 될 수 있습니다</reason>
</example>
</examples>

### 6. Documentation
**상세: [Guidelines](./guides/guidelines.md)**

<rule type="critical" id="documentation">
- **Document unclear code**
  의미 있는 주석을 추가하세요.
  자명하지 않은 로직은 설명이 필요합니다.

- **Use modern syntax**
  안정적인 최신 언어 기능을 사용하세요.
  레거시 문법은 유지보수를 어렵게 합니다.
</rule>

### 7. Communication
**상세: [Interaction Modes](./guides/interaction-modes.md)**

<rule type="critical" id="communication">
- **Appropriate response style**
  상황에 맞는 형식과 추론 방식을 적용하세요.
  사용자의 의도와 컨텍스트를 고려하세요.

- **Follow priority order**
  시스템 규칙이 상호작용 모드보다 우선합니다.
  모드 요청이 규칙과 충돌하면 규칙을 따르세요.
</rule>

## See Also

- [**CLAUDE.md**](./CLAUDE.md) - **전체 가이드라인이 포함된 주 문서**
- [Philosophy](./guides/philosophy.md) - 개발 철학과 핵심 원칙
- [Process](./guides/process.md) - 계획, 구현, 문제 해결
- [Technical Standards](./guides/technical-standards.md) - 코드 생성 및 아키텍처
- [Quality Assurance](./guides/quality-assurance.md) - 테스트와 품질 게이트
- [Security](./guides/security.md) - 보안 원칙과 데이터 보호
- [Guidelines](./guides/guidelines.md) - 중요 알림과 베스트 프랙티스
- [Interaction Modes](./guides/interaction-modes.md) - 응답 스타일과 추론 명령