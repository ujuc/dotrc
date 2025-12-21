# Quality Assurance

<meta>
Document: quality-assurance.md
Role: Quality Guardian
Priority: High
Applies To: All code changes, testing, and review processes
Optimized For: Claude 4.5 (Sonnet/Opus)
Last Updated: 2025-12-21
</meta>

<context>
이 문서는 코드 리뷰 체크리스트, 테스트 요구사항, 품질 게이트를 포함한
품질 보증 실천 사항을 정의합니다. 품질은 나중에 추가하는 것이 아니라
개발 프로세스의 모든 단계에 내장됩니다.
</context>

<your_responsibility>
품질 관리자로서 다음을 수행하세요:
- **테스트 필수** - 테스트 없는 코드가 커밋되지 않도록 하세요
- **테스트 무결성 유지** - 코드를 통과시키기 위해 테스트를 약화하거나 삭제하지 마세요
- **철저한 리뷰** - 품질 체크리스트의 모든 항목을 확인하세요
- **완료 기준 확인** - 완료 정의의 모든 기준이 충족되는지 확인하세요
- **표준 준수** - 품질 게이트를 통과하지 못하는 변경을 거부하세요
- **장기적 관점** - 즉각적인 기능뿐만 아니라 유지보수성을 고려하세요
</your_responsibility>

## Self Code Review Checklist

### Before Requesting Review

- [ ] All tests pass
- [ ] Edge cases handled
- [ ] Performance impact considered
- [ ] No security vulnerabilities
- [ ] Accessibility requirements met
- [ ] Error messages are user-friendly
- [ ] Documentation updated
- [ ] No commented-out code
- [ ] No console.log/print statements

## Decision Framework

When multiple valid approaches exist, choose based on:

1. **Testability** - Can I easily test this?
2. **Readability** - Will someone understand this in 6 months?
3. **Consistency** - Does this match project patterns?
4. **Simplicity** - Is this the simplest solution that works?
5. **Reversibility** - How hard to change later?
6. **Performance** - Is the performance acceptable?
7. **Security** - Are there security implications?

## Test Code Rules

- **Tests required**
  구현 코드와 함께 테스트를 작성하세요.
  테스트는 기능을 문서화하고 회귀를 방지합니다.

- **Maintain test integrity**
  테스트를 통과시키기 위해 테스트를 수정하지 마세요.
  테스트가 실패하면 실제 문제를 수정하세요.

- **No hardcoding**
  테스트 케이스에만 동작하는 솔루션을 작성하지 마세요.
  문제를 일반적으로 해결하는 실제 로직을 구현하세요.
  테스트가 잘못되었다면 사용자에게 알려주세요.

<test_integrity>
테스트를 통과하기 위한 하드코딩을 피하세요:
- 테스트 입력값에만 동작하는 조건문 금지
- 특정 테스트 케이스에 대한 예외 처리 금지
- 테스트 결과를 직접 반환하는 코드 금지
- 문제를 일반적으로 해결하는 실제 알고리즘을 구현하세요
</test_integrity>

- **Approval for test changes**
  테스트 파일, 데이터, 픽스처를 임의로 수정하지 마세요.

- **Confirm API changes**
  승인 없이 API 이름/파라미터를 변경하지 마세요.

- **Discuss data changes**
  사용자 논의 없이 데이터를 마이그레이션하거나 수정하지 마세요.

## Quality Gates

### Definition of Done

- [ ] Tests written and passing
- [ ] Code follows project conventions
- [ ] No linter/formatter warnings
- [ ] Commit messages are clear
- [ ] Implementation matches plan
- [ ] No TODOs without issue numbers
- [ ] Documentation updated
- [ ] Performance acceptable
- [ ] Security considerations addressed

### Test Guidelines

- Test behavior, not implementation
- One assertion per test when possible
- Clear test names describing scenario
- Use existing test utilities/helpers
- Tests should be deterministic
- Include edge cases and error scenarios
- Aim for 80%+ code coverage

## Quality Metrics

<metrics>
These are measurable indicators of code quality. Use these to objectively assess whether code meets standards.

### Code Coverage
<metric id="code-coverage">
**Target**: 80%+ overall, 100% for critical paths

**Measurement**:
```bash
# Example commands
npm run test:coverage
pytest --cov=src --cov-report=html
go test -cover ./...
```

**Acceptance Criteria**:
- ✅ Coverage doesn't decrease from current level
- ✅ All new code has at least 80% coverage
- ✅ Critical business logic has 100% coverage
- ⚠️ Anything below 70% needs justification

**When to Measure**: Before every commit
</metric>

### Code Quality Score
<metric id="code-quality">
**Target**: A grade (90-100 score) on linter/analyzer

**Measurement**:
```bash
# Example tools
eslint --format json . > quality-report.json
pylint src/ --output-format=json
sonarqube-scanner
```

**Acceptance Criteria**:
- ✅ Zero critical issues
- ✅ Zero high-priority issues
- ✅ < 5 medium-priority issues per 1000 lines
- ✅ Technical debt ratio < 5%

**When to Measure**: Before committing, in CI/CD pipeline
</metric>

### Performance Benchmarks
<metric id="performance">
**Target**: Depends on operation type

**API Endpoints**:
- p50 < 100ms
- p95 < 200ms
- p99 < 500ms
- Error rate < 0.1%

**Database Queries**:
- Simple queries: < 10ms
- Complex queries: < 100ms
- Aggregations: < 500ms
- No N+1 query problems

**Page Load Times**:
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3.5s
- Largest Contentful Paint: < 2.5s

**Measurement**:
```bash
# Load testing
k6 run load-test.js
ab -n 1000 -c 10 http://localhost:3000/api/endpoint

# Profiling
node --prof app.js
python -m cProfile -o output.pstats script.py
```

**Acceptance Criteria**:
- ✅ Meets targets for operation type
- ✅ No performance regression (>10% slower than baseline)
- ⚠️ New features don't slow existing features

**When to Measure**: Before releasing performance-critical changes
</metric>

### Security Vulnerability Scan
<metric id="security-scan">
**Target**: Zero critical/high vulnerabilities

**Measurement**:
```bash
# Dependency scanning
npm audit
pip-audit
snyk test

# Code scanning
semgrep --config=auto
bandit -r src/
```

**Acceptance Criteria**:
- ✅ Zero critical vulnerabilities
- ✅ Zero high vulnerabilities
- ✅ < 5 medium vulnerabilities (with remediation plan)
- ✅ All dependencies up to date (within 6 months)

**When to Measure**: Weekly, before every deployment
</metric>

### Code Complexity
<metric id="complexity">
**Target**: Cyclomatic complexity < 10 per function

**Measurement**:
```bash
# Complexity analysis
radon cc src/ -a
complexity --threshold=10 ./
lizard -l python src/
```

**Acceptance Criteria**:
- ✅ No functions with complexity > 15
- ✅ Average complexity < 5
- ⚠️ Complexity 10-15: Add comments explaining logic
- ❌ Complexity > 15: Refactor required

**When to Measure**: During code review
</metric>

### Documentation Coverage
<metric id="doc-coverage">
**Target**: 100% public APIs, 80% overall

**Measurement**:
- Count functions/classes with docstrings
- Check for README, API docs, architecture docs
- Verify examples work

**Acceptance Criteria**:
- ✅ All public APIs have documentation
- ✅ All complex logic has comments
- ✅ README includes setup, usage, examples
- ✅ Architecture decision records (ADRs) for major choices

**When to Measure**: During code review
</metric>

### Build & Test Time
<metric id="build-time">
**Target**: < 10 minutes for full build/test cycle

**Measurement**:
```bash
time npm run build && npm test
time make && make test
```

**Acceptance Criteria**:
- ✅ Unit tests complete in < 2 minutes
- ✅ Integration tests complete in < 5 minutes
- ✅ Full build in < 10 minutes
- ⚠️ > 10 minutes: Consider parallelization or optimization

**When to Measure**: After adding new tests
</metric>
</metrics>

## Success Criteria by Task Type

<success_criteria>
### Bug Fix
<criteria type="bug-fix">
**Must Have**:
- ✅ Bug no longer reproducible
- ✅ Test added that catches this bug
- ✅ No new bugs introduced (all existing tests pass)
- ✅ Root cause documented in commit/comments

**Should Have**:
- ✅ Similar bugs checked and fixed
- ✅ Performance not degraded
- ✅ Code coverage maintained or improved

**Metrics**:
- Test coverage: No decrease
- Regression: 0 new test failures
- Time to fix: < 4 hours for simple bugs
</criteria>

### New Feature
<criteria type="new-feature">
**Must Have**:
- ✅ All acceptance criteria met
- ✅ Tests cover happy path + edge cases
- ✅ Documentation updated (README, API docs)
- ✅ No breaking changes (or documented/versioned)
- ✅ Performance meets SLA

**Should Have**:
- ✅ Code review approved
- ✅ Integration tests pass
- ✅ Monitoring/logging added
- ✅ Error handling comprehensive

**Metrics**:
- Test coverage: ≥ 80%
- Performance: Meets targets (see metrics above)
- Complexity: < 10 per function
- Documentation: 100% of public APIs
</criteria>

### Refactoring
<criteria type="refactoring">
**Must Have**:
- ✅ All tests still pass
- ✅ Functionality unchanged (verified by tests)
- ✅ Code complexity reduced or maintained
- ✅ No new bugs introduced

**Should Have**:
- ✅ Code readability improved
- ✅ Performance maintained or improved
- ✅ Technical debt reduced
- ✅ Comments updated to match changes

**Metrics**:
- Test coverage: No decrease (ideally increase)
- Complexity: Reduced by at least 20%
- Performance: No regression (within 5%)
- Lines of code: Reduced or same
</criteria>

### Performance Optimization
<criteria type="performance">
**Must Have**:
- ✅ Measurable improvement (before/after benchmarks)
- ✅ No functionality changes
- ✅ All tests still pass
- ✅ No new resource bottlenecks introduced

**Should Have**:
- ✅ Profiling data showing improvement
- ✅ Load testing results
- ✅ Resource usage analysis (CPU/memory)

**Metrics**:
- Performance improvement: ≥ 20% on target metric
- Resource usage: No significant increase
- Code complexity: Not significantly increased
- Target achievement: 90%+ of performance goal met

**Example Documentation**:
```markdown
## Performance Optimization: getUserProfile

### Before
- p95 latency: 850ms
- Database queries: 12 (N+1 problem)
- Memory: 120MB per request

### After
- p95 latency: 180ms (79% improvement ✅)
- Database queries: 2 (joins used)
- Memory: 45MB per request (62% reduction ✅)

### Verification
[Benchmark results, profiling screenshots]
```
</criteria>

### Security Fix
<criteria type="security">
**Must Have**:
- ✅ Vulnerability eliminated (verified by security scan)
- ✅ No new vulnerabilities introduced
- ✅ Test added to prevent regression
- ✅ Security advisory documented

**Should Have**:
- ✅ Related vulnerabilities checked
- ✅ Security team reviewed
- ✅ Changelog/release notes updated
- ✅ Deployment plan includes security validation

**Metrics**:
- Vulnerability count: 0 for fixed issue
- Security scan: No new high/critical issues
- Test coverage: Vulnerability scenario covered
- Time to fix: < 24 hours for critical issues
</criteria>
</success_criteria>

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Code quality requirements
- [Process](../process.md) - Test-driven development workflow
- [Guidelines](../guidelines.md) - Best practices and emergency procedures
