# 버전 관리

<meta>
Document: version-control.md
Role: 버전 관리 가이드
Priority: 중간
Applies To: Git 워크플로우 및 커밋 관행
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 Git 워크플로우와 커밋 메시지 관례를 정의합니다. 일관된 버전 관리 관행은 협업과 코드 이력의 가독성을 향상시킵니다.
</context>

<your_responsibility>
버전 관리 전문가로서 다음을 준수해야 합니다:
- **의미 있는 커밋 작성**: 변경의 의도(WHY)를 명확히 전달
- **관례 준수**: Conventional Commits 형식 준수
- **이력 정리**: 논리적 단위로 커밋 구성
- **저작자 표시 포함**: AI 에이전트가 생성한 커밋에 저작자 표시 포함
</your_responsibility>

**기준 문서**: 이 문서의 커밋 메시지 규칙은 [`git message template`](../../../../gitmessage) 템플릿을 기반으로 합니다.
**상세 가이드**: 구현 세부사항은 [commit 스킬](../skills/commit/SKILL.md)을 참조하세요.

## Git 워크플로우

- 기능 브랜치 전략 사용
- 의미 있는 브랜치 이름 (feature/fix/chore/docs)
- Conventional Commits 명세 준수
- PR 템플릿 활용
- 코드 리뷰 필수
- 병합 시 커밋 스쿼시

## 커밋 메시지 형식

### 핵심 원칙

- **의도 중심**: 무엇이 변경되었는지뿐만 아니라 왜 변경되었는지 설명
- **맥락 인식**: 변경의 배경과 목적 포함
- **협업 지향**: 팀 협업을 위한 요구사항과 문제 인식 반영

### 템플릿 구조

```
<type>: <subject>

<body>

<footer>
```

### 커밋 유형

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `style`: 서식 변경 (코드 변경 없음)
- `docs`: 문서 업데이트
- `test`: 테스트 추가 또는 리팩토링
- `chore`: 빌드 프로세스, 의존성, 또는 도구 변경

### 서식 규칙

#### 제목 줄
- 최대 50자
- 유형 접두사 포함 (예: `feat: add user authentication`)
- 명령형 사용 ("add" — "added"나 "adds"가 아님)
- 유형 뒤 첫 글자 대문자
- 끝에 마침표 없음

#### 본문
- 한 줄 최대 72자
- 제목과 빈 줄로 구분
- 변경의 동기를 설명
- 어떻게가 아닌 왜와 무엇에 집중
- 글머리 기호에 "-" 사용

#### 푸터
- 관련 이슈, PR 또는 티켓 참조
- 해당되는 경우 AI 에이전트 저작자 표시 포함

### 한국어 커밋 메시지 (gitmessage 기반)

한국어로 커밋 메시지를 작성할 때 다음 규칙을 따르세요:

- **유형**: 영어 유지 (`feat:`, `fix:`, `docs:` 등)
- **제목과 본문**: 한국어로 작성
- **동사 형태**: "-하다" 어미 사용 (예: 추가하다, 수정하다, 개선하다)
- **마침표**: 제목 끝에 마침표 없음
- **글자 수 제한**: 제목 50자, 본문 72자

**올바른 예시**:
```
feat: 사용자 인증 시스템을 추가하다

JWT 기반 인증을 구현하여 API 엔드포인트를 보호합니다.
이 변경이 필요한 이유:

- 기존 시스템에 적절한 보안 조치가 부족했음
- 사용자들이 계정 보호 기능을 요청함
```

**잘못된 예시** ❌:
```
feat: 사용자 인증 시스템 추가  ← Missing "-하다" ending
```

## 문서 참조

이 문서의 계층 구조는 다음과 같습니다:

```
gitmessage (Source of Truth)
├── version-control.md (This document - Summary guide)
└── commit.md (Detailed implementation guide)
```

- **Git 템플릿**: [`gitmessage`](../../../../gitmessage) - 모든 커밋 메시지 규칙의 원본
- **상세 구현 가이드**: [commit 스킬](../skills/commit/SKILL.md) - 자동 커밋 생성 및 예제
- **변경 동기화**: gitmessage가 변경되면 두 문서 모두 업데이트 필요

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 기본 문서
- [시스템 규칙](../system-rules.md) - 중요 시스템 전체 규칙
- [문서화](../documentation.md) - 문서 및 변경 관리
- [품질 보증](../quality-assurance.md) - 코드 리뷰 및 품질 게이트
