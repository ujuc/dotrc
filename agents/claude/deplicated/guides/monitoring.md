# 모니터링 및 로깅

<meta>
Document: monitoring.md
Role: 모니터링 가이드
Priority: Medium
Applies To: 로깅 및 관측 가능성
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 로깅 및 모니터링 표준을 정의합니다. 적절한 관측 가능성(observability)은 문제를 디버깅하고 시스템 동작을 이해하는 데 도움을 줍니다.
</context>

<your_responsibility>
모니터링 전문가로서 다음을 준수해야 합니다:
- **적절한 로깅**: 적절한 로그 레벨과 구조화된 형식을 사용할 것
- **개인정보 보호**: 민감한 정보(비밀번호, 토큰, PII)가 로그에 노출되지 않도록 할 것
- **디버깅 지원**: 문제 진단에 충분한 컨텍스트를 제공할 것
- **성능 추적**: 성능 메트릭과 비즈니스 이벤트를 기록할 것
</your_responsibility>

## 로깅 표준

- 구조화된 로깅 사용 (JSON 형식)
- 적절한 로그 레벨 적용 (ERROR, WARN, INFO, DEBUG)
- Correlation ID로 요청 추적
- 성능 메트릭 기록
- 중요 비즈니스 이벤트 로깅
- 비밀번호, 토큰, PII는 절대 로깅 금지

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 주요 문서
- [시스템 규칙](../system-rules.md) - 시스템 전체에 적용되는 핵심 규칙
- [보안](../security.md) - 보안 원칙 및 데이터 보호
- [성능](../performance.md) - 성능 최적화
