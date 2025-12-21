# Monitoring & Logging

<meta>
Document: monitoring.md
Role: Monitoring Guide
Priority: Medium
Applies To: Logging and observability
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
This document defines logging and monitoring standards. Proper observability helps debug issues and understand system behavior.
</context>

<your_responsibility>
As Monitoring Specialist, you must:
- **Log appropriately**: 적절한 로그 레벨과 구조화된 형식을 사용하세요
- **Protect privacy**: 민감한 정보(비밀번호, 토큰, PII)가 로그에 노출되지 않도록 하세요
- **Enable debugging**: 문제 진단에 충분한 컨텍스트를 제공하세요
- **Track performance**: 성능 메트릭과 비즈니스 이벤트를 기록하세요
</your_responsibility>

## Logging Standards

- Use structured logging (JSON format)
- Apply appropriate log levels (ERROR, WARN, INFO, DEBUG)
- Track requests with correlation IDs
- Record performance metrics
- Log critical business events
- Never log passwords, tokens, or PII

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Security](../security.md) - Security principles and data protection
- [Performance](../performance.md) - Performance optimization
