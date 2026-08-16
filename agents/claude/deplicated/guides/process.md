# 프로세스

<meta>
Document: process.md
Role: Process Guide
Priority: High
Applies To: All development workflows and problem-solving tasks
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 계획부터 구현, 문제 해결까지의 개발 프로세스를 정의합니다.
이 체계적인 접근 방식을 따르면 일관되고 고품질의 코드를 제공할 수 있습니다.
</context>

<your_responsibility>
프로세스 가이드로서 다음을 준수해야 합니다:
- **코딩 전 계획**: 복잡한 작업을 단계로 나누기
- **각 단계 검증**: 진행하기 전에 각 단계가 완료되었는지 확인
- **진행 상황 문서화**: 진행 상황을 명확히 기록
- **실패를 우아하게 처리**: 문제 발생 시 체계적으로 디버그
</your_responsibility>

## 병렬 작업 가이드

<parallel_operations>
Claude 4.x는 병렬 도구 실행에 뛰어납니다. 효율성을 위해 활용하세요:

**병렬로 실행:**
- 여러 파일을 동시에 읽기
- 독립적인 검색을 동시에 수행
- 의존성 없는 명령어를 동시에 실행

**순차적으로 실행:**
- 이전 결과에 의존하는 작업
- 한 작업의 출력이 다음 작업의 입력인 경우

예시:
```
# Parallel: Read 3 files simultaneously
Read(file1.ts) + Read(file2.ts) + Read(file3.ts)

# Sequential: Create directory then create file
mkdir project && touch project/index.ts
```
</parallel_operations>

## 1. 계획 및 단계 구성

복잡한 작업을 3~5단계로 나눕니다. `IMPLEMENTATION_PLAN.md`에 문서화하세요:

```markdown
## Stage N: [Name]

**Goal**: [Specific deliverable]
**Success Criteria**: [Testable outcomes]
**Tests**: [Specific test cases]
**Status**: [Not Started|In Progress|Complete]
```

- 진행하면서 상태를 업데이트하세요
- 모든 단계가 완료되면 파일을 삭제하세요

## 2. 구현 흐름

<thinking_process>
변경 사항을 구현하기 전에, 다음 단계를 명시적으로 수행하고 추론 과정을 보여주세요:

### 1단계: 이해
**코드베이스의 기존 패턴 학습**

<think>
코드를 작성하기 전에 스스로에게 물어보세요:
- 이 코드베이스에 이미 유사한 기능이나 함수가 있는가?
- 어떤 패턴, 라이브러리, 규칙을 사용하고 있는가?
- 어떤 아키텍처 결정이 내려져 있는가?
- 참고할 수 있는 관련 테스트가 있는가?

**행동**: 유사한 구현을 검색하고, 관련 코드를 읽고, 발견 사항을 문서화
**출력**: "Y 패턴을 사용하는 X개의 유사한 구현을 발견했습니다"
</think>

### 2단계: 테스트
**테스트를 먼저 작성 (red)**

<think>
기능을 구현하기 전에:
- 어떤 동작을 테스트해야 하는가?
- 엣지 케이스는 무엇인가? (null 값, 빈 입력, 경계 조건)
- 오류 시나리오에서는 어떻게 되어야 하는가?
- 정확성을 어떻게 검증할 것인가?

**행동**: 원하는 동작을 설명하는 실패하는 테스트 작성
**출력**: "테스트 작성 완료, 예상대로 실패 중"
</think>

### 3단계: 구현
**테스트를 통과하는 최소한의 코드 (green)**

<think>
구현을 작성할 때:
- 테스트를 통과시키는 가장 간단한 코드는 무엇인가?
- 1단계에서 발견한 패턴을 따르고 있는가?
- 명시적으로 요청된 것만 변경하고 있는가?
- 이것이 기존 동작을 깨뜨리는가?

**행동**: 테스트를 통과하는 최소한의 구현 작성
**출력**: "구현 완료, 모든 테스트 통과"
</think>

### 4단계: 리팩토링
**테스트가 통과하는 상태에서 정리**

<think>
테스트가 통과한 후:
- 이 코드를 더 간단하거나 읽기 쉽게 만들 수 있는가?
- 변수와 함수 이름이 명확하고 설명적인가?
- 프로젝트의 코딩 규칙을 따르고 있는가?
- 코드 냄새나 중복이 있는가?

**행동**: 테스트를 통과시키면서 코드 품질 개선
**출력**: "가독성 향상을 위해 리팩토링, 테스트 여전히 통과"
</think>

### 5단계: 커밋
**계획에 연결되는 명확한 메시지로 커밋**

<think>
커밋하기 전에:
- 무엇이 왜 변경되었는가?
- 커밋 메시지가 동기를 설명하는가?
- 모든 테스트가 여전히 통과하는가?
- 더 작은 커밋으로 나눠야 하는가?

**행동**: 적절한 형식으로 커밋 생성 (version-control.md 참조)
**출력**: "커밋 완료: [type]: [description]"
</think>
</thinking_process>

<instruction>
변경 사항을 구현할 때, 현재 어떤 단계에 있는지 명시적으로 말하고 사고 과정을 보여주세요. 이렇게 하면 문제를 일찍 발견하고 누락을 방지할 수 있습니다.

예시:
"**1단계: 이해** - 기존 인증 (Authentication) 구현을 검색하고 있습니다..."
"**2단계: 테스트** - 잘못된 비밀번호 시나리오에 대한 테스트를 작성하고 있습니다..."
</instruction>

## 3. 막혔을 때 (3회 시도 후)

3회 시도 후에도 해결되지 않으면, 멈추고 다른 접근 방식을 고려하세요.
같은 방법을 반복하는 것은 비효율적입니다.

1. **실패한 내용을 문서화**:
   - 시도한 내용
   - 구체적인 오류 메시지
   - 실패의 추정 원인

2. **대안을 조사**:
   - 2~3개의 유사한 구현 찾기
   - 대안적 접근 방식 문서화

3. **기본 사항 점검**:
   - 올바른 추상화 수준인가?
   - 문제를 더 작은 부분으로 나눌 수 있는가?
   - 완전히 다르고 더 단순한 접근 방식이 있는가?

4. **다른 각도에서 시도**:
   - 다른 라이브러리/프레임워크 기능은?
   - 다른 아키텍처 패턴은?
   - 추상화를 추가하는 대신 제거할 수 있는가?

## 문제 해결 원칙

- **근본 원인 해결**
  증상만 숨기는 임시 방편을 피하세요.
  근본 원인을 해결하면 문제가 재발하는 것을 방지합니다.

- **개선하기, 임시 방편이 아닌**
  메모리 증가, 재시도 횟수 늘리기, 경고 억제로 문제를 해결하지 마세요.
  이는 문제를 연기할 뿐입니다.

- **지속 가능한 솔루션**
  성능, 안정성, 유지보수성을 개선하는 솔루션을 선택하세요.

## 트러블슈팅 의사결정 트리

<decision_tree>
이슈를 디버깅하거나 기술적 결정을 내릴 때 이 체계적인 접근 방식을 사용하세요.

### 수준 1: 초기 평가

<node id="start">
<question>어떤 유형의 이슈에 직면해 있나요?</question>
<options>
- **컴파일/빌드 오류** → [컴파일 이슈](#node-compilation)로 이동
- **런타임 오류** → [런타임 이슈](#node-runtime)로 이동
- **논리 버그** → [논리 이슈](#node-logic)로 이동
- **성능 이슈** → [성능 이슈](#node-performance)로 이동
- **테스트 실패** → [테스트 이슈](#node-test)로 이동
- **불명확한 요구사항** → [명확화 필요](#node-clarify)로 이동
</options>
</node>

### 수준 2: 구체적 이슈 트리

<node id="node-compilation">
<category>컴파일/빌드 오류</category>

**1단계: 오류 메시지 읽기**
<decision>
오류 메시지가 문제를 명확히 나타내는가?
- ✅ 예 → 구체적인 이슈 수정 (구문, import, 타입 오류)
- ❌ 아니오 → 2단계로 진행
</decision>

**2단계: 최근 변경 사항 확인**
<decision>
변경 전에는 작동했는가?
- ✅ 예 → 최근 변경 사항을 검토, 버그가 도입되었을 가능성
- ❌ 아니오 → 의존성과 환경을 확인
</decision>

**3단계: 환경 검증**
<checklist>
- [ ] 의존성이 올바르게 설치되었는가? (`npm install`, `pip install`)
- [ ] 올바른 언어/프레임워크 버전인가?
- [ ] 환경 변수가 설정되었는가?
- [ ] 빌드 캐시가 손상되었는가? (클린 빌드 시도)
</checklist>

**3회 시도 후에도 막혔다면** → 다음 정보와 함께 도움 요청:
- 전체 오류 메시지
- 사용한 빌드 명령어
- 환경 세부 정보 (OS, 버전)
- 최근 변경 사항
</node>

<node id="node-runtime">
<category>런타임 오류</category>

**1단계: 오류 위치 파악**
<decision>
스택 트레이스가 있는가?
- ✅ 예 → 오류를 일으키는 정확한 라인 식별
- ❌ 아니오 → 로깅/디버깅을 추가하여 오류 위치 찾기
</decision>

**2단계: 오류 이해**
<questions>
- 정확한 오류 유형은 무엇인가? (NullPointerException, TypeError 등)
- 어떤 작업이 수행되고 있었는가?
- 입력 값은 무엇이었는가?
- 예상된 것 vs 실제로 발생한 것은?
</questions>

**3단계: 일관되게 재현**
<decision>
오류를 안정적으로 재현할 수 있는가?
- ✅ 예 → 재현하는 테스트를 작성한 후 수정
- ❌ 아니오 → 로깅을 추가하고 엣지 케이스를 시도
</decision>

**4단계: 체계적으로 수정**
<approach>
1. 오류를 잡는 실패하는 테스트 작성
2. 최소한의 수정 구현
3. 테스트 통과 확인
4. 코드베이스에서 유사한 버그 확인
</approach>

**3회 시도 후에도 막혔다면** → 다음 정보와 함께 도움 요청:
- 전체 스택 트레이스
- 재현 단계
- 오류를 유발하는 입력 데이터
- 예상 vs 실제 동작
</node>

<node id="node-logic">
<category>논리 버그 (잘못된 동작)</category>

**1단계: 예상 동작 정의**
<questions>
- 무엇이 일어나야 하는가?
- 실제로 무엇이 일어나고 있는가?
- 어떻게 잘못된 것을 알았는가? (테스트? 사용자 보고?)
</questions>

**2단계: 이슈 격리**
<process>
1. 주요 지점에 로깅 추가
2. 시스템을 통한 데이터 흐름 추적
3. 동작이 예상에서 벗어나는 지점 식별
4. 특정 함수/라인으로 범위 좁히기
</process>

**3단계: 원인 파악**
<decision>
이것은:
- **논리 오류** → 알고리즘을 검토하고 조건을 확인
- **데이터 오류** → 입력 검증과 데이터 변환을 확인
- **상태 오류** → 상태 관리를 검토하고 경쟁 조건을 확인
- **통합 오류** → 외부 의존성과 API를 확인
</decision>

**4단계: 수정 및 검증**
<checklist>
- [ ] 버그를 잡는 테스트 작성
- [ ] 수정 구현
- [ ] 모든 테스트 통과 확인
- [ ] 유사한 이슈 확인
- [ ] 커밋에 근본 원인 문서화
</checklist>

**3회 시도 후에도 막혔다면** → 다음 정보와 함께 도움 요청:
- 예상 vs 실제 동작 (예시 포함)
- 관련 코드 섹션
- 데이터 흐름 다이어그램
- 실패하는 테스트 케이스
</node>

<node id="node-performance">
<category>성능 이슈</category>

**1단계: 먼저 측정**
<decision>
구체적인 메트릭이 있는가?
- ✅ 예 → 2단계로 진행
- ❌ 아니오 → 계측을 추가하고 기준선을 측정
</decision>

**2단계: 병목 지점 식별**
<tools>
- 프로파일링 (CPU, 메모리, I/O)
- 데이터베이스 쿼리 분석
- 네트워크 요청 타이밍
- 로그 분석
</tools>

**3단계: 병목 지점 분류**
<decision>
주요 원인은 무엇인가?
- **데이터베이스** → 쿼리를 확인 (N+1, 누락된 인덱스, 복잡한 조인)
- **연산** → 알고리즘을 확인 (O(n²) → O(n log n), 캐싱)
- **I/O** → 파일/네트워크 작업을 확인 (배치 처리, 비동기, 압축)
- **메모리** → 누수, 큰 객체, 불필요한 복사를 확인
</decision>

**4단계: 체계적으로 최적화**
<approach>
1. 현재 성능을 문서화 (메트릭)
2. 한 번에 하나씩만 변경
3. 각 변경 후 측정
4. 개선되는 변경은 유지, 그렇지 않은 것은 되돌리기
5. 최종 개선 사항 문서화
</approach>

**성능 최적화 체크리스트**:
<checklist>
- [ ] 전/후 메트릭을 측정했는가
- [ ] ≥20% 개선을 달성했는가
- [ ] 모든 테스트가 여전히 통과하는가
- [ ] 새로운 병목 지점이 도입되지 않았는가
- [ ] 리소스 사용량이 적정한가
</checklist>

**3회 시도 후에도 막혔다면** → 다음 정보와 함께 도움 요청:
- 프로파일링 결과
- 현재 메트릭
- 목표 메트릭
- 지금까지 시도한 내용
</node>

<node id="node-test">
<category>테스트 실패</category>

**1단계: 실패 이해**
<decision>
테스트 실패가:
- **예상된 것** (새 코드가 이전 동작을 깨뜨림) → 코드 또는 테스트를 업데이트
- **예상하지 못한 것** (기존 코드가 이제 실패) → 조사 필요
</decision>

**2단계: 이슈 분류**
<types>
- **불안정한 테스트** → 테스트에 무작위 실패 발생 (타이밍, 외부 의존성)
- **잘못된 가정** → 테스트가 부정확한 동작을 기대
- **실제 버그** → 코드에 실제 이슈 존재
- **환경 이슈** → 테스트 환경이 개발 환경과 다름
</types>

**3단계: 적절히 수정**
<decision>
각 유형별:
- **불안정한 테스트** → 테스트 수정 (적절한 모킹, 재시도 로직, 더 긴 타임아웃)
- **잘못된 가정** → 올바른 동작을 반영하도록 테스트 업데이트
- **실제 버그** → 코드를 수정
- **환경 이슈** → 환경 설정을 수정
</decision>

**절대 하지 말 것:**
- ❌ 실패하는 테스트를 삭제
- ❌ 어설션을 주석 처리
- ❌ 오류를 숨기기 위해 `try-catch` 추가
- ❌ 조사 없이 테스트를 건너뛰기

**3회 시도 후에도 막혔다면** → 다음 정보와 함께 도움 요청:
- 테스트 실패 출력
- 테스트가 검사하는 내용
- 테스트에 영향을 줄 수 있는 최근 변경 사항
- 테스트 환경 세부 정보
</node>

<node id="node-clarify">
<category>불명확한 요구사항</category>

**1단계: 불명확한 부분 식별**
<questions>
- 목표가 불명확한가?
- 유효한 접근 방식이 여러 개 있는가?
- 상충하는 요구사항이 있는가?
- 범위가 모호한가?
- 누락된 세부 사항이 있는가?
</questions>

**2단계: 맥락 수집**
<research>
- 기존의 유사한 기능 확인
- 관련 문서 검토
- 과거 논의/결정 찾기
- 이해관계자 식별
</research>

**3단계: 구체적인 질문하기**
<template>
질문을 명확하게 구조화하세요:
1. **맥락**: 하려는 것
2. **불명확한 점**: 구체적으로 무엇이 모호한지
3. **선택지**: 가능한 해석 또는 접근 방식
4. **영향**: 선택이 구현에 미치는 영향
5. **권장 사항**: 근거와 함께 제안하는 접근 방식
</template>

**예시:**
```markdown
I'm implementing the user profile caching feature.

**Unclear**: Cache expiration strategy

**Options**:
1. Time-based (TTL): Cache for X minutes
2. Event-based: Invalidate on user updates
3. Hybrid: TTL with manual invalidation

**Impact**:
- Option 1: Simple, but may serve stale data
- Option 2: Complex, requires event system
- Option 3: Balanced, moderate complexity

**Recommendation**: Option 3 (hybrid approach)
- Use 5-minute TTL for automatic cleanup
- Invalidate immediately on user updates
- Balances freshness and performance

Does this sound right, or should I take a different approach?
```

**절대 하지 말 것:**
- ❌ 묻지 않고 가정하기
- ❌ 모든 가능성을 구현하기
- ❌ 모호함을 무시하고 잘 되기를 바라기
</node>
</decision_tree>

## 기술적 선택을 위한 의사결정 프레임워크

<technical_decisions>
여러 유효한 기술적 접근 방식 중에서 선택할 때, 이 프레임워크를 사용하세요:

### 1. 평가 기준 정의
<criteria_template>
각 옵션을 (1~5점) 평가:
- **단순성**: 이해하고 유지보수하기 얼마나 쉬운가?
- **성능**: 속도/리소스 요구사항을 충족하는가?
- **유연성**: 나중에 필요할 때 변경하기 쉬운가?
- **신뢰성**: 검증되고 안정적이며 잘 테스트되었는가?
- **호환성**: 기존 시스템과 작동하는가?
- **개발 시간**: 구현하는 데 얼마나 걸리는가?
- **팀 숙련도**: 이 기술을 잘 알고 있는가?
</criteria_template>

### 2. 옵션 비교
<comparison_example>
**예시: 상태 관리 선택**

| 기준 | Redux | Zustand | Context API | 가중치 |
|------|-------|---------|-------------|--------|
| 단순성 | 2 | 5 | 4 | 3x |
| 성능 | 5 | 5 | 3 | 2x |
| 유연성 | 5 | 4 | 3 | 2x |
| 팀 숙련도 | 5 | 2 | 5 | 2x |
| **가중 점수** | **41** | **38** | **35** | |

**결정**: Redux (최고 점수)
**근거**: 더 복잡하지만, Redux의 유연성, 성능, 팀 숙련도가 단순성 우려를 상쇄합니다.
</comparison_example>

### 3. 결정 문서화
<documentation_template>
```markdown
## Decision: [Technology/Approach Choice]

**Date**: 2025-11-25
**Status**: Accepted
**Context**: [Why this decision was needed]

**Options Considered**:
1. Option A - [brief description]
2. Option B - [brief description]
3. Option C - [brief description]

**Decision**: Option [X]

**Rationale**:
- [Key reason 1]
- [Key reason 2]
- [Key reason 3]

**Consequences**:
- Positive: [benefits]
- Negative: [trade-offs]
- Risks: [potential issues]

**Validation**: [How we'll verify this was the right choice]
```
</documentation_template>
</technical_decisions>

## 참고

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 기본 문서
- [시스템 규칙](../system-rules.md) - 시스템 전반의 필수 규칙
- [철학](../philosophy.md) - 개발 철학 및 원칙
- [품질 보증](../quality-assurance.md) - 테스트 및 품질 게이트
- [가이드라인](../guidelines.md) - 긴급 절차 및 도움 받기
