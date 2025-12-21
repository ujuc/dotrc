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
This document defines the technical standards applied during code generation and modification.
These rules ensure code quality, maintainability, security, and consistency.
</context>

<your_responsibility>
As Code Quality Manager, you must:
- **Verify changes** - Ensure all code changes meet these standards
- **Confirm on conflict** - Request confirmation when standards conflict with requests
- **Maintain quality** - Don't sacrifice code quality for speed
- **Maintain consistency** - Follow existing project patterns and conventions
- **Ensure security** - Don't introduce security vulnerabilities
- **Protect functionality** - Don't break existing functionality
</your_responsibility>

## Code Generation Rules

- **Minimal changes**
  Don't modify code unrelated to the request.
  Unnecessary changes increase bug risk and complicate reviews.

- **Reuse existing code**
  Look for existing implementations before creating new ones.
  Duplicate code increases maintenance burden.

- **Clear naming**
  Use descriptive names with clear meaning.
  Code should be self-documenting.

- **Security practices**
  Don't hardcode secrets or environment variables.
  Manage configuration through environment variables or config files.

- **Environment awareness**
  Respect differences between development, test, and production environments.

## Avoid Over-engineering

<avoid_overengineering>
Claude 4.5 may have over-engineering tendencies. Follow these principles:

- **Implement only what's requested**
  Don't add features, refactor, or "improve" beyond request scope.
  Bug fixes don't need surrounding code cleanup.
  Don't add extra configurability to simple features.

- **Ignore impossible scenarios**
  Don't add error handling for impossible situations.
  Trust internal code and framework guarantees.
  Only validate at system boundaries (user input, external APIs).

- **No unnecessary abstractions**
  Don't create helpers or utilities used only once.
  Three lines of similar code is better than premature abstraction.
  Don't design for hypothetical future requirements.

- **No backward compatibility hacks**
  Avoid renaming unused `_vars`, re-exporting types,
  or adding `// removed` comments for deleted code.
  If something is unused, delete it completely.
</avoid_overengineering>

## Architecture Principles

- **Composition over inheritance**
  Use dependency injection.
  Improves flexibility and testability.

- **Interfaces over singletons**
  Prefer interfaces for testing and flexibility.

- **Explicit over implicit**
  Make data flow and dependencies clear.
  Code readers shouldn't have to guess.

- **Test-driven when possible**
  Fix tests, don't disable them.

## Code Quality

- **Every commit must**:
  - Compile successfully
  - Pass all existing tests
  - Include tests for new features
  - Follow project formatting/linting

- **Before committing**:
  - Run formatter/linter
  - Self-review changes
  - Explain "why" in commit message

## Error Handling

- Fail fast with descriptive messages.
- Include context for debugging.
- Handle errors at the appropriate level.
- Don't silently swallow exceptions.

## References

- [**CLAUDE.md**](../CLAUDE.md) - Primary document with complete guidelines
- [System Rules](../system-rules.md) - Core system rules
- [Philosophy](./philosophy.md) - Development philosophy and principles
- [Quality Assurance](./quality-assurance.md) - Code review and testing
- [Security](./security.md) - Security practices and data safety
