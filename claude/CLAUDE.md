# Development Guidelines

## Philosophy

### Core Beliefs
- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

### Simplicity Means
- Single responsibility per function/class
- Avoid premature abstractions
- No clever tricks - choose the boring solution
- If you need to explain it, it's too complex

## Process

### 1. Planning & Staging

Break complex work into 3-5 stages. Document in `IMPLEMENTATION_PLAN.md`:

```markdown
## Stage N: [Name]
**Goal**: [Specific deliverable]
**Success Criteria**: [Testable outcomes]
**Tests**: [Specific test cases]
**Status**: [Not Started|In Progress|Complete]
```
- Update status as you progress
- Remove file when all stages are done

### 2. Implementation Flow

1. **Understand** - Study existing patterns in codebase
2. **Test** - Write test first (red)
3. **Implement** - Minimal code to pass (green)
4. **Refactor** - Clean up with tests passing
5. **Commit** - With clear message linking to plan

### 3. When Stuck (After 3 Attempts)

**CRITICAL**: Maximum 3 attempts per issue, then STOP.

1. **Document what failed**:
  - What you tried
  - Specific error messages
  - Why you think it failed

2. **Research alternatives**:
  - Find 2-3 similar implementations
  - Note different approaches used

3. **Question fundamentals**:
  - Is this the right abstraction level?
  - Can this be split into smaller problems?
  - Is there a simpler approach entirely?

4. **Try different angle**:
  - Different library/framework feature?
  - Different architectural pattern?
  - Remove abstraction instead of adding?

## Technical Standards

### Architecture Principles
- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

### Code Quality
- **Every commit must**:
  - Compile successfully
  - Pass all existing tests
  - Include tests for new functionality
  - Follow project formatting/linting

- **Before committing**:
  - Run formatters/linters
  - Self-review changes
  - Ensure commit message explains "why"

### Error Handling
- Fail fast with descriptive messages
- Include context for debugging
- Handle errors at appropriate level
- Never silently swallow exceptions

## Documentation Standards

### Code Documentation
- All public APIs must include clear JSDoc/docstring
- Complex algorithms require inline comments
- Update README when adding new features
- Maintain CHANGELOG for major changes

### Architecture Decision Records (ADR)
- Document important technical decisions
- Include alternatives and reasoning
- Specify future re-evaluation points

### Required Project Files
- `PROJECT_STRUCTURE.md`: Directory structure and major modules
- `DEVELOPMENT.md`: Development setup and run instructions
- `CONVENTIONS.md`: Project-specific coding conventions
- `TECH_STACK.md`: Technology stack and versions

## Security Principles

### Basic Security
- Validate and sanitize all inputs
- Never log sensitive information
- Manage secrets with environment variables
- Follow OWASP Top 10 guidelines
- Apply principle of least privilege

### Data Protection
- Encrypt sensitive data at rest and in transit
- Use secure communication protocols
- Implement proper authentication and authorization
- Regular security audits and dependency updates

## Performance Considerations

### Optimization Guidelines
- Avoid premature optimization, measure first
- Consider Big O complexity
- Optimize database queries (prevent N+1 problems)
- Implement caching strategies
- Prevent memory leaks
- Profile before and after optimization

## Monitoring & Logging

### Logging Standards
- Use structured logging (JSON format)
- Apply appropriate log levels (ERROR, WARN, INFO, DEBUG)
- Track requests with correlation IDs
- Record performance metrics
- Log critical business events
- Never log passwords, tokens, or PII

## Version Control

### Git Workflow
- Use feature branch strategy
- Meaningful branch names (feature/fix/chore/docs)
- Follow Conventional Commits specification
- Utilize PR templates
- Mandatory code reviews
- Squash commits when merging

### Commit Message Format

#### Template Structure
```
<type>: <subject>

<body>

<footer>
```

#### Writing Principles
- **Intent focused**: Explain WHY the change was made, not just WHAT changed
- **Context aware**: Include background and purpose of the change
- **Collaboration oriented**: Reflect requirements and problem awareness for team collaboration

#### Format Rules

##### Subject Line
- Maximum 50 characters
- Include type prefix (e.g., `feat: add user authentication`)
- Use imperative mood ("add" not "added" or "adds")
- Capitalize first letter after type
- No period at the end

##### Body
- Maximum 72 characters per line
- Explain the motivation for the change
- Focus on why and what, not how
- Use "-" for bullet points
- Separate from subject with blank line

##### Footer
- Reference related issues, PRs, or tickets

#### Commit Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring (no functional changes)
- `style`: Formatting changes (no code changes)
- `docs`: Documentation updates
- `test`: Add or refactor tests
- `chore`: Build process, dependencies, or tooling changes

#### Best Practices
1. **Capitalize** the subject line after type
2. **Use imperative mood** in subject line
3. **No period** at the end of subject line
4. **Blank line** between subject and body
5. **Explain why** in body, not how
6. **Use bullet points** with "-" for multiple items

#### Examples
<example>
feat: add user authentication system

Implement JWT-based authentication to secure API endpoints.
This change was needed because:
- Previous system lacked proper security measures
- Users requested account protection features
- Compliance requirements for data protection

Fixes #142
</example>

<example>
refactor: simplify database connection logic

Extract connection pooling into separate module to improve
code maintainability and reduce duplication across services.

Related to INF-24
</example>

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

## Project Integration

### Learning the Codebase
- Find 3 similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns
- Review recent PRs for context

### Tooling
- Use project's existing build system
- Use project's test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification

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

## Internationalization (i18n)

### i18n Guidelines
- Avoid hardcoded strings
- Localize date/time formats
- Consider number and currency formats
- Support RTL languages when applicable
- Use Unicode (UTF-8) encoding
- Test with different locales

## Important Reminders

### NEVER
- Use `--no-verify` to bypass commit hooks
- Disable tests instead of fixing them
- Commit code that doesn't compile
- Make assumptions - verify with existing code
- Store secrets in code
- Ignore security warnings
- Skip code reviews
- Use deprecated APIs without justification

### ALWAYS
- Commit working code incrementally
- Update plan documentation as you go
- Learn from existing implementations
- Stop after 3 failed attempts and reassess
- Consider security implications
- Think about edge cases
- Document non-obvious decisions
- Keep the user experience in mind

## Emergency Procedures

### When Things Break
1. Don't panic
2. Check recent changes
3. Review error logs
4. Isolate the problem
5. Create minimal reproduction
6. Document findings
7. Implement fix with tests
8. Post-mortem for learning

### Getting Help
- After 3 attempts, ask for guidance
- Provide context and what you've tried
- Share error messages and logs
- Explain your understanding of the problem
- Be open to different approaches

---

*Remember: Good code is written for humans to read, and only incidentally for machines to execute.*

*Last Updated: 2025-08-10*