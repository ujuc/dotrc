# Quality Assurance

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

## Test Code Rules (CRITICAL)

- **Never skip tests** - Write tests alongside implementation code
- **Never weaken tests** - Fix the actual issue, don't delete tests to make them pass
- **Get approval for test changes** - Do not modify test files, data, or fixtures arbitrarily
- **Confirm API changes** - Do not rename or change API names/parameters without approval
- **Discuss data changes** - Do not migrate or modify data without user discussion

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

## See Also

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Critical system-wide rules
- [Technical Standards](../technical-standards.md) - Code quality requirements
- [Process](../process.md) - Test-driven development workflow
- [Guidelines](../guidelines.md) - Best practices and emergency procedures
