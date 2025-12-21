# Performance Optimization Guide

<meta>
Document: performance-optimization.md
Role: Performance Optimization Reference
Priority: Medium
Source: https://abseil.io/fast/hints.html
Authors: Jeff Dean, Sanjay Ghemawat
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 Google의 성능 최적화 가이드를 기반으로, 언어에 독립적인 범용 성능 최적화 원칙을 정리한 참조 문서입니다.
</context>

## 1. 핵심 철학

> "우리는 97%의 경우 작은 효율성은 잊어야 한다: 성급한 최적화는 모든 악의 근원이다. **하지만 중요한 3%에서의 기회를 놓쳐서는 안 된다.**" — Donald Knuth

### 성능 작업을 미루면 안 되는 이유

1. **평평한 프로파일**: 늦은 최적화는 명확한 핫스팟이 없는 상황에 직면
2. **외부 코드**: 라이브러리 사용자는 다른 팀의 코드를 쉽게 최적화할 수 없음
3. **변경 비용**: 시스템이 많이 사용될 때 전체 변경이 어려워짐
4. **기회 비용**: 쉬운 성능 개선을 놓치면 비싼 인프라 솔루션이 필요

---

## 2. 연산 비용 추정

### 하드웨어 연산 비용 참조 테이블

| 연산 | 시간 |
|------|------|
| L1 캐시 참조 | 0.5 ns |
| L2 캐시 참조 | 3 ns |
| 분기 예측 실패 | 5 ns |
| Mutex lock/unlock (비경쟁) | 15 ns |
| 메인 메모리 참조 | 50 ns |
| SSD 랜덤 읽기 | 16,000 ns |
| 디스크 탐색 | 5,000,000 ns |
| 네트워크 왕복 (같은 데이터센터) | 500,000 ns |

### 봉투 뒷면 계산법 (Back-of-the-envelope)

구현 전에 대략적인 비용을 계산하여 알고리즘 접근 방식을 비교:

**예시**: 10억 개 항목 정렬
- 메모리 대역폭 비용: ~7.5초 (16GB/s 기준)
- 분기 예측 실패 비용: ~75초 (300억 비교, 50% 예측 실패)
- **결론**: 분기 예측 실패가 지배적 → 이 부분에 최적화 집중

---

## 3. 측정과 프로파일링

### 원칙

- **측정 먼저, 최적화 나중**: 직관이 틀릴 수 있음
- 프로파일링 도구를 활용하여 실제 병목 지점 파악
- 최적화 전후 반드시 측정하여 효과 검증

### 평평한 프로파일 대응법

명확한 병목이 없을 때:
- 여러 1% 개선을 축적
- 호출 스택 상위의 루프 탐색
- 구조적 비효율성 파악
- 너무 일반적인 코드를 특화된 버전으로 교체
- 할당 횟수 줄이기
- 하드웨어 성능 카운터로 캐시 미스 패턴 식별

---

## 4. API 설계

### 벌크 연산 (Bulk Operations)

개별 연산 대신 배치 처리로 오버헤드 감소:

```
// Before: 개별 조회
for each key in keys:
    result = lookup(key)

// After: 벌크 조회
results = lookupMany(keys)
```

**장점**: API 호출 횟수 감소, 알고리즘 최적화 기회, 고정 비용 분산

### 뷰 타입 (View Types)

함수 인자로 데이터의 "뷰"를 전달하여 복사 방지:
- 문자열 뷰 (원본 문자열 참조)
- 배열 슬라이스 (원본 배열의 일부 참조)
- 함수 참조 (함수 객체 복사 방지)

### 사전 계산된 값 전달

이미 계산된 값을 인자로 전달하여 중복 계산 방지:

```
// Before: 내부에서 현재 시간 계산
recordEvent(eventName, data)

// After: 호출자가 이미 가진 값 전달
now = getCurrentTime()
recordEvent(eventName, data, now)
```

### Thread-Compatible vs Thread-Safe

- **Thread-Compatible**: 외부에서 동기화 (호출자 책임)
- **Thread-Safe**: 내부에서 동기화 (항상 락 비용 발생)

스레드 안전성이 필요 없는 호출자가 불필요한 비용을 피할 수 있도록 Thread-Compatible을 기본으로 고려

---

## 5. 알고리즘 개선

알고리즘 개선이 가장 큰 성능 향상을 제공합니다.

### 복잡도 개선 사례

| 상황 | Before | After | 개선 |
|------|--------|-------|------|
| 정렬된 리스트 교집합 | O(N log N) | O(N) 해시 테이블 | ~21% 속도 향상 |
| 그래프 순환 탐지 | 엣지당 비용 | 역 후위 순서 일괄 추가 | 대폭 개선 |

### 자료구조 선택

문제에 맞는 자료구조 선택이 핵심:
- **빈번한 검색**: 해시 테이블 O(1) vs 정렬 리스트 O(log N)
- **범위 쿼리**: 정렬 구조 (트리, 정렬 배열)
- **순서 유지 필요**: 연결 리스트 또는 정렬 구조

---

## 6. 메모리 표현

### 컴팩트 데이터 구조

- 필드 재정렬로 패딩 최소화
- 적절한 경우 더 작은 숫자 타입 사용 (64비트 → 32비트)
- enum에 명시적 크기 지정
- 자주 접근하는 필드를 함께 배치
- 뜨거운(hot) 필드와 차가운(cold) 필드 분리

### 포인터 대신 인덱스

64비트 시스템에서 포인터는 8바이트. 32비트 인덱스 사용 시:
- 메모리 50% 절약
- 연속 저장으로 캐시 지역성 향상

### 연속 저장소 선호

노드 기반 구조 (연결 리스트, 트리)보다 배열 기반 구조 선호:
- 더 나은 캐시 동작
- 낮은 할당자 오버헤드
- 메모리 프리페치 활용

### 중첩 맵 → 복합 키

```
// Before: 2단계 탐색
map[category][item]

// After: 1단계 탐색
map[(category, item)]
```

### 도메인이 작을 때: 맵 대신 배열

키가 작은 정수나 enum일 때:
```
// Before
map[payloadType] = clockRate

// After
clockRates[payloadType] = rate  // 배열 인덱스 접근
```

### 셋 대신 비트 벡터

도메인이 작은 정수로 표현 가능할 때:
```
// Before: 해시 셋
zones = HashSet<ZoneId>

// After: 비트 벡터 (26-31% 성능 향상)
zones = BitVector<256>
```

---

## 7. 할당 최적화

### 불필요한 할당 방지

```
// Before: 매번 새 객체 생성
info = newObject() if data else createEmpty()

// After: 정적 빈 객체 재사용
EMPTY = createEmpty()  // 한 번만 생성
info = newObject() if data else EMPTY
```

### 컨테이너 사전 크기 지정

```
// Before: N번의 재할당 가능
for i in range(n):
    list.append(item)

// After: 한 번의 할당
list = createWithCapacity(n)
for i in range(n):
    list.append(item)
```

### 복사 회피

- 복사 대신 이동(move) 선호
- 임시 구조에 전체 객체 대신 포인터/인덱스 저장
- 안정 정렬(stable sort) 대신 일반 정렬 사용 (내부 복사 감소)

### 임시 객체 재사용

```
// Before: 매 반복마다 생성
for item in items:
    record = createRecord()
    processRecord(record)

// After: 재사용
record = createRecord()
for item in items:
    record.clear()
    processRecord(record)
```

---

## 8. 불필요한 작업 회피

### 공통 케이스 빠른 경로

```
// 90%의 케이스를 위한 빠른 경로
if isCommonCase(input):
    return fastPath(input)
// 나머지 10%를 위한 일반 경로
return slowPath(input)
```

### 비싼 정보 사전 계산

```
// Before: 매번 계산
if isExpensive(node):
    doSomething()

// After: 미리 계산하여 저장
struct Node:
    isExpensive: bool  // 생성 시 계산

if node.isExpensive:
    doSomething()
```

### 루프 불변 코드 이동

```
// Before: 매 반복마다 계산
for i in range(n):
    limit = calculateLimit(data)  // 불변
    process(i, limit)

// After: 루프 밖으로 이동
limit = calculateLimit(data)
for i in range(n):
    process(i, limit)
```

### 지연 계산 (Lazy Evaluation)

```
// Before: 항상 계산
expensiveResult = computeExpensive()
if condition:
    use(expensiveResult)

// After: 필요할 때만 계산
if condition:
    expensiveResult = computeExpensive()
    use(expensiveResult)
```

### 캐싱 활용

입력의 핑거프린트(해시)를 키로 결과 캐싱:
```
cache = {}
fingerprint = hash(input)
if fingerprint in cache:
    return cache[fingerprint]
result = expensiveComputation(input)
cache[fingerprint] = result
return result
```

### 로깅/통계 비용 감소

```
// Before: 핫 루프 내에서 로그 레벨 체크
for item in items:
    if isDebugEnabled():  // 매번 체크
        log(item)

// After: 루프 밖에서 한 번 체크
shouldLog = isDebugEnabled()
for item in items:
    if shouldLog:
        log(item)
// 성능 개선: 8-10%
```

**통계 수집 옵션**:
- 가치가 낮은 통계 제거
- 이벤트 샘플링 (예: 32개당 1개)
- 빠른 모듈러 연산을 위해 2의 거듭제곱 사용

---

## 9. 코드 크기

### 큰 코드의 부정적 효과

- 긴 컴파일/링크 시간
- 부풀어진 바이너리
- 증가된 메모리 사용
- 명령어 캐시 압박
- 분기 예측기 부담

### 신중한 인라인

```
// Before: 모든 호출 사이트에 인라인
inline complexFunction() { ... }

// After: 핫 경로만 인라인, 슬로우 패스는 별도 함수로
inline fastPath():
    if (commonCase):
        return quickResult
    return slowPathHelper()  // 별도 함수 호출

slowPathHelper():  // 인라인 안 함
    ... 복잡한 로직 ...
```

### 템플릿/제네릭 인스턴스화 최소화

```
// Before: 불리언마다 별도 인스턴스
template<bool Flag>
process() { ... }

// After: 런타임 파라미터로 통합
process(bool flag) { ... }
// 인스턴스 수: 287 → 143 (50% 감소)
```

### 벌크 초기화

```
// Before: 개별 삽입 (188KB 코드)
map[key1] = value1
map[key2] = value2
...

// After: 일괄 삽입 (360 bytes)
map.insertAll([
    (key1, value1),
    (key2, value2),
    ...
])
```

---

## 10. 병렬화와 동기화

### 병렬성 활용

현대 머신은 많은 코어를 보유. 작업을 배치로 분할하여 병렬화 비용 분산:
- 4-way 병렬화로 3.6배 속도 향상 사례
- **주의**: CPU나 메모리 대역폭이 포화 상태면 병렬화가 도움이 안 될 수 있음

### 락 획득 분산

```
// Before: 각 노드마다 락 획득
release(node):
    for child in node.children:
        release(child)  // 각각 락 획득
    pool.delete(node)

// After: 전체 트리에 한 번 획득
release(node):
    lock(poolLock)
    releaseInternal(node)

releaseInternal(node):
    for child in node.children:
        releaseInternal(child)  // 락 없이 진행
    pool.delete(node)
```

### 크리티컬 섹션 최소화

```
// Before: 락 내에서 비싼 작업 (RPC, 파일 I/O)
lock(mutex):
    data = prepare()
    sendRPC(data)  // 느린 작업

// After: 결정만 락 내에서, 실행은 밖에서
lock(mutex):
    shouldSend = checkCondition()
    data = prepareData()
if shouldSend:
    sendRPC(data)  // 락 밖에서 실행
```

### 샤딩으로 경쟁 감소

```
class ShardedCache:
    SHARD_COUNT = 16
    shards = [Cache() for _ in range(SHARD_COUNT)]

    lookup(key):
        shardIndex = hash(key) % SHARD_COUNT
        return shards[shardIndex].lookup(key)
```

16-way 샤딩으로 멀티스레드 환경에서 ~2배 처리량 향상

### False Sharing 방지

서로 다른 스레드가 접근하는 가변 데이터는 별도의 캐시 라인에 배치:

```
// Before: 같은 캐시 라인에 위치 가능
counter1: int
counter2: int  // 다른 스레드가 접근

// After: 캐시 라인 정렬
counter1: int (aligned to cache line)
padding: bytes[56]  // 64바이트 캐시 라인 채우기
counter2: int (aligned to cache line)
```

---

## 추가 읽기 자료

- "Optimizing software in C++" - Agner Fog
- "Understanding Software Dynamics" - Richard L. Sites
- "Programming Pearls" - Jon Bentley
- "Hacker's Delight" - Henry S. Warren
- "Computer Architecture: A Quantitative Approach" - Hennessy & Patterson
- [Performance tips of the week](https://abseil.io/fast/) - Abseil

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document
- [Performance](./performance.md) - 기본 최적화 가이드라인
- [Technical Standards](./technical-standards.md) - 아키텍처 및 코드 품질
