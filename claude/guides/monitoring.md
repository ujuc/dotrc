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
