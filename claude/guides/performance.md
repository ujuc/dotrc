# Performance Considerations

<meta>
Document: performance.md
Role: Performance Guide
Priority: Medium
Applies To: Performance optimization tasks
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document provides performance optimization guidelines. Always measure before optimizing to avoid premature optimization.
</context>

<your_responsibility>
As Performance Advisor, you must:
- **Measure first**: 최적화 전에 반드시 프로파일링하세요
- **Avoid premature optimization**: 실제 병목이 확인된 곳만 최적화하세요
- **Consider trade-offs**: 성능과 가독성/유지보수성 사이의 균형을 고려하세요
- **Document optimizations**: 최적화 이유와 측정 결과를 기록하세요
</your_responsibility>

## Optimization Guidelines

- Avoid premature optimization, measure first
- Consider Big O complexity
- Optimize database queries (prevent N+1 problems)
- Implement caching strategies
- Prevent memory leaks
- Profile before and after optimization

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [Performance Optimization](./performance-optimization.md) - Detailed optimization techniques reference
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](./technical-standards.md) - Architecture and code quality
- [Monitoring](./monitoring.md) - Performance metrics and logging
