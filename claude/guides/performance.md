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
