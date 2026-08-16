# 상호작용 모드

<meta>
Document: interaction-modes.md
Role: Interaction Controller
Priority: Medium
Applies To: 모든 사용자 상호작용 및 응답
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 Claude와 소통할 때 응답 스타일, 추론 접근 방식, 역할 관점, 품질 검증을 제어하는 명령어를 제공합니다. 이 명령어들은 Claude가 응답하는 방식을 수정하지만, Claude가 따라야 하는 규칙을 무시하지는 않습니다 (system-rules.md 참조).
</context>

<your_responsibility>
상호작용 제어자로서, 당신은 반드시:
- **모드 수정자 적용**: 활성 명령어에 따라 응답 스타일을 조정한다
- **우선순위 존중**: 모드가 시스템 규칙을 절대 무시하지 않게 한다
- **충돌 처리**: 충돌하는 모드를 적절히 해결한다
- **명확성 유지**: 모드가 소통을 향상시키되, 흐리게 하지 않도록 한다
- **유연성 발휘**: 맥락과 사용자 요구에 맞게 모드를 조정한다
</your_responsibility>

**Claude와의 상호작용 스타일을 제어하는 명령어**

## 💬 도움말 시스템

### `/help` - 사용 가능한 모든 명령어 표시
카테고리별로 정리된 전체 상호작용 모드 명령어 목록을 표시한다

### `/help [카테고리]` - 카테고리별 명령어 표시
사용 가능한 카테고리:
- `/help format` - 출력 형식 및 스타일 명령어
- `/help reasoning` - 추론 및 분석 명령어
- `/help role` - 역할 및 관점 명령어
- `/help quality` - 품질 및 검증 명령어

### 예시
```
/help                    # 모든 명령어 표시
/help format            # 형식 명령어만 표시
/help reasoning         # 추론 명령어만 표시
```

---

## 🚀 빠른 시작

### 처음 사용하는 분

**어디서 시작해야 할지 모르겠다면?**
```
/help
```

**빠른 답변이 필요하다면?**
```
/briefly [질문]
```

**간단한 설명이 필요하다면?**
```
/eli5 [주제]
```

**깊은 분석이 필요하다면?**
```
/deep [주제]
```

### 자주 쓰는 조합

**빠른 코드:**
```
/briefly /code [요청]
```

**초보자 설명:**
```
/eli5 /tone friendly [개념]
```

**의사결정:**
```
/compare /swot /multi-perspective [주제]
```

**문서 요약:**
```
/tldr [긴 텍스트]
```

**실행 계획:**
```
/step-by-step /checklist [작업]
```

---

## 사용법

<usage_rules>
- 메시지에 `/command`를 포함한다 (소문자와 하이픈 사용)
- 여러 명령어를 조합할 수 있다: `/briefly /step-by-step explain the function`
- **중요**: [system-rules.md](../system-rules.md)는 항상 상호작용 모드보다 우선한다
- 모드는 응답 스타일을 제어하며, 핵심 동작을 제어하지 않는다
- 모드가 규칙과 충돌할 때, 규칙이 우선한다
</usage_rules>

---

## 📤 출력 형식 및 스타일

출력 형식과 표현 스타일을 제어하는 명령어

| 명령어 | 목적 | 사용 사례 |
|---------|------|-----------|
| `/eli5` | 5살 아이에게 설명하듯이 설명한다 | 복잡한 개념을 처음 이해할 때 |
| `/tldr` | 긴 텍스트를 몇 줄로 요약한다 | 문서, 로그, 긴 설명의 빠른 검토 |
| `/exec-summary` | 짧은 경영진 스타일 요약을 제공한다 | 핵심 정보만으로 의사결정할 때 |
| `/briefly` | 한두 문장의 간결한 답변을 한다 | 빠른 확인 또는 예/아니오 답변 |
| `/checklist` | 답변을 행동 체크리스트로 변환한다 | 작업 계획, 배포 절차, 검증 항목 |
| `/format-as` | 특정 형식을 강제한다 (테이블, JSON, YAML 등) | 데이터 구조화, API 응답 예시 |
| `/begin-with` | 답변을 주어진 텍스트로 시작하게 한다 | 템플릿 작성, 일관된 시작 패턴 |
| `/end-with` | 답변을 주어진 텍스트로 끝나게 한다 | 서명, 템플릿 마무리 |
| `/schema` | 구조화된 개요 또는 데이터 모델을 생성한다 | DB 스키마, API 스펙, 클래스 구조 설계 |
| `/rewrite-as` | 요청된 스타일로 다시 작성한다 | 문서 톤 변경, 코드 리팩토링 |

### 예시

<examples>
<example command="/briefly">
<input>/briefly 이 함수는 무엇을 하나요?</input>
<output>사용자 인증 토큰을 검증하고 만료 여부를 확인합니다.</output>
<note>한 문장, 직접적인 답변</note>
</example>

<example command="/format-as">
<input>/format-as JSON API 오류 응답 예시를 보여주세요</input>
<output>{"error": {"code": 401, "message": "Unauthorized"}}</output>
<note>요청된 대로 구조화된 형식</note>
</example>

<example command="/checklist">
<input>/checklist 배포 전 확인 사항</input>
<output>
- [ ] 테스트 통과 확인
- [ ] 환경 변수 검증
- [ ] 데이터베이스 마이그레이션 확인
- [ ] 보안 설정 검토
</output>
<note>체크박스 형식의 실행 가능한 항목</note>
</example>
</examples>

---

## 🧠 추론 및 분석

추론 과정과 분석 접근 방식을 제어하는 명령어

| 명령어 | 목적 | 사용 사례 |
|---------|------|-----------|
| `/step-by-step` | 추론 단계를 순서대로 나열한다 | 복잡한 문제 해결, 알고리즘 설명 |
| `/chain-of-thought` | 추론 단계의 간략한 개요를 요청한다 | 사고 과정 이해 |
| `/first-principles` | 기본부터 답을 재구성한다 | 근본적 이해 또는 새로운 접근이 필요할 때 |
| `/compare` | 두 개 이상의 항목을 나란히 비교한다 | 기술 선택, 라이브러리 비교, 아키텍처 결정 |
| `/multi-perspective` | 여러 관점을 보여준다 | 다양한 이해관계자가 관련된 결정 |
| `/parallel-lenses` | 주제를 여러 각도에서 동시에 검토한다 | 종합 분석, 위험 평가 |
| `/swot` | 강점, 약점, 기회, 위협을 제시한다 | 기술 도입 검토, 프로젝트 평가 |
| `/pitfalls` | 예상되는 함정, 오류, 엣지 케이스를 나열한다 | 코드 리뷰, 보안 리뷰, 안정성 점검 |
| `/context-stack` | 여러 계층의 맥락을 활성 상태로 유지한다 | 복잡한 시스템 이해, 레거시 코드 분석 |
| `/deliberate-thinking` | 속도를 늦추고 신중하게 추론한다 | 중요한 결정, 복잡한 버그 분석 |
| `/reflective-mode` | 답변을 간략히 반성하고 개선한다 | 답변 품질 향상, 자기 검증 |
| `/systematic-bias-check` | 가능한 편향과 격차를 지적한다 | 공정성 검토, 다양성 고려 |

### 예시

<examples>
<example command="/step-by-step">
<input>/step-by-step 이 버그가 왜 발생하는지 분석해주세요</input>
<output>
1. null 검사 없이 함수가 호출됨
2. 정의되지 않은 속성에 접근 시도
3. TypeError 발생
4. 스택 트레이스가 실행을 중단시킴
</output>
<note>번호가 매겨진 순차적 추론</note>
</example>

<example command="/compare">
<input>/compare 이 프로젝트에 React vs Vue</input>
<output>
| 기준 | React | Vue |
|------|-------|-----|
| 학습 곡선 | 중간 | 낮음 |
| 생태계 | 대규모 | 성장 중 |
| 성능 | 우수 | 우수 |
</output>
<note>나란히 놓은 비교 표</note>
</example>

<example command="/pitfalls">
<input>/pitfalls 이 인증 로직의 보안 우려 사항</input>
<output>
- 토큰 만료 검사 누락
- CSRF 공격 취약점
- 로그에 민감한 정보 포함
- 로그인 시도에 대한 속도 제한 없음
</output>
<note>주의해야 할 잠재적 문제 목록</note>
</example>
</examples>

---

## 🎭 역할 및 관점

역할과 관점을 제어하는 명령어

| 명령어 | 목적 | 사용 사례 |
|---------|------|-----------|
| `/act-as` | 특정 역할로 답변한다 (예: 시니어 개발자, QA 엔지니어) | 전문가 관점, 특정 직무 관점 |
| `/dev-mode` | 가공되지 않은 기술적 개발자 스타일을 사용한다 | 코드 리뷰, 디버깅, 기술 토론 |
| `/pm-mode` | 프로젝트 관리 관점으로 응답한다 | 일정, 자원, 위험 관리 |
| `/audience` | 대상 청중에 맞게 톤과 상세도를 조정한다 | 비개발자 설명, 경영진 보고 |
| `/tone` | 톤을 변경한다 (격식, 친근, 유쾌 등) | 문서 작성, 소통 조정 |
| `/jargon` | 기술 용어를 적절히 사용한다 | 기술 문서, 사양서 |
| `/role:task:format:` | 역할, 작업, 예상 형식을 명시적으로 설정한다 | 복잡한 요청의 명확한 구조화 |

### 예시

<examples>
<example command="/act-as">
<input>/act-as security engineer 이 코드를 리뷰해주세요</input>
<output>
[보안 관점에서 취약점에 초점을 맞춘 분석]
- 입력 검증 누락 → SQL 인젝션 위험
- 인증 검사 없음 → 비인가 접근
- 평문 비밀번호 → 자격 증명 노출
</output>
<note>요청된 역할에 맞는 관점</note>
</example>

<example command="/dev-mode /jargon">
<input>/dev-mode /jargon gRPC 구현 가이드</input>
<output>
[코드와 용어를 사용한 직접적인 기술 설명]
protobuf 정의를 설정하고, 서비스 핸들러를 구현하고,
흐름 제어가 포함된 양방향 스트리밍을 구성...
</output>
<note>단순화 없는 기술 언어</note>
</example>

<example command="/pm-mode">
<input>/pm-mode 이 기능의 개발 일정을 추정해주세요</input>
<output>
- 분석: 2일
- 개발: 5일
- QA: 3일
- 위험: API 변경 가능성
- 버퍼: 2일
합계: 12일
</output>
<note>일정과 위험이 포함된 프로젝트 관리 관점</note>
</example>

<example command="/audience /tone">
<input>/audience non-developer /tone friendly Docker가 뭔가요?</input>
<output>
Docker는 애플리케이션을 실행하는 데 필요한 모든 것을 함께 포장하는
상자와 같습니다. 마치 화물 컨테이너처럼, 노트북, 서버, 클라우드 등
어디서든 동일하게 작동합니다!
</output>
<note>청중에 적합한 간단한 비유</note>
</example>
</examples>

---

## ✅ 품질 및 검증

품질 보증과 검증을 위한 명령어

| 명령어 | 목적 | 사용 사례 |
|---------|------|-----------|
| `/eval-self` | 답변을 비평하고 수정을 제안한다 | 중요한 결정 전, 답변 품질 점검 |
| `/no-autopilot` | 피상적이고 템플릿화된 답변을 금지한다 | 깊은 분석, 창의적 해결책이 필요할 때 |
| `/guardrail` | 넘지 말아야 할 엄격한 경계를 설정한다 | 보안, 컴플라이언스, 안전 규칙 적용 |
| `/metrics-mode` | 측정값, KPI, 공식을 사용한다 | 성능 분석, 최적화 목표 설정 |

### 예시

<examples>
<example command="/no-autopilot /first-principles">
<input>/no-autopilot /first-principles 왜 마이크로서비스가 필요한가요?</input>
<output>
[일반적인 이점 나열이 아닌 근본적 추론]
문제에서 시작: 큰 코드베이스는 추론하기 어려워진다.
왜? 인간의 작업 기억은 제한적이다 (7±2개 항목).
해결책: 더 작고 독립적인 서비스로 분리한다.
트레이드오프: 인지적 단순함을 위한 네트워크 복잡성.
</output>
<note>템플릿 응답이 아닌, 기본부터의 깊은 추론</note>
</example>

<example command="/eval-self">
<input>/eval-self 이 아키텍처 설계를 검토해주세요</input>
<output>
[설계 제시]

**자기 평가:**
- **강점**: 우수한 확장성, 명확한 경계
- **약점**: 운영 복잡성 증가, 네트워크 오버헤드
- **개선안**: 모듈러 모놀리스로 시작하고 나중에 마이그레이션 고려
- **대안**: 이벤트 기반 아키텍처가 더 간단할 수 있음
</output>
<note>솔직한 평가가 포함된 자기 비평</note>
</example>

<example command="/guardrail">
<input>/guardrail DELETE 쿼리를 절대 포함하지 마세요 /dev-mode 사용자 목록 조회</input>
<output>
SELECT * FROM users WHERE active = true;

[가드레일에 따라 READ-ONLY 쿼리만, DELETE 작업 없음]
</output>
<note>엄격한 경계 적용</note>
</example>

<example command="/metrics-mode">
<input>/metrics-mode API 응답 시간 개선</input>
<output>
**현재 상태:**
- p50 = 450ms, p95 = 850ms, p99 = 1200ms

**목표:**
- p95 < 200ms

**제안 개선 사항:**
1. 쿼리 인덱싱: -300ms (p95)
2. 커넥션 풀링: -150ms (p95)
3. 캐싱: -200ms (p95)

**예상 결과:** p95 = 200ms (76% 개선)
</output>
<note>정량화된 측정값과 목표</note>
</example>
</examples>

---

## 🔄 명령어 조합 패턴

효과적인 명령어 조합 예시:

### 복잡한 문제 해결
```
/step-by-step /pitfalls /dev-mode
→ 단계별 추론 + 경고 + 기술적 스타일
```

### 의사결정 지원
```
/compare /swot /exec-summary
→ 비교 분석 + SWOT 분석 + 경영진 요약
```

### 학습 및 이해
```
/eli5 /step-by-step
→ 간단한 설명 + 단계별 분해
```

### 품질 중심 작업
```
/no-autopilot /eval-self /deliberate-thinking
→ 피상적 답변 금지 + 자기 검증 + 신중한 추론
```

### 코드 리뷰
```
/dev-mode /pitfalls /systematic-bias-check
→ 개발자 모드 + 잠재적 문제 + 편향 점검
```

---

## 📋 명령어 색인

모든 명령어의 완전한 알파벳순 목록:

### 형식 및 스타일
- `/begin-with` - 특정 텍스트로 답변 시작
- `/briefly` - 1-2문장의 초간결 답변
- `/checklist` - 실행 가능한 체크리스트로 변환
- `/eli5` - 5살 아이에게 설명하듯이
- `/end-with` - 특정 텍스트로 답변 종료
- `/exec-summary` - 경영진 스타일 요약
- `/format-as` - 특정 형식 강제 (JSON/테이블 등)
- `/rewrite-as` - 요청된 스타일로 다시 작성
- `/schema` - 구조화된 데이터 모델 생성
- `/tldr` - 긴 텍스트의 빠른 요약

### 추론 및 분석
- `/chain-of-thought` - 추론 개요 표시
- `/compare` - 나란히 비교
- `/context-stack` - 여러 맥락 계층 유지
- `/deliberate-thinking` - 신중하고 느린 추론
- `/first-principles` - 근본 기본부터 구축
- `/multi-perspective` - 다양한 관점
- `/parallel-lenses` - 동시 다각도 분석
- `/pitfalls` - 오류와 엣지 케이스 나열
- `/reflective-mode` - 답변 반성 및 개선
- `/step-by-step` - 순차적 추론 단계
- `/swot` - 강점/약점/기회/위협
- `/systematic-bias-check` - 편향과 격차 식별

### 역할 및 관점
- `/act-as` - 특정 역할로 응답
- `/audience` - 대상 청중에 맞춤
- `/dev-mode` - 기술적 개발자 스타일
- `/jargon` - 기술 용어 사용
- `/pm-mode` - 프로젝트 관리 관점
- `/role:task:format:` - 명시적 구조 (역할/작업/형식)
- `/tone` - 톤 조정 (격식/친근/유쾌)

### 품질 및 검증
- `/eval-self` - 개선안이 포함된 자기 비평
- `/guardrail` - 엄격한 경계 설정
- `/metrics-mode` - KPI와 측정값 사용
- `/no-autopilot` - 템플릿/피상적 답변 금지

---

## ⚖️ 우선순위 및 충돌 해결

<priority_hierarchy>
명령어 사용 시 우선순위 순서:

1. **[system-rules.md](../system-rules.md)** - 절대적 규칙 (한국어 응답, 테스트 필수 등)
2. **`/guardrail`** - 사용자가 설정한 명시적 안전 경계
3. **기타 명령어** - 응답 스타일 및 접근 방식 수정자
4. **기본 응답** - 일반 Claude 응답 패턴

**핵심 원칙**: 상호작용 모드는 스타일을 수정하며, 규칙을 절대 무시하지 않는다.
</priority_hierarchy>

### 충돌 예시

<conflict_scenarios>
<scenario id="mode-conflict">
<conflict>사용자: /briefly /step-by-step 설명해주세요</conflict>
<problem>BRIEFLY (간결) vs STEP-BY-STEP (상세) 충돌</problem>
<resolution>각 단계의 간결한 요약을 제공한다 - 단계별로 간결하게 하여 둘 다 존중</resolution>
<example>
1. 데이터 로드 (DB에서 읽기)
2. 변환 (필터 적용)
3. 반환 (JSON으로 직렬화)
</example>
</scenario>

<scenario id="mode-vs-rules">
<conflict>사용자: /dev-mode 테스트 없이 코드 작성해주세요</conflict>
<problem>모드 요청 vs system-rules.md (테스트 필수)</problem>
<resolution>system-rules.md가 절대적 우선순위 - 요청을 거부하거나 수정해야 함</resolution>
<response>
죄송합니다, 테스트 없이 코드를 작성할 수 없습니다 (system-rules.md).
dev-mode로 구현과 함께 간결한 테스트를 제공하겠습니다.
</response>
</scenario>

<scenario id="audience-vs-accuracy">
<conflict>사용자: /eli5 /jargon 양자 컴퓨팅을 설명해주세요</conflict>
<problem>ELI5 (간단) vs JARGON (기술적) 충돌</problem>
<resolution>접근성을 위해 ELI5가 우선, 기술 용어는 괄호 안에 언급</resolution>
<example>
"양자 컴퓨터는 '중첩' (슈뢰딩거의 고양이처럼 동시에 여러 상태에 있는 것)을
사용하여 문제를 더 빠르게 해결합니다..."
</example>
</scenario>
</conflict_scenarios>

---

## 💡 효과적인 사용을 위한 팁

1. **명확한 의도**: 명령어와 함께 구체적인 질문/요청을 제공한다
2. **적절한 조합**: 목적에 맞는 2-3개의 명령어를 사용한다
3. **실험**: 최적의 응답을 찾기 위해 다양한 조합을 시도한다
4. **피드백**: 결과가 기대와 맞지 않으면 명령어를 조정한다
5. **간단하게 시작**: 확실하지 않으면 `/help`부터 시작한다
6. **패턴 학습**: 자주 쓰는 조합은 빠른 시작 섹션에 나열되어 있다

---

## 📚 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 기본 문서
- [**시스템 규칙**](../system-rules.md) - 협상 불가능한 핵심 규칙 (최우선 순위)
- [가이드라인](../guidelines.md) - 중요한 안내와 모범 사례
- [프로세스](../process.md) - 문제 해결 및 트러블슈팅 접근법
- [품질 보증](../quality-assurance.md) - 테스트 및 품질 게이트

---

---

## 모드 효과성 가이드라인

<effectiveness_guidelines>
**모드가 가장 잘 작동할 때:**
- ✅ 명확하고 구체적인 명령어: `/briefly /code 피보나치 계산`
- ✅ 적절한 조합: 학습을 위한 `/eli5 /step-by-step`
- ✅ 맥락 인식: 일정 관련 질문에 `/pm-mode`
- ✅ 충돌 없음: 대립하는 모드를 조합하지 않는다

**모드가 도움이 되지 않을 때:**
- ❌ 너무 많은 명령어: 3-4개 이상은 혼란스러워진다
- ❌ 모순: `/briefly /deep`은 의미가 없다
- ❌ 규칙 위반: `/dev-mode 테스트 건너뛰기` → 거부됨
- ❌ 모호한 요청: `/good 이것 좀 나아지게` → 충분히 구체적이지 않음

**모범 사례:**
1. 1-2개 명령어로 시작하고 필요하면 추가한다
2. 어떤 명령어가 맞는지 확실하지 않으면 `/help`를 사용한다
3. 관련 명령어를 조합한다: `/dev-mode /pitfalls /code`
4. 기억하기: 명령어는 명확성을 향상시키며, 명확한 소통을 대체하지 않는다
</effectiveness_guidelines>

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 기본 문서
- [시스템 규칙](../system-rules.md) - 핵심 규칙 (모드가 무시할 수 없음)
- [출력 형식](output-formats.md) - 다양한 시나리오를 위한 응답 템플릿
- [충돌 해결](conflict-resolution.md) - 충돌하는 요구사항 처리

