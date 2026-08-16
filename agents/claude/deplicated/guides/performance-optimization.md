# 성능 최적화 가이드

<meta>
Document: performance-optimization.md
Role: 성능 최적화 참조 문서
Priority: Medium
Source: https://abseil.io/fast/hints.html
Authors: Jeff Dean, Sanjay Ghemawat
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 Google의 성능 최적화 가이드를 기반으로 언어에 독립적이고 범용적인 성능 최적화 원칙을 요약한 참조 가이드입니다.
</context>

<your_responsibility>
최적화 전문가로서 다음을 준수해야 합니다:
- **최적화 전 측정**: 추측이 아닌 프로파일링 결과에 기반하여 결정할 것
- **3%에 집중**: 실제 병목 지점에만 최적화 노력을 집중할 것
- **트레이드오프 고려**: 최적화가 가독성과 유지보수성에 미치는 영향을 평가할 것
- **변경사항 문서화**: 최적화 이유와 성능 개선 메트릭을 기록할 것
</your_responsibility>

## 1. 핵심 철학

> "우리는 약 97%의 경우에 작은 효율성은 잊어야 합니다: 성급한 최적화는 모든 악의 근원입니다. **하지만 중요한 3%에서의 기회를 놓쳐서는 안 됩니다.**" — Donald Knuth

### 성능 작업을 미루면 안 되는 이유

1. **평탄한 프로파일**: 늦은 최적화는 명확한 핫스팟이 없는 상황에 직면함
2. **외부 코드**: 라이브러리 사용자가 다른 팀의 코드를 쉽게 최적화할 수 없음
3. **변경 비용**: 광범위하게 사용되는 시스템 전체 변경이 어려워짐
4. **기회 비용**: 쉬운 성능 개선을 놓치면 비용이 많이 드는 인프라 해결책이 필요함

---

## 2. 연산 비용 추정

### 하드웨어 연산 비용 참조 표

| 연산 | 시간 |
|------|------|
| L1 캐시 참조 | 0.5 ns |
| L2 캐시 참조 | 3 ns |
| 분기 예측 실패 | 5 ns |
| Mutex 잠금/해제 (경쟁 없음) | 15 ns |
| 메인 메모리 참조 | 50 ns |
| SSD 랜덤 읽기 | 16,000 ns |
| 디스크 탐색 | 5,000,000 ns |
| 네트워크 왕복 (같은 데이터센터) | 500,000 ns |

### 대략적 계산 (Back-of-the-envelope)

구현 전에 알고리즘 접근 방식을 비교하기 위해 대략적인 비용을 계산하세요:

**예시**: 10억 개 항목 정렬
- 메모리 대역폭 비용: ~7.5초 (16GB/s 기준)
- 분기 예측 실패 비용: ~75초 (300억 비교, 50% 예측 실패)
- **결론**: 분기 예측 실패가 지배적 → 여기에 최적화를 집중

---

## 3. 측정 및 프로파일링

### 원칙

- **먼저 측정하고 나중에 최적화**: 직관은 틀릴 수 있음
- 프로파일링 도구를 사용하여 실제 병목 지점을 식별
- 효과를 검증하기 위해 최적화 전후를 항상 측정

### 평탄한 프로파일 다루기

명확한 병목 지점이 없을 때:
- 여러 개의 1% 개선을 누적
- 콜 스택 상위의 루프를 확인
- 구조적 비효율성을 식별
- 과도하게 범용적인 코드를 특화된 버전으로 대체
- 할당 횟수를 줄임
- 하드웨어 성능 카운터를 사용하여 캐시 미스 패턴을 식별

---

## 4. API 설계

### 대량 연산

개별 연산 대신 일괄 처리로 오버헤드를 줄이세요:

```
// Before: Individual lookups
for each key in keys:
    result = lookup(key)

// After: Bulk lookup
results = lookupMany(keys)
```

**장점**: API 호출 횟수 감소, 알고리즘 최적화 기회, 고정 비용 분산

### View 타입

복사를 방지하기 위해 데이터 "뷰"를 함수 인자로 전달하세요:
- String view (원본 문자열에 대한 참조)
- Array slice (원본 배열 일부에 대한 참조)
- 함수 참조 (함수 객체 복사 방지)

### 사전 계산된 값 전달

중복 계산을 방지하기 위해 이미 계산된 값을 인자로 전달하세요:

```
// Before: Compute current time internally
recordEvent(eventName, data)

// After: Pass value caller already has
now = getCurrentTime()
recordEvent(eventName, data, now)
```

### Thread-Compatible vs Thread-Safe

- **Thread-Compatible**: 외부 동기화 (호출자 책임)
- **Thread-Safe**: 내부 동기화 (항상 잠금 비용 발생)

스레드 안전성이 필요 없는 호출자가 불필요한 비용을 피할 수 있도록 Thread-Compatible을 기본으로 고려하세요

---

## 5. 알고리즘 개선

알고리즘 개선은 가장 큰 성능 향상을 제공합니다.

### 복잡도 개선 예시

| 상황 | 변경 전 | 변경 후 | 개선 |
|------|---------|---------|------|
| 정렬된 리스트 교집합 | O(N log N) | O(N) 해시 테이블 | ~21% 속도 향상 |
| 그래프 순환 탐지 | 엣지당 비용 | 역후위순 일괄 추가 | 상당한 개선 |

### 데이터 구조 선택

문제에 적합한 데이터 구조를 선택하는 것이 핵심입니다:
- **빈번한 조회**: 해시 테이블 O(1) vs 정렬된 리스트 O(log N)
- **범위 쿼리**: 정렬된 구조 (트리, 정렬된 배열)
- **순서 보존 필요**: 연결 리스트 또는 정렬된 구조

---

## 6. 메모리 표현

### 컴팩트 데이터 구조

- 패딩을 최소화하기 위해 필드 재배치
- 적절한 경우 더 작은 숫자 타입 사용 (64비트 → 32비트)
- enum에 명시적 크기 지정
- 자주 접근하는 필드를 함께 배치
- 핫(hot) 필드와 콜드(cold) 필드 분리

### 포인터 대신 인덱스

64비트 시스템에서 포인터는 8바이트입니다. 32비트 인덱스를 사용하면:
- 50% 메모리 절약
- 연속 저장으로 더 나은 캐시 지역성

### 연속 저장 선호

노드 기반 구조(연결 리스트, 트리)보다 배열 기반 구조를 선호하세요:
- 더 나은 캐시 동작
- 낮은 할당자 오버헤드
- 메모리 프리페치 활용

### 중첩된 맵 → 복합 키

```
// Before: 2-level lookup
map[category][item]

// After: 1-level lookup
map[(category, item)]
```

### 도메인이 작을 때: 맵 대신 배열

키가 작은 정수나 enum일 때:
```
// Before
map[payloadType] = clockRate

// After
clockRates[payloadType] = rate  // Array index access
```

### 집합 대신 비트 벡터

도메인을 작은 정수로 표현할 수 있을 때:
```
// Before: Hash set
zones = HashSet<ZoneId>

// After: Bit vector (26-31% performance improvement)
zones = BitVector<256>
```

---

## 7. 할당 최적화

### 불필요한 할당 피하기

```
// Before: Create new object every time
info = newObject() if data else createEmpty()

// After: Reuse static empty object
EMPTY = createEmpty()  // Create only once
info = newObject() if data else EMPTY
```

### 컨테이너 사전 크기 지정

```
// Before: Potentially N reallocations
for i in range(n):
    list.append(item)

// After: Single allocation
list = createWithCapacity(n)
for i in range(n):
    list.append(item)
```

### 복사 피하기

- 복사보다 이동(move)을 선호
- 임시 구조에 전체 객체 대신 포인터/인덱스를 저장
- 안정 정렬 대신 일반 정렬 사용 (내부 복사 감소)

### 임시 객체 재사용

```
// Before: Create every iteration
for item in items:
    record = createRecord()
    processRecord(record)

// After: Reuse
record = createRecord()
for item in items:
    record.clear()
    processRecord(record)
```

---

## 8. 불필요한 작업 피하기

### 일반적인 경우에 대한 빠른 경로

```
// Fast path for 90% of cases
if isCommonCase(input):
    return fastPath(input)
// General path for remaining 10%
return slowPath(input)
```

### 비용이 큰 정보 사전 계산

```
// Before: Compute every time
if isExpensive(node):
    doSomething()

// After: Pre-compute and store
struct Node:
    isExpensive: bool  // Computed at creation

if node.isExpensive:
    doSomething()
```

### 루프 불변 코드 이동

```
// Before: Compute every iteration
for i in range(n):
    limit = calculateLimit(data)  // Invariant
    process(i, limit)

// After: Move outside loop
limit = calculateLimit(data)
for i in range(n):
    process(i, limit)
```

### 지연 평가

```
// Before: Always compute
expensiveResult = computeExpensive()
if condition:
    use(expensiveResult)

// After: Compute only when needed
if condition:
    expensiveResult = computeExpensive()
    use(expensiveResult)
```

### 캐싱 사용

입력의 지문(해시)을 키로 사용하여 결과를 캐싱하세요:
```
cache = {}
fingerprint = hash(input)
if fingerprint in cache:
    return cache[fingerprint]
result = expensiveComputation(input)
cache[fingerprint] = result
return result
```

### 로깅/통계 비용 줄이기

```
// Before: Check log level in hot loop
for item in items:
    if isDebugEnabled():  // Check every time
        log(item)

// After: Check once outside loop
shouldLog = isDebugEnabled()
for item in items:
    if shouldLog:
        log(item)
// Performance improvement: 8-10%
```

**통계 수집 옵션**:
- 가치가 낮은 통계 제거
- 이벤트 샘플링 (예: 32개 중 1개)
- 빠른 모듈로 연산을 위해 2의 거듭제곱 사용

---

## 9. 코드 크기

### 큰 코드의 부정적 효과

- 긴 컴파일/링크 시간
- 비대한 바이너리
- 메모리 사용량 증가
- 명령어 캐시 압박
- 분기 예측기 부담

### 신중한 인라이닝

```
// Before: Inline at all call sites
inline complexFunction() { ... }

// After: Inline only hot path, separate function for slow path
inline fastPath():
    if (commonCase):
        return quickResult
    return slowPathHelper()  // Separate function call

slowPathHelper():  // Not inlined
    ... complex logic ...
```

### 템플릿/제네릭 인스턴스화 최소화

```
// Before: Separate instance per boolean
template<bool Flag>
process() { ... }

// After: Consolidated with runtime parameter
process(bool flag) { ... }
// Instance count: 287 → 143 (50% reduction)
```

### 일괄 초기화

```
// Before: Individual insertions (188KB code)
map[key1] = value1
map[key2] = value2
...

// After: Batch insertion (360 bytes)
map.insertAll([
    (key1, value1),
    (key2, value2),
    ...
])
```

---

## 10. 병렬화 및 동기화

### 병렬성 활용

현대 머신은 많은 코어를 가지고 있습니다. 작업을 배치로 나누어 병렬화 비용을 분산하세요:
- 4방향 병렬화로 한 사례에서 3.6배 속도 향상 달성
- **주의**: CPU 또는 메모리 대역폭이 포화 상태이면 병렬화가 도움이 되지 않을 수 있음

### 잠금 획득 분산

```
// Before: Acquire lock for each node
release(node):
    for child in node.children:
        release(child)  // Each acquires lock
    pool.delete(node)

// After: Acquire once for entire tree
release(node):
    lock(poolLock)
    releaseInternal(node)

releaseInternal(node):
    for child in node.children:
        releaseInternal(child)  // Proceed without lock
    pool.delete(node)
```

### 임계 구역 최소화

```
// Before: Expensive operations inside lock (RPC, file I/O)
lock(mutex):
    data = prepare()
    sendRPC(data)  // Slow operation

// After: Only decisions inside lock, execution outside
lock(mutex):
    shouldSend = checkCondition()
    data = prepareData()
if shouldSend:
    sendRPC(data)  // Execute outside lock
```

### 샤딩으로 경합 줄이기

```
class ShardedCache:
    SHARD_COUNT = 16
    shards = [Cache() for _ in range(SHARD_COUNT)]

    lookup(key):
        shardIndex = hash(key) % SHARD_COUNT
        return shards[shardIndex].lookup(key)
```

16방향 샤딩은 멀티스레드 환경에서 처리량을 ~2배 향상시킴

### 거짓 공유(False Sharing) 방지

서로 다른 스레드가 접근하는 가변 데이터를 별도의 캐시 라인에 배치하세요:

```
// Before: May be on same cache line
counter1: int
counter2: int  // Accessed by different thread

// After: Cache line aligned
counter1: int (aligned to cache line)
padding: bytes[56]  // Fill 64-byte cache line
counter2: int (aligned to cache line)
```

---

## 추가 참고 자료

- "Optimizing software in C++" - Agner Fog
- "Understanding Software Dynamics" - Richard L. Sites
- "Programming Pearls" - Jon Bentley
- "Hacker's Delight" - Henry S. Warren
- "Computer Architecture: A Quantitative Approach" - Hennessy & Patterson
- [Performance tips of the week](https://abseil.io/fast/) - Abseil

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 주요 문서
- [성능](performance.md) - 기본 최적화 가이드라인
- [기술 표준](technical-standards.md) - 아키텍처 및 코드 품질
