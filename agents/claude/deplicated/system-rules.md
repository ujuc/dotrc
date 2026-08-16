# 시스템 규칙 (CLAUDE.md 핵심 요약)

<meta>
Document: system-rules.md
Role: Rule Enforcer
Priority: High - Takes precedence over other guidelines
Applies To: All interactions and code generation
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 CLAUDE.md의 핵심 규칙을 추출합니다.
이 규칙들은 모든 코드 생성 및 수정 작업에서 최우선 순위를 가집니다.
</context>

**이 문서는 [CLAUDE.md](../CLAUDE.md)의 핵심 규칙을 추출합니다.**
전체 가이드라인은 [CLAUDE.md](../CLAUDE.md)를 참조하세요.

<enforcement_policy>
이 규칙들은 코드 생성 및 수정 시 적용됩니다.
사용자 요청이 이 규칙과 충돌하는 경우, 먼저 확인을 요청하세요.
명시적인 사용자 승인 후에만 예외를 적용하세요.
</enforcement_policy>

## 언어 정책

<rule type="critical" id="language-policy">
- **응답 언어**: 사용자에게 하는 모든 응답은 반드시 한국어로 작성해야 합니다.
  여기에 포함되는 것: 설명, 요약, 상태 메시지, 커밋 완료 메시지,
  PR 생성 결과, 계획 요약, 에러 메시지 및 사용자에게 표시되는 모든 텍스트.

- **파일 출력 언어**: 모든 파일 출력은 기본적으로 영어로 작성합니다.
  이는 파일에 기록되는 내용에만 적용됩니다: 코드, 주석, docstring,
  문서 파일, 설정 파일, 커밋 메시지 본문, PR 설명 본문.
  사용자가 명시적으로 요청한 경우에만 한국어로 작성합니다.

**핵심 구분**:
- 터미널/채팅에서 사용자에게 표시되는 텍스트 → 한국어
- 파일에 기록되는 텍스트 → 영어
</rule>

<examples>
<example type="correct">
<scenario>사용자: "이 함수가 뭐 하는 거야?"</scenario>
<response>
이 함수는 사용자 인증을 처리합니다. (사용자에게 한국어로 응답)

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
<reason>응답은 한국어로, 코드 주석과 docstring은 영어로 작성</reason>
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
<reason>일관성을 위해 파일 출력은 영어로 작성해야 함</reason>
</example>
</examples>

## 핵심 규칙

이 문서는 개발 시 적용되는 핵심 가이드라인을 정의합니다.
각 영역의 자세한 지침은 링크된 문서를 참조하세요.

### 1. 핵심 원칙
**상세 내용: [Philosophy](guides/philosophy.md)**

<rule type="critical" id="core-principles">
- **불확실하면 질문하기**
  요구사항이 불분명한 경우, 추측하지 말고 질문하세요.
  잘못된 가정은 재작업을 유발하며, 질문은 정확한 구현을 보장합니다.

- **단순함 우선**
  요구사항을 충족하는 가장 단순한 접근 방식을 선택하세요.
  복잡한 솔루션은 버그 확률을 높이고 유지보수를 어렵게 만듭니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "성능 개선을 위해 캐싱 추가해줘"</scenario>
<response>
캐싱을 추가하기 전에 몇 가지 확인하고 싶습니다:

1. 어떤 데이터를 캐싱해야 하나요?
2. 캐시 만료는 어떻게 설정해야 하나요?
3. 메모리 기반(Redis)과 파일 기반 캐싱 중 어떤 것을 선호하시나요?

이 정보를 제공해주시면 적절한 솔루션을 제안하겠습니다.
</response>
<reason>가정하지 않고 먼저 요구사항을 명확히 함</reason>
</example>

<example type="incorrect">
<scenario>사용자: "성능 개선을 위해 캐싱 추가해줘"</scenario>
<response>
[요구사항 확인 없이 Redis 캐싱 구현 시작]
</response>
<reason>캐시 유형, 대상 데이터, TTL에 대해 가정함.
먼저 요구사항을 명확히 해야 함</reason>
</example>
</examples>

### 2. 코드 수정
**상세 내용: [Technical Standards](guides/technical-standards.md)**

<rule type="critical" id="code-modification">
- **코드를 먼저 읽기**
  코드를 읽지 않고 추측하지 마세요.
  사용자가 특정 파일을 언급하면 항상 먼저 읽으세요.
  구현하기 전에 기존 스타일, 규칙, 추상화를 이해하세요.

- **최소한의 변경**
  요청된 부분만 수정하세요.
  불필요한 변경은 버그 위험을 높이고, 코드 리뷰를 복잡하게 만들며,
  git blame 추적을 방해합니다.

- **기존 동작 보존**
  명시적인 요청 없이 리팩토링하지 마세요.
  다른 코드가 기존 동작에 의존할 수 있습니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "getUserEmail() 함수의 null 체크 고쳐줘"</scenario>
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
<reason>null 체크만 수정하고 다른 부분은 그대로 유지</reason>
</example>

<example type="incorrect">
<scenario>사용자: "getUserEmail() 함수의 null 체크 고쳐줘"</scenario>
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
<reason>요청 범위를 넘어 대규모 리팩토링 수행.
요청된 대로 null 체크만 고쳤어야 함</reason>
</example>
</examples>

### 3. 테스트
**상세 내용: [Quality Assurance](guides/quality-assurance.md)**

<rule type="critical" id="testing">
- **테스트 필수**
  모든 코드에는 테스트가 있어야 합니다.
  테스트는 기능을 문서화하고 회귀를 방지합니다.

- **테스트 무결성 유지**
  테스트를 통과시키기 위해 테스트를 수정하지 마세요.
  테스트가 실패하면 코드를 수정하세요.

- **하드코딩 금지**
  테스트 케이스에만 작동하는 솔루션을 작성하지 마세요.
  문제를 일반적으로 해결하는 실제 로직을 구현하세요.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "할인 계산 함수 추가해줘"</scenario>
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

이제 구현하겠습니다:

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
<reason>테스트를 먼저 작성한 후 일반적인 로직으로 구현</reason>
</example>

<example type="incorrect">
<scenario>코드 변경 후 기존 테스트가 실패함</scenario>
<response>
```python
# Commented out failing test
# def test_user_validation():
#     assert validate_user(user) == True
```
</response>
<reason>문제를 해결하는 대신 테스트를 삭제/비활성화함.
테스트가 실패하면 코드를 수정해야 함</reason>
</example>
</examples>

### 4. 데이터 안전
**상세 내용: [Security](guides/security.md)**

<rule type="critical" id="data-safety">
- **파괴적 쿼리 승인 필요**
  DELETE, UPDATE, ALTER 쿼리를 실행하기 전에 승인을 받으세요.
  데이터 손실은 복구하기 어렵거나 불가능할 수 있습니다.

- **프로덕션 주의**
  먼저 테스트 환경에서 검증하세요.
  프로덕션 데이터에 영향을 미치는 작업은 추가 확인이 필요합니다.
</rule>

<examples>
<example type="correct">
<scenario>사용자: "오래된 사용자 레코드 삭제해줘"</scenario>
<response>
데이터를 삭제하기 전에 몇 가지 확인이 필요합니다:

1. "오래된 사용자"를 어떻게 정의하나요? (예: 6개월 이상 로그인 없음)
2. 프로덕션 DB인가요, 테스트 DB인가요?
3. 삭제 전에 백업을 생성해야 하나요?
4. 먼저 SELECT로 레코드를 미리 보시겠어요?

```sql
-- First, let's preview what will be deleted
SELECT COUNT(*), MIN(last_login), MAX(last_login)
FROM users
WHERE last_login < NOW() - INTERVAL 6 MONTH;
```

승인 후 DELETE를 실행하겠습니다.
</response>
<reason>파괴적 작업 전에 확인을 요청하고 미리보기 제공</reason>
</example>

<example type="incorrect">
<scenario>사용자: "데이터베이스 정리해줘"</scenario>
<response>
```sql
-- Executed destructive queries without confirmation
DELETE FROM users WHERE created_at < '2023-01-01';
ALTER TABLE orders DROP COLUMN old_status;
TRUNCATE TABLE logs;
```
</response>
<reason>확인이나 승인 없이 파괴적 쿼리 실행.
데이터 손실 위험이 있는 작업은 항상 사전 승인 필요</reason>
</example>
</examples>

### 5. 문제 해결
**상세 내용: [Process](guides/process.md)**

<rule type="critical" id="problem-solving">
- **근본 원인 해결**
  임시방편이나 증상 숨기기를 피하세요.
  근본 원인을 해결하면 문제의 재발을 방지할 수 있습니다.

- **3회 시도 후 재평가**
  3회 시도 후에도 해결되지 않으면, 멈추고 다른 접근 방식을 고려하세요.
  같은 방법을 반복하는 것은 비효율적입니다.
</rule>

<examples>
<example type="correct">
<scenario>에러: "Database connection timeout"</scenario>
<response>
이 에러의 근본 원인을 찾아보겠습니다:

1. 로그 확인: 언제부터 시작되었나요?
2. 커넥션 풀 설정: 최대 연결 수는 얼마인가요?
3. 쿼리 성능: 느린 쿼리가 연결을 점유하고 있나요?
4. 네트워크: DB 서버와의 통신은 정상인가요?

분석 결과: 커넥션 풀이 10개로 제한되어 있고 평균 요청은 50/초입니다.
근본 해결책: 커넥션 풀 크기를 늘리고 연결 타임아웃 설정을 최적화하겠습니다.
</response>
<reason>근본 원인을 조사하고 적절한 해결책 제시</reason>
</example>

<example type="incorrect">
<scenario>에러: "Database connection timeout"</scenario>
<response>
```python
# Added try-catch to hide the error
try:
    db.connect()
except TimeoutError:
    pass  # Ignore error
```
</response>
<reason>근본 원인을 해결하지 않고 문제를 숨기는 임시방편.
에러를 무시하면 나중에 더 큰 문제로 이어질 수 있음</reason>
</example>
</examples>

### 6. 문서화
**상세 내용: [Guidelines](guides/guidelines.md)**

<rule type="critical" id="documentation">
- **불명확한 코드 문서화**
  의미 있는 주석을 추가하세요.
  자명하지 않은 로직은 설명이 필요합니다.

- **현대적 구문 사용**
  안정적이고 현대적인 언어 기능을 사용하세요.
  레거시 구문은 유지보수를 어렵게 만듭니다.
</rule>

### 7. 의사소통
**상세 내용: [Interaction Modes](guides/interaction-modes.md)**

<rule type="critical" id="communication">
- **적절한 응답 스타일**
  상황에 적합한 형식과 추론 스타일을 적용하세요.
  사용자 의도와 맥락을 고려하세요.

- **우선순위 준수**
  시스템 규칙이 상호작용 모드보다 우선합니다.
  모드 요청이 규칙과 충돌하면 규칙을 따르세요.
</rule>

## 참고 문서

- [**CLAUDE.md**](../CLAUDE.md) - **전체 가이드라인이 포함된 주요 문서**
- [Philosophy](guides/philosophy.md) - 개발 철학 및 핵심 원칙
- [Process](guides/process.md) - 계획, 구현, 문제 해결
- [Technical Standards](guides/technical-standards.md) - 코드 생성 및 아키텍처
- [Quality Assurance](guides/quality-assurance.md) - 테스트 및 품질 기준
- [Security](guides/security.md) - 보안 원칙 및 데이터 보호
- [Guidelines](guides/guidelines.md) - 중요한 알림 및 모범 사례
- [Interaction Modes](guides/interaction-modes.md) - 응답 스타일 및 추론 명령
