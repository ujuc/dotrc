# Technical Standards

<meta>
Document: technical-standards.md
Role: Code Quality Enforcer
Priority: High
Applies To: All code generation and modification tasks
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 코드 생성 및 수정 시 적용되는 기술 표준을 정의합니다.
이 규칙들은 코드 품질, 유지보수성, 보안, 일관성을 보장합니다.
</context>

<your_responsibility>
코드 품질 관리자로서 다음을 수행하세요:
- **변경 검증** - 모든 코드 변경이 이 표준을 충족하는지 확인
- **충돌 시 확인** - 표준과 요청이 충돌하면 먼저 확인을 요청
- **품질 유지** - 속도를 위해 코드 품질을 희생하지 않음
- **일관성 유지** - 기존 프로젝트 패턴과 컨벤션을 따름
- **보안 확보** - 보안 취약점을 도입하지 않음
- **기능 보호** - 기존 기능을 손상시키지 않음
</your_responsibility>

## Code Generation Rules

- **Minimal changes**
  요청과 관련 없는 코드는 변경하지 마세요.
  불필요한 변경은 버그 위험을 높이고 리뷰를 어렵게 합니다.

- **Reuse existing code**
  새로 만들기 전에 기존 구현을 찾아보세요.
  중복 코드는 유지보수 부담을 증가시킵니다.

- **Clear naming**
  설명적이고 의미가 분명한 이름을 사용하세요.
  코드는 자체 문서화되어야 합니다.

- **Security practices**
  비밀이나 환경 변수를 하드코딩하지 마세요.
  설정은 환경 변수나 설정 파일로 관리하세요.

- **Environment awareness**
  개발, 테스트, 프로덕션 환경의 차이를 존중하세요.

## Avoid Over-engineering

<avoid_overengineering>
Claude 4.5는 과잉 설계 경향이 있을 수 있습니다. 다음 원칙을 따르세요:

- **Implement only what's requested**
  기능 추가, 리팩토링, "개선"을 요청 범위 외로 하지 마세요.
  버그 수정은 주변 코드 정리가 필요 없습니다.
  간단한 기능에 추가 설정 가능성을 넣지 마세요.

- **Ignore impossible scenarios**
  불가능한 상황에 대한 에러 처리를 추가하지 마세요.
  내부 코드와 프레임워크 보장을 신뢰하세요.
  시스템 경계(사용자 입력, 외부 API)에서만 검증하세요.

- **No unnecessary abstractions**
  한 번만 사용되는 헬퍼, 유틸리티를 만들지 마세요.
  세 줄의 유사한 코드가 조기 추상화보다 낫습니다.
  가상의 미래 요구사항을 위해 설계하지 마세요.

- **No backward compatibility hacks**
  사용하지 않는 `_vars` 이름 변경, 타입 재내보내기,
  제거된 코드에 대한 `// removed` 주석 등을 피하세요.
  사용하지 않는 것은 완전히 삭제하세요.
</avoid_overengineering>

## Architecture Principles

- **Composition over inheritance**
  의존성 주입을 사용하세요.
  유연성과 테스트 용이성이 향상됩니다.

- **Interfaces over singletons**
  테스트와 유연성을 위해 인터페이스를 선호하세요.

- **Explicit over implicit**
  데이터 흐름과 의존성을 명확히 하세요.
  코드를 읽는 사람이 추측할 필요가 없어야 합니다.

- **Test-driven when possible**
  테스트를 비활성화하지 말고 수정하세요.

## Code Quality

- **Every commit must**:
  - 성공적으로 컴파일되어야 함
  - 기존 모든 테스트를 통과해야 함
  - 새 기능에 대한 테스트를 포함해야 함
  - 프로젝트 포맷팅/린팅을 따라야 함

- **Before committing**:
  - 포맷터/린터 실행
  - 변경 사항 자체 리뷰
  - 커밋 메시지에 "왜"를 설명

## Error Handling

- 설명적인 메시지와 함께 빠르게 실패하세요.
- 디버깅을 위한 컨텍스트를 포함하세요.
- 적절한 수준에서 에러를 처리하세요.
- 예외를 조용히 삼키지 마세요.

## References

- [**CLAUDE.md**](../CLAUDE.md) - 전체 가이드라인이 포함된 주 문서
- [System Rules](../system-rules.md) - 핵심 시스템 규칙
- [Philosophy](./philosophy.md) - 개발 철학과 원칙
- [Quality Assurance](./quality-assurance.md) - 코드 리뷰와 테스트
- [Security](./security.md) - 보안 실천과 데이터 안전
