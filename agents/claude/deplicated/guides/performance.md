# 성능 고려사항

<meta>
Document: performance.md
Role: 성능 가이드
Priority: 중간
Applies To: 성능 최적화 작업
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 성능 최적화 가이드라인을 제공합니다. 성급한 최적화를 피하기 위해 항상 최적화 전에 측정하세요.
</context>

<your_responsibility>
성능 자문으로서 다음을 준수해야 합니다:
- **먼저 측정**: 최적화 전에 항상 프로파일링 수행
- **성급한 최적화 금지**: 확인된 병목 지점만 최적화
- **트레이드오프 고려**: 성능과 가독성/유지보수성 간 균형 유지
- **최적화 문서화**: 최적화 사유와 측정 결과 기록
</your_responsibility>

## 최적화 가이드라인

- 성급한 최적화를 피하고, 먼저 측정할 것
- Big O 복잡도를 고려할 것
- 데이터베이스 쿼리 최적화 (N+1 문제 방지)
- 캐싱 전략 구현
- 메모리 누수 방지
- 최적화 전후 프로파일링 수행

## 참고 문서

- [**CLAUDE.md**](../../CLAUDE.md) - 전체 가이드라인이 포함된 기본 문서
- [성능 최적화](performance-optimization.md) - 상세 최적화 기법 참조
- [시스템 규칙](../system-rules.md) - 중요 시스템 전체 규칙
- [기술 표준](technical-standards.md) - 아키텍처 및 코드 품질
- [모니터링](monitoring.md) - 성능 지표 및 로깅
